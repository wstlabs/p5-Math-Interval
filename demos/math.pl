use strict;
use warnings;
use Math::Interval;
use Math::Interval::Util qw( :all );
use Log::Inline;
use Carp;


our $DEBUG = 1;
GetVerbose;

do {
    print<<__;
usage:  perl $0 I op J 
where I and J are either intervals or elements, but if intervals,
should definitely be in quotes, like thus:

    perl $0 "[2,3)" plus "[3,4)"
    perl $0 "[2,3)" plus 7 
    perl $0 "[2,3)" multiply "[3,4)"
__
    exit 0; 
} unless @ARGV == 3; 
my ($iarg,$op,$jarg) = @ARGV;
trace "I = $iarg, op = $op, J = $jarg";

trace "I = $iarg, J = $jarg";
my $I = $iarg =~ m{[\[\(\)\]]} ? Math::Interval->new($iarg) : 0+$iarg;
my $J = $jarg =~ m{[\[\(\)\]]} ? Math::Interval->new($jarg) : 0+$jarg;
trace "I => $I, J => $J";

if ( is_interval($I) ) {
    confess "badness" unless $I->can($op);

    my $K = $I->$op($J); 
    trace "K = $K\n";
}
else  {
    confess "use case not yet implemented"
}




