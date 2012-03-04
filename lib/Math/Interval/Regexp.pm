package Math::Interval::Regexp;
use strict;
use warnings;
use Readonly;
use Carp qw( confess );
use Readonly;
#
# very much in the spirit of, but not yet integrated with the builder
# interface of fine package, Regexp::Common.
#

use base 'Exporter'; 
our @EXPORT_OK = qw/
        %RE
    /;
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

Readonly::Scalar our $XINT     => qr{(?: (?:[+-]?) (?:[\d]+|inf) )      }xms;
Readonly::Scalar our $IVXINT   => qr{ [\[\(] (?:$XINT),(?:$XINT) [\)\]] }xms;
Readonly::Scalar our $IVXINT_K => qr{ [\[\(]   ($XINT),  ($XINT) [\)\]] }xms;
Readonly::Scalar our $IVMT     => qr{ [\[\(] [\)\]]                     }xms;
Readonly::Scalar our $JFAOP    => qr{(?: [abe]|[dfmos]i? )              }xms;
Readonly::Scalar our $JFABIN   => qr{
    (?: $XINT | $IVXINT ) \s+ 
    (?: $JFAOP )          \s+ 
    (?: $XINT | $IVXINT ) 
}xms;

Readonly::Scalar our $JFABIN_K  => qr{
    ( $XINT | $IVXINT ) \s+ 
    ( $JFAOP )          \s+ 
    ( $XINT | $IVXINT ) 
}xms;

Readonly::Hash our %RE => (
    'ival' => {

        'num'  => {
            -isa  => $XINT,
            -keep => qr{($XINT)}xms 
        },

        'xint'  => {
            -isa   => $IVXINT, 
            -keep  => $IVXINT_K
        },

        'op'   => {
            -isa  => $JFAOP,
            -keep => qr{($JFAOP)}xms
        },

        'mt'   => {
            -isa  => $IVMT, 
            -keep => qr{($IVMT)}
        }, 
        'expr' => {
            -isa  => $JFABIN,
            -keep => $JFABIN_K 
        }
    }
);


__END__

