

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Math-Interval',
    VERSION_FROM => 'lib/Math/Interval.pm', # finds \$VERSION
    AUTHOR       => 'WST ( null@nobody.org )',
    ABSTRACT     => 'Module abstract (<= 44 characters) goes here',
    PREREQ_PM    => {
        'Assert::Std' => 0.001,
        'Test::Simple'  => 0.44,
        'Test::More'    => 0.31,
        'Log::EZ'   => 0.001,
        'Readonly'  => '1.03',
        'Scalar::Util' => 1.23,
        'Exporter::Tidy' => 0.07,
    }
);

