# -*- perl -*-
use Test::More;
use Math::Interval;
use strict;
no warnings; # commas

    our $EMPTY = Math::Interval->new_Empty();

    # empty & storage empty
    our @SE = ( 
        $EMPTY,
        Math::Interval->new("[]"),
        Math::Interval->new("[)"),
        Math::Interval->new("(]"),
        Math::Interval->new("()")
    );

    # empty, but not storage empty
    our @EM = qw|
        [3,2]
        (3,2]
        [3,2)
        (3,2) 
        (2,2]
        [2,2)
        (2,2) 
        (2]
        [2) 
        (2) 
        [inf]
        (inf]
        [inf)
        (inf)
        [-inf]
        (-inf]
        [-inf)
        (-inf)
        [inf,inf]
        (inf,inf]
        [inf,inf)
        (inf,inf)
        [-inf,-inf]
        (-inf,-inf]
        [-inf,-inf)
        (-inf,-inf)
        [inf,-inf]
        (inf,-inf]
        [inf,-inf)
        (inf,-inf)
    |;


use warnings;

plan tests => 3 * @SE + 4 * @EM;

while (@SE)  {
    my $I = shift @SE;
    is ($I->is_empty,         1, "$I is empty");
    is ($I->is_storage_empty, 1, "$I is storage empty");
    is ($I->equals($EMPTY),   1, "$I == \$EMPTY" );
}

while (@EM)  {
    my $i = shift @EM;
    my $I = Math::Interval->new($i);
    is ( $I->is_empty,            1, "$i => $I is empty" );
    is ( $I->is_storage_empty,   '', "$i => $I not storage empty" );
    is ( $I->equals($EMPTY),      1, "$i => $I == \$EMPTY" );
    is ( $EMPTY->equals($I),      1, "\$EMPTY == $I <= $i" );
}




