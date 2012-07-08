package Math::Interval::Store::Std;
use strict;
use warnings;
use Assert::Std                qw( :types );
use Assert::Numeric            qw( is_nan );
use Scalar::Util               qw( refaddr );
use Carp                       qw( confess );
use parent 'Math::Interval';
# use Log::EZ;

{
    my (%X,%Y,%Z,%Q);

    # 
    # asis acccessors - ro
    #
    sub has_q  { exists $Q{ refaddr shift } }
    sub has_x  { exists $X{ refaddr shift } }
    sub has_y  { exists $Y{ refaddr shift } }
    sub has_z  { exists $Z{ refaddr shift } }

    sub _get_xyzq  {
        my $id = refaddr shift;
        return ( $X{ $id }, $Y{ $id }, $Z{ $id }, $Q{ $id } ) 
    }

    sub del_xyz  { 
        my $id = refaddr shift;
        delete $X{ $id }; delete $Y{ $id }; delete $Z{ $id }; 
        return
    }

    # XXX assumes x,y,z are either scalars or distinct references.
    sub total_size  {
        my $self = shift; 
        require Devel::Size;
        my $sz = Devel::Size::total_size($self);
        $sz += Devel::Size::total_size($self->get_x) if $self->has_x; 
        $sz += Devel::Size::total_size($self->get_y) if $self->has_y; 
        $sz += Devel::Size::total_size($self->get_z) if $self->has_z; 
        $sz += Devel::Size::total_size($self->get_q) if $self->has_q; 
        return $sz
    }

    sub member_sizes  {
        my $self = shift; 
        return { 
            'id'  => Devel::Size::total_size($self),
            $self->has_x ? ('x' => Devel::Size::total_size($self->get_x)) : (),
            $self->has_y ? ('y' => Devel::Size::total_size($self->get_y)) : (),
            $self->has_z ? ('z' => Devel::Size::total_size($self->get_z)) : (),
            $self->has_q ? ('q' => Devel::Size::total_size($self->get_q)) : ()
        }
    }


    #
    # logical accessors
    # these need to maintain contract on X, Y, Z 
    #

    #
    # note that we make an implementation-specific decision 
    # to set q to a scalar copy; this is because their typical
    # usage is to set to copies of readonly values, which brings
    # essentially no benefit in the inside-out case (because these
    # values are still easily mutable), but casting to non-ro
    # scalars saves us 32 bytes, or about 1/4 of the overall 
    # storage profile.
    #
    # if this were a readonly impl, then we'd stay with the 
    # readonly assignments, of course. 
    #
    sub get_q  {  $Q{ refaddr shift } }
    sub set_q  {
        my ($self, $q) = @_; 
        confess "need a quantifier flag" unless defined $q;
        confess "bad quantifier flag" 
            unless $q eq $q+0 && 0 <= $q && $q <= 3;
        # see note above
        $Q{ refaddr $self } = 0+$q 
    }

    sub get_x  {
        my $self = shift; 
        my $id = refaddr $self;
        my ($x,$y,$z) = ( $X{$id}, $Y{$id}, $Z{$id} );

        # unary case
        defined $z ?
            defined $x ? confess "corrupted state" : 
            defined $y ? confess "corrupted state" : 
            $z

        # binary case
        : defined $x && defined $y ? $x 

        # invalid case
        : defined $x || defined $y ? confess "corrupted state" 
        
        # empty case
        : undef 
    }

    sub set_x  {
        my ($self, $x) = @_; 
        my $id = refaddr $self;
        confess "need a left endpoint" unless defined $x;
        confess "can't set endpoint to NaN" if is_nan($x); 

        # unary => binary
        if ( defined $Z{$id} )  {
            confess "corrupted state" if 
                defined $X{$id} || defined $Y{$id};
            $Y{$id} = delete $Z{$id}; 
            $X{$id} = $x
        }

        # binary case:  mutate left
        elsif ( defined $X{$id} )  {
            confess "corrupted state" unless defined $Y{$id}; 
            $X{$id} = $x
        }

        # imbalanced case 
        elsif ( defined $X{$id} )  { 
            confess "corrupted state"
        }

        # empty case:  unary init
        else  {  
            $Z{$id} = $x
        }

        return $x
    }

    sub get_y  {
        my $self = shift; 
        my $id = refaddr $self;
        my ($x,$y,$z) = ( $X{$id}, $Y{$id}, $Z{$id} );

        # unary case
        defined $z ?
            defined $y ? confess "corrupted state" : 
            defined $x ? confess "corrupted state" : 
            $z

        # binary case
        : defined $y && defined $x ? $y 

        # invalid case
        : defined $x || defined $y ? confess "corrupted state" 
        
        # empty case
        : undef 
    }

    sub set_y  {
        my ($self, $y) = @_; 
        my $id = refaddr $self;
        confess "need a right endpoint" unless defined $y;
        confess "can't set endpoint to NaN" if is_nan($y); 

        # unary => binary
        if ( defined $Z{$id} )  {
            confess "corrupted state" if
                defined $Y{$id} || defined $X{$id};
            $X{$id} = delete $Z{$id}; 
            $Y{$id} = $y
        }

        # binary case:  mutate left
        elsif ( defined $Y{$id} )  {
            confess "corrupted state" unless defined $X{$id}; 
            $Y{$id} = $y
        }

        # imbalanced case 
        elsif ( defined $X{$id} )  { 
            confess "corrupted state"
        }

        # empty case:  unary init
        else  {  
            $Z{$id} = $y
        }

        return $y
    }


    sub get_z  {
        my $self = shift; 
        my $id = refaddr $self;
        defined $Z{$id} ?
            defined $X{$id} ? confess "corrupted state" :
            defined $Y{$id} ? confess "corrupted state" :
            $Z{$id}
        : undef
    }

    sub set_z  {
        my ($self, $z) = @_; 
        my $id = refaddr $self;
        confess "need a common endpoint" unless defined $z;
        confess "can't set endpoint to NaN" if is_nan($z); 
        delete $X{$id};
        delete $Y{$id};
        return $Z{$id} = $z
    }

    sub get_xy  {
        my $self = shift; 
        my $id = refaddr $self;
        my ($x,$y,$z) = ( $X{$id}, $Y{$id}, $Z{$id} );

        # unary case
        defined $z ?
            defined $y ? confess "corrupted state" : 
            defined $x ? confess "corrupted state" : 
            ($z,$z) 

        # binary case
        : defined $x && defined $y ? ($x,$y) 

        # confess "invalid case
        : defined $x || defined $y ? confess "corrupted state" 

        # empty case
        : ()
    }

    sub set_xy  {
        my ($self, $x, $y) = @_; 
        my $id = refaddr $self;
        confess "need a left endpoint"  unless defined $x;
        confess "need a right endpoint" unless defined $y;
        # trace { asis => $self->asis  };

        # unary => binary
        if ( defined $Z{$id} )  {
            confess "corrupted state" if
                defined $X{$id} || defined $Y{$id};
            $X{$id} = $x;
            $Y{$id} = $y;
            delete $Z{$id}
        }

        # binary case
        elsif ( defined $X{$id} && defined $Y{$id} )  {
            $X{$id} = $x;
            $Y{$id} = $y
        }

        # invalid case 
        elsif ( defined $X{$id} || defined $Y{$id} )  {
            confess "corruptd state"
        }

        # empty case
        else  {  
            $X{$id} = $x;
            $Y{$id} = $y
        }

        return ($X{$id},$Y{$id})
    }

    sub DESTROY  {
        my $id = refaddr shift;
        delete $X{ $id };
        delete $Y{ $id };
        delete $Z{ $id };
        delete $Q{ $id };
        1
    }
}

sub new {
    my ($class,$spec) = @_;
    assert_hash_ref($spec);
    my $ival = bless \do { my $foo = 1 }, $class;
    my ($x,$y,$z,$q) = @{$spec}{qw/ x y z q /};

    # always set quantifier
    $ival->set_q($q);

    # unary case
    if ( defined $z )  {
        defined $x || defined $y 
            ? confess "invalid spec" 
            : $ival->set_z($z) 
    }

    # binary case
    elsif ( defined $x && defined $y )  {
        $ival->set_xy($x,$y)  
    }

    # invalid case
    elsif ( defined $x || defined $y ) {
        confess "invalid spec" 
    }

    # empty case
    else  { }

    $ival
}


1


