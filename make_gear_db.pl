#!/usr/bin/perl

use strict;
use warnings;

use Sigrie;

# list of item ids to parse
my @items = qw(
  56278 56358 57873 58098 58103 62410 63478 # head 346
  59344 59487 60356 63531 # head 359
  65038 65096 65130 65226 # head 372
  
  52323 56319 56360 56411 56421 57930 57932 63438 68172 68173 # neck 346
  59319 59442 62447 67138 # neck 359
  65025 65059 65379 65380 # neck 372

  56318 56452 58100 58104 63470 # shou 346
  59356 59471 59901 60358 67144 # shou 359
  65027 65101 65142 65228 # shou 372

  56275 56304 56355 56369 56397 56467 56549 63467 # back 346
  58190 58192 59466 59507 62383 # back 359
  65010 65117 # back 372

  56308 56425 58096 58101 63458 # ches 346
  55058 55060 59316 59486 60354 67143 # ches 359
  65062 65131 65224 # ches 372
  
  56301 56416 57870 63457 67238 # brac 346
  59118 59470 62449 # brac 359
  65085 65143 # brac 372

  56336 56428 58099 58105 62408 63434 63474 # hand 346
  59225 59505 60355 # hand 359
  65071 65119 65225 # hand 372

  56392 56447 57913 57914 63453 67235 # belt 346
  55059 55061 59117 59342 62384 63490 63491 # belt 359
  65040 65086 65369 65370 # belt 372

  56283 56294 56367 58097 58102 # legs 346
  59317 59503 60357 63500 63501 67141 # legs 359
  65061 65121 65379 65380 # legs 372

  56378 56381 62382 63444 # feet 346
  58195 58197 59221 59328 59464 62418 # feet 359
  65012 65051 65075 # feet 372

  52320 56332 56365 56388 56398 56415 56444 56457 62350 62351 62440 # ring 346
  58185 58187 59233 59518 63488 63489 63494 63499 67139 # ring 359
  65070 65106 65367 65372 65373 65382 # ring 372

  52351 52352 56280 56285 56345 56347 56406 56431 56449 56458 # trin 346
  58180 58182 58483 59224 59332 59461 59506 59515 59520 62048 62049 62466 # trin 359
  65048 65072 65109 65118 # trin 372

  55067 56266 56364 62457 65170 67602 67605 # axe 346
  55065 56312 56353 56396 56459 57872 62459 65171 # mac 346
  56346 56384 56430 56433 65164 65166 65173 # swo 346

  59443 61324 61325 # axe 359
  59347 59459 61335 61336 61338 63680 # mac 359
  59333 59463 59521 61344 61345 63533 64885 68127 68129 68161 # swo 359

  65024 67473 67474 # axe 372
  65017 65036 65090 67454 67470 67471 # mac 372
  65013 65047 65094 65103 67468 67469 68130 68131 68132 # swo 372

  56314 56426 57926 # shie 346
  55069 59444 61359 67145 # shie 359
  65023 67477 # shie 372

  56279 56337 62243 63480 # reli 346
  64674 64676 # reli 359
  # reli 372
);

# corrections to items
my %corrections = (
  # Bile-Encrusted Medallion
  50682 => { earmor => 216 }, # missing armor
  
  # Devium's Eternally Cold Ring
  50622 => { earmor => 216 }, # missing armor
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