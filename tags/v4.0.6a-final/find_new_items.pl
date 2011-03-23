#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use Sigrie;

my $ua = new LWP::UserAgent;
my $r = $ua->get('http://db.mmo-champion.com/latest/');

if ($r->is_error) {
  print STDERR "Could not get latest items\n";
  print STDERR $r->status_line, "\n";
  exit;
}

my $body = $r->content;

# find potential items
while ($body =~ m|<a href="/i/(\d+)/[^"]+" class="q[34]">|g) {
  my $id = $1;
  my %item = Sigrie::get_item($id);
  
  # only want higher than wotlk items
  next if $item{ilvl} < 285;
  
  # tank items must not have any of these stats
  next if $item{agi} or $item{spi} or $item{int};
  
  # tank items must have at least one of these stats
  next unless $item{dodge} or $item{parry} or $item{earmor} or $item{wtype};
  
  print "http://db.mmo-champion.com/i/$id - $item{name}\n";
}