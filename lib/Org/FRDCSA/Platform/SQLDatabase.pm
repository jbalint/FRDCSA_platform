use strict;
use warnings;
package Org::FRDCSA::Platform::SQLDatabase;
# ABSTRACT: sql database access

use Error;
use Org::FRDCSA::Platform::Config;

my $config = Org::FRDCSA::Platform::Config->getConfig('Org::FRDCSA::Platform::SQLDatabase');

has 'dbh' => (
	      is => 'ro'
);

=pod

=method B<connect(databaseName)> (class method)

Returns: a database handle to the requested database.

Throws: ... if connection fails

=cut

sub connect {
}

=pod

=method B<findRecordById(tableName, columnName, keyValue)>

Lookup a record by id using the specified table and column.

Returns: A hash ref of the requested record.

Throws: C<Error::Simple> if the requested record is not found.

=cut

sub findRecordById {
  my ($self, $tableName, $columnName, $keyValue) = @_;
  # note, this only works with client-side prepare
  my $stmt = $self->dbh->prepare("select * from ? where ? = ?");
  $stmt->execute($keyValue);
  my $rows = $stmt->fetchall_hashref($columnName);
  if ($rows->{keyValue}) {
    return $rows->{keyValue};
  }
  throw Error::Simple(sprintf("no record found in %s table where %s=%s", $tableName, $columnName, $keyValue));
}

1;
