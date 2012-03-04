use strict;
use warnings;
use Math::Interval qw( :const );
use Log::EZ;

our $DEBUG = 1;
GetVerbose;

my $I = Math::Interval->new_Closed(2,$SV_POS_INF);
print "I = $I\n";

__END__


