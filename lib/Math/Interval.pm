#
#
package Math::Interval;
use strict;
use warnings;
use Assert::Types          qw( :all );
use Scalar::Util           qw( reftype );
use Carp                   qw( confess );
use Readonly;
use Log::Inline;
use Math::Interval::Regexp qw( :all );
use Math::Interval::Const  qw( :all );
use Math::Interval::Util   qw( :all );
use Math::Interval::Ops    qw( :all );
# in future versions, storage will be fully pluggable and dynamically
# loaded; for now we just offer one storage type, and make in the default.
# see notes in the constructor, below.
use Math::Interval::Store::Std;

our $VERSION = '0.03c';

use base 'Exporter';
our @EXPORT_OK = @Math::Interval::Const::EXPORT_OK;
our %EXPORT_TAGS = (
    'all'   => \@EXPORT_OK,
    'const' => \@Math::Interval::Const::EXPORT_OK
);

# unary +/- ? 
use overload (qw/
    ""   stringify
    <=>  compare
    ==   equals
    <    is_lt 
    >    is_gt 
    <=   is_le
    >=   is_ge
    ~~   just_touches
/);


# eventually, storage will be fully pluggable.  for now, we just 
# have one impl to provide, so make it the hard-coded default: 
Readonly::Scalar our $STORE => 'Math::Interval::Store::Std';

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    # shouldn't happen
    confess "bad package configuration" unless defined $STORE;
    confess "bad store package $STORE"  unless $STORE->can('new');

    # empty case
    if (@_ == 0)  {
        return $class->_new({ q => $CLOSED }) 
    }

    # single-arg case:  either a string or a hash spec
    elsif (@_ == 1)  {
        my $rt = defined $_[0] ? reftype $_[0] :
            confess "can't construct on undefined argument";
        return
            !defined $rt  ? $class->_from_string($_[0]) :
            $rt eq 'HASH' ? $class->_new($_[0]) :
            confess "can't construct on reftype $rt"
    } 
    else  {
        confess "multi-arg constructors not yet implemented" 
    }
}

# you'll note that our model here is to first instantiate our storage 
# container as a fully independent object instance, and then bless a 
# reference to that reference as our Math::Interval object.
sub _new  {
    my ($proto, $spec) = @_;
    my $class = ref $proto || $proto;
    assert_hash_ref($spec);
    my $store = $STORE->new($spec);
    bless \$store, $class
}
sub store  { ${$_[0]} }


# XXX won't handle recursive, or otherwise deliberately
# contaminated cases.  but that's ok, for now.
sub _from_string  {
    my ($class,$string) = @_;
    assert_scalar($string);
    # see comments around subs 'bra' and 'ket' for etymology of those terms
    my ($bra, $mid, $ket) = 
        $string =~ m{\A ([\[\(]) (.*) ([\)\]]) \z}xms ? ($1,$2,$3) :
        confess "malformed input string"; 
    trace3 { bra => $bra, mid => $mid, ket => $ket };
    my $q = b2q($bra.$ket);
    # should never happen
    confess "invalid state" unless defined $q;
    my @t = split /,/, $mid;
    trace3 { q => $q, t => \@t };
    # works for pure-numeric and numeric string representations and +/-inf
    return
        @t == 0 ? $class->new_Empty :
        @t == 1 ? $class->_new({ q => $q, z => 0+$t[0] }) :
        @t == 2 ? $class->_new({ q => $q, x => 0+$t[0], y => 0+$t[1] }) 
    : confess "too many comma-separated terms"
}



#
# -- impl methods --
#
# must/should be provided by delegated stores, as noted.
#

#
# logical, DWIM accesors for external use.
#


#
# the 'xyz' accessors are intended to provide DWIM behavior
# w.r.t. the -logical- values x, y, and z, while maintaining 
# internal consistency of the (somewhat different) underlying
# physical state of the storage slots (x,y,z).
#
# internally, they must be designed to maintain the following contract:
#
#     has_z XOR ( has_x && has_y) XOR ( !has_x && !has_y & !has_z ) 
#
# in the sense of the 'physical' storage locations x, y, and z at all times.
# each takes an endpoint as a single argument, which must be defined. 
#

sub has_x    { my $self = shift; $self->store->has_x(@_) } 
sub get_x    { my $self = shift; $self->store->get_x(@_) } 
sub set_x    { my $self = shift; $self->store->set_x(@_) } 

sub has_y    { my $self = shift; $self->store->has_y(@_) } 
sub get_y    { my $self = shift; $self->store->get_y(@_) } 
sub set_y    { my $self = shift; $self->store->set_y(@_) } 

sub has_z    { my $self = shift; $self->store->has_z(@_) } 
sub get_z    { my $self = shift; $self->store->get_z(@_) } 
sub set_z    { my $self = shift; $self->store->set_z(@_) } 

sub has_q    { my $self = shift; $self->store->has_q(@_) } 
sub get_q    { my $self = shift; $self->store->get_q(@_) } 
sub set_q    { my $self = shift; $self->store->set_q(@_) } 



