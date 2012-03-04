package Math::Interval::Const;
use strict;
use warnings;
use Readonly;
use base 'Exporter'; 

our @EXPORT_OK = qw/
        $CLOSED   
        $LCLOSED   
        $ROPEN   
        $LOPEN   
        $RCLOSED   
        $OPEN   
        $SVPINF
        $SVNINF
    /;
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );



# 
# so-called 'quantifier flag' represents -intended- topology.
#
# dec  bin   meaning
#
#   0   00   [] 
#   1   01   [) 
#   2   10   (]
#   3   11   ()
#
Readonly::Scalar our $CLOSED  => 0; 
Readonly::Scalar our $LCLOSED => 1; 
Readonly::Scalar our $ROPEN   => 1; 
Readonly::Scalar our $LOPEN   => 2; 
Readonly::Scalar our $RCLOSED => 2; 
Readonly::Scalar our $OPEN    => 3; 


# temporary hack, until we find a more standard 
# way to generate these constants
{
    Readonly::Scalar our $SVPINF => 0+'inf'; 
    Readonly::Scalar our $SVNINF => 0+'-inf'; 
    Readonly::Scalar our $SVNAN  => 0+'nan'; 
}

1


__END__

    # we can quickly enable this code to test the above:
    confess "bad constant" if $SVNAN  == 0; 
    confess "bad constant" if $SVPINF == 0; 
    confess "bad constant" if $SVNINF == 0; 
    confess "bad constant" unless $SVPINF > 0; 
    confess "bad constant" unless $SVNINF < 0; 
    confess "bad constant" unless $SVPINF > $SVNINF; 
    confess "bad constant" unless $SVNINF < $SVPINF; 
    confess "bad constant" unless $SVNAN  eq 'nan'; 
    confess "bad constant" unless $SVPINF eq 'inf'; 
    confess "bad constant" unless $SVNINF eq '-inf'; 
    confess "bad constant" unless ($SVPINF+$SFNINF) eq 'nan'; 
    confess "bad constant" unless -$SVPINF == $SVNINF; 
    confess "bad constant" unless -$SVNINF == $SVPINF; 


