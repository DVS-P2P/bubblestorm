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


#include "cusp/cusp.h"

// (to disable assert)
// #define NDEBUG

#include <stdio.h>
#include <assert.h>
#include <vector>

using namespace BS;
using namespace BS::CUSP;


class Server : private EndPoint::AdvertiseHandler
{
	private:
		class Connection : private InStream::ReadHandler,
  				private OutStream::WriteHandler, private OutStream::ShutdownHandler
		{
			private:
				InStream is;
				Server& server;
				Host remoteHost;
				OutStream os;
				bool ready;
			
			public:
				Connection(Server& server, const InStream& instream, const Host& host)
					: is(instream), server(server), remoteHost(host), os(), ready(false)
				{
					is.read(this, sizeof(ServiceId)); // read the service id first
				}
				
				virtual ~Connection()
				{
				}
				
				std::string getName() const
				{
					return remoteHost.keyStr();
				}
				
				void sendMessage(const void* data, int size)
				{
					if (os.isValid() && ready) {
// 						printf("sendMessage()\n");
						ready = false;
						os.write(data, size, this);
					} else
						printf("sendMessage(): %s not ready!\n", remoteHost.keyStr().c_str());
				}
			
			private:
				// InStream::ReceiveHandler implementation
				virtual void onReceive(const void* data, int size)
				{
					std::string key = remoteHost.keyStr();
					if (os.isValid()) {
						// -> already initialized
						std::string s((char*) data, size);
						printf("Received %d bytes from %s: %s\n", size, key.c_str(), s.c_str());
						server.broadcastMessage(data, size);
					} else {
						// -> connect outstream
						if (size == sizeof(ServiceId)) {
							ServiceId service = *((ServiceId*) data);
							printf("Received client callback service id %d from %s\n", service, key.c_str());
							os = remoteHost.connect(service);
							ready = true;
							sendMessage("HELLO", 6);
						} else {
							// invalid init message
							printf("Received invalid callback service id from %s\n", key.c_str());
							is.reset();
							server.removeConnection(this);
							delete this;
							return;
						}
					}
					is.read(this);
				}
				virtual void onShutdown()
				{
					printf("Client shutdown.\n");
					ready = false;
					if (os.isValid()) {
						printf("  Shutting down outstream.\n");
						os.shutdown(this);
					} else {
						printf("  Done.\n");
						server.removeConnection(this);
						delete this;
					}
				}
				virtual void onReset()
				{
					// (InStream OR OutStream reset)
					printf("Reset.\n");
					is.reset();
					if (os.isValid())
						os.reset();
					server.removeConnection(this);
				}
				
				// OutStream::WriteHandler implementation
				virtual void onReady()
				{
// 					printf("Write ready.\n");
					ready = true;
				}
				
				// OutStream::ShutdownHandler implementation
				virtual void onShutdown(bool success)
				{
					printf("Shutdown %s.\n", (success) ? "successful" : "failed");
					if (os.isValid() && !success)
						os.reset();
					server.removeConnection(this);
					delete this;
				}
		};
	
	private:
		EndPoint ep;
		std::vector<Connection*> connections;
	
	public:
		Server(int argc, const char** argv)
		{
			// init CUSP
			cuspInit(argc, argv);
		}
		
		virtual ~Server()
		{
			// close all connections
			for (std::vector<Connection*>::iterator it = connections.begin(); it != connections.end(); it++) {
				delete *it;
			}
			connections.clear();
			// close endpoint
			ep = EndPoint();
			// shut down CUSP
			cuspShutdown();
		}
		
		void run()
		{
			// create endpoint
			ep = EndPoint::create(8585);
			// advertise my service
			ep.advertise(23, this);
			// show available cryptio suites
			printf("Default crypto suites:\n");
			printf("  PublicKey\n");
			PublicKeySuiteSet pk = PublicKeySuiteSet::defaults();
			for (PublicKeySuiteSet::Iterator it = pk.iterator(); it.hasNext(); ) {
				PublicKeySuite suite = it.next();
				printf("    %s (cost: %f)\n", suite.name().c_str(), suite.cost());
			}
			printf("  Symmetric\n");
			SymmetricSuiteSet sym = SymmetricSuiteSet::defaults();
			for (SymmetricSuiteSet::Iterator it = sym.iterator(); it.hasNext(); ) {
				SymmetricSuite suite = it.next();
				printf("    %s (cost: %f)\n", suite.name().c_str(), suite.cost());
			}
			// run main loop
			printf("Waiting for connections...\n");
			evtMain();
		}
		
		void broadcastMessage(const void* data, int size)
		{
			for (std::vector<Connection*>::iterator it = connections.begin(); it != connections.end(); it++) {
				(*it)->sendMessage(data, size);
			}
		}
		
		void removeConnection(const Connection* conn)
		{
			printf("Removing connection to %s\n", conn->getName().c_str());
			for (std::vector<Connection*>::iterator it = connections.begin(); it != connections.end(); it++) {
				if (*it == conn) {
					connections.erase(it);
					break;
				}
			}
		}
		
		void printHosts()
		{
			printf("Hosts:\n");
			for (Host::Iterator it = ep.hosts(); it.hasNext(); ) {
				Host h = it.next();
				printf("  %s", h.keyStr().c_str());
				Address addr = h.address();
				if (addr.isValid())
					printf(" - %s", addr.toString().c_str());
				printf("\n");
			}
		}
	
		void printChannels()
		{
			printf("Channels:\n");
			for (Channel::Iterator it = ep.channels(); it.hasNext(); ) {
				Channel ch = it.next();
				printf("  %s", ch.address().toString().c_str());
				if (ch.host().isValid())
					printf(" - %s", ch.host().keyStr().c_str());
				printf("\n");
			}
		}
	
	private:
		// EndPoint::AdvertiseHandler implementation
		void onConnect(Host& host, InStream& stream)
		{
			printf("Connect: %s\n", host.toString().c_str());
			connections.push_back(new Connection(*this, stream, host));
			// show hosts & channels
			printHosts();
			printChannels();
		}
};


int main(int argc, const char** argv)
{
	Server server(argc, argv);
	printf("Start...\n");
	server.run();
	printf("Done.\n");
	return 0;
}
