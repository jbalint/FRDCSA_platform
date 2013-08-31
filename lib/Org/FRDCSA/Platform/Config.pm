use strict;
use warnings;
package Org::FRDCSA::Platform::Config;
# ABSTRACT: Access to configuration data.

use Moose;

=pod

=head1 SYNOPSIS

    use Org::FRDCSA::Platform::Config;
    my $config = Org::FRDCSA::Platform::Config->getConfig("my_app");
    print $config->{someConfigurationVar};

=head1 DESCRIPTION

Configuration data resides on the file system and is accessed by
modules and applications. By using Org::FRDCSA::Platform::Config,
the need to manually find and parse configuration files is bypassed
and the responsibility is passed to Org::FRDCSA::Platform::Config.

TODO document file locations and search paths

=cut

################################
=pod

=method B<getConfig(moduleName)>

Get a configuration for the given module name. 

Returns: A configuration object, if one is available.

=cut

sub getConfig {
  return {};
}

1;
