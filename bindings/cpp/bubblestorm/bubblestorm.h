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

//
// C++ wrapper for the BubbleStorm C-bindings
//

#ifndef BUBBLESTORM_H 
#define BUBBLESTORM_H 

#include "common/bscommon.h"
#include "cusp/cusp-base.h"

#include "bubblestorm/libbubblestorm.h"

namespace BS {

// forward declarations
class BubbleStorm;
class BubbleMaster;
class BasicBubbleType;
class PersistentBubbleType;
class InstantBubbleType;
class ID;
class Measurement;
class NotificationReceiver;
class NotificationResult;
class NotificationSender;
class Query;
class QueryRespond;

//
// Library open & close functions
//

void bsInit();
void bsInit(int argc, const char** argv);
void bsShutdown();
bool bsIsInitialized();

//
// BubbleStorm API classes
//


class BubbleStorm {
	public:
		/// (bootstrap is optinal, may be invalid)
		static BubbleStorm create(float bandwidth, float minBandwidth,
				const CUSP::Address& bootstrap, int port,
				CUSP::PrivateKey key = CUSP::PrivateKey::create(), bool encrypt = true);
		static BubbleStorm createWithEndpoint(float bandwidth, float minBandwidth,
				const CUSP::Address& bootstrap, CUSP::EndPoint& endpoint);
		static void setLanMode(bool enable);
		
		BubbleStorm();
		BubbleStorm(const BubbleStorm& bs);
		~BubbleStorm();
		void swap(BubbleStorm& bs);
		/// Assignment operator.
		BubbleStorm& operator =(const BubbleStorm& bs);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		class JoinHandler {
			public:
				virtual void onJoinComplete() = 0;
		};
		class LeaveHandler {
			public:
				virtual void onLeaveComplete() = 0;
		};
		
		void createRing(const CUSP::Address& localAddr, JoinHandler* handler = NULL);
		void join(JoinHandler* handler);
		void leave(LeaveHandler* handler);
		
		CUSP::EndPoint endpoint() const;
		BubbleMaster bubbleMaster() const;
		CUSP::Address address() const;
	
	private:
		Handle handle;
		BubbleStorm(Handle handle);
		
		static void joinCallback(CPointer userData);
		static void leaveCallback(CPointer userData);
};


/// FIXME documentation
/// Represents a bubble type. On {@link Topology} the application has to provide
/// a set of bubble types which it intends to use.
/// <p>
/// First, the bubble type specifies the (optional) application-level handler
/// for incoming bubbles. Second, pairs of bubble types (typically data/query
/// pairs) have to be {@link #match(BubbleType, float, MatchHandler) matched} to
/// that the bubble balancer computes their sizes to guarantee a certain match
/// probability.
/// </p>
///
class BasicBubbleType {
	public:
		BasicBubbleType();
		BasicBubbleType(Handle handle);
		/// Copy constructor. Creates a new handle on SML side.
		BasicBubbleType(const BasicBubbleType& bt);
		/// Destructor. Frees SML handle.
		virtual ~BasicBubbleType();
		void swap(BasicBubbleType& bt);
		/// Assignment operator.
		BasicBubbleType& operator =(const BasicBubbleType& bt);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		class BubbleHandler {
			public:
				virtual void onBubble(const uint8_t* data, int dataLen) = 0;
		};
		
		int typeId() const;
		int defaultSize() const;
		
		void match(PersistentBubbleType& with, double lambda, BubbleHandler* handler);

	private:
		Handle handle;

		static void bubbleCallback(Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData);
		friend class BubbleMaster;
};


class PersistentBubbleType : public BasicBubbleType {
	public:
		PersistentBubbleType();
		PersistentBubbleType(Handle handle, Handle basicHandle);
		/// Copy constructor. Creates a new handle on SML side.
		PersistentBubbleType(const PersistentBubbleType& bt);
		/// Destructor. Frees SML handle.
		virtual ~PersistentBubbleType();
		void swap(PersistentBubbleType& bt);
		/// Assignment operator.
		PersistentBubbleType& operator =(const PersistentBubbleType& bt);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		class BubbleHandlerWithId {
			public:
				virtual void onBubble(ID id, const uint8_t* data, int dataLen) = 0;
		};
		
		void matchWithId(PersistentBubbleType& with, double lambda, BubbleHandlerWithId* handler);

	private:
		Handle handle;

		static void bubbleWithIdCallback(Handle idHandle, Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData);
		friend class BubbleMaster;
};


class InstantBubbleType : public BasicBubbleType {
	public:
		InstantBubbleType();
		InstantBubbleType(Handle handle);
		/// Copy constructor. Creates a new handle on SML side.
		InstantBubbleType(const InstantBubbleType& bt);
		/// Destructor. Frees SML handle.
		virtual ~InstantBubbleType();
		void swap(InstantBubbleType& bt);
		/// Assignment operator.
		InstantBubbleType& operator =(const InstantBubbleType& bt);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		void createBubble(const uint8_t* data, int dataLen);

