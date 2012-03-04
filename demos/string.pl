use strict;
use warnings;
use Math::Interval;
use Log::Inline;
use Carp;

our $DEBUG = 1;
GetVerbose;

my $arg = shift;
confess "need an arg" unless defined $arg;
trace "arg = '$arg'";

my $I = Math::Interval->new($arg);
trace "I = $I"; 
trace "I = ",$I->asis;
trace "I = ",[ $I->_display ];

