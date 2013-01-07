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

package net.bubblestorm.jni;

public class BSJni extends CUSPJni {

	//
	// public
	//

	/**
	 * Initialize all JNI stuff. Has to be called prior to using any other method.
	 * <p>
	 * (This method 'overrides' CUSPJni's init() so that CUSPJni will not try to load the cuspjni
	 * library.)
	 * </p>
	 */
	public static void init() {
		if (!initialized) {
			// load native SQLite and BubbleStorm libraries
			// (bsjni depends on them, but the OS may not find it if it's not in
			// the search path)
			System.loadLibrary("sqlite3");
			System.loadLibrary("bubblestorm");
			// load native BS JNI library
			System.loadLibrary("bsjni");
			// init super class
			BSJniBase.init();
			//
			initialized = true;
		}
	}

	/**
	 * Shut down the JNI library and terminate all internal threads. Note that you are not allowed
	 * to use any BubbleStorm/CUSP object after calling this method.
	 */
	public static void shutdown() {
		BSJniBase.shutdown();
	}

	//
	// native declarations
	//

	// BubbleStorm

	public static native int bsBubbleStormNew(float bandwidth, float minBandwidth, int port,
			boolean encrypt);

	public static native int bsBubbleStormNewWithEndpoint(float bandwidth, float minBandwidth,
			int epHandle);

	public static native int bsBubbleStormCreate(int handle, int addrHandle, Object handler);

	public static native int bsBubbleStormJoin(int handle, Object handler);

	public static native int bsBubbleStormLeave(int handle, Object handler);

	public static native int bsBubbleStormEndpoint(int handle);

	public static native int bsBubbleStormBubbleMaster(int handle);

	public static native int bsBubbleStormAddress(int handle);

	public static native byte[] bsBubbleStormSaveHostCache(int handle);

	public static native int bsBubbleStormLoadHostCache(int handle, byte[] data, int bootstrapHandle);

	public static native void bsBubbleStormSetLanMode(boolean enable);

	public static native boolean bsBubbleStormFree(int handle);

	// BubbleMaster

	public static native int bsBubbleMasterNewInstant(int handle, int id, float priority);

	public static native int bsBubbleMasterNewFading(int handle, int id, float priority,
			Object handler);

	public static native int bsBubbleMasterNewManaged(int handle, int id, float priority,
			Object handler);

	public static native int bsBubbleMasterNewDurable(int handle, int id, float priority,
			Object handler);

	public static native boolean bsBubbleMasterFree(int handle);

	// BubbleType Basic

	public static native int bsBubbleTypeBasicMatch(int handle, int withHandle, double lambda,
			Object handler);

	public static native int bsBubbleTypeBasicTypeId(int handle);

	public static native int bsBubbleTypeBasicDefaultSize(int handle);

	public static native boolean bsBubbleTypeBasicFree(int handle);

	// BubbleType Persistent

	public static native int bsBubbleTypePersistentMatchWithId(int handle, int withHandle,
			double lambda, Object handler);

	public static native boolean bsBubbleTypePersistentFree(int handle);

	// BubbleType Instant

	public static native int bsBubbleTypeInstantBasic(int handle);

	public static native boolean bsBubbleTypeInstantFree(int handle);

	// BubbleType Fading

	public static native int bsBubbleTypeFadingBasic(int handle);

	public static native int bsBubbleTypeFadingPersistent(int handle);

	public static native boolean bsBubbleTypeFadingFree(int handle);

	// BubbleType Managed

	public static native int bsBubbleTypeManagedBasic(int handle);

	public static native int bsBubbleTypeManagedPersistent(int handle);

	public static native boolean bsBubbleTypeManagedFree(int handle);

	// BubbleType Durable

	public static native int bsBubbleTypeDurableBasic(int handle);

	public static native int bsBubbleTypeDurablePersistent(int handle);

	public static native boolean bsBubbleTypeDurableFree(int handle);

	// BubbleType Durable Datastore

	public static native int bsBubbleTypeDurableDatastoreGetCb(int handle, long version, long time,
			byte[] data);

	public static native int bsBubbleTypeDurableDatastoreVersionCb(int handle, long version,
			long time);

	public static native int bsBubbleTypeDurableDatastoreListCb(int handle, int idHandle,
			long version, long time, byte[] data);

	// Bubble Instant

	public static native int bsBubbleInstantCreate(int typeHandle, byte[] data);

	// Bubble Fading

	public static native int bsBubbleFadingCreate(int typeHandle, int idHandle, byte[] data);

	// Bubble Managed

	public static native int bsBubbleManagedInsert(int typeHandle, int idHandle, byte[] data,
			Object handler);

	public static native int bsBubbleManagedId(int handle);

	public static native byte[] bsBubbleManagedData(int handle);

	public static native int bsBubbleManagedUpdate(int handle, byte[] data, Object handler);

	public static native int bsBubbleManagedDelete(int handle, Object handler);

	public static native boolean bsBubbleManagedFree(int handle);

	// Bubble Durable

	public static native int bsBubbleDurableLookup(int typeHandle, int idHandle, Object handler);

	public static native int bsBubbleDurableCreate(int typeHandle, int idHandle, byte[] data);

	public static native int bsBubbleDurableId(int handle);

	public static native byte[] bsBubbleDurableData(int handle);

	public static native int bsBubbleDurableUpdate(int handle, byte[] data);

	public static native int bsBubbleDurableDelete(int handle);

	public static native boolean bsBubbleDurableFree(int handle);

	// // Measurement
	//
	// public static native int bsMeasurementNew(long freq);
	//
	// public static native boolean bsMeasurementSum(int handle, Object
	// handler);
	//
	// public static native boolean bsMeasurementMax(int handle, Object
	// handler);
	//
	// public static native boolean bsMeasurementFree(int handle);

	// ID

	public static native int bsIdFromHash(byte[] data);

	public static native int bsIdFromRandom();

	public static native int bsIdFromBytes(byte[] data);

	public static native byte[] bsIdToBytes(int handle);

	public static native String bsIdToString(int handle);

	public static native int bsIdEquals(int aHandle, int bHandle);

	public static native int bsIdHash(int handle);

	public static native boolean bsIdFree(int handle);

	// Notification

	public static native int bsNotificationNew(int epHandle, Object handler);

	public static native int bsNotificationClose(int handle);

	public static native int bsNotificationMaxEncodedLength();

	public static native byte[] bsNotificationEncode(int handle, int localAddrHandle);

	public static native long bsNotificationDecode(byte[] data, int epHandle);

	public static native boolean bsNotificationFree(int handle);

	public static native int bsNotificationResultId(int handle);

	public static native int bsNotificationResultPayload(int handle);

	public static native int bsNotificationResultCancel(int handle);

	public static native boolean bsNotificationResultFree(int handle);

	public static native int bsNotificationSendFn(int handle, int idHandle, Object handler);

	public static native int bsNotificationSendFnImmediate(int handle, int idHandle, byte[] data);

	public static native boolean bsNotificationSendFnFree(int handle);

	// Query

	public static native int bsQueryNew(int masterHandle, int dataBubbleHandle, int queryBubbleId,
			float lambda, Object responder);

	public static native int bsQueryQuery(int handle, byte[] queryData, Object responseCb);

	public static native boolean bsQueryFree(int handle);

	// QueryRespond

	public static native int bsQueryRespond(int handle, int idHandle, Object writer);

	public static native boolean bsQueryRespondFree(int handle);

}
