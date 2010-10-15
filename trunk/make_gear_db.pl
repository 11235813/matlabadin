#!/usr/bin/perl

use strict;
use warnings;

use Sigrie;

# list of item ids to parse
my @items = qw(
  51265 51266 51267 51268 51269 50682 50466 51901 50991 50625 50622 50404 50356 
  54571 50708 50729 50461
  
  55059 55058 59359 58483 52352 56549 62351 62432 62428 62449 62471 57932 57914 
  58104 58102 58103 58105 58101 57926 60354 60355 60356 60357 60358 64676 58182 
  58187 58192 58197
  
  50737 50738 50672 50012 49997 51947 50412 51937 51916 51893 51858 51869 47526
  47506 47156 51795 50760 50050 50787 50810 51021 51010 47967 48714 47148 49501
  47973 47966 45442 50303 47810 50290 50191 50268 45947 45876 49296 47816 47808
  45110 45463
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

# slot numbers by name
my %slots = (
  'Head'      => 1,
  'Neck'      => 2,
  'Shoulders' => 3,
  'Back'      => 4,
  'Chest'     => 5,
  'Wrist'     => 6,
  'Hand'      => 7,
  'Waist'     => 8,
  'Legs'      => 9,
  'Feet'      => 10,
  'Finger'    => 11,
  'Trinket'   => 13,
  'One-Hand'  => 15,
  'Off Hand'  => 16,
  'Relic'     => 17,
);

# attributes about which we care
my @attrs = qw(
  name      wtype     ilvl      tooldps  
  swing     avgdmg    str       sta      
  agi       int       spi       hit      
  crit      exp       haste     mast     
  dodge     parry     block     barmor   
  earmor    msock     rsock     bsock     
  ysock
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
    
    print "idb.iid($id).$_=";
    if ($item{$_} =~ /[^0-9.]/) {
      $item{$_} =~ s/'/''/g;
      print "'$item{$_}'";
    } else {
      print $item{$_} + 0;
    }
    print ";\n";
  }
  
  # misc stats
  # print "idb.iid($id).slot=$slots{$item{slot}};\n" if $item{slot};
  print "idb.iid($id).atype=1;\n" if $item{atype} and $item{atype} eq 'Plate';
  
  if ($item{sbstat}) {
    print "idb.iid($id).sb.$item{sbstat}=$item{sbval};\n";
    print "idb.iid($id).sb.active=[" . join(' ', map $_ || 0, @item{qw{rsock ysock bsock}}) . "];\n";
  }
  
  print "\n";
}