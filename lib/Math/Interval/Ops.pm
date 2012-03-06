package Math::Interval::Ops;
use strict;
use warnings;
use Readonly;
use Carp qw( confess );
use base 'Exporter'; 
use Assert::Std qw( :types );
use Math::Interval::Regexp qw( :all );
use Log::EZ;

our @EXPORT_OK = qw/
        jfa_infl
        jfa_defl
        jfa_inf
        jfa_rev
        jfa_eval_bin
    /;
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

Readonly::Hash our %ALLEN => (qw/
    b    before 
    m    meets 
    mi   imeets 
    s    starts
    si   istarts
    o    overlaps
    oi   ioverlaps
    f    finishes
    fi   ifinishes
    d    during
    di   iduring
    a    after
    e    equals
/); 

Readonly::Hash our %AINV => (qw/
     a b  b a     
    m mi  mi m 
    s si  si s 
    f fi  fi f 
    d di  di d 
    o oi  oi o 
       e  e
/);


Readonly::Hash our %IALLEN => reverse %ALLEN; 


sub jfa_infl  {
    my $op = shift;
    defined $ALLEN{$op}  ? $ALLEN{$op}  : confess "no such op" 
}

sub jfa_defl  {
    my $op = shift;
    defined $IALLEN{$op} ? $IALLEN{$op} : confess "no such op" 
}

sub jfa_inv  {
    my $op = shift;
    defined $AINV{$op}   ? $AINV{$op}   : confess "no such op" 
}

sub jfa_rev  { confess "not yet implemented"  }

sub jfa_eval  {
    my $expr = shift;
    confess "not yet implemented"
}

# evals a simple binary expression, "I op J"
sub jfa_eval_bin  {
    my $expr = shift;
    confess "need an interval expression" unless defined $expr;
    if ( $expr =~ m{\A $RE{ival}{expr}{-keep} \z}xms ) {
        my ($i, $op, $j) = ($1,$2,$3);
        trace2 'got ',[$i,$op,$j];
        my $I = Math::Interval->new($i);
        my $J = Math::Interval->new($j);
        my $rel = jfa_infl($op); 
        trace2 "I = $I :".(ref $I)." = ",$I->serial_asis;
        trace2 "J = $J :".(ref $J)." = ",$J->serial_asis;
        trace2 "full:  $I $rel $J";
        return $I->$rel($J)
    }  else  {
        confess "not a binary interval expression"
    }
}

sub _assert_ival_expr  {
    my $x = shift;
    confess "need an interval expression" unless defined $x; 
    confess "not an interval expression (not SCALAR)" 
        unless is_scalar($x); 
    undef
}

1

__END__




