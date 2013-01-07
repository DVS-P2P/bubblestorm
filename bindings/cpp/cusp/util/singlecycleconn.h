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

#ifndef SINGLECYCLECONN_H
#define SINGLECYCLECONN_H

#include <string>
#include <bidiconn.h>

namespace BS {
namespace CUSP {

/// Simplifies creating a (client) connection for just one request/response
/// cycle.
class SingleCycleConn : private BiDiConn::Handler
{
	public:
		class Handler
		{
			public:
				virtual void onResponse(const std::string& response) = 0;
				virtual void onFail() = 0;
		};
		
		SingleCycleConn(EndPoint& endPoint, const Address& addr, const ServiceId service,
				const std::string& request, Handler& handler);
		SingleCycleConn(const Host& h, const ServiceId service, const std::string& request,
				Handler& handler);
		
		/// Blocking request-reponse cycle.
		static std::string request(EndPoint& endPoint, const Address& addr,
				const ServiceId service, const std::string& request);
		static std::string request(const Host& h, const ServiceId service,
				const std::string& request);
	
	private:
		Handler& handler;
		std::string requestStr;
		std::string responseStr;
		BiDiConn conn;
		
		// BiDiConn::Handler implementation
		virtual void onContactFail();
		virtual void onSendReady();
		virtual void onReceiveData(const void* data, int size);
		virtual void onReceiveShutdown();
		virtual void onSendShutdownReady(bool success);
		virtual void onReset();
	
};

/// Server component for handling single cycle client connections.
class SingleCycleServer : private EndPoint::AdvertiseHandler, private Host::ListenHandler
{
	public:
		class Handler
		{
			public:
				virtual std::string onRequest(const std::string& request, const Host& from) = 0;
		};
		
		SingleCycleServer(const EndPoint& ep, const ServiceId listenService, Handler& handler);
		SingleCycleServer(const Host& h, Handler& handler);
		virtual ~SingleCycleServer();
		
		ServiceId getListenService();
	
	private:
		class Conn : private BiDiConn, private BiDiConn::Handler
		{
			public:
				Conn(SingleCycleServer& server, const Host& h, const InStream& stream);
			
			private:
				SingleCycleServer& server;
				bool sendReady;
				std::string request;
				std::string response;
				
				// BiDiConn::Handler implementation
				virtual void onContactFail();
				virtual void onSendReady();
				virtual void onReceiveData(const void* data, int size);
				virtual void onReceiveShutdown();
				virtual void onSendShutdownReady(bool success);
				virtual void onReset();
		};
		friend class Conn;
		
		EndPoint endPoint;
		Host host;
		ServiceId localService;
		Handler& handler;
	
		// EndPoint::AdvertiseHandler imeplementation
		virtual void onConnect(Host& host, InStream& stream);
		// Host::ListenHandler implementation
		virtual void onConnect(ServiceId service, InStream& stream);

};

}} // namespace BS::CUSP

#endif
