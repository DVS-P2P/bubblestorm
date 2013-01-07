/*
	This file is part of BubbleStorm.
	Copyright © 2008-2013 the BubbleStorm authors

	BubbleStorm is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BubbleStorm is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BubbleStorm.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "singlecycleconn.h"

namespace BS {
namespace CUSP {

//
// SingleCycleConn
//

SingleCycleConn::SingleCycleConn(EndPoint& endPoint, const Address& addr, const ServiceId service,
		const std::string& request, Handler& handler)
	: handler(handler), requestStr(request), conn(endPoint, addr, service, *this)
{
}

SingleCycleConn::SingleCycleConn(const Host& h, const ServiceId service, const std::string& request,
		Handler& handler)
	: handler(handler), requestStr(request), conn(h, service, *this)
{
}

std::string SingleCycleConn::request(EndPoint& endPoint, const Address& addr,
		const ServiceId service, const std::string& request)
{
	class BlockHandler : public Handler {
		public:
			std::string response;
			virtual void onResponse(const std::string& resp)
			{
				response = resp;
				evtStopMain();
			}
			virtual void onFail()
			{
				evtStopMain();
			}
	};
	BlockHandler h;
	SingleCycleConn conn(endPoint, addr, service, request, h);
	evtMain();
	return h.response;
}

std::string SingleCycleConn::request(const Host& host, const ServiceId service,
		const std::string& request)
{
	class BlockHandler : public Handler {
		public:
			std::string response;
			virtual void onResponse(const std::string& resp)
			{
				response = resp;
				evtStopMain();
			}
			virtual void onFail()
			{
				evtStopMain();
			}
	};
	BlockHandler h;
	SingleCycleConn conn(host, service, request, h);
	evtMain();
	return h.response;
}

// BiDiConn::Handler implementation

void SingleCycleConn::onContactFail()
{
	handler.onFail();
	conn.reset();
}

void SingleCycleConn::onSendReady()
{
	if (!requestStr.empty()) {
		conn.sendData(requestStr.data(), requestStr.size());
		requestStr.clear();
	} else
		conn.shutdown();
}

void SingleCycleConn::onReceiveData(const void* data, int size)
{
	responseStr.append((const char*) data, size);
}

void SingleCycleConn::onReceiveShutdown()
{
	handler.onResponse(responseStr);
}

void SingleCycleConn::onSendShutdownReady(bool success)
{
	// ignore (?)
}

void SingleCycleConn::onReset()
{
	handler.onFail();
	conn.reset();
}


//
// SingleCycleServer
//

SingleCycleServer::SingleCycleServer(const EndPoint& ep, const ServiceId listenService, Handler& handler)
	: endPoint(ep), localService(listenService), handler(handler)
{
	endPoint.advertise(localService, this);
}

SingleCycleServer::SingleCycleServer(const Host& h, Handler& handler)
	: host(h), handler(handler)
{
	localService = host.listen(this);
}

SingleCycleServer::~SingleCycleServer()
{
	if (endPoint.isValid())
		endPoint.unadvertise(localService);
	if (host.isValid())
		host.unlisten(localService);
}

ServiceId SingleCycleServer::getListenService()
{
	return localService;
}

// EndPoint::AdvertiseHandler imeplementation

void SingleCycleServer::onConnect(Host& host, InStream& stream)
{
	new Conn(*this, host, stream);
}

// Host::ListenHandler implementation
void SingleCycleServer::onConnect(ServiceId service, InStream& stream)
{
	new Conn(*this, host, stream);
}

// SingleCycleServer::Conn

SingleCycleServer::Conn::Conn(SingleCycleServer& server, const Host& h, const InStream& stream)
	: BiDiConn(h, stream, *this), server(server), sendReady(false), request(), response()
{
}

// BiDiConn::Handler implementation

void SingleCycleServer::Conn::onContactFail()
{
	// abort
	delete this;
}

void SingleCycleServer::Conn::onSendReady()
{
	if (!sendReady) {
// 		printf("SingleCycleServer::Conn::onSendReady: now ready\n");
		// send response if available
		if (!response.empty()) {
// 			printf("SingleCycleServer::Conn::onSendReady: resp: \"%s\"\n", response.c_str());
			sendData(response.data(), response.size());
		}
		// set send ready, so next time we'll shut down
		sendReady = true;
	} else {
// 		printf("SingleCycleServer::Conn::onSendReady: already ready\n");
		// done, shut down
		if (!shutdown()) {
			delete this;
			return;
		}
	}
}

void SingleCycleServer::Conn::onReceiveData(const void* data, int size)
{
// 	printf("SingleCycleServer::Conn::onReceiveData: \"%s\"\n", std::string((const char*)data, size).c_str());
	// receive (part of) request
	request.append((const char*) data, size);
}

void SingleCycleServer::Conn::onReceiveShutdown()
{
// 	printf("SingleCycleServer::Conn::onReceiveShutdown: \"%s\"\n", request.c_str());
	// all data read, process request
	response = server.handler.onRequest(request, getHost());
	// check response
	if (!response.empty()) {
		// send if possible
		if (sendReady)
			sendData(response.data(), response.size());
	} else {
		// make sure we shut down
		if (sendReady) {
			if (!shutdown()) {
				delete this;
				return;
			}
		} else
			sendReady = true;
	}
}

void SingleCycleServer::Conn::onSendShutdownReady(bool success)
{
// 	printf("SingleCycleServer::Conn::onSendShutdownReady\n");
	// done
	delete this;
}

void SingleCycleServer::Conn::onReset()
{
// 	printf("SingleCycleServer::Conn::onReset\n");
	// done
	delete this;
}

}} // namespace BS::CUSP
