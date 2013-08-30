package Org::FRDCSA::Platform::Log;
# ABSTRACT: Logging wrapper for use by FRDCSA modules.

use Moose;

sub getLogger {

}

# Example use
sub someUniLangMethod {
  $self->logger($Org::FRDCSA::Platform::Log->getLogger("Org::FRDCSA::UniLang"));
  $self->logger()->debug("i am initializing");
  # 16:47:54 Fri Aug 30 [DEBUG] Org::FRDCSA::UniLang(UniLang.pm:30) - i am initialzing
  $self->logger($Org::FRDCSA::Platform::Log->getLogger("Org::FRDCSA::FreeKBS2"));
  $self->logger->warn("i am KBS!!");
  # 12:47:54 Fri Aug 30 [WARN] Org::FRDCSA::FreeKBS2(FreeKBS2.pm:30) - i am KBS!!
}
