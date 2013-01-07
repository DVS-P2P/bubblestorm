
#include <string>
#include <vector>
#include <iostream>
#include <cmath>

#include "ns3/core-module.h"
#include "ns3/simulator-module.h"
#include "ns3/node-module.h"
#include "ns3/helper-module.h"
#include "ns3/object-factory.h"
#include "ns3/global-route-manager.h"

#include "libsim-ns3.h"

#include "bs-app.h"
#include "bs-log.h"
#include "bs-statistics.h"
#include <ns3/point-to-point-net-device.h>
#include <ns3/point-to-point-channel.h>

using namespace std;
using namespace ns3;

NS_LOG_COMPONENT_DEFINE("BubbleStormWrapper");

string addrToString(const Ipv4Address& addr) {
	stringstream s;
	s << addr;
	return s.str();
}

void run() {
	//
	// create nodes & topology
	//
	
	NS_LOG_INFO("Creating nodes");
	static const int NUM_NODES = 100;
	NodeContainer nodes;
	nodes.Create(NUM_NODES + 1);
	
	PointToPointHelper pointToPoint;
	pointToPoint.SetDeviceAttribute("DataRate", StringValue("1Mbps"));
	pointToPoint.SetChannelAttribute("Delay", StringValue("10ms"));
	
	CsmaHelper csma;
	csma.SetChannelAttribute("DataRate", StringValue("10Mbps"));
	csma.SetChannelAttribute("Delay", TimeValue(NanoSeconds(6560)));
	
	// Connect nodes
	NS_LOG_INFO("Connecting nodes");
	NetDeviceContainer devices;
// 	devices = pointToPoint.Install (nodes);
	for (unsigned int i = 1; i < nodes.GetN(); i++) {
		devices.Add(pointToPoint.Install(nodes.Get(0), nodes.Get(i)));
	}
// 	devices = csma.Install (nodes);
	
	// Internet stack
	InternetStackHelper stack;
	stack.Install(nodes);
	
	// IPv4 addresses
	NS_LOG_INFO("Assigning addresses");
	Ipv4AddressHelper address;
/*	address.SetBase("10.0.0.0", "255.255.0.0");
	Ipv4InterfaceContainer interfaces = address.Assign(devices);*/
	Ipv4InterfaceContainer interfaces;
	for (unsigned int i = 0; i < devices.GetN() / 2; i++) {
		stringstream s;
		s << "10." << (i / 256) << "." << (i % 256) << ".0";
		address.SetBase(s.str().c_str(), "255.255.255.0");
		NetDeviceContainer dev;
		dev.Add(devices.Get(i * 2));
		dev.Add(devices.Get(i * 2 + 1));
		interfaces.Add(address.Assign(dev));
	}
	
	// Global routing
	NS_LOG_INFO("Populating routing tables");
	Ipv4GlobalRoutingHelper::PopulateRoutingTables();
	
	//
	// install applications
	//
	
	NS_LOG_INFO("Installing application");
	
// 	cout << "Addr: " << nodes.Get(0)->GetDevice(0)->GetAddress() << endl;
/*	for (unsigned int i = 0; i < interfaces.GetN(); i++) {
		cout << "Addr: " << interfaces.GetAddress(i) << endl;
	}*/
	string bootstrapAddr = addrToString(interfaces.GetAddress(1));
// 	printf("bootstrap addr: %s\n", bootstrapAddr.c_str());
	
	const char* appName1 = "query-test";
	const char* appName2 = "query-test";
	const char* args1[] = {"-create", bootstrapAddr.c_str()};
	const char* args2[] = {"-bootstrap", bootstrapAddr.c_str()};

	ObjectFactory factory;
	factory.SetTypeId(BSApp::GetTypeId());
	Ptr<BSApp> app1 = factory.Create<BSApp>();
	app1->SetAttribute("NodeId", IntegerValue(1));
	app1->SetAppName(appName1);
	app1->SetArgs(vector<string>(args1, args1 + sizeof(args1) / sizeof(const char*)));
	nodes.Get(1)->AddApplication(app1);
	
	for (unsigned int i = 2; i < nodes.GetN(); i++) {
		Ptr<BSApp> app2 = factory.Create<BSApp>();
		app2->SetAttribute("NodeId", IntegerValue(i));
		app2->SetAppName(appName2);
		app2->SetArgs(vector<string>(args2, args2 + sizeof(args2) / sizeof(const char*)));
		nodes.Get(i)->AddApplication(app2);
		
		app2->SetStartTime(Time::FromDouble(log(i * 1000), Time::S));
	}
	
	//
	// set logging & tracing
	//
	
// 	Log::addFilter("cusp", Log::DEBUG);
// 	Log::addFilter("topology", Log::DEBUG);
// 	Log::addFilter("bubblestorm/query/demo", Log::DEBUG);
	
// 	LogComponentEnable("DropTailQueue", LOG_LEVEL_LOGIC);
	
// 	pointToPoint.EnablePcapAll ("test");
// 	csma.EnablePcap ("second", csmaDevices.Get (1), true);
// 	pointToPoint.EnablePcapInternal ("node1", nodes.Get(0)->GetDevice(0), false, false);
	
	Statistics::logInterval(Time("60s"));
	
	//
	// run
	//
	
	Simulator::Stop(Time("7200s"));
	
	NS_LOG_INFO("Starting simulation");
	Simulator::Run ();
	
	NS_LOG_INFO("Simulation done.");
	Simulator::Destroy ();
}

int main(int argc, const char *argv[])
{
	LogComponentEnable("BubbleStormWrapper", LOG_LEVEL_INFO);
	
	// initialize SML part
	sim_ns3_open(argc, argv);
	
	// check ns-3 time resolution
	NS_ASSERT_MSG(Time::GetResolution() >= Time::NS, "Time resolution must be at least one nanosecond");
	
	// run
	run();
	
	// done
	sim_ns3_close();
	return 0;
}
