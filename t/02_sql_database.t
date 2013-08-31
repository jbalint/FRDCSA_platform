# very basic test for SQL database module
# see test configuration in t/Org_FRDCSA_Platform_SQLDatabase.conf
use strict;
use warnings;
use Test::More;

require_ok('Org::FRDCSA::Platform::SQLDatabase');

my $db = Org::FRDCSA::Platform::SQLDatabase->new( { configPath => 't' } );
$db->connect('test');

# create a simple table for testing
$db->executeUpdate('drop table if exists sqldb_test1');
$db->executeUpdate(
    'create table sqldb_test1(x int, y varchar(10), primary key (x))');

# insert some data
my $yValue = 'why oh why';
my $newKey =
  $db->executeInsert( 'insert into sqldb_test1 (y) values (?)', [$yValue] );

# check the new key value
is( 0, $newKey );

# make sure we can find it by key
my $row = $db->findRecordById( 'sqldb_test1', 'x', $newKey );
is( $newKey, $row->{x} );
is( $yValue, $row->{y} );

# clean up
$db->executeUpdate('drop table sqldb_test1');

$db->disconnect();

# connect several times successively
$db->connect('test');
$db->connect('test');
$db->connect('test');
$db->connect('test');
is( 'test', $db->currentDatabaseName );
$db->disconnect();

# TODO error testing

done_testing();
