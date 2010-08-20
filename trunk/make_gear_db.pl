#!/usr/bin/perl

use strict;
use warnings;

use Sigrie;

# list of item ids to parse
my @items = qw(
  50862 50763 50860 50968 49904 49907 50802 50978 47731 49118
  50760 50794 47664
  
  51265 51266 51267 51268 51269 50682 50466 51901 50991 50625
  50622 50404 50356 54571 50708 50729 50461
  
  55059 55058 59359 57268 55023 54876 59785 58483 52352 59607
  56549 61402 
);

# corrections to items
my %corrections = (
  # Bile-Encrusted Medallion
  50682 => { earmor => 216 }, # missing armor
  
  # Devium's Eternally Cold Ring
  50622 => { earmor => 216 }, # missing armor
  
  # Libram of the Eternal Tower
  50461 => { dodge => 219 }, # 3 stacks
  
  # Libram of Defiance
  47664 => { dodge => 200 }, # almost always up
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

foreach my $id (@items) {
  # get the item
  my %item = Sigrie::get_item($id);
  
  # apply item corrections
  if (my $hash = $corrections{$id}) {
    $item{$_} = $hash->{$_} for keys %$hash;
  }
  
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