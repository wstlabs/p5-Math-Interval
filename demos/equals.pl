use strict;
use warnings;
use Math::Interval;
use Math::Interval::Util qw( :all );
use Log::Inline;
use Carp;


our $DEBUG = 1;
GetVerbose;
local $SIG{__DIE__} = sub { confess "die: $!"; };

my ($iarg,$jarg) = @ARGV;
confess "need an I arg" unless defined $iarg;
confess "need an J arg" unless defined $jarg;

trace "I = $iarg, J = $jarg";
my $I = Math::Interval->new($iarg);
my $J = Math::Interval->new($jarg);
trace  "->";
trace  "$I equals $J ? ",$I->equals($J); 
trace  "$J equals $I ? ",$J->equals($I); 

trace  "allen:";
trace  "$I equals $J ? ",allen_equals($I,$J);
trace  "$J equals $I ? ",allen_equals($J,$I); 

