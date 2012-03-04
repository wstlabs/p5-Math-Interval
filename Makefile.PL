

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Math-Interval',
    VERSION_FROM => 'lib/Math/Interval.pm', # finds \$VERSION
    AUTHOR       => 'null@nobody.org',
    ABSTRACT     => 'Module abstract (<= 44 characters) goes here',
    PREREQ_PM    => {
        'Assert::Types' => 0,
        'Test::Simple'  => 0.44,
        'Test::More'    => 0,
        'Log::Inline'   => 0,
    }
);

