#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use POSIX;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

my @uname = POSIX::uname();
if($uname[4] =~ m/ubuntu/i) {
  plan( skip_all => "Mysql on Ubuntu does not work due to Apparmor restrictions" );
} else {
  plan( tests => 28 );
}

##################################################
# create our test site
my $omd_bin = TestUtils::get_omd_bin();
my $site    = TestUtils::create_test_site() or BAIL_OUT("no further testing without site");

##################################################
# execute some checks
my $tests = [
  { cmd => $omd_bin." config $site set MYSQL on" },
  { cmd => $omd_bin." config $site show MYSQL",  like => '/on/', 'unlike' => [ '/error/', '/off/' ] },
  { cmd => $omd_bin." start  $site" },
  { cmd => $omd_bin." status $site",             like => '/mysql:\s*running/' },
  { cmd => "/bin/su - $site -c 'mysql mysql'", stdin => "show tables;\n", like => [ '/user/', '/tables_priv/' ] },
  { cmd => $omd_bin." stop   $site" },
];
for my $test (@{$tests}) {
    TestUtils::test_command($test);
}

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
