use strict;
use warnings;
use Math::Interval;
use Assert::Std qw(:types); 
use Log::EZ;

GetVerbose;

trace "inst...";
my $I = Math::Interval->new(2,3,0);
trace "I = $I\n";

my $tf = $I->get_tf;
my @xy = $I->endpoints;
my $topo = $I->topology;
print "xy = @xy : $topo\n";


my $s = $I->serial;
trace "s = ",$s;

