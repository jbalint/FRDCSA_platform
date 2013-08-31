use strict;
use warnings;

package Org::FRDCSA::Platform::SQLDatabase;

# ABSTRACT: sql database access

use DBI;
use Error;
use Moose;
use Org::FRDCSA::Platform::ConfigLoader;

=pod

=head1 CONFIGURATION

Org::FRDCSA::Platform::SQLDatabase reads a configuration file with datasources. A configuration file
can include more than one datasource. Only one should be specified as a default data source. That is,
each datasource should have a list of databases that it provides except for the default data source.

The format is as follows:
<datasource NAME_OF_DATASOURCE>
	    driver = DBI_DRIVER_NAME
	    host = SQL_SERVER_HOST_NAME
	    port = SQL_SERVER_PORT
	    user = SQL_SERVER_USER
	    password = SQL_SERVER_PASSWORD
	    databases = comma,separated,list,of,databases
</datasource>

=head1 ATTRIBUTES

B<dbh> DBI database handle.

B<config> Configuration.

B<configPath> Optional path to configuration file, must be provided to constructor.

B<currentDataSource>

B<databaseName>

B<logger>

=cut

has 'dbh'        => ( is => 'rw', );
has 'configPath' => ( is => 'ro', );
has 'config'     => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_config',

    # TODO note that config can be provided with a config file.. to the ctor
);
has 'currentDatabaseName' => ( is => 'rw' );
has 'currentDataSource'   => ( is => 'rw' );
has 'logger'              => (
    is      => 'ro',
    default => sub { Org::FRDCSA::Platform::Log->getLogger(); },
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

=method B<connect(databaseName)>

Connect to the specified database.

Throws: Error::Simple if connection fails

=cut

sub connect {
    my ( $self, $databaseName ) = @_;

    # disconnect if already connected to another database
    if ( $self->dbh ) {
        $self->dbh->disconnect();
        $self->dbh(undef);
    }

    # lookup the data source to use for this database
    my $dataSource = $self->getDataSourceForDatabase($databaseName);
    $self->currentDataSource($dataSource);
    my $connectString =
      sprintf( 'DBI:%s:%s', $self->currentDataSource->{driver}, $databaseName );
    my $user     = $self->currentDataSource->{user};
    my $password = $self->currentDataSource->{password};
    $self->dbh( DBI->connect( $connectString, $user, $password ) );
    if ( not $self->dbh ) {
        my $errmsg = sprintf( 'Cannot connect to \'%s\': %s', $connectString,
            DBI->errstr );
        throw Error::Simple($errmsg);
    }
    $self->currentDatabaseName($databaseName);
}

=pod

=method B<disconnect()>

Disconnect from the current database.

=cut

sub disconnect {
    my $self = shift;
    return unless ( $self->dbh );
    $self->dbh->disconnect;
    $self->dbh(undef);
    $self->currentDataSource(undef);
    $self->currentDatabaseName(undef);
}

=method B<getDataSourceForDatabase(databaseName)>

Looks up a data source in the configuration. If one matches the database
request, it will take precedence over the default datasource. Otherwise,
the default datasource will be returned.

Returns: a data source for the given database.

=cut

sub getDataSourceForDatabase {
    my ( $self, $databaseName ) = @_;
    my $defaultDataSource;

    # TODO document config file format
    my $dataSources = $self->config->{datasource};
    while ( my ( $name, $dataSource ) = each(%$dataSources) ) {
        if ( not $dataSource->{databases} and not $defaultDataSource ) {
            $self->logger->debug(
                sprintf( "Using %s as default data source", $name ) );
            $defaultDataSource = $dataSource;
            $dataSource->{name} = $name;
        }
        elsif ( $dataSource->{databases} ) {

            # TODO handle database-specific configuration
        }
    }
    return $defaultDataSource;
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

    # TODO use MooseX::Types for validation of these values
    if (   $tableName =~ /[^\w\d_]/
        || $columnName =~ /[^\w\d_]/ )
    {
        throw Error::Simple("Table and/or column contains invalid characters");
    }
    my $sqlQuery =
      sprintf( 'select * from %s where %s = ?', $tableName, $columnName );
    my $stmt = $self->dbh->prepare($sqlQuery);
    $stmt->execute($keyValue);
    my $rows = $stmt->fetchall_hashref($columnName);
    if ( $rows->{$keyValue} ) {
        return $rows->{$keyValue};
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
    return $self->dbh->last_insert_id( undef, undef, undef, undef );
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
