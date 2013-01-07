#include "ns3/nstime.h"
#include "ns3/simulator.h"

// (must be AFTER ns-3 includes!)
#include "libsim-ns3.h"

#include <cstdio>
using namespace std;

namespace ns3 {

extern "C" Int64_t c_event_time()
{
	return Simulator::Now().GetNanoSeconds();
}

void onEvent(Int32_t cbHandle)
{
	bs_event_fire(cbHandle);
}

extern "C" void c_event_schedule_in(Int64_t t, Int32_t cbHandle)
{
	const Time time = Time::FromInteger(t, Time::NS);
	Simulator::Schedule(time, &onEvent, cbHandle);
}

// extern "C" void c_event_schedule_at(Int64_t t, Int32_t cbHandle)
// {
// 	const Time time = Time::FromInteger(t, Time::NS) - Simulator::Now();
// 	Simulator::Schedule(time, &onEvent, cbHandle);
// }

} // namespace ns3