# prunes all endpoints, to make instance storag-empty. 
sub del_xyz      { my $self = shift; $self->store->del_xyz(@_) } 
# special as-is accessor; returns tuple of all 4 storage states, 
# but unlike x and y accessors, doesn't enforce  consistency checks.
sub _get_xyzq    { my $self = shift; $self->store->_get_xyzq(@_) } 



# as in Devel::Size.  useful, but more of SHOULD than a MUST.
# XXX ideally these should distinguish storage-degenerate cases,
# ie where x and y both contain the same object referenes, and deal
# will invalid cases, e.g. has z and x but not y, as well.
sub total_size   { confess "not yet implemented" }
sub member_sizes { confess "not yet implemented" }







#
#  -- derived methods --
#
# everything else emerges by default from the above,
# but may be overridden for performance or other considerations.
#


#
# get_xy and set_xy work as you would expect -- acting on  
# simultanous mutators, acting on a tuple (x,y) in both directions.
#
sub get_xy   { ( $_[0]->get_x, $_[0]->get_y ) } 
sub set_xy   { 
    my $self = shift;
    $self->set_x(shift);
    $self->set_y(shift); 1
}


# convenience accessors
sub xy   { $_[0]->get_xy }
sub yx   { reverse $_[0]->get_xy }

sub xyq  { ( $_[0]->get_xy, $_[0]->get_q ) }
sub xq   { ( $_[0]->get_x,  $_[0]->get_q ) }
sub yq   { ( $_[0]->get_y,  $_[0]->get_q ) }
sub zq   { ( $_[0]->get_z,  $_[0]->get_q ) }


sub clone  {
    my $self = shift;
    $self->_new( $self->serial_new )
}


#
# naive serializers - providing a simple recursive structure
# suitable for casual ( YAML, JSON, Data::Dumper) serialization.
#
# three flavors currently supported:  old, new and asis.
#
# both 'new' and 'old' are streamlined to emit both the binary 
# ('x' and 'y' members present) and the unary ('z' member only)
# cases efficiently.
#
# 'new' emits endpoint members which are themselves clones, 
# assuming that the constituent members respond to the '+' op 
# appropriately (when evaluted from the right); sutiable for
# cloning serialization.
#
# 'old' emits endpoint members directly; suitable for efficient
# representation of the existing object state.
#
# finally, 'asis' emits all members explicitly.  note that
# 'old' and 'asis' are nearly equiavelent (the former being
# effectively a subset of the latter.)
#
sub serial_new { $_[0]->_serialize_minimal(1) }
sub serial_old { $_[1]->_serialize_minimal(0) }

sub _serialize_minimal {
    my ($self, $is_new) = @_;
    my ($x,$y,$z,$q) = $self->_get_xyzq;
    return 

        # unary case
        defined $z ? 
            $is_new ?  
                { 'q' => $q, 'z' => $z+0 } : 
                { 'q' => $q, 'z' => $z   } 

        # binary case
        : defined $x && defined $y ? 
            $is_new ?  
                { 'q' => $q, 'x' => $x+0, 'y' => $y+0 } :
                { 'q' => $q, 'x' => $x,   'y' => $y   } 

        # empty case
        : !defined $x && !defined $y ? 
            { 'q' => $q }

        # if we get down here then we have one of x or y defined,
        # but not both, which should never happen.
        : confess "corrupted state" 

}

sub serial_asis {
    my $self = shift;
    my ($x,$y,$z,$q) = $self->_get_xyzq;
    return {
        'x' => $x, 'y' => $y, 'z' => $z, 'q' => $q
    }
}
*asis = \&serial_asis;

#
# finally there's the 'eval' serialization, which returns serialization 
# of the interval as it arithmetically evalutes, in canonical form. 
#
# so improper intervals are emitted as empty intervals, and infinite
# and half-infinite intervals are emitted with the brakets on the 
# infinite side(s) set to open as they should be, etc.
#
# like the standard naive serialization, it will have both 
# new and old sub-roles.
#
sub serial_eval_new {  $_[0]->_serial_eval(1)  }
sub serial_eval_old {  $_[0]->_serial_eval(0)  }


sub _serial_eval {
    my ($self, $is_new) = @_;
    my ($z,$q) = $self->zq;

    # canonical degenerate
    return {
        'z' => $is_new ? $z+0 : $z,
        'q' => $CLOSED
    } if defined $z;

    my ($x,$y) = $self->xy;
    if (defined $x && defined $y)  {

        my $cmp = $x <=> $y;
        return

            # always improper; eval to empty 
            $cmp > 0 ? { 'q' => $CLOSED }
            : 

            # x == y, depends on topology
            $cmp == 0 ? 

                # yes, it's equivalent to a degenerate interval, but 
                # we don't canonicalize (x,y) to (z) because this has 
                # side effects & we have no way of choosing. 
                $q == $CLOSED ? {
                    'x' => $is_new ? $x+0 : $x,
                    'y' => $is_new ? $y+0 : $y,
                    'q' => $q 
                } :
                 

                # but if it's full- or half-open then this is
                # a degenerate case; so we return as empty
                {  'q' => $CLOSED }
            :

            # proper interval; normalize topo, depending on +/- inf 
            $cmp < 0 ? {
                'x' => $is_new ? $x+0 : $x,
                'y' => $is_new ? $y+0 : $y,
                'q' => _eval_topo_proper($q,$x,$y) 
            } :

            # logically excluded; should only happen if we
            # get some wacked-out $cmp value that doesn't eval
            # to one of the above cases
            confess "invalid state" 

    }

    # invalid case 
    elsif (defined $x || defined $y)  { confess "corupted state" }

    # canonical empty 
    else  {  return { 'q' => $CLOSED }  }
}

