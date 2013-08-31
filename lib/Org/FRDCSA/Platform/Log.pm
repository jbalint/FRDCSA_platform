use strict;
use warnings;
package Org::FRDCSA::Platform::Log;
# ABSTRACT: Logging wrapper for use by FRDCSA modules.

use Moose;

use Log::Log4perl qw(:easy);

Log::Log4perl->easy_init($DEBUG);

sub getLogger {
  return get_logger(shift);
}

1;
