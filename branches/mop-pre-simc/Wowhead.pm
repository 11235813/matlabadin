package Wowhead;

use strict;
use warnings;

use LWP::UserAgent;
use URI::Escape;

my $ua = LWP::UserAgent->new(timeout => 3);

# Regexen for extracting stats from tooltips
my %parsers = (
  name      => qr{<b class="q\d">(.*?)</b>},
  wtype     => qr{>(
    Dagger    | Fist      | Axe       | Mace      |
    Sword     | Polearm   | Staff     | Gun       |
    Bow       | Crossbow  | Thrown    | Wand
  )<}x,
  ilvl      => qr{>Item Level (\d+)<},
  tooldps   => qr{>\(([0-9.]+) damage per second\)<},
  swing     => qr{>Speed ([0-9.]+)<},
  damage    => qr{>(\d+ - \d+) Damage<},
  slot      => qr{>(
    Head      | Neck      | Shoulder  | Back      |
    Chest     | Wrist     | Hands     | Waist     |
    Legs      | Feet      | Finger    | Trinket   |
    One-Hand  | Off\sHand | Relic
  )<}x,
  sockbon   => qr{>Socket Bonus: \+(\d+ \w+)<},
  atype     => qr{>(Plate|Mail|Leather|Cloth)<},
  heroic    => qr{>(Heroic)<},
  lfr       => qr{>(Raid Finder)<},
  tforged   => qr{>(Thunderforged)<},
  htforged  => qr{>(Heroic Thunderforged)<},
  str       => qr{>\+(\d+) Strength<},
  sta       => qr{>\+(\d+) Stamina<},
  agi       => qr{>\+(\d+) Agility<},
  int       => qr{>\+(\d+) Intellect<},
  spi       => qr{>\+(\d+) Spirit<},
  hit       => qr{>\+<!--rtg\d+-->(\d+) Hit&nbsp;<},
  crit      => qr{>\+<!--rtg\d+-->(\d+) Critical Strike&nbsp;<},
  haste     => qr{>\+<!--rtg\d+-->(\d+) Haste&nbsp;<},
  exp       => qr{>\+<!--rtg\d+-->(\d+) Expertise&nbsp;<},
  mast      => qr{>\+<!--rtg\d+-->(\d+) Mastery&nbsp;<},
  dodge     => qr{>\+<!--rtg\d+-->(\d+) Dodge&nbsp;<},
  parry     => qr{>\+<!--rtg\d+-->(\d+) Parry&nbsp;<},
  sp        => qr{>\+(\d+) Spell Power&nbsp;<},
  ap        => qr{>Equip: Increases attack power by (\d+)},
  armor     => qr{>(\d+) Armor},
  earmor    => qr{Armor \(\+(\d+)\)},
  setname   => qr{<a href="/itemset=\d+" class="q">(.*?)</a>},
);

# stat name translations
my %stat_names = (
  'strength' => 'str',
  'stamina' => 'sta',
  'agility' => 'agi',
  'intellect' => 'int',
  'spirit' => 'spi',
  'hit' => 'hit',
  'critical Strike' => 'crit',
  'haste' => 'haste',
  'expertise' => 'exp',
  'mastery' => 'mast',
  'dodge' => 'dodge',
  'parry' => 'parry',
  'block rating' => 'block',
  'spell power' => 'sp',
  'attack power' => 'ap',
);

sub get_item {
  my $id = shift;
  
  # get the item tooltip from wowhead
  my $response = $ua->get("http://ptr.wowhead.com/item=$id&power");
  if ($response->is_error) {
    print STDERR "\rError getting item $id:", $response->status_line, "\n";
    return ();
  }

  # weed out the useless bits
  my ($tooltip) = $response->content =~ m/tooltip_ptr:\s+'(.*)'/;
  unless ($tooltip) {
    print STDERR "\rError parsing item $id\n";
    print STDERR $response->content;
    return ();
  }

  # unencode entities
  $tooltip =~ s/&#(\d+);/chr($1)/ge;

  # run the parsers
  my %item = ();
  foreach (keys %parsers) {
    $tooltip =~ m/$parsers{$_}/ or next;
    $item{$_} = ($1);
  }

  # rename heroic/lfr items to prevent name clashes
  $item{name} .= ' (Heroic)' if $item{heroic};
  $item{name} .= ' (Raid Finder)' if $item{lfr};
  $item{name} .= ' (Thunderforged)' if $item{tforged};
  $item{name} .= ' (Heroic Thunderforged)' if $item{htforged};
  
  # change weapon type to 3 lower case letters
  $item{wtype} = substr(lc $item{wtype}, 0, 3) if $item{wtype};
  
  # average weapon damage
  if ($item{damage}) {
    $item{damage} =~ m/(\d+) - (\d+)/;
    $item{avgdmg} = ($1 + $2) / 2;
  }
  
  # base/extra armor
  if ($item{armor}) {
    if ($item{slot} and $item{slot} =~ /^(?:Neck|Finger|Trinket)$/) {
      $item{earmor} = $item{armor};
    } else {
      $item{barmor} = $item{armor};
    }
  }
  
  # make socket string
  while ($tooltip =~ />([MRYBP])\w+ Socket</g) {
    $item{socket} .= $1;
  }
  
  # relics have their prismatic sockets marked as red
  $item{socket} =~ y/R/P/ if $item{slot} and $item{slot} eq 'Relic';
  
  # get the socket bonus and what stat it is
  if ($item{sockbon} and $item{sockbon} =~ /(\d+) (\w+)/) {
    $item{sbval} = $1;

    my $key = lc $2;
    $key .= ' rating' unless exists $stat_names{$key};
    print STDERR "Unknown socket bonus stat: $key" unless exists $stat_names{$key};
    $item{sbstat} = $stat_names{$key};
  }
  
  # fallback for slot
  $item{slot} ||= 'Unknown';

  return %item;
}

my %filter_stat_map = (
  str   => 20,
  sta   => 22,
  agi   => 21,
  int   => 23,
  spi   => 24,
  hit   => 119,
  crit  => 96,
  haste => 103,
  exp   => 117,
  mast  => 170,
  dodge => 45,
  parry => 46,
  sp    => 123,
  ap    => 77,
);

my %filter_comparison_map = (
  gt  => 1,
  gte => 2,
  eq  => 3,
  lte => 4,
  lt  => 5,
);

sub search_items {
  my ($path, %filters) = @_;

  my %params = ();
  my @cr     = ();
  my @crs    = ();
  my @crv    = ();

  foreach (keys %filters) {
    if (exists $filter_stat_map{$_}) {
      push @cr, $filter_stat_map{$_};
      push @crs, $filter_comparison_map{$filters{$_}[0]};
      push @crv, $filters{$_}[1];
    } else {
      $params{$_} = $filters{$_};
    }
  }

  $params{cr}  = join ':', @cr;
  $params{crs} = join ':', @crs;
  $params{crv} = join ':', @crv;

  my $filter = uri_escape join ';', map "$_=$params{$_}", keys %params;

  my $response = $ua->get("http://ptr.wowhead.com/items=$path?filter=$filter");
  if ($response->is_error) {
    print STDERR "\rError searching for items: ", $response->status_line, "\n";
    return ();
  }

  my $body = $response->content;
  if ($body =~ /LANG\.lvnote_tryfiltering/) {
    print STDERR "\rItem list truncated, filters too broad\n";
  }

  my @results = ();
  while ($body =~ /_\[(\d+)\]={name_enus/gc) {
    push @results, $1;
  }

  return @results;
}

1;
