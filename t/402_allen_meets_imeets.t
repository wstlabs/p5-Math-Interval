# -*- perl -*-


use Test::More;
use Math::Interval;
use Math::Interval::Util qw( :all );
use strict;
no warnings; # commas

    # anti-symetric 
    our @TANT = qw|
        [2,3] meets      [3,4)
        [2,3] just_meets (3,4)
        [2,3) just_meets [3,4)
        [2,3) just_meets [3,3]
        [2,3] meets      [3,3]
        [3,3] meets      [3,4)
        [3,3] just_meets (3,4)
        [2,3] meets      [3,inf]
        [2,3] meets      [3,inf)
        [2,3] just_meets (3,inf)
        [2,3) just_meets [3,inf)
        (-inf,3] meets      [3,inf)
        (-inf,3) just_meets      [3,inf)
        (-inf,3) just_meets      [3,inf]
        [-inf,3) just_meets      [3,inf)
        [-inf,3) just_meets      [3,inf]
        (-inf,3] just_meets      (3,inf)
        (-inf,3) just_meets      [3,inf)
    |;

    # symmetric; inverse also true
    our @TSYM = qw|
        [3,3] meets      [3,3]
    |;

    # false-symmetric
    our @FSYM = qw|
        [2,3) meets      [3,4)
        [2,3] meets      (3,4)
        [2,3] meets      (4,5)
        [2,4] meets      (3,5)
        [2,4] meets      (2,5)
        [2,4] meets      (1,5)
        [2,4] meets      (1,2]
        [2,4] meets      [0,1]
        [2,4] meets      [4,2]
        []    meets      []
        [2]   meets     [3]
        [inf] meets     [inf]
        [2)   meets     [2]
        [2)   meets     [2,3)
        (2]   meets     [2,3)
        [2)   just_meets     [2,3)
        [2)   just_meets     [2]
        (-inf,inf) meets []
        (-inf,inf) meets [0]
        (-inf,inf) meets [2,3]
        (-inf,inf) meets [inf]
        [0,inf) meets [inf]
        [0,inf) just_meets [inf]
    |;

use warnings;

plan tests => 
    4 * ( @TANT   / 3 ) +
    4 * ( @TSYM   / 3 ) +
    2 * ( @FSYM   / 3 ) ;

while (@TANT)  {
    my $i  = shift @TANT;
    my $op = shift @TANT;
    my $j  = shift @TANT;
    my $I  = Math::Interval->new($i);
    my $J  = Math::Interval->new($j);
    die "badness" unless Math::Interval->can($op);
    my $iop = _inverse($op);
    is ($I->$op($J),   1, "T $I->$op($J)");
    is ($J->$op($I),  '', "F $J->$op($I)");
    is ($J->$iop($I),  1, "T $J->$iop($I)");
    is ($I->$iop($J), '', "F $I->$iop($J)");
}

while (@TSYM)  {
    my $i  = shift @TSYM;
    my $op = shift @TSYM;
    my $j  = shift @TSYM;
    my $I  = Math::Interval->new($i);
    my $J  = Math::Interval->new($j);
    die "badness" unless Math::Interval->can($op);
    my $iop = _inverse($op);
    is ($I->$op($J),   1, "T $I->$op($J)");
    is ($J->$op($I),   1, "T $J->$op($I)");
    is ($J->$iop($I),  1, "T $J->$iop($I)");
    is ($I->$iop($J),  1, "T $I->$iop($J)");
}

while (@FSYM)  {
    my $i  = shift @FSYM;
    my $op = shift @FSYM;
    my $j  = shift @FSYM;
    my $I  = Math::Interval->new($i);
    my $J  = Math::Interval->new($j);
    die "badness" unless Math::Interval->can($op);
    my $iop = _inverse($op);
    is ($I->$op($J),   '', "F $I->$op($J)");
    is ($J->$iop($I),  '', "F $J->$iop($I)");
}




sub _inverse  {
    my $op = shift;
    die "need an op" unless defined $op;
    if ( $op =~ m{^just} )  {  $op =~ s{_(\w+)$}{_i$1}g  }
                      else  {  $op = "i$op"  }
    return $op
}

