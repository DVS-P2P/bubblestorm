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

#include "bubblestorm/bubblestorm.h"

#include "assert.h"

#include "common/bscommon.cpp"
#include "cusp/cusp-base.cpp"

#include <cstdio>
#include <cmath>

namespace BS {

using namespace CUSP;

//
// Library open & close functions
//

unsigned int openCounter = 0;

void bsInit()
{
	if (openCounter == 0) {
		// HACK: pass one argument as a workaround for LogCommandLine bug
		const char* argv[] = { "", NULL };
		bubblestorm_open(1, argv);
	}
	openCounter++;
}

void bsInit(int argc, const char** argv)
{
	// parameters can only be passed in first open call
	assert(openCounter == 0);
	bubblestorm_open(argc, argv);
	openCounter++;
}

void bsShutdown()
{
	assert(openCounter > 0);
	openCounter--;
	if (openCounter == 0) {
		bubblestorm_close();
	}
}

bool bsIsInitialized()
{
	return (openCounter > 0);
}

// CUSP compatibility functions
void cuspInit() { bsInit(); }
void cuspInit(int argc, const char** argv) { bsInit(argc, argv); }
void cuspShutdown() { bsShutdown(); }

//
// BubbleStorm
//

BubbleStorm BubbleStorm::create(float bandwidth, float minBandwidth, const Address& bootstrap, int port,
		PrivateKey key, bool encrypt)
{
	Handle h = checkResult(bs_bubblestorm_new(bandwidth, minBandwidth, port, key.getHandle(), encrypt));
	// FIXME old API compatibility: bootstrap node should be passed by loadHostcache()
	if (IS_VALID_HANDLE(h)) {
		bs_bubblestorm_load_hostcache(h, NULL, 0, bootstrap.getHandle());
	}
	//
	return BubbleStorm(h);
}

BubbleStorm BubbleStorm::createWithEndpoint(float bandwidth, float minBandwidth, const Address& bootstrap, EndPoint& endpoint)
{
	Handle h = checkResult(bs_bubblestorm_new_with_endpoint(bandwidth, minBandwidth, endpoint.getHandle()));
	// FIXME old API compatibility: bootstrap node should be passed by loadHostcache()
	if (IS_VALID_HANDLE(h)) {
		bs_bubblestorm_load_hostcache(h, NULL, 0, bootstrap.getHandle());
	}
	//
	return BubbleStorm(h);
}

void BubbleStorm::setLanMode(bool enable)
{
	checkResult(bs_bubblestorm_set_lan_mode(enable));
}

BubbleStorm::BubbleStorm()
	: handle(HANDLE_NONE)
{
}

BubbleStorm::BubbleStorm(const BubbleStorm& bs)
{
	if (IS_VALID_HANDLE(bs.handle)) {
		handle = bs_bubblestorm_dup(bs.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

BubbleStorm::BubbleStorm(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

BubbleStorm::~BubbleStorm()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_bubblestorm_free(handle));
}

void BubbleStorm::swap(BubbleStorm& bs)
{
	std::swap(bs.handle, handle);
}

BubbleStorm& BubbleStorm::operator =(const BubbleStorm& bs)
{
	BubbleStorm nbs(bs);
	swap(nbs);
	return *this;
}

bool BubbleStorm::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void BubbleStorm::createRing(const Address& localAddr, JoinHandler* handler)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_bubblestorm_create(handle, localAddr.getHandle(), (void*) joinCallback, handler));
}

void BubbleStorm::join(JoinHandler* handler)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_bubblestorm_join(handle, (void*) joinCallback, handler));
}

void BubbleStorm::leave(LeaveHandler* handler)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_bubblestorm_leave(handle, (void*) leaveCallback, handler));
}

EndPoint BubbleStorm::endpoint() const
{
	ASSERT_HANDLE(handle);
	Handle h = checkResult(bs_bubblestorm_endpoint(handle));
	return EndPoint(h);
}

BubbleMaster BubbleStorm::bubbleMaster() const
{
	ASSERT_HANDLE(handle);
	Handle h = checkResult(bs_bubblestorm_bubblemaster(handle));
	return BubbleMaster(h);
}

Address BubbleStorm::address() const
{
	ASSERT_HANDLE(handle);
	Handle h = checkResult(bs_bubblestorm_address(handle));
	if (IS_VALID_HANDLE(h))
		return Address(h);
	else
		return Address();
}

