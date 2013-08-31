# simple test to make sure modules load and logging calls succeed
use strict;
use warnings;
use Test::More tests => 1;

require_ok('Org::FRDCSA::Platform::Log');

my $log = Org::FRDCSA::Platform::Log->getLogger("02_log_basic");

$log->debug("THIS IS A TEST MESSAGE AT (debug) LEVEL");
$log->info("THIS IS A TEST MESSAGE AT (info) LEVEL");
$log->warn("THIS IS A TEST MESSAGE AT (warn) LEVEL");
$log->error("THIS IS A TEST MESSAGE AT (error) LEVEL");
$log->debug("THIS IS A TEST MESSAGE AT (debug) LEVEL");

