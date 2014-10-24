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
// C++ wrapper for the CUSP C-bindings
//
// Author: Max Lehn
//

#ifndef CUSP_BASE_H
#define CUSP_BASE_H

/*! \mainpage CUSP
 *
 * CUSP is a reliable and secure general purpose transport designed with peer-to-peer
 * (P2P) networking in mind. While many transport protocols have been proposed in the past,
 * we believe ours is the first systematically designed to address the specific
 * requirements of P2P applications. We designed CUSP for P2P partly because we believe
 * that P2P covers the requirements of many modern network applications. P2P applications
 * exhibit asynchronous, dynamic, and complex interactions with a large number of
 * communication partners. We believe that many (if not most) existing Internet
 * applications would have benefited from a protocol like CUSP during their design.
 *
 * Building upon ideas from SST and SCTP, CUSP separates low-level packet management from
 * streams into reusable channels. The stream interface allows application designers to
 * directly express application logic in the message flow. Streams are cheap, created
 * without a round trip and thus need not be used sparingly. As not all messages expect an
 * immediate or direct answer, streams in CUSP are unidirectional; bidirectional streams
 * are modelled on top of this primitive. Applications prioritize streams individually,
 * allowing high priority streams to cut in line.
 *
 * CUSP is implemented on top of UDP making it easy to deploy and reuse established NAT
 * traversal mechanisms. The protocol also offers mobile IP support, seamlessly
 * renegotiating channels and resuming streams. The channel layer has built-in cryptography;
 * assured authenticity simplifies its design and cryptographic negotiation is streamlined
 * into channel creation. Despite being feature-rich, CUSP is a simple protocol and can be
 * implemented in comparably few lines of code.
 *
 * Project website: http://www.dvs.tu-darmstadt.de/research/cusp/
 *
 */

#include <string>

namespace BS {
namespace CUSP {

//
// Basic types
//
   
/// Transport protocol service identifier.
typedef uint16_t ServiceId;
   
//
// CUSP classes
//

// forward declarations
class EndPoint;
class Address;
class Host;
class InStream;
class OutStream;
class PublicKey;
class PrivateKey;
class PublicKeySuite;
class PublicKeySuiteSet;
class SymmetricSuite;
class SymmetricSuiteSet;


/// Inbound stream.
class InStream
{
	public:
		InStream();
		InStream(Handle handle);
		InStream(const InStream& is);
		~InStream();
		void swap(InStream& s);
		InStream& operator =(const InStream& s);
		bool isValid() const;
		
		Handle getHandle() const { return handle; };
		
		/// Handler interface for read().
		class ReadHandler {
			public:
				/// Invoked when data is received.
				virtual void onReceive(const void* data, int size) = 0;
				/// Invoked when a remote shutdown is received.
				virtual void onShutdown() = 0;
				/// Invoked when the stream is reset. No more reading can be done
				/// after that.
				virtual void onReset() = 0;
		};
		
		/// Reads data from the stream. The maximum number of bytes to receive may
		/// be specified via maxCount.
		void read(ReadHandler* handler, int maxCount = -1);
		/// Resets the stream, ensuring that no more handlers are invoked.
		void reset();
		
		/// Retruns the number of bytes that have been reveived but cannot be
		/// read because they are out of order.
		int queuedOutOfOrder() const;
		/// Retruns the number of bytes waiting to be read.
		int queuedUnread() const;
		/// Returns the total number of bytes received.
		int64_t bytesReceived() const;
	
		/// Iterator over InStream objects.
		class Iterator
		{
			public:
				Iterator();
				Iterator(const Iterator& i);
				~Iterator();
				void swap(Iterator& i);
				Iterator& operator =(const Iterator& i);
				bool isValid() const;
				
				/// Returns whether there is at least one element left.
				bool hasNext() const;
				/// Returns the next element.
				InStream next();
			private:
				Handle handle;
				Iterator(Handle handle);
				friend class Host;
		};
		
	private:
		Handle handle;

