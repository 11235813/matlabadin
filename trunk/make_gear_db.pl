#!/usr/bin/perl

use strict;
use warnings;

use Sigrie;
use Getopt::Long;

# list of item ids to parse
my @items = ();

# Head
push @items, qw(56278 56358 57873 58098 58103 62410 63478); #346
push @items, qw(69558 69614); #353
push @items, qw(59344 59487 60356 63531); #359
push @items, qw(65038 65096 65130 65226); #372

# Neck
push @items, qw(52323 56319 56338 56360 56411 56421 57930 57932 63438 68172 68173); #346
push @items, qw(69605 69635); #353
push @items, qw(59319 59442 62447 67138); #359
push @items, qw(65025 65059 65379 65380); #372

# Shoulders
push @items, qw(56318 56452 58100 58104 63470); #346
push @items, qw(69573 69582); #353
push @items, qw(59356 59471 59901 60358 67144); #359
push @items, qw(65027 65101 65142 65228); #372

# Back
push @items, qw(56275 56304 56355 56369 56379 56397 56467 56548 56549 63467 63473); #346
push @items, qw(69572 69767 69770 69800); #353
push @items, qw(58190 58192 59466 59507 62383); #359
push @items, qw(65010 65117); #372

# Chest
push @items, qw(56308 56425 58096 58101 63458); #346
push @items, qw(69587 69593); #353
push @items, qw(55058 55060 59316 59486 60354 67143); #359
push @items, qw(65062 65131 65224); #372
  
# Wrist
push @items, qw(56301 56416 57870 63457 67238); #346
push @items, qw(69608 69801); #353
push @items, qw(59118 59470 62449); #359
push @items, qw(65085 65143); #372

# Hand
push @items, qw(56336 56428 58099 58105 62408 63434 63474); #346
push @items, qw(69619 69633); #353
push @items, qw(59225 59505 60355); #359
push @items, qw(65071 65119 65225); #372

# Waist
push @items, qw(56392 56447 57913 57914 63453 67235); #346
push @items, qw(69604); #353
push @items, qw(55059 55061 59117 59342 62384); #359
push @items, qw(65040 65086); #372

# Legs
push @items, qw(56283 56294 56367 58097 58102); #346
push @items, qw(69557 69583); #353
push @items, qw(59317 59503 60357 67141); #359
push @items, qw(65061 65121 65227); #372

# Feet
push @items, qw(56378 56381 62382 63444); #346
push @items, qw(69588); #353
push @items, qw(58195 58197 59221 59328 59464 62418); #359
push @items, qw(65012 65051 65075); #372

# Finger
push @items, qw(52320 52348 56270 56299 56310 56332 56365 56388 56398 56412 56415 56444 56457 62348 62350 62351 62440); #346
push @items, qw(69553 69563 69610 69802); #353
push @items, qw(58185 58187 59233 59518 63488 63489 63494 63499 67139); #359
push @items, qw(65070 65106 65367 65372 65373 65382); #372

# Trinket
push @items, qw(52351 52352 56280 56285 56345 56347 56406 56431 56449 56458); #346
push @items, qw(58180 58182 58483 59224 59332 59461 59506 59515 59520 62048 62049 62466); #359
push @items, qw(65048 65072 65109 65118); #372

# Axe
push @items, qw(55067 56266 56364 62457 65170 67602 68740); #346
push @items, qw(59443 61324 61325); #359
push @items, qw(65024 67473 67474); #372

# Mace
push @items, qw(55065 56312 56353 56396 56459 57872 62459 65171); #346
push @items, qw(69575 69581 69803); #353
push @items, qw(59347 59459 61335 61336 61338 63680); #359
push @items, qw(65017 65036 65090 67454 67470 67471); #372

# Sword
push @items, qw(56346 56384 56430 56433 65164 65166 65173); #346
push @items, qw(69609 69618 69639); #353
push @items, qw(59333 59463 59521 61344 61345 63533 64885 68161); #359
push @items, qw(65013 65047 65094 65103 67468 67469); #372

# Shield
push @items, qw(56314 56402 56426 57926); #346
push @items, qw(69627 69629); #353
push @items, qw(55069 59444 61359 67145); #359
push @items, qw(65023 67477); #372

# Relic
push @items, qw(56279 56337 62243 63480); #346
push @items, qw(64674 64676); #359

# override parsed items
@items = @ARGV if @ARGV;

# corrections to items
my %corrections = (
	# None at the moment
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
  earmor    socket    sbstat    sbval
  ap        sp
);

my $verbose = 0;

GetOptions(
  verbose => \$verbose,
);

sub notef { printf STDERR @_ if $verbose; }

my $count = @items;
my $progress = 0;
foreach my $id (@items) {
  notef "\r%4u / %4u  %3u%%", $progress++, $count, $progress / $count * 100;
  
  # get the item
  my %item;
  
  for (1 .. 5) {
    %item = Sigrie::get_item($id);
    last if %item;
    print STDERR "Retrying item $id\n";
  }
  
  # apply item corrections
  if (my $hash = $corrections{$id}) {
    $item{$_} = $hash->{$_} for keys %$hash;
  }
  
  # print out the attributes about which we care, skipping any that are null
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
  
  # atype = 1 if item is plate (is this still useful?)
  print "idb.iid($id).atype=1;\n" if $item{atype} and $item{atype} eq 'Plate';
  
  
  print "\n";
}