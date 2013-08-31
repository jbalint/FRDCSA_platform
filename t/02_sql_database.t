use strict;
use warnings;
use Test::More;

require_ok('Org::FRDCSA::Platform::SQLDatabase');

my $db = Org::FRDCSA::Platform::SQLDatabase->connect('02_sql_database');

done_testing();