		static void readCallback(int32_t count, int32_t ofs, void* data, void* userData);
		friend class EndPoint;
		friend class Host;
};


/// Outbound stream.
class OutStream
{
	public:
		OutStream();
		OutStream(Handle handle);
		OutStream(const OutStream& is);
		~OutStream();
		void swap(OutStream& s);
		OutStream& operator =(const OutStream& s);
		bool isValid() const;
		
		Handle getHandle() const { return handle; };
		
		/// Handler interface for write().
		class WriteHandler {
			public:
				/// Invoked when the stream has become ready to write (after a
				/// previous write).
				virtual void onReady() = 0;
				/// Invoked when the stream is reset from the remote end. No
				/// more writing can be done.
				virtual void onReset() = 0;
		};
		/// Handler interface for shutdown().
		class ShutdownHandler {
			public:
				/// Callback for a shutdown, indicating the success of the
				/// operation.
				virtual void onShutdown(bool success) = 0;
				virtual ~ShutdownHandler() {}
		};
		
		/// Returns the stream's current priority.
		float getPriority() const;
		/// Sets the stream's priority (default: 0).
		void setPriority(float priority);
		/// Writes data. It is not allowed to call this method a second time
		/// before WriteHandler::onReady() is invoked.
		void write(const void* data, int size, WriteHandler* handler);
		/// Shuts down the stream, indicating that no more data will be written.
		/// Can only be called when the stream is ready to write.
		void shutdown(ShutdownHandler* handler);
		/// Resets the stream, ensuring that no more handlers are invoked.
		void reset();
		
		/// Returns the number of buffered bytes awaiting acknowledgment.
		int queuedInflight() const;
		/// Returns the number of bytes waiting to be retransmit.
		int queuedToRetransmit() const;
		/// Returns the total number of bytes sent.
		int64_t bytesSent() const;
		
		/// Iterator over OutStream objects.
		class Iterator
		{
			public:
				Iterator();
				Iterator(const Iterator& i);
				~Iterator();
				void swap(Iterator& i);
				Iterator& operator =(const Iterator& i);
				bool isValid() const;
				
				/// Returns whether there is at least one element left.
				bool hasNext() const;
				/// Returns the next element.
				OutStream next();
			private:
				Handle handle;
				Iterator(Handle handle);
				friend class Host;
		};
		
	private:
		Handle handle;
		static void writeCallback(int32_t status, void* userData);
		static void shutdownCallback(bool success, void* userData);
		friend class EndPoint;
		friend class Host;
};


/// Represents an IP address.
class Address
{
	public:
		/// Creates an adress object from a string ("host" or "host:port").
		/// The default port if none is specified is 8585.
		/// Returns an uninitialized Address on failure.
		static Address fromString(const std::string& str);
		
		/// Uninitialized address constructor. Use fromString() to create
		/// a valid address object.
		Address();
		Address(Handle handle);
		Address(const Address& a);
		~Address();
		void swap(Address& e);
		Address& operator =(const Address& a);
		bool isValid() const;
		
		Handle getHandle() const { return handle; };
		
		/// Formats the address to a string.
		std::string toString() const;

	private:
		Handle handle;

		friend class EndPoint;
		friend class Host;
		friend class Channel;
};


/**
 * Represents a public key encryption suite.
 * To be used with PublicKeySuiteSet.
 */
class PublicKeySuite
{
	public:
		/// Returns whether the object describes a valid suite.
		inline bool isValid() const { return (value && !(value & (value - 1))); };
		/// Returns the name of the suite.
		std::string name() const;
		/// Returns the relative computational cost of the suite.
		float cost() const;
	
	private:
		inline PublicKeySuite(uint16_t value) : value(value) {};
		uint16_t value;
		friend class PublicKeySuiteSet;
		friend class PublicKey;
		friend class PrivateKey;
		friend class EndPoint;
};


/**
 * Represents a set of public key encryption suites.
 * Used with EndPoint, suite sets allow the selection of available
 * encryption implementations during channel negotiation.
 * @see PublicKeySuite
 */
class PublicKeySuiteSet
{
	public:
		/// Returns the set of all available encryption suites.
		static PublicKeySuiteSet all();
		/// Returns the default set of encryption suites.
		/// The default set may not contain all available suites, e.g.
		/// if a particular suite is known to be broken but still
		/// supported for compatibility.
		static PublicKeySuiteSet defaults();
		
