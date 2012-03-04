# -*- perl -*-


use Test::More;
use Math::Interval;

{
    # ugh - "possible attempt to separate with commas"
    no warnings;

    our @NONEMPTY = qw|
        [+2,3]     [2,3]
        [2,+3]     [2,3]
        [2,2]      [2]
        [2]        [2,2]
        [-inf,inf] (-inf,inf) 
        (-inf,inf] (-inf,inf) 
        [-inf,inf) (-inf,inf) 
        (-inf,inf) [-inf,inf]
        [2,inf]    [2,inf)
        [2,inf)    [2,inf]
        [-inf,2]   (-inf,2]
        (-inf,2]   [-inf,2]
    |;

    our @EMPTY = qw|
        [3,2]      []
        [2,2)      []
        (2,2)      []
        (2,2]      []
        []         [] 
        [)         [] 
        (]         [] 
        ()         [] 
        [2,2)      []
        (2,2]      []
        (2,2)      []
        [inf,inf]  []
        [inf,-inf] []
        [inf]      [] 
        [-inf]     [] 
        (inf)      [] 
        (inf]      [] 
        [inf)      [] 
        [inf]      [] 
        [2,-inf)   []
        [inf,2]    []
        [2,2)      (2,2] 
        [2,2)      (2,2)
        (2,2]      [2,2)
        (2,2]      (2,2)
        (2,2)      [2,2)
        (2,2)      (2,2]
        [3,2]      [3,2] 
        [3,2)      (3,2]
        (3,2)      (3,2)
    |;
}


plan tests => 3 * (@NONEMPTY + @EMPTY);

while (@NONEMPTY)  {
    my $i = shift @NONEMPTY;
    my $j = shift @NONEMPTY;
    test_them($i,$j);
}

while (@EMPTY)  {
    my $i = shift @EMPTY;
    my $j = shift @EMPTY;
    test_them($i,$j);
}

sub test_them  {
    my ($i,$j) = @_;
    my $I = Math::Interval->new($i);
    my $J = Math::Interval->new($j);
    is ( $I ==  $J, 1, "$i ==  $j" );
    is ( $J ==  $I, 1, "$j ==  $i" );
    is ( $I !=  $J, '', "!($i !=  $j)" );
    is ( $J !=  $I, '', "!($j !=  $i)" );
    is ( $I <=> $J, 0, "$i <=> $j" );
    is ( $J <=> $I, 0, "$j <=> $i" );
}




