# simple test to make sure modules load and logging calls succeed
use Test::More tests => 1;

require_ok('Org::FRDCSA::Platform::Log');

my $log = Org::FRDCSA::Platform::Log->getLogger("02_log_basic");

$log->debug("debug");
$log->info("info");
$log->warn("warn");
$log->error("error");
$log->fatal("fatal");