		/// Intersects two suite sets.
		inline PublicKeySuiteSet operator& (PublicKeySuiteSet b)
			{ return PublicKeySuiteSet(set & b.set); };
		/// Creates the union of two suite sets.
		inline PublicKeySuiteSet operator| (PublicKeySuiteSet b)
			{ return PublicKeySuiteSet(set | b.set); };
		/// Removes the suites contained in one set from another.
		inline PublicKeySuiteSet operator- (PublicKeySuiteSet b)
			{ return PublicKeySuiteSet(set & ~b.set); };
		/// Checks whether the suite set is empty.
		inline bool isEmpty() const
			{ return (!set); };
		
		/// Checks wether the suite set contains a particular suite.
		inline bool contains(PublicKeySuite s) const
			{ return set & s.value; };
		/// Adds the given suite to the set.
		inline PublicKeySuiteSet operator+ (PublicKeySuite b)
			{ return PublicKeySuiteSet(set | b.value); };
		/// Creates a suite set containing one element.
		inline static PublicKeySuiteSet element(PublicKeySuite s)
			{ return PublicKeySuiteSet(s.value); };
		
		class Iterator
		{
			public:
				Iterator() : set(0) {};
				bool hasNext() const;
				PublicKeySuite next();
			private:
				Iterator(uint16_t set) : set(set) {};
				uint16_t set;
				friend class PublicKeySuiteSet;
		};
		
		/// Returns the cheapest suite from the set.
		/// There may be no valid result; check the return value for
		/// validity (PublicKeySuite::isValid()).
		PublicKeySuite cheapest() const;
		/// Returns an iterator over all contained suites.
		Iterator iterator() const;
		
		/// DO NOT USE
		inline uint16_t toMask() const
			{ return set; };
		/// DO NOT USE
		inline static PublicKeySuiteSet fromMask(uint16_t mask)
			{ return PublicKeySuiteSet(mask); };
	
	private:
		inline PublicKeySuiteSet(uint16_t set) : set(set) {};
		uint16_t set;
		friend class EndPoint;
};


/**
 * Represents a symmetric encryption suite.
 * To be used with SymmetricSuiteSet.
 */
class SymmetricSuite
{
	public:
		/// Returns whether the object describes a valid suite.
		inline bool isValid() const { return (value && !(value & (value - 1))); };
		/// Returns the name of the suite.
		std::string name() const;
		/// Returns the relative computational cost of the suite.
		float cost() const;
	
	private:
		inline SymmetricSuite(uint16_t value) : value(value) {};
		uint16_t value;
		friend class SymmetricSuiteSet;
		friend class EndPoint;
};


/**
 * Represents a set of symmetric encryption suites.
 * Used with EndPoint, suite sets allow the selection of available
 * encryption implementations during channel negotiation.
 * @see SymmetricSuite
 */
class SymmetricSuiteSet
{
	public:
		/// Returns the set of all available encryption suites.
		static SymmetricSuiteSet all();
		/// Returns the default set of encryption suites.
		/// The default set may not contain all available suites, e.g.
		/// if a particular suite is known to be broken but still
		/// supported for compatibility.
		static SymmetricSuiteSet defaults();
		
		/// Intersects two suite sets.
		inline SymmetricSuiteSet operator& (SymmetricSuiteSet b)
			{ return SymmetricSuiteSet(set & b.set); };
		/// Creates the union of two suite sets.
		inline SymmetricSuiteSet operator| (SymmetricSuiteSet b)
			{ return SymmetricSuiteSet(set | b.set); };
		/// Removes the suites contained in one set from another.
		inline SymmetricSuiteSet operator- (SymmetricSuiteSet b)
			{ return SymmetricSuiteSet(set & ~b.set); };
		/// Checks whether the suite set is empty.
		inline bool isEmpty() const
			{ return (!set); };
		