	private:
		Handle handle;
};


class FadingBubbleType : public PersistentBubbleType {
	public:
		FadingBubbleType();
		FadingBubbleType(Handle handle);
		/// Copy constructor. Creates a new handle on SML side.
		FadingBubbleType(const FadingBubbleType& bt);
		/// Destructor. Frees SML handle.
		virtual ~FadingBubbleType();
		void swap(FadingBubbleType& bt);
		/// Assignment operator.
		FadingBubbleType& operator =(const FadingBubbleType& bt);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		void createBubble(const ID& id, const uint8_t* data, int dataLen);

	private:
		Handle handle;
};


// class BubbleType {
// 	public:
// 		BubbleType();
// 		BubbleType(Handle handle);
// 		/// Copy constructor. Creates a new handle on SML side.
// 		BubbleType(const BubbleType& bt);
// 		/// Destructor. Frees SML handle.
// 		~BubbleType();
// 		void swap(BubbleType& bt);
// 		/// Assignment operator.
// 		BubbleType& operator =(const BubbleType& bt);
// 		/// Checks for handle validity. Any methods operating on
// 		/// the object will only work if this method returns true.
// 		bool isValid() const;
// 		/// Returns the SML handle. For internal use only.
// 		Handle getHandle() const { return handle; };
// 		
// 		class BubbleHandlerWithId {
// 			public:
// 				virtual void onBubble(ID id, const uint8_t* data, int dataLen) = 0;
// 		};
// 		class BubbleHandlerWithoutId {
// 			public:
// 				virtual void onBubble(const uint8_t* data, int dataLen) = 0;
// 		};
// 		
// 		int id() const;
// 		int defaultSize() const;
// 		
// 		void matchWithId(BubbleType& with, double lambda, BubbleHandlerWithId* handler);
// 		void matchWithoutId(BubbleType& with, double lambda, BubbleHandlerWithoutId* handler);
// 		
// 		void bubblecast(const uint8_t* data, int dataLen);
// 		void bubblecast(int size, const uint8_t* data, int dataLen);
// 		void bubblecastWithId(ID& id, const uint8_t* data, int dataLen);
// 		void bubblecastWithId(int size, ID& id, const uint8_t* data, int dataLen);
// 
// 	private:
// 		Handle handle;
// 
// 		static void bubbleWithIdCallback(Handle idHandle, Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData);
// 		static void bubbleWithoutIdCallback(Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData);
// 		friend class BubbleManager;
// };


class BubbleMaster {
	public:
		BubbleMaster();
		BubbleMaster(Handle handle);
		BubbleMaster(const BubbleMaster& bm);
		~BubbleMaster();
		void swap(BubbleMaster& bm);
		BubbleMaster& operator =(const BubbleMaster& bm);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		InstantBubbleType newInstant(int id);
		InstantBubbleType newInstant(int id, float priority);
		FadingBubbleType newFading(int id, PersistentBubbleType::BubbleHandlerWithId* handler);
		FadingBubbleType newFading(int id, float priority, PersistentBubbleType::BubbleHandlerWithId* handler);
	
	private:
		Handle handle;
};


/// ID class
class ID {
	public:
		ID();
		ID(Handle handle);
		/// Copy constructor. Creates a new handle on SML side.
		ID(const ID& id);
		/// Destructor. Frees SML handle.
		~ID();
		void swap(ID& id);
		/// Assignment operator.
		ID& operator =(const ID& id);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		/// Returns the size of an ID (20 bytes).
		static int size() { return 20; };
		
		static ID fromHash(const uint8_t* data, int length);
		static ID fromRandom();
		
		/// Creates an ID from the given data (20 bytes).
		static ID fromBytes(const uint8_t* bytes);
		
		void toBytes(uint8_t* buffer) const;
		bool equals(ID& other) const;
		int hashCode() const;
		std::string toString() const;
	
	private:
		Handle handle;
};


/* /// Measurement class
class Measurement {
	public:
		Measurement();
		Measurement(const Measurement& m);
		/// Destructor. Frees SML handle.
		~Measurement();
		void swap(Measurement& m);
		/// Assignment operator.
		Measurement& operator =(const Measurement& m);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;

		class PullHandler {
			public:
				virtual float pull() = 0;
		};

		class PushHandler {
			public:
				virtual void push(float value) = 0;
		};

		static Measurement create(const int64_t interval);
		void sum(const PullHandler* pullHandler, const PushHandler* pushHandler);
		void max(const PullHandler* pullHandler, const PushHandler* pushHandler);

		Handle getHandle();

	private:
		Handle handle;
		Measurement(Handle handle);

		static float pullCallback(void* userData);
		static void pushCallback(float value, void* userData);
}; */


/// NotificationReceiver class
class NotificationReceiver {
	public:
		NotificationReceiver();
		NotificationReceiver(const NotificationReceiver& n);
		~NotificationReceiver();
		void swap(NotificationReceiver& n);
		NotificationReceiver& operator =(const NotificationReceiver& n);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
/*		class LocalAddressProvider {
			public:
				virtual CUSP::Address getLocalAddress() = 0;
		};*/
		class ResultReceiver {
			public:
				virtual void onResult(NotificationResult& result) = 0;
		};
		