void BubbleStorm::joinCallback(CPointer userData)
{
	if (userData)
		((JoinHandler*) userData)->onJoinComplete();
}

void BubbleStorm::leaveCallback(CPointer userData)
{
	if (userData)
		((LeaveHandler*) userData)->onLeaveComplete();
}

//
// BasicBubbleType
//

BasicBubbleType::BasicBubbleType()
	: handle(HANDLE_NONE)
{
}

BasicBubbleType::BasicBubbleType(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

BasicBubbleType::BasicBubbleType(const BasicBubbleType& bt)
{
	if (IS_VALID_HANDLE(bt.handle)) {
		handle = bs_bubbletype_basic_dup(bt.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

BasicBubbleType::~BasicBubbleType()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_bubbletype_basic_free(handle));
}

void BasicBubbleType::swap(BasicBubbleType& bt)
{
	std::swap(bt.handle, handle);
}

BasicBubbleType& BasicBubbleType::operator =(const BasicBubbleType& bt)
{
	BasicBubbleType nbt(bt);
	swap(nbt);
	return *this;
}

bool BasicBubbleType::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

int BasicBubbleType::typeId() const
{
	ASSERT_HANDLE(handle);
	int id = checkResult(bs_bubbletype_basic_typeid(handle));
	assert(id >= 0);
	return id;
}

int BasicBubbleType::defaultSize() const
{
	ASSERT_HANDLE(handle);
	return checkResult(bs_bubbletype_basic_default_size(handle));
}

void BasicBubbleType::match(PersistentBubbleType& with, double lambda, BubbleHandler* handler)
{
	ASSERT_HANDLE(handle);
	assert(handler);
	checkResult(bs_bubbletype_basic_match(handle, with.getHandle(), lambda,
			(void*) bubbleCallback, handler));
}

void BasicBubbleType::bubbleCallback(Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData)
{
	assert(userData);
	// have to copy data which could be garbage collected after next ML call
	uint8_t* buf = (uint8_t*) malloc((size_t) len);
	assert(buf);
	memcpy(buf, ((uint8_t*) data) + ofs, (size_t) len);
	((BubbleHandler*) userData)->onBubble(buf, len);
	free(buf);
}

//
// PersistentBubbleType
//

PersistentBubbleType::PersistentBubbleType()
	: BasicBubbleType(), handle(HANDLE_NONE)
{
}

PersistentBubbleType::PersistentBubbleType(Handle handle, Handle basicHandle)
	: BasicBubbleType(basicHandle), handle(handle)
{
	ASSERT_HANDLE(handle);
}

PersistentBubbleType::PersistentBubbleType(const PersistentBubbleType& bt)
	: BasicBubbleType(bt)
{
	if (IS_VALID_HANDLE(bt.handle)) {
		handle = bs_bubbletype_persistent_dup(bt.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

PersistentBubbleType::~PersistentBubbleType()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_bubbletype_persistent_free(handle));
}

void PersistentBubbleType::swap(PersistentBubbleType& bt)
{
	BasicBubbleType::swap(bt);
	std::swap(bt.handle, handle);
}

PersistentBubbleType& PersistentBubbleType::operator =(const PersistentBubbleType& bt)
{
	PersistentBubbleType nbt(bt);
	swap(nbt);
	return *this;
}

bool PersistentBubbleType::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void PersistentBubbleType::matchWithId(PersistentBubbleType& with, double lambda, BubbleHandlerWithId* handler)
{
	ASSERT_HANDLE(handle);
	assert(handler);
	checkResult(bs_bubbletype_persistent_match_with_id(handle, with.getHandle(), lambda,
			(void*) bubbleWithIdCallback, handler));
}

void PersistentBubbleType::bubbleWithIdCallback(Handle idHandle, Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData)
{
	assert(userData);
	// have to copy data which could be garbage collected after next ML call
	uint8_t* buf = (uint8_t*) malloc((size_t) len);
	assert(buf);
	memcpy(buf, ((uint8_t*) data) + ofs, (size_t) len);
	ID id(idHandle);
	((BubbleHandlerWithId*) userData)->onBubble(id, buf, len);
	free(buf);
}

//
// InstantBubbleType
//

InstantBubbleType::InstantBubbleType()
	: BasicBubbleType(), handle(HANDLE_NONE)
{
}

InstantBubbleType::InstantBubbleType(Handle handle)
	: BasicBubbleType(bs_bubbletype_instant_basic(handle)), handle(handle)
{
	ASSERT_HANDLE(handle);
	ASSERT_HANDLE(BasicBubbleType::getHandle());
}

InstantBubbleType::InstantBubbleType(const InstantBubbleType& bt)
	: BasicBubbleType(bt)
{
	if (IS_VALID_HANDLE(bt.handle)) {
		handle = bs_bubbletype_instant_dup(bt.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

InstantBubbleType::~InstantBubbleType()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_bubbletype_basic_free(handle));
}

void InstantBubbleType::swap(InstantBubbleType& bt)
{
	BasicBubbleType::swap(bt);
	std::swap(bt.handle, handle);
}

InstantBubbleType& InstantBubbleType::operator =(const InstantBubbleType& bt)
{
	InstantBubbleType nbt(bt);
	swap(nbt);
	return *this;
}

bool InstantBubbleType::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void InstantBubbleType::createBubble(const uint8_t* data, int dataLen)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_bubble_instant_create(handle, (uint8_t*) data, dataLen));
}

//
// FadingBubbleType
//

FadingBubbleType::FadingBubbleType()
	: PersistentBubbleType(), handle(HANDLE_NONE)
{
}

FadingBubbleType::FadingBubbleType(Handle handle)
	: PersistentBubbleType(bs_bubbletype_fading_persistent(handle), bs_bubbletype_fading_basic(handle)), handle(handle)
{
	ASSERT_HANDLE(handle);
}

FadingBubbleType::FadingBubbleType(const FadingBubbleType& bt)
	: PersistentBubbleType(bt)
{
	if (IS_VALID_HANDLE(bt.handle)) {
		handle = bs_bubbletype_fading_dup(bt.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

FadingBubbleType::~FadingBubbleType()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_bubbletype_fading_free(handle));
}

void FadingBubbleType::swap(FadingBubbleType& bt)
{
	PersistentBubbleType::swap(bt);
	std::swap(bt.handle, handle);
}

FadingBubbleType& FadingBubbleType::operator =(const FadingBubbleType& bt)
{
	FadingBubbleType nbt(bt);
	swap(nbt);
	return *this;
}

bool FadingBubbleType::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void FadingBubbleType::createBubble(const ID& id, const uint8_t* data, int dataLen)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_bubble_fading_create(handle, id.getHandle(), (uint8_t*) data, dataLen));
}

// //
// // BubbleType
// //
// 
// BubbleType::BubbleType()
// 	: handle(HANDLE_NONE)
// {
// }
// 
// BubbleType::BubbleType(Handle handle)
// 	: handle(handle)
// {
// 	ASSERT_HANDLE(handle);
// }
// 
// BubbleType::BubbleType(const BubbleType& bt)
// {
// 	if (IS_VALID_HANDLE(bt.handle)) {
// 		handle = bs_bubbletype_dup(bt.handle);
// 		ASSERT_HANDLE(handle);
// 	} else
// 		handle = HANDLE_NONE;
// }
// 
// BubbleType::~BubbleType()
// {
// 	if (IS_VALID_HANDLE(handle))
// 		ASSERT_CALL_TRUE(bs_bubbletype_free(handle));
// }
// 
// void BubbleType::swap(BubbleType& bt)
// {
// 	std::swap(bt.handle, handle);
// }
// 
// BubbleType& BubbleType::operator =(const BubbleType& bt)
// {
// 	BubbleType nbt(bt);
// 	swap(nbt);
// 	return *this;
// }
// 
// bool BubbleType::isValid() const
// {
// 	return IS_VALID_HANDLE(handle);
// }
// 
// int BubbleType::id() const
// {
// 	ASSERT_HANDLE(handle);
// 	int id = checkResult(bs_bubbletype_id(handle));
// 	assert(id >= 0);
// 	return id;
// }
// 
// int BubbleType::defaultSize() const
// {
// 	ASSERT_HANDLE(handle);
// 	return checkResult(bs_bubbletype_default_size(handle));
// }
// 
// void BubbleType::matchWithId(BubbleType& with, double lambda, BubbleHandlerWithId* handler)
// {
// 	ASSERT_HANDLE(handle);
// 	assert(handler);
// 	checkResult(bs_bubbletype_match_with_id(handle, with.getHandle(), lambda,
// 			(void*) bubbleWithIdCallback, handler));
// }
// 
// void BubbleType::matchWithoutId(BubbleType& with, double lambda, BubbleHandlerWithoutId* handler)
// {
// 	ASSERT_HANDLE(handle);
// 	assert(handler);
// 	checkResult(bs_bubbletype_match_without_id(handle, with.getHandle(), lambda,
// 			(void*) bubbleWithoutIdCallback, handler));
// }
// 
// void BubbleType::bubblecast(const uint8_t* data, int dataLen)
// {
// 	bubblecast(defaultSize(), data, dataLen);
// }
// 
// void BubbleType::bubblecast(int size, const uint8_t* data, int dataLen)
// {
// 	ASSERT_HANDLE(handle);
// 	checkResult(bs_bubbletype_bubblecast(handle, size, (uint8_t*) data, dataLen));
// }
// 
// void BubbleType::bubblecastWithId(ID& id, const uint8_t* data, int dataLen)
// {
// 	bubblecastWithId(defaultSize(), id, data, dataLen);
// }
// 
// void BubbleType::bubblecastWithId(int size, ID& id, const uint8_t* data, int dataLen)
// {
// 	ASSERT_HANDLE(handle);
// 	checkResult(bs_bubbletype_bubblecast_with_id(handle, size, id.getHandle(), (uint8_t*) data, dataLen));
// }
// 
// void BubbleType::bubbleWithIdCallback(Handle idHandle, Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData)
// {
// 	assert(userData);
// 	// have to copy data which could be garbage collected after next ML call
// 	uint8_t* buf = (uint8_t*) malloc((size_t) len);
// 	assert(buf);
// 	memcpy(buf, ((uint8_t*) data) + ofs, (size_t) len);
// 	ID id(idHandle);
// 	((BubbleHandlerWithId*) userData)->onBubble(id, buf, len);
// 	free(buf);
// }
// 
// void BubbleType::bubbleWithoutIdCallback(Vector(Int8_t) data, Int32_t ofs, Int32_t len, CPointer userData)
// {
// 	assert(userData);
// 	// have to copy data which could be garbage collected after next ML call
// 	uint8_t* buf = (uint8_t*) malloc((size_t) len);
// 	assert(buf);
// 	memcpy(buf, ((uint8_t*) data) + ofs, (size_t) len);
// 	((BubbleHandlerWithoutId*) userData)->onBubble(buf, len);
// 	free(buf);
// }

//
// BubbleManager
//

BubbleMaster::BubbleMaster()
	: handle(HANDLE_NONE)
{
}

BubbleMaster::BubbleMaster(const BubbleMaster& bm)
{
	if (IS_VALID_HANDLE(bm.handle)) {
		handle = bs_bubblemaster_dup(bm.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

BubbleMaster::BubbleMaster(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

BubbleMaster::~BubbleMaster()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_bubblemaster_free(handle));
}

void BubbleMaster::swap(BubbleMaster& bm)
{
	std::swap(bm.handle, handle);
}

BubbleMaster& BubbleMaster::operator =(const BubbleMaster& bm)
{
	BubbleMaster nbm(bm);
	swap(nbm);
	return *this;
}

bool BubbleMaster::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

InstantBubbleType BubbleMaster::newInstant(int id)
{
	return newInstant(id, NAN);
}

InstantBubbleType BubbleMaster::newInstant(int id, float priority)
{
	ASSERT_HANDLE(handle);
	Handle h = checkResult(bs_bubblemaster_new_instant(handle, id, priority));
	return InstantBubbleType(h);
}

FadingBubbleType BubbleMaster::newFading(int id, FadingBubbleType::BubbleHandlerWithId* handler)
{
	return newFading(id, NAN, handler);
}

FadingBubbleType BubbleMaster::newFading(int id, float priority, PersistentBubbleType::BubbleHandlerWithId* handler)
{
	ASSERT_HANDLE(handle);
	assert(handler);
	Handle h = checkResult(bs_bubblemaster_new_fading(handle, id, priority,
			(void*) PersistentBubbleType::bubbleWithIdCallback, handler));
	return FadingBubbleType(h);
}

//
// ID
//

ID::ID()
	: handle(HANDLE_NONE)
{
}

ID::ID(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

ID::ID(const ID& id)
{
	if (IS_VALID_HANDLE(id.handle)) {
		handle = bs_id_dup(id.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

ID::~ID()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_id_free(handle));
}

void ID::swap(ID& id)
{
	std::swap(id.handle, handle);
}

ID& ID::operator =(const ID& id)
{
	ID nid(id);
	swap(nid);
	return *this;
}

bool ID::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

ID ID::fromHash(const uint8_t* data, int length)
{
	Handle h = checkResult(bs_id_from_hash((uint8_t*) data, length));
	if (IS_VALID_HANDLE(h))
		return ID(h);
	else
		return ID();
}

ID ID::fromRandom()
{
	Handle h = checkResult(bs_id_from_random());
	if (IS_VALID_HANDLE(h))
		return ID(h);
	else
		return ID();
}

ID ID::fromBytes(const uint8_t* bytes)
{
	Handle h = checkResult(bs_id_from_bytes((uint8_t*) bytes));
	if (IS_VALID_HANDLE(h))
		return ID(h);
	else
		return ID();
}

void ID::toBytes(uint8_t* buffer) const
{
	ASSERT_HANDLE(handle);
	Int32_t len;
	const uint8_t* data = (const uint8_t*) bs_id_to_bytes(handle, &len);
	checkResult(len);
	assert(len == size());
	memcpy(buffer, data, (size_t) len);
}

bool ID::equals(ID& other) const
{
	ASSERT_HANDLE(handle);
	ASSERT_HANDLE(other.handle);
	return (bool) checkResult(bs_id_equals(handle, other.handle));
}

int ID::hashCode() const
{
	ASSERT_HANDLE(handle);
	return (int) checkResult(bs_id_hash(handle));
}

std::string ID::toString() const
{
	ASSERT_HANDLE(handle);
	Int32_t len;
	const char* data = (const char*) bs_id_to_string(handle, &len);
	checkResult(len);
	return std::string(data, len);
}

//
// Measurement
//

// Measurement::Measurement()
// 	: handle(HANDLE_NONE)
// {
// }
// 
// Measurement::Measurement(Handle handle)
// 	: handle(handle)
// {
// 	ASSERT_HANDLE(handle);
// }
// 
// Measurement::Measurement(const Measurement& m)
// {
// 	if (IS_VALID_HANDLE(m.handle)) {
// 		handle = bs_measurement_dup(m.handle);
// 		ASSERT_HANDLE(handle);
// 	} else
// 		handle = HANDLE_NONE;
// }
// 
// Measurement::~Measurement()
// {
// 	if (IS_VALID_HANDLE(handle))
// 		ASSERT_CALL_TRUE(bs_measurement_free(handle));
// }
// 
// void Measurement::swap(Measurement& m)
// {
// 	std::swap(m.handle, handle);
// }
// 
// Measurement& Measurement::operator =(const Measurement& m)
// {
// 	Measurement nm(m);
// 	swap(nm);
// 	return *this;
// }
// 
// bool Measurement::isValid() const
// {
// 	return IS_VALID_HANDLE(handle);
// }
// 
// Measurement Measurement::create(const int64_t interval)
// {
// 	Handle handle = bs_measurement_new(interval);
// 	if (IS_VALID_HANDLE(handle))
// 		return Measurement(handle);
// 	else
// 		return Measurement();
// }
// 
// void Measurement::sum(const PullHandler* pullHandler, const PushHandler* pushHandler)
// {
// 	ASSERT_HANDLE(handle);
// 	bs_measurement_sum(handle, (void*) pullCallback, (void*) pullHandler, (void*) pushCallback, (void*) pushHandler);
// }
// 
// void Measurement::max(const PullHandler* pullHandler, const PushHandler* pushHandler)
// {
// 	ASSERT_HANDLE(handle);
// 	bs_measurement_max(handle, (void*) pullCallback, (void*) pullHandler, (void*) pushCallback, (void*) pushHandler);
// }
// 
// float Measurement::pullCallback(void* userData)
// {
// 	assert(userData);
// 	return ((PullHandler*) userData)->pull();
// }
// 
// void Measurement::pushCallback(float value, void* userData)
// {
// 	if (userData) {
// 		assert(userData);
// 		((PushHandler*) userData)->push(value);
// 	}
// }
// 
// Handle Measurement::getHandle()
// {
// 	return handle;
// }


//
// NotificationReceiver
//

NotificationReceiver::NotificationReceiver()
	: handle(HANDLE_NONE)
{
}

NotificationReceiver::NotificationReceiver(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

NotificationReceiver::NotificationReceiver(const NotificationReceiver& n)
{
	if (IS_VALID_HANDLE(n.handle)) {
		handle = bs_notification_dup(n.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

NotificationReceiver::~NotificationReceiver()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_notification_free(handle));
}

void NotificationReceiver::swap(NotificationReceiver& n)
{
	std::swap(n.handle, handle);
}

NotificationReceiver& NotificationReceiver::operator =(const NotificationReceiver& n)
{
	NotificationReceiver nn(n);
	swap(nn);
	return *this;
}

bool NotificationReceiver::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

NotificationReceiver NotificationReceiver::create(CUSP::EndPoint& endpoint,
		/*LocalAddressProvider* localAddrProvider,*/ ResultReceiver* resultReceiver)
{
	Handle h = checkResult(bs_notification_new(endpoint.getHandle(), /*(void*) getLocalAddrCallback, localAddrProvider,*/
			(void*) resultReceiverCallback, resultReceiver));
	return NotificationReceiver(h);
}

void NotificationReceiver::close()
{
	ASSERT_HANDLE(handle);
	checkResult(bs_notification_close(handle));
}

int NotificationReceiver::maxEncodedLength()
{
	int l = checkResult(bs_notification_max_encoded_length());
	assert(l >= 0);
	return (size_t) l;
}

int NotificationReceiver::encode(const CUSP::Address& localAddr, uint8_t* buffer, int bufSize) const
{
	ASSERT_HANDLE(handle);
	assert(buffer);
	Int32_t l;
	const uint8_t* data = (const uint8_t*) bs_notification_encode(handle, localAddr.getHandle(), &l);
	checkResult(l);
	assert(l >= 0);
	int dataLen = l;
	// have to copy data which could be garbage collected after next ML call
	if (dataLen <= bufSize) {
		memcpy(buffer, data, (size_t) dataLen);
		return dataLen;
	} else
		return 0;
}

NotificationSender NotificationReceiver::decode(const uint8_t* data, int& dataLen, CUSP::EndPoint& endpoint)
{
	Int32_t l = dataLen;
	Handle h = bs_notification_decode((uint8_t*) data, &l, endpoint.getHandle());
	checkResult(l);
	dataLen = l;
	return NotificationSender(h);
}

// Handle Notification::getLocalAddrCallback(void* userData)
// {
// 	assert(userData);
// 	Address addr = ((LocalAddressProvider*) userData)->getLocalAddress();
// 	Handle h = addr.getHandle();
// 	ASSERT_HANDLE(h);
// 	return cusp_address_dup(h);
// }

void NotificationReceiver::resultReceiverCallback(Handle resultHandle, void* userData)
{
	assert(userData);
	NotificationResult result(resultHandle);
	((ResultReceiver*) userData)->onResult(result);
}

//
// NotificationResult
//

NotificationResult::NotificationResult()
	: handle(HANDLE_NONE)
{
}

NotificationResult::NotificationResult(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

NotificationResult::NotificationResult(const NotificationResult& n)
{
	if (IS_VALID_HANDLE(n.handle)) {
		handle = bs_notification_result_dup(n.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

NotificationResult::~NotificationResult()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_notification_result_free(handle));
}

void NotificationResult::swap(NotificationResult& n)
{
	std::swap(n.handle, handle);
}

NotificationResult& NotificationResult::operator =(const NotificationResult& n)
{
	NotificationResult nn(n);
	swap(nn);
	return *this;
}

bool NotificationResult::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

ID NotificationResult::id() const
{
	ASSERT_HANDLE(handle);
	Handle h = checkResult(bs_notification_result_id(handle));
	return ID(h);
}

InStream NotificationResult::payload()
{
	ASSERT_HANDLE(handle);
	Handle h = checkResult(bs_notification_result_payload(handle));
	return InStream(h);
}

void NotificationResult::cancel()
{
	ASSERT_HANDLE(handle);
	checkResult(bs_notification_result_cancel(handle));
}

//
// NotificationSender
//

NotificationSender::NotificationSender()
	: handle(HANDLE_NONE)
{
}

NotificationSender::NotificationSender(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

NotificationSender::NotificationSender(const NotificationSender& n)
{
	if (IS_VALID_HANDLE(n.handle)) {
		handle = bs_notification_sendfn_dup(n.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

NotificationSender::~NotificationSender()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_notification_sendfn_free(handle));
}

void NotificationSender::swap(NotificationSender& n)
{
	std::swap(n.handle, handle);
}

NotificationSender& NotificationSender::operator =(const NotificationSender& n)
{
	NotificationSender nn(n);
	swap(nn);
	return *this;
}

bool NotificationSender::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void NotificationSender::send(ID& id, Handler* handler)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_notification_sendfn(handle, id.getHandle(), (void*) sendCallback, handler));
}

void NotificationSender::sendImmediate(ID& id, const uint8_t* data, int dataLen)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_notification_sendfn_immediate(handle, id.getHandle(), (uint8_t*) data, dataLen));
}

void NotificationSender::sendCallback(Handle osHandle, void* userData)
{
	assert(userData);
	if (IS_VALID_HANDLE(osHandle)) {
		OutStream os(osHandle);
		((Handler*) userData)->getData(os);
	} else
		((Handler*) userData)->abort();
}


//
// Query
//

Query::Query()
	: handle(HANDLE_NONE)
{
}

Query::Query(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

Query::Query(const Query& q)
{
	if (IS_VALID_HANDLE(q.handle)) {
		handle = bs_query_dup(q.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

Query::~Query()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_query_free(handle));
}

void Query::swap(Query& q)
{
	std::swap(q.handle, handle);
}

Query& Query::operator =(const Query& q)
{
	Query nq(q);
	swap(nq);
	return *this;
}

bool Query::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

Query Query::create(BubbleMaster& master, PersistentBubbleType& dataBubble, int queryBubbleId,
		float lambda, Responder* responder)
{
	Handle handle = checkResult(bs_query_new(master.getHandle(), dataBubble.getHandle(), queryBubbleId, lambda,
			(void*) createQueryCallback, (void *) responder));
	return Query(handle);
}

Abortable Query::query(uint8_t* queryData, int length, ResponseReceiver* receiver)
{
	ASSERT_HANDLE(handle);
	Handle h = checkResult(bs_query_query(handle, queryData, length,
			(void*) queryCallback, (void*) receiver));
	if (IS_VALID_HANDLE(h)) /* FIXME assert(not -1), throw exception on -2 */
		return Abortable(h);
	else
		return Abortable();
}

void Query::createQueryCallback(Vector(Word8_t) data, Int32_t offset, Int32_t length,
		Handle queryRespondHandle, void* userData)
{
	if (userData) { // (result receiver is optional)
		QueryRespond respond(queryRespondHandle);
		uint8_t* cpy = (uint8_t*) malloc(length);
		memcpy(cpy, (uint8_t*) data + offset, length);
		((Responder*) userData)->respond(cpy, length, &respond);
		free(cpy);
	}
}

void Query::queryCallback(Handle idHandle, Handle streamHandle, void* userData)
{
	assert(userData);
	ID id(idHandle);
	InStream stream(streamHandle);
	((ResponseReceiver*) userData)->onResponse(id, stream);
}

//
// QueryRespond
//

QueryRespond::QueryRespond()
	: handle(HANDLE_NONE)
{
}

QueryRespond::QueryRespond(Handle handle)
	: handle(handle)
{
	ASSERT_HANDLE(handle);
}

QueryRespond::QueryRespond(const QueryRespond& q)
{
	if (IS_VALID_HANDLE(q.handle)) {
		handle = bs_query_respond_dup(q.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

QueryRespond::~QueryRespond()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(bs_query_respond_free(handle));
}

void QueryRespond::swap(QueryRespond& q)
{
	std::swap(q.handle, handle);
}

QueryRespond& QueryRespond::operator =(const QueryRespond& q)
{
	QueryRespond nq(q);
	swap(nq);
	return *this;
}

bool QueryRespond::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void QueryRespond::respond(ID& id, Writer* writer)
{
	ASSERT_HANDLE(handle);
	checkResult(bs_query_respond(handle, id.getHandle(),
			(void*) respondCallback, (void*) writer));
}

void QueryRespond::respondCallback(Handle osHandle, void* userData)
{
	assert(userData);
	if (IS_VALID_HANDLE(osHandle)) {
		OutStream stream(osHandle);
		((Writer*) userData)->write(stream);
	} else {
		((Writer*) userData)->abort();
	}
}

}; // end of namespace BS