		/// Checks wether the suite set contains a particular suite.
		inline bool contains(SymmetricSuite s) const
			{ return set & s.value; };
		/// Adds the given suite to the set.
		inline SymmetricSuiteSet operator+ (SymmetricSuite b)
			{ return SymmetricSuiteSet(set | b.value); };
		/// Creates a suite set containing one element.
		inline static SymmetricSuiteSet element(SymmetricSuite s)
			{ return SymmetricSuiteSet(s.value); };
		
		class Iterator
		{
			public:
				Iterator() : set(0) {};
				bool hasNext() const;
				SymmetricSuite next();
			private:
				Iterator(uint16_t set) : set(set) {};
				uint16_t set;
				friend class SymmetricSuiteSet;
		};
		
		/// Returns the cheapest suite from the set.
		/// There may be no valid result; check the return value for
		/// validity (SymmetricSuite::isValid()).
		SymmetricSuite cheapest() const;
		/// Returns an iterator over all contained suites.
		Iterator iterator() const;
		
		/// DO NOT USE
		inline uint16_t toMask() const
			{ return set; };
		/// DO NOT USE
		inline static SymmetricSuiteSet fromMask(uint16_t mask)
			{ return SymmetricSuiteSet(mask); };
	
	private:
		inline SymmetricSuiteSet(uint16_t set) : set(set) {};
		uint16_t set;
		friend class EndPoint;
};


/// A public key.
class PublicKey
{
	public:
		/// Uninitialized endpoint constructor.
		PublicKey();
		/// Copy constructor. Creates a new handle on SML side.
		PublicKey(const PublicKey& k);
		/// Destructor. Frees SML handle.
		~PublicKey();
		/// Swaps the given object with this one.
		void swap(PublicKey& k);
		/// Asignment operator.
		PublicKey& operator =(const PublicKey& k);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		
		Handle getHandle() const { return handle; };
		
		/// Returns the key as a string.
		std::string toString() const;
		/// Returns the suite to which the key belongs.
		PublicKeySuite suite() const;
		
	private:
		Handle handle;
		PublicKey(Handle handle);
		friend class PrivateKey;
		friend class Host;
};


/// A private key for public key encryption.
class PrivateKey
{
	public:
		/// Uninitialized endpoint constructor. Use the create() method
		/// to create a usable key.
		PrivateKey();
		/// Copy constructor. Creates a new handle on SML side.
		PrivateKey(const PrivateKey& k);
		/// Destructor. Frees SML handle.
		~PrivateKey();
		/// Swaps the given object with this one.
		void swap(PrivateKey& k);
		/// Asignment operator.
		PrivateKey& operator =(const PrivateKey& k);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		
		Handle getHandle() const { return handle; };
		
		/// Creates a new (random) private key.
		static PrivateKey create();
		/// Saves the key to a string encrypted by password.
		/// @see load()
		std::string save(const std::string& password) const;
		/// Restores a previously saved string.
		/// @see save()
		static PrivateKey load(const std::string& key, const std::string password);
		/// Retruns the public key for the given suite.
		PublicKey pubkey(PublicKeySuite suite) const;
		
	private:
		Handle handle;
		PrivateKey(Handle handle);
		friend class EndPoint;
};


/// Represents a remote host.
class Host
{
	public:
		Host();
		Host(const Host& h);
		~Host();
		void swap(Host& h);
		Host& operator =(const Host& h);
		bool isValid() const;
		
		Handle getHandle() const { return handle; };
		
		/// Handler interface for listen().
		class ListenHandler {
			public:
				/// Invoked when the remote host creates an instream.
				virtual void onConnect(ServiceId service, InStream& stream) = 0;
		};
		
		/// Creates an outstream to the remote host. The stream is immediately
		/// returned an is ready for write.
		OutStream connect(ServiceId service);
		/// Listens for incoming streams only from the host represented by this
		/// object. The service ID is returned by this method.
		ServiceId listen(ListenHandler* handler);
		/// Stops listening for the given service.
		void unlisten(const ServiceId service);
		/// Returns the public key of the remote host.
		PublicKey key() const;
		/// Returns the key of the remote host.
		std::string keyStr() const;
		/// Returns the host's remote IP address or an invalid address if the
		/// address is unknown.
		Address address() const;
		/// Reaturns a string representation for the host containing the
		/// remote host key and IP address.
		std::string toString() const;
		
