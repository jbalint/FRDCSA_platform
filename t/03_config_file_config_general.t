# Config::General file format test for Org::FRDCSA::Platform::ConfigLoader
use Test::More;

require_ok('Org::FRDCSA::Platform::ConfigLoader');
my $configLoader = Org::FRDCSA::Platform::ConfigLoader->new;
$configLoader->searchPaths(['t']); # test conf in test dir
my $config = $configLoader->getConfig('03_config_file_config_general');
ok($config);
is($config->{block}->{x}, 1);
is($config->{block}->{z}, 2);
is($config->{block}->{wine}, 'Red');
is($config->{block}->{music}, 'Good');
is($config->{block}->{subblock}->{Named}->{y}, 44);

done_testing();
