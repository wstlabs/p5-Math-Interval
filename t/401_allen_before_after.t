# -*- perl -*-


use Test::More;
use Math::Interval;
use Math::Interval::Util qw( :all );
use strict;
no warnings; # commas

our @before = qw|
        [2,3) [3,4)
        [2,3] [4,4]
        (-inf,3) [3]
        (-inf,3) [3]
        [2] [3]
        [2] (2,inf) 
        (-inf,2) [2] 
        (-inf,2) [2,inf] 
|;

our @notbef = qw|
        [2,3] [3,4)
        [2,4) [3,5)
        [2]   [2]
        [3]   [2]
        []    [2]
        [2]   []
        [3,2] [3,2]
        [3,2] []
        [-inf] [2]
        [2]    [inf]
|;

use warnings;

plan tests => 4 * @before + 2 * @notbef;

while (@before)  {
    my $i = shift @before;
    my $j = shift @before;
    my $I = Math::Interval->new($i);
    my $J = Math::Interval->new($j);
    test_allen_T($I,$J);
    test_lt_gt($I,$J);
}

while (@notbef)  {
    my $i = shift @notbef;
    my $j = shift @notbef;
    my $I = Math::Interval->new($i);
    my $J = Math::Interval->new($j);
    test_allen_F($I,$J);
}

sub test_allen_T  {
    my ($I,$J) = @_;
    is ( $I->before($J),       1, "$I ->before $J" );
    is ( $J->after($I),        1, "$J ->after  $I" );
    is ( allen_before($I,$J),  1, "allen_before( $I, $J )" );
    is ( allen_after ($J,$I),  1, "allen_after ( $J, $I )" );
}

sub test_allen_F  {
    my ($I,$J) = @_;
    is ( $I->before($J),       '', "! $I ->before $J" );
    is ( $J->after($I),        '', "! $J ->after  $I" );
    is ( allen_before($I,$J),  '', "! allen_before( $I, $J )" );
    is ( allen_after ($J,$I),  '', "! allen_after ( $J, $I )" );
}

sub test_lt_gt  {
    my ($I,$J) = @_;
    is ( $I < $J,              1, "$I < $J == 1" );
    is ( $J < $I,             '', "$J < $I == ''" );
    is ( $I > $J,             '', "$I > $J == ''" );
    is ( $J > $I,              1, "$J > $I == 1" );
}


