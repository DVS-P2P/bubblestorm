#include <ns3/ptr.h>
#include <ns3/type-id.h>
#include <ns3/socket.h>
#include <ns3/application.h>
#include <ns3/inet-socket-address.h>

// (must be AFTER ns-3 includes!)
#include "libsim-ns3.h"

// #include <cstdio>
// using namespace std;

namespace ns3 {

class BsUdp
{
	public:
		BsUdp(Application* app, Word16_t port, Int32_t cbHandle)
		{
			TypeId tid = TypeId::LookupByName("ns3::UdpSocketFactory");
			sock = Socket::CreateSocket(app->GetNode(), tid);
			sock->Bind(InetSocketAddress(port));
		// 	sock->Connect(InetSocketAddress (m_peerAddress, m_peerPort));
			this->cbHandle = cbHandle;
			sock->SetRecvCallback(MakeCallback(&BsUdp::recvCallback, this));
		}
		~BsUdp()
		{
// 			sock->SetRecvCallback(MakeNullCallback<void, ns3::Ptr<ns3::Socket> >());
			sock->Close();
		}
		int send(const uint8_t* data, int len, uint32_t ip, uint16_t port)
		{
			return sock->SendTo(data, len, 0, InetSocketAddress(Ipv4Address(ip), port));
		}
		int recv(uint8_t* buffer, int len, Address& addr)
		{
			return sock->RecvFrom(buffer, len, 0, addr);
		}
	
	private:
// 		Application* app;
		Ptr<Socket> sock;
		Int32_t cbHandle;
		
		void recvCallback(Ptr<Socket> sock)
		{
// 			if (sock) {
// 			printf("recvCallback\n");
			bs_udp_recv_callback(cbHandle);
// 			}
		}
};


extern "C" CPointer c_udp_new(CPointer context, Word16_t port, Int32_t cbHandle)
{
// 	printf("udp_new\n");
	Application* app = (Application*) context;
	return new BsUdp(app, port, cbHandle);
}

extern "C" void c_udp_close(CPointer context, CPointer udpPtr)
{
	BsUdp* bsUdp = (BsUdp*) udpPtr;
	delete bsUdp;
}

extern "C" Bool_t c_udp_send(CPointer context, CPointer udpPtr, Word32_t ip, Word16_t port, Vector(Word8_t) buf, Int32_t ofs, Int32_t len)
{
// 	printf("udp_send %d\n", len);
	BsUdp* bsUdp = (BsUdp*) udpPtr;
	const uint8_t* data = ((uint8_t*) buf) + ofs;
	int res = bsUdp->send(data, len, ip, port);
	return (res == len);
}

extern "C" Int32_t c_udp_recv(CPointer context, CPointer udpPtr, Vector(Word32_t) addrData, Vector(Word8_t) buf, Int32_t ofs, Int32_t len)
{
// 	printf("udp_recv\n");
	BsUdp* bsUdp = (BsUdp*) udpPtr;
	uint8_t* data = ((uint8_t*) buf) + ofs;
	Address addr;
	int res = bsUdp->recv(data, len, addr);
	if (res > 0) {
		InetSocketAddress soAddr = InetSocketAddress::ConvertFrom(addr);
		((Int32_t*) addrData)[0] = soAddr.GetIpv4().Get();
		((Int32_t*) addrData)[1] = soAddr.GetPort();
	}
// 	printf("udp_recv %d\n", res);
	return res;
}

} // namespace ns3
