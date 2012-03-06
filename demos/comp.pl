use strict;
use warnings;
use Math::Interval qw( :const );
use Log::EZ;

our $DEBUG = 1;
GetVerbose;

my $I = Math::Interval->new("[2,3)");
my $J = Math::Interval->new("[3,4)");

check_it($I,$J);
$I->set_q( $CLOSED );
check_it($I,$J);

sub check_it  {
    my ($I,$J) = @_;
    trace "$I before $J ? ", $I->before($J);
    trace "$J before $I ? ", $J->before($I);
    trace "$I before $I ? ", $I->before($I);
}

