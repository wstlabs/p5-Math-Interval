# -*- perl -*-
use Test::More;
use Math::Interval;
use strict;
no warnings; # commas


# TODO:  open/half-open versions of good cases 

# empty, but not storage empty
our @GOOD = qw|
        [0]         0
        [1]         1 
        [2]         2 
        [3]         3 
        [0,0]       0 
        [1,1]       1 
        [2,2]       2 
        [3,3]       3 
        [-42,-42] -42
        [-1]       -1 
        [0,2]       1
        [0,1]       0.5 
        [-1,0]     -0.5 
        [2,4]       3 
        [-4,-2]    -3 
        [-1,1]      0 
        [-3,3]      0 
|;

# have no defined midpoint
our @BAD = qw|
        []
        [inf]
        [-inf]
        [3,2]
        [-2,-3]
        [2,2)
        (2,2]
        (2,2)
        [2,inf)
        (-inf,2]
        (-inf,inf)
|;


use warnings;

plan tests => @GOOD / 2 + @BAD; 

while (@GOOD)  {
    my $i  = shift @GOOD;
    my $t0 = shift @GOOD;
    my $I  = Math::Interval->new($i); 
    my $t  = 0+$t0;
    die "badness" unless $t eq $t0;
    is ($I->midpoint, $t, "$I->midpoint == $t");
}

while (@BAD)  {
    my $i = shift @BAD;
    my $I = Math::Interval->new($i);
    is ( $I->midpoint,  undef, "$I->midpoint == undef" );
}