# returns normalized topo flag, depending on +/- inf, given that
# x and y both exist and are in proper relation (x < y).
sub _eval_topo_proper  {
    my ($q,$x,$y) = @_;

    # XXX assert x < y
    trace3 "qxy = ",[$q,$x,$y];

    # possible shortcut; open always stays open
    # return $q if $q == $OPEN;

    my $xbdd =  $SVNINF < $x       ;
    my $ybdd =       $y < $SVPINF  ; 

    # return
    my $stat = 

        # as-is for bounded intervals
        $xbdd && $ybdd ? $q
        :
    
        # [x,+inf] => [x,+inf)   or 
        # (x,+inf] => (x,+inf)
        $xbdd ?
            $q == $CLOSED  ? $ROPEN : 
            $q == $RCLOSED ?  $OPEN : $q
        :

        # [-inf,y] => (-inf,y]  or 
        # [-inf,y) => (-inf,y)
        $ybdd ?
            $q == $CLOSED  ? $LOPEN : 
            $q == $LCLOSED ?  $OPEN : $q
        :

        # (-inf,+inf)
        $OPEN
    ;
    trace3 "stat = ",$stat;
    return $stat

}

#
# returns the canonical topology of the interval as evaluated. 
# note that in some cases this may be different from the assigned
# topology; but that's ok, too.
#
sub eval_topo  {
    my $self = shift;
    my ($z,$q) = $self->zq;
    return $CLOSED if defined $z;

    # binary cases
    my ($x,$y) = $self->xy;
    if (defined $x && defined $y)  {
        my $cmp = $x <=> $y;
        return

            # improper or degenerate 
            $cmp >=  0 ? $CLOSED 

            # depends on boundedness
            : _eval_topo_proper($q,$x,$y) 
    }

    # invalid case
    elsif (defined $x || defined $y)  { confess "corupted state" }

    # canonical empty 
    return $CLOSED
}


sub canonical { 
    $_[0]->_new( $_[0]->serial_eval_new )
}
sub is_canonical  { confess "not yet implemented"  }

# make instance canonical, ie physically equal to its eval serialization.   
# returns boolean status as to whether mods were made or not.
sub fixup  { 
    my $self = shift;
    if ($self->is_empty)  {
        $self->del_xyz;  return 1
    }
    my $q = $self->get_q;
    return '' if $q == $OPEN;

    my ($x,$y) = $self->get_xy;
    if ( $SVNINF == $x && $SVPINF == $y )  {
        $self->set_q($OPEN);  return 1
    }

    elsif ( $SVNINF == $x )  {
        if ( $q == $ROPEN  ) {  $self->set_q($OPEN);  return 1  }
        if ( $q == $CLOSED ) {  $self->set_q($LOPEN); return 1  }
        return ''
    }

    elsif ( $y == $SVPINF )  {
        if ( $q == $LOPEN  ) {  $self->set_q($OPEN);  return 1  }
        if ( $q == $CLOSED ) {  $self->set_q($ROPEN); return 1  }
        return ''
    }

    # fullly bounded cases:  no mods necessary 
    else  {  return '' }
}


#
# half-open constructors.  note that these are stricter
# than the boolean accesors of the same; so we can say
# 
# my $I = new Math::Interval->([2,3]) :LeftClosed;
# $I->is_right_open();  # true 
#
sub new_LeftClosed  { 
    $_[0]->new({ 
        'x' => $_[1], 'y' => $_[2], 'q' => $LCLOSED 
    })
};

sub new_LeftOpen  { 
    $_[0]->new({ 
        'x' => $_[1], 'y' => $_[2], 'q' => $LOPEN
    })
};

sub new_RightClosed  { 
    $_[0]->new({ 
        'x' => $_[1], 'y' => $_[2], 'q' => $RCLOSED 
    })
};

sub new_RightOpen  { 
    $_[0]->new({ 
        'x' => $_[1], 'y' => $_[2], 'q' => $ROPEN
    })
};

sub new_Open   { 
    $_[0]->new({ 
        'x' => $_[1], 'y' => $_[2], 'q' => $OPEN
    })
};

sub new_Closed   { 
    $_[0]->new({ 
        'x' => $_[1], 'y' => $_[2], 'q' => $CLOSED
    })
};

sub new_Empty   { 
    $_[0]->new({ 'q' => $CLOSED  })
};

sub new_Degenerate  {
    $_[0]->new({ 
        'z' => $_[1], 'q' => $CLOSED
    })
};