		/// Returns an iterator over all attached instreams.
		InStream::Iterator inStreams() const;
		/// Returns an iterator over all attached outstreams.
		OutStream::Iterator outStreams() const;
		
		/// Retruns the number of bytes that have been reveived but cannot be
		/// read because they are out of order.
		int queuedOutOfOrder() const;
		/// Retruns the number of bytes waiting to be read.
		int queuedUnread() const;
		/// Returns the number of buffered bytes awaiting acknowledgment.
		int queuedInflight() const;
		/// Returns the number of bytes waiting to be retransmit.
		int queuedToRetransmit() const;
		/// Returns the total number of bytes received.
		int64_t bytesReceived() const;
		/// Returns the total number of bytes sent.
		int64_t bytesSent() const;
		/// Retruns the time of last receiving a packet.
		Time lastReceive() const;
		/// Retruns the time of last sending a packet.
		Time lastSend() const;
		
		/// Iterator over Host objects.
		class Iterator
		{
			public:
				Iterator();
				Iterator(const Iterator& i);
				~Iterator();
				void swap(Iterator& i);
				Iterator& operator =(const Iterator& i);
				bool isValid() const;
				
				Handle getHandle() const { return handle; };
				
				/// Returns whether there is at least one element left.
				bool hasNext() const;
				/// Returns the next element.
				Host next();
			private:
				Handle handle;
				Iterator(Handle handle);
				friend class EndPoint;
		};
	
	private:
		Handle handle;
		Host(Handle handle);
		static void listenCallback(ServiceId service, Handle instreamHandle, void* userData);
		friend class EndPoint;
		friend class Channel;
};


/// A channel, constisting of a remote address and possibly a host object
/// describing the connected remote host.
class Channel
{
	public:
		/// The remote IP address.
		Address address() const { return addr; };
		/// The host object to which the channel connects.
		/// May be invalid if the cahnnel is not connected (yet).
		Host host() const { return h; };
		
		Channel(Address& address, Host& host) : addr(address), h(host) {}
		
		class Iterator
		{
			public:
				Iterator();
				Iterator(const Iterator& i);
				~Iterator();
				void swap(Iterator& i);
				Iterator& operator =(const Iterator& i);
				bool isValid() const;
				
				Handle getHandle() const { return handle; };
				
				/// Returns whether there is at least one element left.
				bool hasNext() const;
				/// Returns the next element.
				Channel next();
			private:
				Handle handle;
				Iterator(Handle handle);
				friend class EndPoint;
		};
	
	private:
		Address addr;
		Host h;
};


/// An EndPoint is the local connection point for the transport protocol.
class EndPoint
{
	public:
		/**
		 * Creates a new endpoint.
		 * Returns an uninitialized EndPoint on failure.
		 * @param port the UDP bind port for the endpoint, -1 for any.
		 * @param key the private key for the endpoint. The default value is a new
		 *        random key.
		 * @param encrypt optionally disables ecryption when set to <code>false</code>.
		 *        Note: Encryption an a particular channel is only turned off if both
		 *        sides agree that they do not require encryption.
		 * @param publicKeySuites allows the explicit selection of public key encryption suites
		 *        that are allowed to be used.
		 * @param symmetricSuites allows the explicit selection of symmetric encryption suites
		 *        that are allowed to be used.
		 */
		static EndPoint create(int port = -1,
				PrivateKey key = PrivateKey::create(),
				bool encrypt = true,
				PublicKeySuiteSet publicKeySuites = PublicKeySuiteSet::defaults(),
				SymmetricSuiteSet symmetricSuites = SymmetricSuiteSet::defaults());
		
