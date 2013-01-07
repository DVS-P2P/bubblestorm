
#include "bs-app.h"

// #include <cstdio>

#include "libsim-ns3.h"
// #include "ns3/log.h"
#include <ns3/string.h>
#include <ns3/integer.h>

using namespace std;

namespace ns3 {

TypeId BSApp::GetTypeId (void)
{
	static TypeId tid = TypeId("ns3::BSApp")
		.SetParent<Application>()
		.AddConstructor<BSApp>()
		.AddAttribute ("NodeId", 
					"The node ID",
					IntegerValue(0),
					MakeIntegerAccessor(&BSApp::m_nodeId),
					MakeIntegerChecker<int>(0))
		.AddAttribute ("AppName", 
					"The name of the application implemented in SML",
					StringValue(""),
					MakeStringAccessor(&BSApp::m_appName),
					MakeStringChecker())
/*		.AddAttribute ("Params", 
					"Command line parameters to be passed to the application",
					StringValue(""),
					MakeStringAccessor(&BSApp::m_params),
					MakeStringChecker())*/
		;
	return tid;
}

BSApp::BSApp()
	: m_handle(-1)
{
}

BSApp::~BSApp()
{
	if (m_handle >= 0)
		StopApplication();
}

void BSApp::SetAppName(const string& appName)
{
	m_appName = appName;
}

void BSApp::SetArgs(const vector<string>& args)
{
	m_args = args;
}

// void BSApp::DoDispose()
// {
// 	NS_LOG_FUNCTION_NOARGS();
// 	Application::DoDispose();
// }

void BSApp::StartApplication()
{
	NS_ASSERT_MSG(m_handle < 0, "BSApp::StartApplication(): Application already running");
	NS_ASSERT_MSG(!m_appName.empty(), "BSApp::StartApplication(): AppName not set");
// 	printf("Start app \"%s\"\n", m_appName.c_str());
	int argc = m_args.size();
	char** args = new char*[argc];
	int* argl = new int[argc];
	for (int i = 0; i < argc; i++) {
		const string a = m_args[i];
		args[i] = (char*) a.data();
		argl[i] = a.size();
	}
	m_handle = bs_app_start(this, m_nodeId, (void*) m_appName.data(), m_appName.length(), args, argl, argc);
	delete[] argl;
	delete[] args;
}

void BSApp::StopApplication()
{
	NS_ASSERT_MSG(m_handle >= 0, "BSApp::StopApplication(): Application not running");
	bs_app_stop(m_handle);
	m_handle = -1;
}

} // namespace ns3
