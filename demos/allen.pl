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
usage:  perl $0 I allenop J 
where I and J are valid intervals, and generally should be in quotes, like so

    perl $0 "[2,3)" before "[3,4)"
    perl $0 "[2,3)" just_meets "[3,4)"
__
    exit 0; 
} unless @ARGV == 3; 
my ($iarg,$op,$jarg) = @ARGV;

trace "I = $iarg, J = $jarg, op = $op";
my $I = Math::Interval->new($iarg);
my $J = Math::Interval->new($jarg);
die "bad op" unless $I->can($op);
trace  "$I $op $J ? ",$I->$op($J); 
trace  "$J $op $I ? ",$J->$op($I); 

