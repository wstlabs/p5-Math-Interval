package Math::Interval::Util;
use strict;
use warnings;
use Assert::Std            qw( :types );
use Scalar::Util           qw( reftype blessed );
use Carp                   qw( confess );
use Readonly;
use Math::Interval::Const  qw( :all );
# use Log::EZ;

use base 'Exporter';
our @EXPORT_OK = qw/
        is_nan
        q2b b2q 
        is_interval
        assert_interval
        allen_before
        allen_after
        allen_equals
    /;
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

Readonly::Hash our %Q2B => (
       $CLOSED => '[]', 
       $ROPEN  => '[)',   # == $LCLOSED 
       $LOPEN  => '(]',   # == $RCLOSED
       $OPEN   => '()'
); 
Readonly::Hash our %B2Q => (reverse %Q2B);

sub q2b  {
    my $q = shift;
    confess "need a quantifier" unless defined $q;
    $Q2B{$q}
}

sub b2q  {
    my $bb = shift;
    confess "need a pair of brakets" unless defined $bb;
    $B2Q{$bb}
}


sub is_interval  {
    defined $_[0] && blessed $_[0] && $_[0]->isa('Math::Interval')
}

sub assert_interval  {
    my $I = shift;
    confess "need a Math::Interval object" unless defined $I;
    confess "not a Math::Interval object"  unless is_interval($I); 
    return undef
}

sub allen_before  {
    my ($I,$J) = @_;
    return
        is_interval($I) ? $I->before($J) :
        is_interval($J) ?
            $J->is_empty     ? undef :
            $J->is_left_open ? 
                 $I <= $J->get_y : 
                 $I <  $J->get_y 
        : $I < $J
}

sub allen_after  {
    my ($I,$J) = @_;
    return
        is_interval($I) ? $I->after($J) :
        is_interval($J) ?
            $J->is_empty      ? undef :
            $J->is_right_open ? 
                 $J->get_y <= $I : 
                 $J->get_y <  $I 
        : $I > $J
}

sub allen_equals  {
    my ($I,$J) = @_;
    my $isI = is_interval($I);
    my $isJ = is_interval($J);
    return $I->equals($J) if  $isI &&  $isJ;
    return $I == $J       if !$isI && !$isJ;
    return
}



#
# TODO
#

# convex hull of a sequence of intervals.
# tricky, because they have to be of a common basetype !
sub hull_of  {
    confess "not yet implemented"
}

1

__END__


