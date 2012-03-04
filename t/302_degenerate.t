# -*- perl -*-
use Test::More;
use Math::Interval;
use strict;
no warnings;

    # empty, but not storage empty
    our @DEG = qw|
        [2]
        [2,2]
    |;

    our @NOT = qw|
        []
        [3,2]
        (2]
        [2) 
        (2) 
        [2,2)
        (2,2]
        (2,2)
        [inf]
        (inf]
        [inf)
        (inf)
        [-inf]
        (-inf]
        [-inf)
        (-inf)
    |;



use warnings;

plan tests => @DEG + @NOT; 

while (@DEG)  {
    my $i = shift @DEG;
    my $I = Math::Interval->new($i); 
    is ($I->is_degenerate,         1, "$I degenerate");
}

while (@NOT)  {
    my $i = shift @NOT;
    my $I = Math::Interval->new($i);
    is ($I->is_degenerate,         '', "$I not degenerate");
}




