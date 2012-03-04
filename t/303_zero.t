# -*- perl -*-


use Test::More;
use Math::Interval;

# ugh - "possible attempt to separate with commas"
no warnings;

    our @EQUAL = qw|
        [0,0]      [0]
        [0,-0]     [0]
        [-0,0]     [0]
        [-0,-0]    [0]
        [0]        [0,0]
        [-0]       [0]
    |;


use warnings;

plan tests => 2 * @EQUAL; 

while (@EQUAL)  {
    my $i = shift @EQUAL;
    my $j = shift @EQUAL;
    test_them($i,$j);
}


sub test_them  {
    my ($i,$j) = @_;
    my $I = Math::Interval->new($i);
    my $J = Math::Interval->new($j);
    is ( $I ==  $J,  1, "$i =>   $I == $I   <= $j" );
    is ( $J ==  $I,  1, "$j =>   $J == $J   <= $i" );
    is ( $I !=  $J, '', "$i =>   $I != $I   <= $j   (not!)" );
    is ( $J !=  $I, '', "$j =>   $J != $J   <= $i   (not!)" );
}




