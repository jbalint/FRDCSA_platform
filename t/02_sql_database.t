use strict;
use warnings;
use Test::More;

require_ok('Org::FRDCSA::Platform::SQLDatabase');

my $db = Org::FRDCSA::Platform::SQLDatabase->new({configPath => 't'});

done_testing();