		/// Creates a new notification object.
		/// localAddrProvider should alwys provide the recent local addres (e.g. retrieved via BubbleStorm::address()).
		/// resultReceiver will be invoked for each incoming notification.
		static NotificationReceiver create(CUSP::EndPoint& endpoint, /*LocalAddressProvider* localAddrProvider,*/
				ResultReceiver* resultReceiver);
		/// Closes the notification object, i.e., no more results will be received.
		void close();
		/// Returns the maximum number of bytes an encoded notification may take.
		static int maxEncodedLength();
		/// Encodes the notification callback data into a byte buffer.
		/// bufSize specifies the buffer size and should be set to at least the return value of maxEncodedLength().
		/// Returns the number of bytes written.
		int encode(const CUSP::Address& localAddr, uint8_t* buffer, int bufSize) const;
		/// Decodes a previously encoded notification callback.
		static NotificationSender decode(const uint8_t* data, int& dataLen, CUSP::EndPoint& endpoint);
	
	private:
		Handle handle;
		NotificationReceiver(Handle handle);
		
// 		static Handle getLocalAddrCallback(void* userData);
		static void resultReceiverCallback(Handle resultHandle, void* userData);
};

/// NotificationResult class
class NotificationResult {
	public:
		NotificationResult();
		NotificationResult(const NotificationResult& n);
		~NotificationResult();
		void swap(NotificationResult& n);
		NotificationResult& operator =(const NotificationResult& n);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		/// Returns the result ID (the ID associated with the result payload).
		ID id() const;
		/// Returns the payload stream.
		/// Either this method or cancel() must be called exactly once on each received result!
		CUSP::InStream payload();
		/// Indicates that the result payload is not required.
		/// Either this method or payload() must be called exactly once on each received result!
		void cancel();
	
	private:
		Handle handle;
		NotificationResult(Handle handle);
		friend class NotificationReceiver;
};

/// NotificationSender class
class NotificationSender {
	public:
		NotificationSender();
		NotificationSender(const NotificationSender& n);
		~NotificationSender();
		void swap(NotificationSender& n);
		NotificationSender& operator =(const NotificationSender& n);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		class Handler {
			public:
				/// Invoked to indicate that the result payload should be written.
				virtual void getData(CUSP::OutStream& os) = 0;
				/// Invoked to indicated that the result payload is not required.
				virtual void abort() = 0;
		};
		
		/// Sends a result.
		void send(ID& id, Handler* handler);
		/// Sends a result and immediately pushes the payload.
		void sendImmediate(ID& id, const uint8_t* data, int dataLen);
	
	private:
		Handle handle;
		NotificationSender(Handle handle);
		friend class NotificationReceiver;
		
		static void sendCallback(Handle osHandle, void* userData);
};


/// Query class
class Query {
	public:
		Query();
		Query(const Query& q);
		/// Destructor. Frees SML handle.
		~Query();
		void swap(Query& q);
		/// Assignment operator.
		Query& operator =(const Query& q);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		class Responder {
			public:
				virtual void respond(const uint8_t* data, int length, QueryRespond* queryRespond) = 0;
		};
		class ResponseReceiver {
			public:
				virtual void onResponse(ID& id, CUSP::InStream& stream) = 0;
		};
		
		static Query create(BubbleMaster& master, PersistentBubbleType& dataBubble, int queryBubbleId,
				float lambda, Responder* responder);
		/// Executes a query.
		/// receiver may be set to NULL.
		Abortable query(uint8_t* queryData, int length, ResponseReceiver* receiver);
	
	private:
		Handle handle;
		Query(Handle handle);
		
		static void createQueryCallback(Vector(Word8_t) data, Int32_t offset, Int32_t length,
				Handle queryRespondHandle, void* userData);
		static void queryCallback(Handle idHandle, Handle streamHandle, void* userData);
};


/// QueryRespond class
class QueryRespond
{
	public:
		QueryRespond();
		QueryRespond(Handle handle);
		QueryRespond(const QueryRespond& q);
		/// Destructor. Frees SML handle.
		~QueryRespond();
		void swap(QueryRespond& q);
		/// Assignment operator.
		QueryRespond& operator =(const QueryRespond& q);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		class Writer {
			public:
				virtual void write(CUSP::OutStream& stream) = 0;
				virtual void abort() = 0;
		};
		
		void respond(ID& id, Writer* writer);
	
	private:
		Handle handle;
		
		static void respondCallback(Handle osHandle, void* userData);
};

}; // end of namespace BS

#endif