		/// Uninitialized endpoint constructor. Use the create() method
		/// to create a usable endpoint.
		EndPoint();
		EndPoint(Handle handle);
		/// Copy constructor. Creates a new handle on SML side.
		EndPoint(const EndPoint& e);
		/// Destructor. Frees SML handle.
		~EndPoint();
		/// Swaps the given endpoint with this one.
		void swap(EndPoint& e);
		/// Asignment operator.
		EndPoint& operator =(const EndPoint& e);
		/// Checks for endpoint (handle) validity. Any methods operating on
		/// the end point will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		/// Handler interface for whenSafeToDestroy().
		class SafeToDestroyHandler {
			public:
				/// Invoked when it is safe to destroy the endpoint.
				virtual void onSafeToDestroy() = 0;
		};
		/// Handler interface for contact().
		class ContactHandler {
			public:
				/// Invoked on successful contact. The Host object may be
				/// used to create further streams.
				virtual void onContact(Host& host, OutStream& os) = 0;
				/// Invoked if contacting the host has failed (timeout etc.).
				virtual void onContactFail() = 0;
		};
		/// Handler interface for advertise().
		class AdvertiseHandler {
			public:
				/// Invoked when a remote host connects to a service.
				virtual void onConnect(Host& host, InStream& stream) = 0;
		};
		
		/// Destroys the endpoint and closes the socket.
		/// Further use of the endpoint or any of its hosts/streams/etc.
		/// results in undefined behavior.
		/// It is not recommended to call destroy() before the handler
		/// of whenSafeToDestroy() was invoked.
		/// @see whenSafeToDestroy()
		void destroy();
		/// Invokes the handler when it is safe to destroy the endpoint.
		/// @see destroy()
		Abortable whenSafeToDestroy(SafeToDestroyHandler* handler) const;
// 		/// Sets the transmission rate limit (bytes/second).
// 		void setRate(int rate);
		/// Returns the local private key
		PrivateKey key() const;
		/// Returns the local local public key for the given suite.
		std::string publicKeyStr(PublicKeySuite suite) const;
		/// Returns the number of bytes sent.
		int64_t bytesSent() const;
		/// Returns the number of bytes received.
		int64_t bytesReceived() const;
		/// Contacts a remote host given by its address. On success,
		/// a Host object and a stream (to the given service) to that peer
		/// are created.
		Abortable contact(const Address& addr, ServiceId service, ContactHandler* handler);
		// TODO?
		// Host host(pubkey)
		/// Returns an iterator for all known hosts.
		Host::Iterator hosts() const;
		/// Returns an iterator for all channels.
		Channel::Iterator channels() const;
		/// Advertises a service for a given Id (like TCP's listen).
		/// Valid service IDs are in the range 0..32767.
		void advertise(const ServiceId service, AdvertiseHandler* handler);
		/// Closes an advertised service.
		void unadvertise(const ServiceId service);

	private:
		Handle handle;
		static void safeToDestroyCallback(void* userData);
		static void contactCallback(Handle hostHandle, Handle osHandle, void* userData);
		static void advertiseCallback(Handle hostHandle, Handle streamHandle, void* userData);
		friend class Channel;
};


class UDP
{
	public:
		class DataReadyHandler {
			public:
			/// Invoked when data is available for read.
			virtual void onDataReady() = 0;
		};
		
		static UDP create(DataReadyHandler* dataReady);
		static UDP create(int port, DataReadyHandler* dataReady);
		
		/// Uninitialized endpoint constructor. Use the create() method
		/// to create a usable endpoint.
		UDP();
		UDP(Handle handle);
		/// Copy constructor. Creates a new handle on SML side.
		UDP(const UDP& u);
		/// Destructor. Frees SML handle.
		~UDP();
		/// Swaps the given endpoint with this one.
		void swap(UDP& u);
		/// Asignment operator.
		UDP& operator =(const UDP& u);
		/// Checks for endpoint (handle) validity. Any methods operating on
		/// the end point will only work if this method returns true.
		bool isValid() const;
		/// Returns the SML handle. For internal use only.
		Handle getHandle() const { return handle; };
		
		bool send(const Address& addr, const void* data, int size);
		const void* recv(Address& addr, int& size);

	private:
		Handle handle;
		static void dataReadyCallback(void* userData);
};

};}; // namespace BS::CUSP

#endif