# to-do:  allow constructions off of a given type, e.g. BigInt.
sub new_Whole { 
    my ($class, $type) = @_;
    confess "typed constructions not yet implemented" if defined $type;
    $_[0]->new({ 
        'x' => $SVNINF, 'y' => $SVPINF, 'q' => $CLOSED
    })
}



# if the logical endpoints (x,y) are properly ordered. 
# for empty intervals, evaluates to false.
sub is_ordered  {
    my $self = shift;

    $self->is_empty      ? undef : 
    $self->is_unary      ? 1     : 
        $self->get_x <= $self->get_y

}
sub _assert_ordered  { confess "not yet implemented" }



# sub lower = \*left; 
# sub upper = \*right; 

#
# so-called display vector
#
# XXX $self->serial_canon first?
#
sub _display  {
    my $self = shift;
    my $q  = $self->get_q;
    my @bb = split//, q2b( $q );
    return (@bb, $self->xy)
}
        
# 'bra' and 'ket' are notations from quantum mechanics.  here, they
# have no fancy meaning, other than as cute a way of splittng the english
# word 'bracket' into two fixed-width subterms.  and because that  
# go that far, we might as well just drop the 'c' which was superfluous
# to begin with, anyway.
sub brakets  {
    my $self = shift;
    split//, q2b( $self->get_q )
}

sub bra { ($_[0]->brakets)[0] }
sub ket { ($_[0]->brakets)[1] }
*left_braket   = \&bra;
*right_braket  = \&ket;

sub stringify  {
    my $self = shift;
    my ($bra,$ket) = split//, q2b( $self->get_q );
    my $z = $self->get_z;
    return
        defined $z ? 
            $bra.$z.','.$z.$ket
        :
        $self->has_x && $self->has_y ? 
            $bra. $self->get_x .','. $self->get_y .$ket
        :
        $self->has_x || $self->has_y ? 
            confess "corrupted state"
        :
            $bra.$ket
    
}


sub is_open        {  confess "not yet implemented"  }
sub is_closed      {  confess "not yet implemented"  }
sub is_half_open   {  confess "not yet implemented"  }
sub is_half_closed {  confess "not yet implemented"  }

sub is_clopen {
    $_[0]->is_empty || $_[0]->is_whole
}


# 
# left- or right-closed if the left- or righ-complement is closed.
#
# caveat:  as a consequence, half-open intervals are both open -and- closed, 
# ie clopen, on their infinite side (since their left/right complements
# are empty).
#
sub is_right_open   { 
    my $self = shift;
    my @qxy = $self->eval_qxy;
    @qxy == 1 ? 1 : $qxy[0] == $ROPEN  || $qxy[0] == $OPEN    
}

sub is_left_open   { 
    my $self = shift;
    my @qxy = $self->eval_qxy;
    @qxy == 1 ? 1 : $qxy[0] == $LOPEN  || $qxy[0] == $OPEN    
}

sub is_right_closed { 
    my $self = shift;
    my @qxy = $self->eval_qxy;
    @qxy == 1 ? 1 : $qxy[0] == $RCLOSED  || $qxy[0] == $CLOSED 
}

sub is_left_closed { 
    my $self = shift;
    my @qxy = $self->eval_qxy;
    @qxy == 1 ? 1 : $qxy[0] == $LCLOSED  || $qxy[0] == $CLOSED 
    # $_[0]->is_empty             ||
    # $_[0]->get_q == $LCLOSED    ||
    # $_[0]->get_q == $CLOSED     ||
    # $_[0]->get_x  > $SVNINF 
}



#
# XXX some redundancy here, in that we already do inf comparisons in the 
# is_empty check - but at least the expression are simple enough.
#
sub is_bounded {
    $_[0]->is_empty ? undef :
    $SVNINF < $_[0]->get_x && $_[0]->get_y < $SVPINF
} 
sub is_whole {
    $_[0]->is_empty ? undef :
    $SVNINF == $_[0]->get_x && $_[0]->get_y == $SVPINF
} 

sub is_right_unbounded { $_[0]->is_empty ? undef : $_[0]->get_y == $SVPINF }
sub is_right_bounded   { $_[0]->is_empty ? undef : $_[0]->get_y  < $SVPINF }
sub is_left_bounded    { $_[0]->is_empty ? undef : $SVNINF  < $_[0]->get_x }
sub is_left_unbounded  { $_[0]->is_empty ? undef : $SVNINF == $_[0]->get_x }


# bounded on one end, but not the other
sub is_half_bounded {
    my $self = shift;
    $_[0]->is_empty ? undef : 
        $SVNINF < $_[0]->get_x xor $_[0]->get_y < $SVPINF
} 

