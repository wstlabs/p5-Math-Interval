# -*- perl -*-
use Test::More;
use Math::Interval;
use Devel::Size qw( total_size );
use YAML;
use strict;
no warnings; # commas

#
# more of a demo than a unit test; but at leasts verifies that 
# the size methods have been implemented in some form or another. 
#


    my $x = 42;
    my $sz_iv = Devel::Size::total_size(42);
    my $I = Math::Interval::->new("[2,3)");
    print "iv size = $sz_iv\n";
    print "size $I = " . $I->store->total_size . "\n";
    print "mems $I = " . Dump $I->store->member_sizes;


use warnings;
plan tests => 1; 
ok(1);  # suppress complaint about no tests run

