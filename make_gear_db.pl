#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
my $ua = new LWP::UserAgent;

# list of item ids to parse
my @items = qw(
  51265  51266  51267  51268  51269
  50682  50466  51901  50991  50625
  50622  50404  50356  54571  50708
  50729  50461
);

# corrections to items
my %corrections = (
  # Bile-Encrusted Medallion
  50682 => { earmor => 216 }, # missing armor
  
  # Devium's Eternally Cold Ring
  50622 => { earmor => 216 }, # missing armor
  
  # Libram of the Eternal Tower
  50461 => { dodge => 219 }, # 3 stacks
);

# attributes about which we care
my @attrs = qw(
  name      wtype     ilvl      tooldps  
  swing     avgdmg    str       sta      
  agi       int       spi       hit      
  crit      exp       haste     mast     
  dodge     parry     block     barmor   
  earmor
);

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
  
  # apply item corrections
  if (my $hash = $corrections{$id}) {
    $item{$_} = $hash->{$_} for keys %$hash;
  }
  
  return %item;
}
 
foreach my $id (@items) {
  # get the item
  my %item = get_item($id);
  
  # print out the attributes we care about, skipping any that are 0
  foreach (@attrs) {
    next unless $item{$_};
    
    print "idb($id).$_=";
    if ($item{$_} =~ /[^0-9.]/) {
      $item{$_} =~ s/'/''/g;
      print "'$item{$_}'";
    } else {
      print $item{$_} + 0;
    }
    print ";\n";
  }
  
  print "\n";
}