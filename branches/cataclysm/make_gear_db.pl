#!/usr/bin/perl

use strict;
use warnings;

use Sigrie;
use Getopt::Long;
use Switch;

# Load item list from file if not passed on command line
our @items = ();
if (@ARGV) {
  @items = @ARGV;
} else {
  require 'item_list.pl';

  # Addition items not found by the item finder
}

# Corrections to items
my %corrections = (
  78485 => { name => "Maw of the Dragonlord (Raid Finder)" }, # RF tag
  78488 => { name => "Souldrinker (Raid Finder)" }, # RF tag
);

# Slot numbers by name
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

# Attributes about which we care
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
  
  # Get the item
  my %item;
  
  for (1 .. 5) {
    %item = Sigrie::get_item($id);
    last if %item;
    print STDERR "Retrying item $id\n";
  }
  
  # Apply item corrections
  if (my $hash = $corrections{$id}) {
    $item{$_} = $hash->{$_} for keys %$hash;
  }
  
  # Print out the attributes about which we care, skipping any that are null
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
  
  # Armor type flag
  print "idb.iid($id).atype=1;\n" if $item{atype} and $item{atype} eq 'Plate';
  
  # Reforging flag
  print "idb.iid($id).isreforged=0;\n";
  
  # Tier set flag
  switch ($id) {
    case [60354..60358,65224..65228] { print "idb.iid($id).istierP=[1 0 0];\n" }
    case [70946..70950,71522..71526] { print "idb.iid($id).istierP=[0 1 0];\n" }
    case [71063..71067,71512..71516] { print "idb.iid($id).istierR=[0 1 0];\n" }
    case [77003..77007,78772,78790,78810,78827,78840,78677,78695,78715,78732,78745] { print "idb.iid($id).istierP=[0 0 1];\n" }
    case [76874..76878,78837,78807,78788,78770,78822,78742,78712,78693,78675,78727] { print "idb.iid($id).istierR=[0 0 1];\n" }
  }
  
  print "\n";
}
