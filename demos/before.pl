use strict;
use warnings;
use Math::Interval;
use Math::Interval::Util qw( :all );
use Log::EZ;
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
trace  "$I before $J ? ",$I->before($J); 
trace  "$J before $I ? ",$J->before($I); 
trace  "$I after  $J ? ",$I->after($J); 
trace  "$J after  $I ? ",$J->after($I); 

trace  "allen:";
trace  "$I before $J ? ",allen_before($I,$J);
trace  "$J before $I ? ",allen_before($J,$I); 
trace  "$I after  $J ? ",allen_after($I,$J); 
trace  "$J after  $I ? ",allen_after($J,$I); 

