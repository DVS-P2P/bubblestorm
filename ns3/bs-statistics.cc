#include "bs-statistics.h"
#include "libsim-ns3.h"

using namespace ns3;

void Statistics::logInterval(const Time& interval)
{
	bs_statistics_log_interval(interval.GetNanoSeconds());
}
