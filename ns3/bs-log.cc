#include "bs-log.h"
#include "libsim-ns3.h"

void Log::addFilter(const std::string& module, Level level)
{
	bs_log_add_filter((void*) module.data(), module.size(), (int) level);
}
