use strict;
use warnings;
package Org::FRDCSA::Platform::ConfigLoader;
# ABSTRACT: Access to configuration data.

use Config::Any;
use Moose;
use Org::FRDCSA::Platform::Log;

=pod

=head1 ATTRIBUTES

B<searchPaths> Array ref of paths to search for config files. Default values are ~/.frdcsa, /etc/frdcsa.

=cut

has 'searchPaths' => (
		      is => 'rw',
		      default => sub { ['~/.frdcsa', '/etc/frdcsa'] },
);

has 'logger' => (
		 is => 'ro',
		 default => sub { Org::FRDCSA::Platform::Log->getLogger('Org::FRDCSA::Platform::ConfigLoader'); },
);

=pod

=head1 SYNOPSIS

    use Org::FRDCSA::Platform::ConfigLoader;
    my $config = Org::FRDCSA::Platform::ConfigLoader->getConfig('my_app');
    print $config->{someConfigurationVar};

=head1 DESCRIPTION

Configuration data resides on the file system and is accessed by
modules and applications. By using Org::FRDCSA::Platform::ConfigLoader,
the need to manually find and parse configuration files is bypassed
and the responsibility is passed to Org::FRDCSA::Platform::ConfigLoader.

TODO document file locations and search paths

=cut

################################
=pod

=method B<getConfig(moduleName)>

Get a configuration for the given module name. If module name is not specified,
the package of the caller will be used to search for a configuration instance.

Returns: A configuration object, if one is available. Otherwise,
and empty object.

=cut

sub getConfig {
  my ($self, $moduleName) = @_;
  if (not $moduleName) {
    my ($callingPackage) = caller();
    if ($callingPackage ne "main") {
      $self->logger->warn(sprintf('Module name not provided. Defaulting to caller %s', $callingPackage));
      $moduleName = $callingPackage;
    }
  }
  # check for file
  my $filename = $moduleName;
  $filename =~ s/::/_/g;
  $filename .= '.conf';
  # in order of priority
  my @possibleFilenames = map { $_ . '/' . $filename } @{$self->searchPaths};
  for my $f (@possibleFilenames) {
    next unless (-r $f);
    my $c = Config::Any->load_files({ files => [$f] });
    next unless $c;
    # we found a usable file, return it's config
    $self->logger->debug(sprintf("Loaded %s config from %s", $moduleName, $f));
    return $c->[0]->{$f};
  }
  return {};
}

1;

