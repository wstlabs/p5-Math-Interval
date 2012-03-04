Math::Interval
--------------

A class representing the usual mathematical notion of an interval over any (topologically complete) ordered field, providing as complete a set of basic set-theoretic operations as are practical and useful.  

Currently this module is a work in progress; about 60% complete.  

Features
========

By "interval" we man the usual notion from your first year calculus class with all the sweet, wholesome that comes to mind:  open, closed, and half-open intevals, intervals including points at infinity (or not), degenerate intervals, etc:
  
     $I = Math::Interval->new("(2,4)");
     $J = Math::Interval->new("[3,+inf)");
     $K = $I->union($J);      # (2,+inf) 
     $L = $I->intersect($J);  # [3,4)

All the usual set-theoretic operations apply:  we can create unions or intersections of intervals; we can derive the closure, or the interior of an interval. 

Math::Interval objects can also be created from alternive numeric constructs (such as bigints, bigrats, and bigfloats) as well as from non-numeric objects (like DateTime or Benchmark objects); and can be constructed from non-homogenous pairings of such objects as well.  Only constraints are:  (1) undefined endpoints are not allowed, as are NaN-equivalent values; and (2) whatever the initial basetype, it needs to support the basic comparator operations ( <, >, <=>, ==, != ) that apply to regular perl scalars.   

There is also a suite of lesser-known operations known as "Allen Relations" provide by James F. Allen in 1983:  predicates such as

    I before J
    I meets J
    I overlaps J

indicating what they intuitively mean in the sense of temporal intervals.  Allen's definition implicitly dealt only with strictly closed intervals (of the form [x,y]); most notably they omit any notion of intervals with are "just touching" as in the case of
  
    [x,y) just_touches [y,z)  # where x < y < z 

so we've provide appropriate analogies of Allens' initial 14 operations  for open and half-open intervals (as well as for degenerate intervals).

Caveats
=======

First there are the mathematical caveats:  the basic idea is that the constructor is interpreted as providing arguments to what set-theorists call the "builder notation" for intervals, that is:
  
    $I = Math::Interval->new_RightOpen($a,$b);

is mathematically equivalent to
   
    { all x s.t. a <= x and x < b }

no matter what values of a and b are given; that is, since the conventional set-theoretic definition is fully GIGO on this point, so is our constructor.  

Also, infinity behaves differently as an endpoint:  that's because strictly speaking "infinity", in the context of an interval, is not a member of our underlying base field, but a de-facto logical quantifier.  So when we try to construct our interval [2,inf), i.e.: 
  
     $I = Math::Interval->new("[2,inf)"); 

we might think we're saying

    { all x s.t. a <= x and x < b }

but what we're really telling the construct is "ignore the second endpoint", i.e.:

    { all x s.t. a <= x }

Among the consequences is that, with our intervals (as in conventional set-theoretic notation), we have
 
    [2,inf) == [2,inf]

we also have that [2,inf) is considered to be a fully closed interval, ie 

    Math::Interval->new("[2,inf)")->is_closed

evaluates to 1.  Also, our interval faithfully represent the topological nature of entire (or bi-infinite) intervals:  so not only is 
  
    [-inf,inf] == [-inf,inf) == (-inf,inf] == (-inf,+inf)

but the bi-infinite interval is in fact, both closed and open.

The way to make this all work is to have Interval objects always be lazy-evaluated: this is because it's essentially impossible to fully encapsulate the state of an interval's endpoints (even if the underlying storage class it itself fully encapsulated, like Math::Interval::Store::Std).  This is because once you've created, say, an interval out of two bigints, say:
    
    $I = Math::Interval->new_RightOpen($x,$y);

there's nothing to stop you from decrementing (or subtracting) from $y until it is less than $x -- at which point is no longer "right-closed", but in fact empty.  

So in fact, every time an Interval is compared to (or subject to an arithmetic or set-theoretic operation), it is lazy-evaluated, in place. 

Storage also ends up being a not entirely trivial consideration:  one of the properties of the Interval interface is that it happily lets you set the same object reference to both endpoints: 

    $I = Math::Interval->new_Closed($x,$x);   # [x,x]

which is equivalent to 

    $I = Math::Interval->new_Closed($x);   # [x]

and in fact it is often desirable to do so (in cases where the underlying basetype is very expensive -- a bigint or a bigrat, say).  

In such cases, the intervals, while topologically equivalent, will have different storage representations (and will serialize differently, also).  But it all works out at the end; main thing is that interval objects DWYM, robustly, in both senses.

Status
======

Work was begun in a few weekends in Januray and 2010, and put on pause.  One thing I noticed was that in order to rigorously test the Allen relations (and their extensions for non-closed intervals), we'll need about some 4000+ combinatorial cases to exercise all meaningful interval pairings.  Not to difficult to generate (and in fact there are some nice combinatorial loops for this, but still, it needed to be done).  

And since this actually looks like a good application of TDD, I resolved to generate the remaining cases before implementing the last 7 or 8 Allen relations (na the 6 or so extenions) remaining.

Nonetheless, a goodly number of test cases have been implemented by hand; these are available under the usual t/ directory.

Todo
====

* combinatoiral cases
* polymorphics cases
* autoboxing, i.e. "[2,5)"->intersect("(3,7]")
* attribute notation for constructors 

Links
=====

* <http://en.wikipedia.org/wiki/Interval_(mathematics)>
* <http://en.wikipedia.org/wiki/Allen's_Interval_Algebra>
