use strict;
use warnings;
use Math::Interval;
use Log::EZ;

our $DEBUG = 1;
GetVerbose;


my $I = Math::Interval->new_LeftClosed(2,3);
trace "I = $I"; 
trace "I = ",$I->asis;
trace "I = ",[ $I->_display ];

my $s = $I->stringify;

{
trace "..";
my $J = Math::Interval->new($s);
trace "J = ",$J->asis;
trace "J = ",[ $J->_display ];
trace "$s => $J";
}


{
trace "..";
my $J = Math::Interval->new("(3,2]");
trace "J = $J"; 
trace "J = ",$J->asis;
trace "J = ",[ $J->_display ];
}


{
trace "..";
my $J = Math::Interval->new("(2)");
trace "J = $J"; 
trace "J = ",$J->asis;
trace "J = ",[ $J->_display ];
}

