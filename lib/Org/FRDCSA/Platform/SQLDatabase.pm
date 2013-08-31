use strict;
use warnings;

package Org::FRDCSA::Platform::SQLDatabase;

# ABSTRACT: sql database access

use Error;
use Moose;
use Org::FRDCSA::Platform::ConfigLoader;

=pod

=head1 ATTRIBUTES

B<dbh> DBI database handle.

B<configPath> Optional path to configuration file, must be provided to constructor.

B<config> Configuration.

=cut

has 'dbh'        => ( is => 'ro', );
has 'configPath' => ( is => 'ro', );
has 'config'     => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_config',
);

=pod

=method B<_build_config>

Read config file.

=cut

sub _build_config {
    my $self         = shift;
    my $configLoader = Org::FRDCSA::Platform::ConfigLoader->new;
    if ( $self->configPath ) {
        $configLoader->searchPaths( [ $self->configPath ] );
    }
    return $configLoader->getConfig;
}

=pod

=method B<connect(databaseName)> (class method)

Returns: a database handle to the requested database.

Throws: ... if connection fails

=cut

sub connect {

    # TODO
}

=pod

=method B<BUILD()> (constructor)

Internal intialization.

=cut

sub BUILD {
    my $self = shift;

    # cause config init
    $self->config;
}

=pod

=method B<findRecordById(tableName, columnName, keyValue)>

Lookup a record by id using the specified table and column.

Returns: A hash ref of the requested record.

Throws: C<Error::Simple> if the requested record is not found.

=cut

sub findRecordById {
    my ( $self, $tableName, $columnName, $keyValue ) = @_;

    # note, this only works with client-side prepare
    my $stmt = $self->dbh->prepare("select * from ? where ? = ?");
    $stmt->execute($keyValue);
    my $rows = $stmt->fetchall_hashref($columnName);
    if ( $rows->{keyValue} ) {
        return $rows->{keyValue};
    }
    throw Error::Simple(
        sprintf(
            "no record found in %s table where %s=%s",
            $tableName, $columnName, $keyValue
        )
    );
}

=pod

=method B<executeQuery>

Execute a query.

Returns: The result set.

=cut

sub executeQuery {
    my ( $self, $query, $argArray, $args ) = @_;
    my $stmt = $self->dbh->prepare("$query");
    $stmt->execute();
}

=pod

=method B<executeInsert>

Insert a single record.

Returns: The ID of the inserted record.

=cut

sub executeInsert {
    my ( $self, $query, $argArray ) = @_;
    my $stmt = $self->dbh->prepare($query);
    $stmt->execute(@$argArray);
    return $self->last_insert_id;
}

=pod

=method B<executeUpdate(query, argArrayRef)>

Execute an update DML or DDL statement.

Returns: nothing.

=cut

sub executeUpdate {
    my ( $self, $query, $argArray ) = @_;
    my $stmt = $self->dbh->prepare($query);
    $stmt->execute(@$argArray);
}

1;
