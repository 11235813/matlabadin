#!/usr/bin/perl

use strict;
use warnings;

use Wowhead;
use Getopt::Long;

=head1 NAME

make_gear_db.pl - Generate gear db for Matlabadin

=head1 SYNOPSIS

  perl make_gear_db.pl --verbose >gear_db.m

=head1 CONFIGURATION

There are several different configuration variables that can be 
changed without much knowledge of perl.

=head2 Corrections

  my %corrections = (
    # Theck's Emberseal should have had mastery
    71367 => { hit => 0, mast => 115 },
  );

The C<%corrections> variable let's you manually set stats for an item in case
the database has incorrect data.  This should not usually be necessary, but
sometimes they have incorrect armor values or other silliness.  You need only
specifiy the stats you wish to change, and the script will use the values from
the database for the rest.

=cut

my %corrections = (
);

=head2 Manual Item Inclusion

  my @items = qw( 
    27978, # Soap on a Rope
    38090, # Sapphire Pinky Ring
  );

The C<@items> array allows you to specify additional item ids to include in the
final gear database that the item finder did not find.  Use this only to
include items that have strange stats and wouldn't match the filters normally.

=cut

my @items = qw(
);

=head2 Relevant Item Levels

  my @ilvls = qw(
    440 450 463 476 483 489 496 502 509 516
  );

The C<@ilvls> array allows you to specify what item levels should be included 
in the gear database.  There isn't much intersting to say about it, just change 
it as new content is added and old content becomes irrelevant.

=cut 

my @ilvls = qw(
  440 450 463 476 483 489 496 502 509 516
);

=head2 Item Filters

  my %search = (
    int       => [ eq => 0 ],
    agi       => [ eq => 0 ],
    crit      => [ eq => 0 ],
    haste     => [ eq => 0 ],
    resil     => [ eq => 0 ],
  );

The C<%search> variable allows you to specify what filters will be used to find
items to include.  I think the defaults are pretty reasonable, but I'm sure we
will be investigating "dps" sets by the end of the expansion again, so I put
this here to easily include non-tank gear.  Unfortunately, due to limitations
with Wowhead, you can only put 5 "stat" filters in here.  Also, the format of
non-stat filters will remain largely undocumented because there are far more
silly filters on Wowhead than free hours in my day.

=cut

my %search = (
  int       => [ eq => 0 ],
  agi       => [ eq => 0 ],
  crit      => [ eq => 0 ],
  haste     => [ eq => 0 ],
  resil     => [ eq => 0 ],
);

# End of configuration

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

notef "Finding items\n";

for my $ilvl (@ilvls) {
  for (1 .. 5) {
    my @armor =  Wowhead::search_items(
      4,                              # armor
      minle => $ilvl, maxle => $ilvl, # only current ilvl
      ub => 2,                        # pally gear
      %search,                        # search criteria
    );

    if (@armor) {
      notef "Got %u armors at ilvl %u\n", scalar(@armor), $ilvl;
      push @items, @armor;
      last;
    }
  }

  for (1 .. 5) {
    my @weapons = Wowhead::search_items(
      2,                              # weapons
      minle => $ilvl, maxle => $ilvl, # only current ilvl
      ub => 2,                        # pally gear
      %search,                        # search criteria
    );

    if (@weapons) {
      notef "Got %u weapons at ilvl %u\n", scalar(@weapons), $ilvl;
      push @items, @weapons;
      last;
    }
  }
};

notef "Done finding items.\n";
notef "Getting full item data.\n";

# Print out a warning
print <<END_WARNING;
%%% WARNING %%%
% This file is generated by make_gear_db.pl.  Do not edit it directly, as any
% changes will be overrun when the script is run again.  You should instead edit
% gear_db_head.m or gear_db_foot.m if you need to make changes to this output

END_WARNING

# Print out the gear_db header
open my $head, '<', 'gear_db_head.m';
print <$head>;
close $head;

my $count = @items;
my $progress = 0;
foreach my $id (@items) {
  notef "\r%4u / %4u  %3u%%", $progress++, $count, $progress / $count * 100;
  
  # Get the item
  my %item;
  
  for (1 .. 5) {
    %item = Wowhead::get_item($id);
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
  for ($item{setname} or '') {
    /White Tiger Plate/      and print "idb.iid($id).istierP=[1];\n";
    /White Tiger Battlegear/ and print "idb.iid($id).istierR=[1];\n";
  }
  
  print "\n";
}

notef "\nDone getting item data.\n";

# Print out the gear_db footer
open my $foot, '<', 'gear_db_foot.m';
print <$foot>;
close $foot;

notef "\nDone generating gear db\n";
