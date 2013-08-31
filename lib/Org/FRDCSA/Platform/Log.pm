use strict;
use warnings;

package Org::FRDCSA::Platform::Log;

# ABSTRACT: Logging wrapper for use by FRDCSA modules.

use Moose;
use MooseX::ClassAttribute;
use Log::Log4perl qw(:easy);
use namespace::autoclean;

class_has 'logger' => (
    is      => 'ro',
    default => sub { get_logger('Org::FRDCSA::Platform::Log'); },
);

Log::Log4perl->easy_init($DEBUG);

sub getLogger {
    my $loggerName = shift;
    if ( not $loggerName ) {
        my ($callingPackage) = caller();
        Org::FRDCSA::Platform::Log->logger->debug(
            sprintf( 'Module name not provided. Defaulting to caller %s',
                $callingPackage )
        );
        $loggerName = $callingPackage;
    }

    return get_logger($loggerName);
}

__PACKAGE__->meta->make_immutable;
1;
