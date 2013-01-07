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

#ifndef NODE_CPP
#define NODE_CPP

#include "cusp/cusp.h"
#include "bubblestorm/bubblestorm.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cassert>
#include <vector>
#include <map>
#include <time.h>

using namespace std;

using namespace BS;
using namespace CUSP;

// startNode() function export
extern "C" {
	void startGlobal();
	void startNode(const char* bootstrapAddr, int bootstrapAddrLen);
}

static int globalPort = 8585;

class Node : public BubbleStorm::JoinHandler, public BubbleType::BubbleHandlerWithId,
		public Query::Responder, public Query::ResponseReceiver, public QueryRespond::Writer,
		public Event::Handler, public InStream::ReadHandler, public OutStream::WriteHandler
{
	private:

		struct DataElement {
			char* data;
			int len;
			DataElement(char* _data, int _len) : data(_data), len(_len) {};
			~DataElement() {
				if (data != NULL)
					delete data;
				data = NULL;
			}
		};
		typedef std::map<std::string, DataElement*> ValueTable;

		struct PeerData {
			int x;
			int y;
			int id;
		};

		class StopHandler: public Event::Handler {
			public:
				StopHandler() {
				};
				~StopHandler() {
				}
				void setStoppable(Stoppable& _s) {
					s = _s;
				}
			private:
				Stoppable s;

				void onEvent(Event& ev) {
//					printf("StopHandler::onEvent() start\n");
					s.stop();
//					printf("StopHandler::onEvent() end\n");
				}
		};

		int argc;
		const char** argv;
		int port;
		EndPoint ep;
		BubbleStorm bubbleStorm;
		BubbleType dataBubble;
// 		Measurement* measurements;
// 		BubbleType* bubbleTypes;
// 		Topology topology;
		Query query;
		ID id;
		InStream is;
		ValueTable* values;
		StopHandler sh;
		PeerData* peerData;
		Address addr;

	public:
		Node(int argc, const char** argv) : argc(argc), argv(argv)
		{
			values = new ValueTable();
			peerData = new PeerData();
		}

		virtual ~Node()
		{
// 			delete[] measurements;
// 			delete[] bubbleTypes;
			delete peerData;

			ValueTable::const_iterator iter;
			for ( iter = values->begin(); iter != values->end(); iter++ ) {
				delete iter->second;
			}
			delete values;
		}

		void run() {
			srand(time(NULL));
			
			port = (argc >= 4) ? (int)strtol(argv[3], NULL, 0) : 8585;
			ep = EndPoint::create(port);
			
			BubbleStorm::setLanMode(true);
			
			Address bootstrap = Address::fromString("localhost");
			bubbleStorm = BubbleStorm::createWithEndpoint(1.0, bootstrap, ep);
			BubbleManager bm = bubbleStorm.bubbleManager();

			dataBubble = bm.newFading(1, this);
			query = Query::create(dataBubble, 2, 4.0f, this);

// 			Measurement measurement = Measurement::create(Time::fromSeconds(1L).toNanoseconds());
// 			measurement.sum(this, this);

// 			// topology
// 			bubbleTypes = new BubbleType[2];
// 			bubbleTypes[0] = dataBubble;
// 			bubbleTypes[1] = queryBubble;

// 			topology = Topology::create(ep, 12, this, bubbleTypes, 2, measurements, 1);

			if (strcmp("bootstrap", argv[1]) == 0 && argc >= 3) {
				Address address = Address::fromString(argv[2]);
				bubbleStorm.createRing(address);

				// run event loop
				sendPositionUpdate();

				Event ev = Event::create(this);
				ev.scheduleIn(Time::fromSeconds(8));

			} else if(strcmp("join", argv[1]) == 0 && argc >= 4) {
				addr = Address::fromString(argv[2]);
				bubbleStorm.join(this);
			} else {
				printf("Args error\n");
				return;
			}

			evtMain();
		}

		void sim(const char* bootstrapAddr) {
			port = 8585;
			if (strlen(bootstrapAddr) > 0) {
				port = globalPort++;
			}
			ep = EndPoint::create(port);
			printf("%d\tEndpoint created on port %d\n", port, port);

			Address bootstrap = Address::fromString(bootstrapAddr);
			bubbleStorm = BubbleStorm::createWithEndpoint(1.0, bootstrap, ep);
			BubbleManager bm = bubbleStorm.bubbleManager();
			
			dataBubble = bm.newFading(1, this);
			query = Query::create(dataBubble, 2, 4.0f, this);

// 			Measurement measurement = Measurement::create(Time::fromSeconds(1L).toNanoseconds());
// 			measurement.sum(this, this);

			if (strlen(bootstrapAddr) == 0) {
				addr = Address::fromString(std::string("0.0.0.1"));
				Address address = Address::fromString(std::string("0.0.0.1"));
				printf("%d\tBootstrap mode [%s]\n", port, address.toString().c_str());
				bubbleStorm.createRing(address);
			} else {
				addr = Address::fromString(bootstrapAddr);
				printf("%d\tJoining bootstrapper on %s [%s]\n", port, bootstrapAddr, addr.toString().c_str());
				bubbleStorm.join(this);
			}

			//evtMain();
		}

	private:
		void sendPositionUpdate() {
			id = ID::fromRandom();
			peerData->x = rand() % 25;
			peerData->y = rand() % 25;
			peerData->id = port;
			dataBubble.bubblecastWithId(id, (const uint8_t*) peerData, sizeof(PeerData));
//			printf("%d\tsendPositionUpdate: [%d, %d] with id: %s\n", port, peerData->x, peerData->y, id.toString().c_str());
		}

		float pull() {
			/*printf("pull: values so far:\n");
			ValueTable::const_iterator iter;
			for (iter = values->begin(); iter != values->end(); iter++) {
				printf("\t%s -> '%s', %d\n", iter->first.c_str(), iter->second->data, iter->second->len);
			}*/
			return 1.0f;
		}

		void push(float value) {
		}

		Address& getAddress() {
			return addr;
		}

		void onJoinComplete() {
			printf("%d\tonJoinComplete: external address: %s\n", port, bubbleStorm.address().toString().c_str());

			sendPositionUpdate();

			Event ev = Event::create(this);
			ev.scheduleIn(Time::fromSeconds(8));
		}

		// StorageHandler::onStore
		void onBubble(ID id, const uint8_t* data, size_t length) {
			/*printf("%d\tStorageHandler::onStore(%s, %s, %d)\n", port, id.toString().c_str(), data, length);

			char* cpy = new char[length];
			memcpy(cpy, data, length);
			DataElement* de = new DataElement(cpy, length);

			values->insert(std::make_pair(id.toString(), de));

			printf("onStore: values so far:\n");
			ValueTable::const_iterator iter;
			for ( iter = values->begin(); iter != values->end(); iter++ ) {
				printf("\t%s -> '%s', %d\n", iter->first.c_str(), std::string(iter->second->data, iter->second->len).c_str(), iter->second->len);
			}*/
		}

		// Responder::respond
		void respond(void* data, const int length, QueryRespond* queryRespond) {
			PeerData* c = (PeerData*) data;
//			printf("%d\tResponder::respond([%d, %d], %d, %p)\n", port, c->x, c->y, length, queryRespond);

			// check if we are "close"
			if (peerData->x >= c->x - 5 && peerData->x <= c->x + 5
					&& peerData->y >= c->y - 5 && peerData->y <= c->y + 5
					&& peerData->id != c->id)
			{
				printf("---------------\n");
				printf("Proximity: I[%d; %d, %d] Peer[%d; %d, %d]\n", peerData->id, peerData->x, peerData->y, c->id, c->x, c->y);
				printf("---------------\n");

				// send answer
			   queryRespond->respond(id, this);
			}

			/*if (strcmp(data, "query all") == 0) {
				printf("Responder::respond: query all issued\n");
				// send answer
			   queryRespond->respond(id, this);
			} else {
				ID id = ID::fromHash((char*) data, length);
				printf("Responder::respond: looking for id %s\n", id.toString().c_str());

				ValueTable::const_iterator iter;
				iter = values->find(id.toString());
				if(iter != values->end()) {
				   printf("Responder::respond: found value: '%s'\n", std::string(iter->second->data, iter->second->len).c_str());

				   // send answer
				   queryRespond->respond(id, this);
				}
				else
				   printf("Responder::respond: value not found!\n");
			}*/
		}

		// ResponseReceiver::onResponse
		void onResponse(ID& id, InStream& stream)
		{
//			printf("ResponseReceiver::onResponse: Got data for id: %s\n", id.toString().c_str());
			is = stream;
			// will call onReceive method
			stream.read(this);
		}

		// InStream::ReadHandler implementation
		void onReceive(const void* data, int size)
		{
			PeerData* pd = (PeerData*) data;
//			printf("%d\tInStream::ReadHandler::onReceive([%d; %d, %d], %d)\n", port, pd->id, pd->x, pd->y, size);
			printf("%d\t  |\\____              |\\____\n", port);
			printf("%d\t   \\____`>    +-->     \\____`>\n", port);
			printf("%d\t  [%d; %d, %d]         [%d; %d, %d]\n", port, peerData->id, peerData->x, peerData->y, pd->id, pd->x, pd->y);
		}

		virtual void onShutdown()
		{
			printf("InStream::ReadHandler::onShutdown()\n");
		}

		virtual void onReset()
		{
			printf("In/OutStream::ReadHandler::onReset()\n");
			// (this is InStream OR OutStream reset!!)
			if (is.isValid()) {
				is.reset();
				is = InStream();
			}
		}

		// OutStream::WriteHandler implementation
		virtual void onReady()
		{
			printf("OutStream::ReadHandler::onReady()\n");
		}

		// QueryRespond::Writer::write
		void write(OutStream& stream)
		{
			printf("QueryRespond::Writer::write: sending data \n");
			stream.write(peerData, sizeof(PeerData), this);
		}

		// QueryRespond::Writer::abort
		void abort()
		{
			printf("QueryRespond::Writer::abort()\n");
		}

		// Event::Handler
		void onEvent(Event& ev)
		{
			// update my position
			sendPositionUpdate();

			// query my new PeerData and see, which peers will answer
			query.query((void*) peerData, sizeof(PeerData), this);
			printf("%d\tEvent::Handler::onEvent: querying for coords [%d, %d]\n", port, peerData->x, peerData->y);

			Event e = Event::create(this);
			e.scheduleIn(Time::fromSeconds(1));
		}
};


// called once on simulation startup
void startGlobal() {

}

// node start function, called from SML simulator code
void startNode(const char* bootstrapAddr, int bootstrapAddrLen) {
	std::string bootstrap(bootstrapAddr, bootstrapAddrLen);
	printf("startNode(%s, %d)\n", bootstrap.c_str(), bootstrapAddrLen);

	Node* n = new Node(0, NULL);
	n->sim(bootstrap.c_str());
}

#endif