#
# return true if the interval lazy-evaluates to the empty set,
# which in turn happens if one of the 3 holds:
#
#    - it's storage-empty
#    - it's improper ( x > y )
#    - it's a singleton, or singleton-equivalent ( x == y ), 
#      AND either not fully closed, or closed but the unary
#      endpoint is at +/- inf
#
sub is_empty  { 
    my $self = shift;
    my ($z,$q) = $self->zq;

    # unary case
    if (defined $z)  {
        return 
            $q == $CLOSED ?
                $z == $SVNINF || $z == $SVPINF 
            : 1
    }


    # binary cases
    my ($x,$y) = $self->xy;
    if (defined $x && defined $y)  {
        return
            # positive measure
            $x < $y  ? '' :
            # improper
            $x > $y  ? 1  :
            # x == y 
            # equivalent to singleton case
            $q == $CLOSED ?
                $x == $SVNINF || $y == $SVPINF 
            : 1
    }

    # invalid case
    elsif (defined $x || defined $y)  {
         confess "corrupted state"
    }

    # storage-empty 
    else { return 1 }

}

sub is_storage_empty  {
    my $self = shift;
    return !($self->has_x || $self->has_y || $self->has_z)
}

sub eval_qxy  {
    my $self = shift;
    my $s = $self->serial_eval_old;
    keys %$s == 1 ? ($s->{q} ) :
    keys %$s == 2 ? ($s->{q}, $s->{z}, $s->{z} ) :
    keys %$s == 3 ? ($s->{q}, $s->{x}, $s->{y} ) :
        confess "invalid state"
}

# -storage properties-
sub is_unary  {  $_[0]->has_z  }
sub is_binary {  $_[0]->has_x && $_[0]->has_y  }

# an interval is degenerate if it evaluates to a non-empty
# of cardinality 1 (ie, both endpoints are equal). 
sub is_degenerate  {
    my $self = shift;
    $self->is_empty ? '' :  # does most of the legwork 
    $self->has_z    ?  1 :  # shortcut to avoid costly x==y comp 
    $self->get_x == $self->get_y
}

sub cardinality  {
    my $self = shift;
    $self->is_empty      ? 0 :
    $self->is_degenerate ? 1 : 
    $SVPINF 
}

sub is_proper  { 
    my $self = shift;
    return !$self->is_empty && $self->get_x <= $self->get_y
}

sub is_improper       { !$_[0]->is_proper  } 


#
# JF Allen relational operators, extended naturally to open, closed, 
# and half-open sets, as well as free-floating elements - and defaulting
# to standard Allen behavior for two closed intervals. 
# 
# btw we recommend you NOT import these; use the corresponding
# allen_* methods in Math::Interval::Util instead.  these are also
# fully symmetric, and support all 4 cases
#
#   i,i -- interval,interval case 
#   i,e -- interval,element case 
#   e,i -- element,interval case 
#   e,e -- element,element case
#
# as opposed to the method ops, which only support the i,* cases.
#

sub is_lt  {
    my ($I, $J, $rv) = @_;
    { no warnings; trace3 "I = $I, J = $J, rv = $rv"; }
    # XXX fails on +inf
    return $rv ? $J->before($I) : $I->before($J)
}

sub is_gt  {
    my ($I, $J, $rv) = @_;
    { no warnings; trace3 "I = $I, J = $J, rv = $rv"; }
    # XXX fails on -inf
    return $rv ? $J->after($I) : $I->after($J)
}


#
# $I <= $J is NOT equivalent to ( $I < $J || $I == $J ),
#
# that is:  lt => le, eq => le, but we don't have le => lt || eq.
#
# what it means: 
#
#   $I <op> $J => for all s in I, for t in J, s <op> t holds.
#
#
# open question:  how to handle element comparisions, esp +-inf.
# we could say:  
#
#   I <op> x <=> I <op> [x]
#
# which would mean strange before for x == inf, because [inf] == []. 
#
# or we could say:
#
#   $I <op> x => for all s in I, s <op> x holds
#
# which would be more DWIM-y wrt inf.
#


#
# I <= J if I and J if { s <= t } for all s in I, t in J.
# as a consequence, either I must be before J, or I and J must 
# be just-touching from the left.
#
sub is_le  {
    my ($I, $J, $rv) = @_;
    { no warnings; trace3 "I = $I, J = $J, rv = $rv"; }
    return $rv ? 
        $J->before($I) || $J->meets($I) : 
        $I->before($J) || $I->meets($J) 
}

sub is_ge  {
    my ($I, $J, $rv) = @_;
    { no warnings; trace3 "I = $I, J = $J, rv = $rv"; }
    return $rv ? 
        $J->after($I) || $J->imeets($I)  :
        $I->after($J) || $I->imeets($J)
}

#
# Allen Operations
#
# we break convention and use $I instead of $self, to provide
# more symmetric internal notation.  
#

# equivalent to "less than":
# 
#   [2,3] is before (3,4], but not [3,4].
#
# XXX:  what to do about +inf?
#
sub before {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }

    return

        # i,i
        is_interval($J) ? 
            $I->is_empty || $J->is_empty ? '' : 
                $I->is_right_open || $J->is_left_open ?
                    $I->get_y <= $J->get_x :
                    $I->get_y <  $J->get_x

        # i,e
        :
            $I->is_empty ? '' : 
                $I->is_right_open ?
                    $I->get_y <= $J : 
                    $I->get_y <  $J

}


