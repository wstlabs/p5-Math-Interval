use strict;
use warnings;
use Math::Interval;
use Math::Interval::Util qw( :all );
use Log::EZ;
use Carp;


our $DEBUG = 1;
GetVerbose;

my $iarg = shift;
confess "need an I arg" unless defined $iarg;

our $EMPTY = Math::Interval->new_Empty();

trace2 "I = $iarg";
my $I = Math::Interval->new($iarg);
trace "$iarg => $I";


trace  "$I empty ? ",$I->is_empty;
trace  "$I s_empty ? ",$I->is_storage_empty;
trace  "$I == EMPTY ? ",$I->equals($EMPTY);
trace  "EMPTY == $I ? ",$EMPTY->equals($I);


