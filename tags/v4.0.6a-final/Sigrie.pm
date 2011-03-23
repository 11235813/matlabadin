package Sigrie;

use strict;
use warnings;

use LWP::UserAgent;
my $ua = LWP::UserAgent->new(timeout => 3);

# Regexen for extracting stats from tooltips
my %parsers = (
  name      => qr{<a href=".*?" class="q\d">(.*?)</a>},
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
    Head      | Neck      | Shoulders | Back      |
    Chest     | Wrist     | Hand      | Waist     |
    Legs      | Feet      | Finger    | Trinket   |
    One-Hand  | Off\sHand | Relic
  )<}x,
  atype     => qr{>(Plate|Mail|Leather|Cloth)<},
  heroic    => qr{>(Heroic)<},
  str       => qr{>\+(\d+) Strength<},
  sta       => qr{>\+(\d+) Stamina<},
  agi       => qr{>\+(\d+) Agility<},
  int       => qr{>\+(\d+) Intellect<},
  spi       => qr{>\+(\d+) Spirit<},
  hit       => qr{>Equip: Improves hit rating by (\d+)},
  crit      => qr{>Equip: Improves critical strike rating by (\d+)},
  haste     => qr{>Equip: Improves haste rating by (\d+)},
  exp       => qr{>Equip: Increases your expertise rating by (\d+)},
  mast      => qr{>Equip: Increases your mastery rating by (\d+)},
  dodge     => qr{>Equip: Increases your dodge rating by (\d+)},
  parry     => qr{>Equip: Increases your parry rating by (\d+)},
  block     => qr{>Equip: Increases your shield block rating by (\d+)},
  sp        => qr{>Equip: Increases spell power by (\d+)},
  ap        => qr{>Equip: Increases attack power by (\d+)},
  armor     => qr{>(\d+) Armor},
  earmor    => qr{Armor \(\+(\d+)\)},
);

# stat name translations
my %stat_names = (
  'strength' => 'str',
  'stamina' => 'sta',
  'agility' => 'agi',
  'intellect' => 'int',
  'spirit' => 'spi',
  'hit rating ' => 'hit',
  'critical strike rating' => 'crit',
  'haste rating' => 'haste',
  'expertise rating' => 'exp',
  'mastery rating' => 'mast',
  'dodge rating' => 'dodge',
  'parry rating' => 'parry',
  'block rating' => 'block',
  'spell power' => 'sp',
  'attack power' => 'ap',
);

sub get_item {
  my $id = shift;
  
  # get the item tooltip from sigrie
  my $response = $ua->get("http://db.mmo-champion.com/i/$id/tooltip/js");
  if ($response->is_error) {
    print STDERR "Error getting item $id:", $response->status_line, "\n";
    return ();
  }

  # weed out the useless bits
  my ($tooltip) = $response->content =~ m/tooltip: '(.*)',/;
  unless ($tooltip) {
    print STDERR "Error parsing item $id\n";
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

  # rename heroic items to prevent name clashes
  $item{name} .= ' (Heroic)' if $item{heroic};
  
  # change weapon type to 3 lower case letters
  $item{wtype} = substr(lc $item{wtype}, 0, 3) if $item{wtype};
  
  # average weapon damage
  if ($item{damage}) {
    $item{damage} =~ m/(\d+) - (\d+)/;
    $item{avgdmg} = ($1 + $2) / 2;
  }
  
  # armor nerf
  $item{earmor} *= 2 / 7 if $item{earmor};
  
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
  if ($tooltip =~ /Socket Bonus: <a .*?>\+(\d+) (.*?)</) {
    $item{sbval} = $1;
    $item{sbstat} = $stat_names{lc $2};
  }
  
  return %item;
}

1;
