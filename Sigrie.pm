package Sigrie;

use strict;
use warnings;

use LWP::UserAgent;
my $ua = new LWP::UserAgent;

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
    Legs      | Feet      | Finger    | Trinket
  )<}x,
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
  armor     => qr{>(\d+) Armor},
  earmor    => qr{Armor \(\+(\d+)\)},
);

# stat name translations
my %stat_names = (
  Strength => 'str',
  Stamina => 'sta',
  Agility => 'agi',
  Intellect => 'int',
  Spirit => 'spi',
  'hit rating ' => 'hit',
  'critical strike rating' => 'crit',
  'haste rating' => 'haste',
  'expertise rating' => 'exp',
  'mastery rating' => 'mast',
  'dodge rating' => 'dodge',
  'parry rating' => 'parry',
  'block rating' => 'block',
);

sub get_item {
  my $id = shift;
  
  # get the item tooltip from sigrie
  my $response = $ua->get("http://db.mmo-champion.com/i/$id/tooltip/js");
  if ($response->is_error) {
    print STDERR "Error getting item $id:", $response->status_line, "\n";
    next;
  }

  # weed out the useless bits
  my ($tooltip) = $response->content =~ m/tooltip: '(.*)',/;
  unless ($tooltip) {
    print STDERR "Error parsing item $id\n";
    next;
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
  
  # we can't use the normal parsers for sockets because we need a count of 
  # matches rather than the matches themselves
  for (qw{Meta Red Yellow Blue}) {
    my @matches = ($tooltip =~ />$_ Socket</g);
    my $key = 'sock_' . lc(substr($_, 0, 4));
    $item{$key} = scalar @matches;
  }
  
  # get the socket bonus and what stat it is
  if ($tooltip =~ /Socket Bonus: <a .*?>\+(\d+) (.*?)</) {
    $item{sock_val} = $1;
    $item{sock_stat} = $stat_names{$2};
  }
  
  return %item;
}

1;