# equivalent to "greater than"
sub after {
    my ($I, $J, $rv) = @_;
    {
        no warnings;
        trace2 "I = $I, J = $J, rv = $rv"; 
    }
    confess "rv case not yet implemented" if $rv;

    return

        # i,i
        is_interval($J) ? 
            $I->is_empty || $J->is_empty ? '' : 
                $J->is_right_open || $I->is_left_open ?
                    $J->get_y <= $I->get_x :
                    $J->get_y <  $I->get_x 

        # i,e
        :
            $I->is_empty ? '' : 
                $I->is_left_open ?
                    $J <= $I->get_x :
                    $J <  $I->get_x 

}


#
# I meets J iff I->y == J->x and I intersect J is non-empty. 
# note that as a consequence, the intersection will also be
# degenerate.
#
sub meets {
    my ($I, $J) = @_;
    _inspect('I' => $I, 'J' => $J);

    return

        # i,i
        is_interval($J) ? 
            $I->is_empty || $J->is_empty ? '' : 
                $I->is_right_closed && $J->is_left_closed ?
                    $I->get_y == $J->get_x 
                : ''

        # i,e
        :
            $I->is_empty ? '' : 
                $I->is_right_closed ?
                    $I->get_y == $J 
                : ''

}

sub imeets {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }

    return

        # i,i
        is_interval($J) ? 
            $I->is_empty || $J->is_empty ? '' : 
                $J->is_right_closed && $I->is_left_closed ?
                    $J->get_y == $I->get_x 
                : ''

        # i,e
        :
            $I->is_empty ? '' : 
                $I->is_left_closed ?
                    $J == $I->get_x 
                : ''

}

#
# we say I just-meets J iff I and J are disjoint, 
# but closure(I) meets closure(J).
#
# or that is, "I just-touches J from the left".
#
sub just_meets {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }

    return

        # i,i
        is_interval($J) ? 
            $I->is_empty || $J->is_empty ? '' : do { 
                my $irc = $I->is_right_closed;
                my $jlc = $J->is_left_closed;
                $irc && $jlc ? '' :  # must be disjoint
                $irc || $jlc ? 
                    $I->get_y == $J->get_x 
                : ''
            }

        # i,e
        :
            $I->is_empty ? '' : 
                $I->is_right_open ?
                    $I->get_y == $J 
                : ''

}

# we say I just-imeets J (or I is "just met by" J) iff 
# I and J are disjoin, and  closure(I) imeets (is met by) closure(i).
#
sub just_imeets {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }

    return

        # i,i
        is_interval($J) ? 
            $I->is_empty || $J->is_empty ? '' : do { 
                my $ilc = $I->is_left_closed;
                my $jrc = $J->is_right_closed;
                $ilc && $jrc ? '' :  # must be disjoint
                $ilc || $jrc ? 
                    $J->get_y == $I->get_x 
                : ''
            }

        # i,e
        :
            $I->is_empty ? '' : 
                $I->is_right_open ?
                    $J == $I->get_x 
                : ''

}



sub overlaps {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }

    return
        # i,i
        is_interval($J) ? 
            $I->is_empty || $J->is_empty ? '' : 
                $I->is_right_closed && $J->is_left_closed ?
                    $I->get_y < $J->get_y &&
                    $I->get_x < $J->get_x 
                : ''

        # i,e
        :
            $I->is_empty ? '' : 
                $I->is_right_closed ?
                    1 # XXX wrong!
                : ''

}

# ...at this point it became clear that we were going to need to write
# a full-fledged combinatorial unit test suite, with some 4000+ cases.
# not too hard, being as there are some nifty loops and symmetries to
# generate these cases, but it still needs to be done.

sub ioverlaps {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }
    confess "not yet implemented"  
}
sub starts {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }
    confess "not yet implemented"  
}
sub istarts {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }
    confess "not yet implemented"  
}
sub during {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }
    confess "not yet implemented"  
}
sub iduring {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }
    confess "not yet implemented"  
}
sub finishes {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }
    confess "not yet implemented"  
}
sub ifinishes {
    my ($I, $J) = @_;
    { no warnings; trace3 "I = $I, J = $J"; }
    confess "not yet implemented"  
}


sub equals    {  
    my ($I, $J, $rv) = @_;
    { no warnings; trace2 "I = $I, J = $J, rv = $rv"; }

    # $foo == $I case, where $foo is a non-interval; always false. 
    # use "contains_only" instead.
    return '' if $rv;

    if (is_interval($J))  {
        my $ie = $I->is_empty;
        my $je = $J->is_empty;
        return $ie && $je if $ie || $je;
        my ($iq,$ix,$iy) = $I->eval_qxy;
        my ($jq,$jx,$jy) = $J->eval_qxy;
        trace3 "I = ",[$iq,$ix,$iy];
        trace3 "J = ",[$jq,$jx,$jy];
        return $iq == $jq && $ix == $jx && $iy == $jy
    }  
    else  { 
        return '' 
    }
}

