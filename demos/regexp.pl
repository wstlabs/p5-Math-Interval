use strict;
use warnings;
use Math::Interval;
use Math::Interval::Util qw( :all );
use Math::Interval::Regexp qw( :all );
use Log::Inline;
use Carp;


our $DEBUG = 1;
GetVerbose;

do {
    print<<__;
usage:  perl $0 pat text
__
    exit
} unless @ARGV == 2;

my ($pat,$text) = @ARGV; 

trace3 "RE = ",\%RE;
my $base = $RE{ival}{$pat} || confess "bad pat";
my $isa  = $base->{-isa};
my $keep = $base->{-keep};

trace "text = '$text'";
trace2 "isa  ($pat) = $isa";
trace2 "keep ($pat) = $keep";


for my $tag (qw/ -isa -keep /)  {
    trace "re $tag ...";
    check_it ($text, $base->{$tag}, $tag)
}

sub check_it  {
    my ($text, $re, $tag) = @_;
    if ( $text =~ m{\A $re \z}xms ) {
        trace "yes $tag";
        trace "@@ = ",[$1,$2,$3]
    }  else  {
        trace "no match!";
    }
}


__END__

