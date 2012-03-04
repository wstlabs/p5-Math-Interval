use strict;
use warnings;
use Math::Interval;
use DateTime;
use Log::EZ;

our $DEBUG = 1;
GetVerbose;

my $t1 = DateTime->now; sleep(1);
my $t2 = DateTime->now; sleep(1);
my $t3 = DateTime->now;
trace "t1,t2 = $t1,$t2";


my $lt12 = $t1 < $t2 ? 'yes' : 'no';
my $lt21 = $t2 < $t1 ? 'yes' : 'no';
trace "lt:  $lt12, $lt21";

my $dt = $t2 - $t1;
trace "dt = $dt = ",$dt;

my $I = Math::Interval->new_RightClosed($t1,$t3);
trace "I = $I"; 


__END__