#
# warning!  intervals are NOT totally ordered, so we -can't- come up
# with an exclusive set of return values -1,0,+1.  best we can do is come 
# up with a third symbol, '' that means 'none of the above' and which 
# evaluates to false (and we don't want to return undef, for general 
# interface considerations). 
#
sub compare   {  
    my ($I, $J, $rv) = @_;
    { no warnings; trace2 "I = $I, J = $J, rv = $rv"; }

    return $rv ?
        $J->before($I) ? +1 :
        $J->after ($I) ? -1 :
        $J->equals($I) ?  0 : 
        '' 
    :
        $I->before($J) ? -1 :
        $I->after ($J) ? +1 :
        $I->equals($J) ?  0 : 
        '' 
}


# generalizations to half-open sets
sub just_starts    {  confess "not yet implemented"  }
sub just_istarts   {  confess "not yet implemented"  }
sub just_finishes  {  confess "not yet implemented"  }
sub just_ifinishes {  confess "not yet implemented"  }

# Non-Allen relations
# sub omits (point|ival)
# sub touches () 
# sub contains (point|ival)
sub just_touches   {  confess "not yet implemented"  }

sub contains_only  {
    my ($self,$t) = @_;
    defined $t && $self->is_degenerate && $self->get_x == $t
}



# functional ops
sub abs {} 
sub center {} 

#
# XXX couple of major caveats with this method: 
#
# - for one, it naively attempts to compute the midpoint, even if the 
#   underlying type, e.g. BigInt or DateTime may or may not suppport 
#   that resolution (depending on configuration).
#
# - for another, even for types that do, theoretically, have sufficient 
#   resolution to support the "true" midpoint of (x,y), the expression we 
#   use, (x+y)/2, is known to be unstable, and might return NaN for cases
#   where x+y generates an overflow.
# 
#   the simplest alternative, x+(y-x)/2, while theoretically more safe 
#   against overlows, suffers from directional bias, and is considerably 
#   more expensive for bigints and bigrats (and in particular, is just
#   as likely to blow up for bigrats where the denominators happen to 
#   be both coprime and very large.)
#
# unfortunately there just aren't good/reliable ways to detect these
# problem cases a priori, so the best we can do is state these caveats. 
# we also provide the "midpoint_via" so you can at least provide a 
# custom midpoint op, if so inclined.
#
# note that the endoint is undefined for empty, whole, or unbounded
# (infinite and half-infinite) cases.
#    
#  

sub midpoint  {
    my $self = shift;
    $self->midpoint_via (
        sub { ( $_[0] + $_[1] ) / 2 }
    )
} 

sub midpoint_via  {
    my ($self, $code) = @_;
    assert_code_ref($code);
    $self->is_empty      ? undef :
    $self->is_degenerate ? 0+$self->get_x : do {
        my ($x,$y) = $self->get_xy;
        $x == $SVNINF || $y == $SVPINF ? undef :
            $code->( $self->get_x, $self->get_y )
    }
} 


# metric operations
sub width    {
    my $self = shift;
    $self->is_empty      ? undef :
    $self->is_degenerate ? 0     : 
        $self->get_y - $self->get_x
} 

# similar caveats as to midpoint() w.r.t. rounding.
sub radius   { 
    my $self = shift;
    $self->is_empty ? undef : $self->width / 2 
}

# TODO
sub integer_width {} # number of integers contained
sub distance {}      # distance between two intervals == abs position
sub position {}      # like distance, but signed to indicate ordering 
sub omeasure {}      # signed overlap measure (signed) 
# sub width = \*diameter;


# shared "basetype" of the interval's endpoints.  e.g. if they're both
# bigrats, we'd like to have an easy way of knowing that.  it gets kind of 
# tricky though, being as if X and Y are of two different object types,
# then we'd like to know their nearest common ancestor B (if any)...
# which is slightly tricky to derive, in Perl.
sub basetype  {
    my $self = shift;
    confess "not yet implemented"
}


#
# TODO - left as stubs for now
#


#
# math ops
#
# caveats:
#
# observing that in point-wise arithmetic in Perl, undef is eval'd to 0 
# (but generates a warning) in arithmetic ops, we'd be tempted to provide
# an analogous treatment for interval comparisons.
#
# we don't (explanation needed -- no "natural zero" in i-arithemetic).
#

#
# cloning & forking ops - methods that return new intervals 
#
# slightly tricky because the basetype of the newly created 
# intervals has to agree with that of object(s) it was derived
# from.
#

#
# standard set-theoretic ops
#
sub set_minus     { confess "not yet implemented" } 
sub set_union     { confess "not yet implemented" } 

# union of two disjoint, but just-touching intervals
sub set_adjoin      { confess "not yet implemented" } 
sub set_adjoin_dir  { confess "not yet implemented" } 

sub set_overlap     { confess "not yet implemented" } 
*intersect = \&set_overlap;

# convex hull of two intervals, ie, smallest interval containing both.
# also sometimes referred to as the -interval enclosure- or -interval span- 
sub set_hull     { confess "not yet implemented" } 


