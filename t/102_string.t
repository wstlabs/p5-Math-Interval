# -*- perl -*-


use Test::More;
use Math::Interval;

{
# ugh - "possible attempt to separate with commas"
no warnings;

# parseable
our @s = qw|
        [2,3)
        (2,3]
        (2,3)
        [2,3]
        [2,2]     
        [2,inf)
        (-inf,2]
        [2,-inf)
        (inf,2]
        [2,inf] 
        []
    |;

our @junk = qw|
        (2,3(
        ]2,3]
        ]2[
        [[
        ]] 
        [2,3]]
        [2,]
        [,3]
        [,]
        [,,]
        [,,,]
        [,2,]
    |;


our @collapse = qw|
        [+2,3]   [2,3]
        [2]      [2,2]
    |;
}


plan tests => scalar @s + @collapse / 2;

for my $s (@s)  {
    is ( Math::Interval->new($s)->stringify, $s, "$s" );
} 

while (@collapse)  {
    my $k = shift @collapse;
    my $v = shift @collapse;
    is ( Math::Interval->new($k)->stringify, $v, "$k => $v" );
}




