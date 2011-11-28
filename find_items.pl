#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use Sigrie;

sub debug { print STDERR @_ };

# adjusting this to only update newer items, the rest are already in GDB
# my @levels = qw(346 353 359 365 372 378 379 391 397);
my @levels = qw(378 379 384 390 391 397 403 410 416);

my $base = 'http://ptr.wowhead.com/items';
my $filters = 'ub=2;cr=23:21:96:103:79;crs=3:3:3:3:3;crv=0:0:0:0:0;qu=3:4:5';
# For reference, the filters described above are as follows:
#  Usable By: Paladin
#  Quality: Rare, Epic, Legendary
#  Intellect = 0
#  Agility = 0
#  Critical Strike Rating = 0
#  Haste Rating = 0
#  Resilience Rating = 0

my %items = ();
my $ua = new LWP::UserAgent;

foreach my $ilvl (@levels) {
  debug "Getting items for level $ilvl\n";

  my $uri = sprintf('%s?filter=%s;minle=%u;maxle=%u', $base, $filters, $ilvl, $ilvl);
  my $r = $ua->get($uri);

  if ($r->is_error) {
    debug "Could not get items: ", $r->status_line, "\n";
    exit;
  }

  my $body = $r->content;

  my ($data) = $body =~ /^new Listview\({.*?data: \[(.*)\]}\);$/m;
  if ($body =~ /_truncated: 1/) {
    debug "Too many items returned, please add additional filters.\n";
    exit;
  }

  # find potential items
  while ($data =~ /"id":(\d+)/g) {
    my $id = $1;
    my %item = Sigrie::get_item($id);

    # Tank items must have at least one of mastery, dodge, or parry
    # Trinkets need only have stamina
    # Weapons need only have strength
    next unless $item{mast} or $item{dodge} or $item{parry} 
      or ($item{slot} eq 'Trinket' and $item{sta})
      or ($item{slot} eq 'One-Hand' and $item{str});
    
    $items{$item{slot}}{$ilvl}{$id} = $item{name};
  }
}

foreach my $slot (sort keys %items) {
  print "# $slot\n";
  foreach my $ilvl (@levels) {
    my @ids = keys %{$items{$slot}{$ilvl}} or next;
    print "push \@items, qw(" . join(' ', @ids) . "); #$ilvl\n";
  }
}