#
# 'closure' and 'interior' are cloning unary ops that return
# new intervals as defined in the usual set-theoretic senses
# of those terms:
#
#  my $J = $I->closure;   # J = smallest closed interval containing I
#  my $J = $I->interior;  # J = largest open interval contained in I
#
# the new interval is always returned in canonical form.
#
sub closure   { confess "not yet implemented" }
sub interior  { confess "not yet implemented" }

# left and right complemements, wrt unbounded interval, (-inf,+inf).
# depends on implicit basetype, which is not yet implemented 
sub right_complement { confess "not yet implemented" }
sub left_complement  { confess "not yet implemented" }

# both L and R complements
sub complements  {
    ( $_[0]->left_complement, $_[0]->right_complement ) 
}



#
#  -- arithmetic --
#


sub plus  {
    my ($I, $J, $rv) = @_;
    { no warnings; trace2 "I = $I, J = $J, rv = $rv"; }
    return _plus_left ($J,$I) if $rv;

    confess "invalid usage:  instance method only" unless is_interval($I);

    if ( is_interval($J) )  {
        return _plus_ival ($I,$J)
    }
    else  {
        return _plus_right ($I,$J)
    }

}

# separte left- and right- addition cases, so as to expose possibly 
# buggy (assymetric) implementations for member objects, even though 
# these will in theory be arithmetically equivalent. 
#

# J is element, I is inteval; called as J + I, then I->plus(J,1)
sub _plus_left  {
    my ($j, $I) = @_;

    confess "invalid usage" unless is_interval($I);
    confess "invalid usage" if     is_interval($j);
    return $I->new_Empty if $I->is_empty;

    my $K = $I->new({ 'q' => $I->get_q });
    if ( $I->has_z)  {
        $K->set_z( $j + $I->get_z )
    } 
    elsif ( $I->has_x && $I->has_y )  {
        $K->set_x( $j + $I->get_x );
        $K->set_y( $j + $I->get_y );
    }
    elsif ( $I->has_x || $I->has_y )  {
        confess "corrupted state"
    }
    # storage-empty case; cheerfully pass same along.
    else  { }
    $K->fixup;
    return $K
}

sub _plus_right  {
    my ($I, $j) = @_;

    confess "invalid usage" unless is_interval($I);
    confess "invalid usage" if     is_interval($j);
    return $I->new_Empty if $I->is_empty;

    my $K = $I->new({ 'q' => $I->get_q });
    if ( $I->has_z)  {
        $K->set_z( $I->get_z + $j )
    } 
    elsif ( $I->has_x && $I->has_y )  {
        $K->set_x( $I->get_x + $j);
        $K->set_y( $I->get_y + $j);
    }
    elsif ( $I->has_x || $I->has_y )  {
        confess "corrupted state"
    }
    # storage-empty case; cheerfully pass same along.
    else  { }
    $K->fixup;
    return $K
}


# so... mixed degen-nondegan cases?
sub _plus_ival  {
    my ($I,$J) = @_;
    confess "interval-to-interval ops not yet supported" ;
}



sub _inspect  {
    my %args = @_;
    no warnings 'uninitialized';
    for my $k (keys %args)  {
        my $v = $args{$k};
        trace3 "$k = $v ",{
            'ref'    => ref $v,
            'isa'    => is_interval($v), 
            'serial' => is_interval($v) ? $v->serial_asis : 'n/a'
        }
    }
}

1;

__END__


        #
        # valid case of $I < $J, where $J is an interval but $I is not: 
        #
        # is_interval($J) ? $J->before($I) 

        #
        # if we make it here, then neither I nor J are intervals.
        # this brings up a perennial point about the distinction 
        # between 'instance' and 'parametric' comparisons, that
        # applies to several other ops besides this one.
        #
        # we could call the parametric equivalent, in situations like
        # these -- ie allen_before(), in this case -- but we choose to 
        # bail instead, for two reasons:  (1) the "is_op" functions 
        # are intended to be invoked as -instance- methods only, 
        # so logically the case of neither I nor J being interval 
        # instances should never happen, unless someone went and did
        #
        #   Math::Interval::is_lt($foo,$bar)
        #
        # which is asking for trouble; and (2) we don't want to
        # risk falling into a deep-recursion situation that would
        # result from either of the instance or parametric methods 
        # being improperly programmed.
        #
        # : confess "instance method only - use allen_before instead" 



Interval::Projective - includes unsigned +/- inf; happily divides by 0 
Interval::Extended - includes (-inf,+inf)
Interval::Bounded  - excludes (-inf,+inf)


use cases:
intlike - Number::RGB
signed zeros?
smallest epsilon?
biggest x < +inf?
use integer
bigint, bigfloat, bigrat
intervals-of-intervals (circular?)

storable
readonly
dualvar


test vectors(?):
[-1,0] x [5,+inf] = [-inf,0]


degeneracy
= contains a single real number

emptiness
(a,a) = [a,a) = (a,a] = empty set
[a,b] where a > b for all variants [],(),[),(] = empty set

IEEE Interval Standard  P1788


=head1 NAME

=head1

=head1 CAVEATS

=head2 Topological considerations

=item clopen intervals
=item circular intervals
=item projective infinity


=head1 REFERENCES

=cut
=cut





