# simple API test for Org::FRDCSA::Platform::ConfigLoader
use strict;
use warnings;
use Test::More;

require_ok("Org::FRDCSA::Platform::ConfigLoader");
my $config = Org::FRDCSA::Platform::ConfigLoader->new->getConfig("my_app");
print $config->{someConfigurationVar} || "";

done_testing();
