# simple API test for Org::FRDCSA::Platform::Config
use Test::More;

require_ok("Org::FRDCSA::Platform::Config");
my $config = Org::FRDCSA::Platform::Config->getConfig("my_app");
print $config->{someConfigurationVar} || "";

done_testing();
