use strict;
use warnings;
use Math::Interval;
use Math::Interval::Util qw( :all );
use Math::Interval::Ops  qw( :all );
use Log::Inline;
use Carp;


our $DEBUG = 1;
GetVerbose;

do {
    print<<__;
usage:  perl $0 "expr" 
__
    exit 0; 
} unless @ARGV;
my $expr = shift;

trace "expr = '$expr'";
my $rv = jfa_eval_bin($expr);
trace "rv = ",$rv; 

