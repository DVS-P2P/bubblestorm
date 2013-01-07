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

#include "bs-jni.h"
#include <libbubblestorm.h>

#define LIBCUSP_H_INCLUDED
#include "../cusp/cusp-jni.c"

//
// BubbleStorm
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormNew
		(JNIEnv* env, jclass cl, jfloat bandwidth, jfloat minBandwidth, jint port, jboolean encrypt)
{
	disableSignals();
	int hKey = cusp_privatekey_new();
	jint handle = bs_bubblestorm_new(bandwidth, minBandwidth, port, hKey, encrypt);
	enableSignals();
	return handle;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormNewWithEndpoint
		(JNIEnv* env, jclass cl, jfloat bandwidth, jfloat minBandwidth, jint epHandle)
{
	disableSignals();
	jint handle = bs_bubblestorm_new_with_endpoint(bandwidth, minBandwidth, epHandle);
	enableSignals();
	return handle;
}

void doneCallback(CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	if (cd->obj) {
		jmethodID mid = getMethod(env, cd->obj, "done", "()V");
		(*env)->ExceptionClear(env);
		(*env)->CallVoidMethod(env, cd->obj, mid);
		handleException(env);
	}
	
	deleteCallbackData(env, cd);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormCreate
		(JNIEnv* env, jclass cl, jint handle, jint addrHandle, jobject callback)
{
	CallbackData* cd = newCallbackData(env, callback);
	disableSignals();
	jint res = bs_bubblestorm_create(handle, addrHandle, doneCallback, cd);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormJoin
		(JNIEnv* env, jclass cl, jint handle, jobject callback)
{
	CallbackData* cd = newCallbackData(env, callback);
	disableSignals();
	jint res = bs_bubblestorm_join(handle, doneCallback, cd);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormLeave
		(JNIEnv* env, jclass cl, jint handle, jobject callback)
{
	CallbackData* cd = newCallbackData(env, callback);
	disableSignals();
	jint res = bs_bubblestorm_leave(handle, doneCallback, cd);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormEndpoint
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubblestorm_endpoint(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormBubbleMaster
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubblestorm_bubblemaster(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormAddress
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubblestorm_address(handle);
	enableSignals();
	return res;
}

JNIEXPORT jbyteArray JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormSaveHostCache
		(JNIEnv* env, jclass cl, jint handle)
{
	Int32_t len;
	disableSignals();
	const void* data = bs_bubblestorm_save_hostcache(handle, &len);
	enableSignals();
	if (len >= 0) {
		jbyteArray res = (*env)->NewByteArray(env, len);
		if (!res) return NULL;
		void* arrayData = (*env)->GetPrimitiveArrayCritical(env, res, NULL);
		if (!arrayData) return NULL;
		memcpy(arrayData, data, len);
		(*env)->ReleasePrimitiveArrayCritical(env, res, arrayData, 0);
		return res;
	} else
		return NULL;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormLoadHostCache
		(JNIEnv* env, jclass cl, jint handle, jbyteArray data, jint bootstrapHandle)
{
	jsize dataLen;
	jbyte* dataPtr;
	if (data) {
		dataLen = (*env)->GetArrayLength(env, data);
		dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	} else {
		dataLen = 0;
		dataPtr = NULL;
	}
	disableSignals();
	jint res = bs_bubblestorm_load_hostcache(handle, dataPtr, dataLen, bootstrapHandle);
	enableSignals();
	if (dataPtr) {
		(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	}
	return res;
}

JNIEXPORT void JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormSetLanMode
		(JNIEnv* env, jclass cl, jboolean enable)
{
	disableSignals();
	bs_bubblestorm_set_lan_mode(enable);
	enableSignals();
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleStormFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubblestorm_free(handle);
	enableSignals();
	return res;
}

//
// BubbleMaster
//

void bubbleHandler(Vector(WordU8_t) data, Int32_t ofs, Int32_t len, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	if (cd->obj) {
		jbyteArray bufArray = (*env)->NewByteArray(env, len);
		if (!bufArray) return;
		jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, bufArray, NULL);
		if (!bufData) return;
		memcpy(bufData, data + ofs, (size_t) len);
		(*env)->ReleasePrimitiveArrayCritical(env, bufArray, bufData, 0);
		
		jmethodID mid = getMethod(env, cd->obj, "handle", "([B)V");
		(*env)->ExceptionClear(env);
		(*env)->CallVoidMethod(env, cd->obj, mid, bufArray);
		handleException(env);
	}
	
	detachThread();
	disableSignals();
}

void bubbleHandlerWithId(Int32_t idHandle, Vector(WordU8_t) data, Int32_t ofs, Int32_t len, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	if (cd->obj) {
		jbyteArray bufArray = (*env)->NewByteArray(env, len);
		if (!bufArray) return;
		jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, bufArray, NULL);
		if (!bufData) return;
		memcpy(bufData, data + ofs, (size_t) len);
		(*env)->ReleasePrimitiveArrayCritical(env, bufArray, bufData, 0);
		
		jmethodID mid = getMethod(env, cd->obj, "handle", "(I[B)V");
		(*env)->ExceptionClear(env);
		(*env)->CallVoidMethod(env, cd->obj, mid, idHandle, bufArray);
		handleException(env);
	}
	
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleMasterNewInstant
		(JNIEnv* env, jclass cl, jint handle, jint id, jfloat priority)
{
	disableSignals();
	jint res = bs_bubblemaster_new_instant(handle, id, priority);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleMasterNewFading
		(JNIEnv* env, jclass cl, jint handle, jint id, jfloat priority, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = bs_bubblemaster_new_fading(handle, id, priority, bubbleHandlerWithId, cd);
	enableSignals();
	// TODO delete cd!?
	return res;
}

void bubbleManagedBackendInsertCallback(Int32_t idHandle, Vector(WordU8_t) data, Int32_t ofs, Int32_t len,
		Bool_t bucket, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jbyteArray bufArray = (*env)->NewByteArray(env, len);
	if (!bufArray) return;
	jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, bufArray, NULL);
	if (!bufData) return;
	memcpy(bufData, data + ofs, (size_t) len);
	(*env)->ReleasePrimitiveArrayCritical(env, bufArray, bufData, 0);
	
	jmethodID mid = getMethod(env, cd->obj, "insert", "(I[BZ)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle, bufArray, (jboolean) bucket);
	handleException(env);
	
	detachThread();
	disableSignals();
}

void bubbleManagedBackendUpdateCallback(Int32_t idHandle, Vector(WordU8_t) data, Int32_t ofs, Int32_t len,
		CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jbyteArray bufArray = (*env)->NewByteArray(env, len);
	if (!bufArray) return;
	jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, bufArray, NULL);
	if (!bufData) return;
	memcpy(bufData, data + ofs, (size_t) len);
	(*env)->ReleasePrimitiveArrayCritical(env, bufArray, bufData, 0);
	
	jmethodID mid = getMethod(env, cd->obj, "update", "(I[B)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle, bufArray);
	handleException(env);
	
	detachThread();
	disableSignals();
}

void bubbleManagedBackendDeleteCallback(Int32_t idHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "delete", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

void bubbleManagedBackendFlushCallback(Bool_t bucket, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "flush", "(Z)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, (jboolean) bucket);
	handleException(env);
	
	detachThread();
	disableSignals();
}

Int32_t bubbleManagedBackendSizeCallback(CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return 0;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "size", "()I");
	(*env)->ExceptionClear(env);
	jint res = (*env)->CallIntMethod(env, cd->obj, mid);
	handleException(env);
	
	detachThread();
	disableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleMasterNewManaged
		(JNIEnv* env, jclass cl, jint handle, jint id, jfloat priority, jobject handler)
{
	handler = (*env)->NewGlobalRef(env, handler); // global reference to prevent handler from being collected by GC
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = bs_bubblemaster_new_managed(handle, id, priority,
			bubbleManagedBackendInsertCallback, bubbleManagedBackendUpdateCallback,
			bubbleManagedBackendDeleteCallback, bubbleManagedBackendFlushCallback,
			bubbleManagedBackendSizeCallback, cd);
	enableSignals();
	// TODO delete cd & global handler ref!?
	return res;
}

void bubbleDurableBackendStoreCallback(Int32_t idHandle, Int64_t version, Int64_t time,
		Vector(WordU8_t) data, Int32_t ofs, Int32_t len, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
// 	printf("### bubbleDurableBackendStoreCallback %llx %llx\n", (unsigned long long) cd, (unsigned long long) cd->obj); fflush(stdout);
	
// 	printf("store...\n"); fflush(stdout);
	jbyteArray bufArray;
	if (len >= 0) {
		bufArray = (*env)->NewByteArray(env, len);
		if (!bufArray) return;
		jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, bufArray, NULL);
		if (!bufData) return;
		memcpy(bufData, data + ofs, (size_t) len);
		(*env)->ReleasePrimitiveArrayCritical(env, bufArray, bufData, 0);
	} else {
		bufArray = NULL;
	}
	
// 	printf("store2...\n"); fflush(stdout);
	jmethodID mid = getMethod(env, cd->obj, "store", "(IJJ[B)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle, version, time, bufArray);
	handleException(env);
// 	printf("store3...\n"); fflush(stdout);
	
	detachThread();
	disableSignals();
}

void bubbleDurableBackendLookupCallback(Int32_t idHandle, Int32_t cbHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "lookup", "(II)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle, cbHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

void bubbleDurableBackendRemoveCallback(Int32_t idHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "remove", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

// void bubbleDurableBackendVersionCallback(Int32_t idHandle, Int32_t cbHandle, CPointer userData)
// {
// 	enableSignals();
// 	JNIEnv *env = attachThread();
// 	if (!env) return;
// 	CallbackData* cd = (CallbackData*) userData;
// // 	printf("### bubbleDurableBackendVersionCallback %llx %llx\n", (unsigned long long) cd, (unsigned long long) cd->obj); fflush(stdout);
// 	
// 	jmethodID mid = getMethod(env, cd->obj, "version", "(II)V");
// 	(*env)->ExceptionClear(env);
// 	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle, cbHandle);
// 	handleException(env);
// 	
// 	detachThread();
// 	disableSignals();
// }

void bubbleDurableBackendIteratorCallback(Int32_t cbHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "iterator", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, cbHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

Int32_t bubbleDurableBackendSizeCallback(CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return 0;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "size", "()I");
	(*env)->ExceptionClear(env);
	jint res = (*env)->CallIntMethod(env, cd->obj, mid);
	handleException(env);
	
	detachThread();
	disableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleMasterNewDurable
		(JNIEnv* env, jclass cl, jint handle, jint id, jfloat priority, jobject handler)
{
	handler = (*env)->NewGlobalRef(env, handler); // global reference to prevent handler from being collected by GC
	if (!handler) return -1;
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = bs_bubblemaster_new_durable(handle, id, priority,
			bubbleDurableBackendStoreCallback, bubbleDurableBackendLookupCallback,
			bubbleDurableBackendRemoveCallback, /*bubbleDurableBackendVersionCallback,*/
			bubbleDurableBackendIteratorCallback, bubbleDurableBackendSizeCallback, cd);
	enableSignals();
	// TODO delete cd & global handler ref!?
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleMasterFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubblemaster_free(handle);
	enableSignals();
	return res;
}


//
// BubbleType Basic
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeBasicMatch
		(JNIEnv* env, jclass cl, jint handle, jint withHandle, jdouble lambda, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = bs_bubbletype_basic_match(handle, withHandle, lambda, bubbleHandler, cd);
	enableSignals();
	// TODO delete cd!?
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeBasicTypeId
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_basic_typeid(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeBasicDefaultSize
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_basic_default_size(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeBasicFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubbletype_basic_free(handle);
	enableSignals();
	return res;
}

//
// BubbleType Persistent
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypePersistentMatchWithId
		(JNIEnv* env, jclass cl, jint handle, jint withHandle, jdouble lambda, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = bs_bubbletype_persistent_match_with_id(handle, withHandle, lambda, bubbleHandlerWithId, cd);
	enableSignals();
	// TODO delete cd!?
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypePersistentFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubbletype_persistent_free(handle);
	enableSignals();
	return res;
}

//
// BubbleType Instant
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeInstantBasic
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_instant_basic(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeInstantFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubbletype_instant_free(handle);
	enableSignals();
	return res;
}

//
// BubbleType Fading
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeFadingBasic
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_fading_basic(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeFadingPersistent
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_fading_persistent(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeFadingFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubbletype_fading_free(handle);
	enableSignals();
	return res;
}

//
// BubbleType Managed
//


JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeManagedBasic
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_managed_basic(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeManagedPersistent
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_managed_persistent(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeManagedFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubbletype_managed_free(handle);
	enableSignals();
	return res;
}


//
// BubbleType Durable
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeDurableBasic
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_durable_basic(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeDurablePersistent
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubbletype_durable_persistent(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeDurableFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubbletype_durable_free(handle);
	enableSignals();
	return res;
}

//
// BubbleType Durable Datastore
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeDurableDatastoreGetCb
		(JNIEnv* env, jclass cl, jint handle, jlong version, jlong time, jbyteArray data)
{
	jsize dataLen;
	jbyte* dataPtr;
	// (version < 0 -> no version stored)
	if (data) {
		dataLen = (*env)->GetArrayLength(env, data);
		dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	} else {
		dataLen = -1;
		dataPtr = NULL;
	}
	
	disableSignals();
	jint res = bs_bubbletype_durable_datastore_lookup_cb(handle, version, time, dataPtr, dataLen);
	enableSignals();
	
	if (data) {
		(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	}
	return res;
}

// JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeDurableDatastoreVersionCb
// 		(JNIEnv* env, jclass cl, jint handle, jlong version, jlong time)
// {
// 	disableSignals();
// 	jint res = bs_bubbletype_durable_datastore_version_cb(handle, version, time);
// 	enableSignals();
// 	return res;
// }

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleTypeDurableDatastoreListCb
		(JNIEnv* env, jclass cl, jint handle, jint idHandle, jlong version, jlong time, jbyteArray data)
{
	jsize dataLen;
	jbyte* dataPtr;
	if (data) {
		dataLen = (*env)->GetArrayLength(env, data);
		dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	} else {
		dataLen = -1;
		dataPtr = NULL;
	}
	
	disableSignals();
	jint res = bs_bubbletype_durable_datastore_iterator_cb(handle, idHandle, version, time, dataPtr, dataLen);
	enableSignals();
	
	if (data) {
		(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	}
	return res;
}


//
// Bubble Instant
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleInstantCreate
		(JNIEnv* env, jclass cl, jint typeHandle, jbyteArray data)
{
	jsize dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_bubble_instant_create(typeHandle, dataPtr, dataLen);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}

//
// Bubble Fading
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleFadingCreate
		(JNIEnv* env, jclass cl, jint typeHandle, jint idHandle, jbyteArray data)
{
	jsize dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	// !!! need to copy data because bs_bubble_fading_create may recursively call the bubble handler...
	void* dataCopy = malloc(dataLen);
	memcpy(dataCopy, dataPtr, dataLen);
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	disableSignals();
	jint res = bs_bubble_fading_create(typeHandle, idHandle, dataCopy, dataLen);
	enableSignals();
	free(dataCopy);
// 	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}


//
// Bubble Managed
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleManagedInsert
		(JNIEnv* env, jclass cl, jint typeHandle, jint idHandle, jbyteArray data, jobject callback)
{
	CallbackData* cd = newCallbackData(env, callback);
	jsize dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_bubble_managed_insert(typeHandle, idHandle, dataPtr, dataLen, doneCallback, cd);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleManagedId
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubble_managed_id(handle);
	enableSignals();
	return res;
}

JNIEXPORT jbyteArray JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleManagedData
		(JNIEnv* env, jclass cl, jint handle)
{
	Int32_t len;
	disableSignals();
	const void* data = bs_bubble_managed_data(handle, &len);
	enableSignals();
	if (len >= 0) {
		jbyteArray res = (*env)->NewByteArray(env, len);
		if (!res) return NULL;
		void* arrayData = (*env)->GetPrimitiveArrayCritical(env, res, NULL);
		if (!arrayData) return NULL;
		memcpy(arrayData, data, len);
		(*env)->ReleasePrimitiveArrayCritical(env, res, arrayData, 0);
		return res;
	} else
		return NULL;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleManagedUpdate
		(JNIEnv* env, jclass cl, jint handle, jbyteArray data, jobject callback)
{
	CallbackData* cd = newCallbackData(env, callback);
	jsize dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_bubble_managed_update(handle, dataPtr, dataLen, doneCallback, cd);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleManagedDelete
		(JNIEnv* env, jclass cl, jint handle, jobject callback)
{
	CallbackData* cd = newCallbackData(env, callback);
	disableSignals();
	jint res = bs_bubble_managed_delete(handle, doneCallback, cd);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleManagedFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubble_managed_free(handle);
	enableSignals();
	return res;
}


//
// Bubble Durable
//

void bubbleDurableLookupCallback(Int32_t bubbleHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "receive", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, bubbleHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleDurableLookup
		(JNIEnv* env, jclass cl, jint typeHandle, jint idHandle, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler); // TODO delete cd somewhere (on abort)
	disableSignals();
	jint res = bs_bubble_durable_lookup(typeHandle, idHandle, bubbleDurableLookupCallback, cd);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleDurableCreate
		(JNIEnv* env, jclass cl, jint typeHandle, jint idHandle, jbyteArray data)
{
	jsize dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_bubble_durable_create(typeHandle, idHandle, dataPtr, dataLen);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleDurableId
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubble_durable_id(handle);
	enableSignals();
	return res;
}

JNIEXPORT jbyteArray JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleDurableData
		(JNIEnv* env, jclass cl, jint handle)
{
	Int32_t len;
	disableSignals();
	const void* data = bs_bubble_durable_data(handle, &len);
	enableSignals();
	if (len >= 0) {
		jbyteArray res = (*env)->NewByteArray(env, len);
		if (!res) return NULL;
		void* arrayData = (*env)->GetPrimitiveArrayCritical(env, res, NULL);
		if (!arrayData) return NULL;
		memcpy(arrayData, data, len);
		(*env)->ReleasePrimitiveArrayCritical(env, res, arrayData, 0);
		return res;
	} else
		return NULL;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleDurableUpdate
		(JNIEnv* env, jclass cl, jint handle, jbyteArray data)
{
	jsize dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_bubble_durable_update(handle, dataPtr, dataLen);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleDurableDelete
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_bubble_durable_delete(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsBubbleDurableFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_bubble_durable_free(handle);
	enableSignals();
	return res;
}


// //
// // Measurement
// //
// 
// JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsMeasurementNew
// 		(JNIEnv* env, jclass cl, jlong freq)
// {
// 	disableSignals();
// 	jint res = bs_measurement_new(freq);
// 	enableSignals();
// 	return res;
// }
// 
// Real32_t measurementPullCallback(CPointer userData)
// {
// 	enableSignals();
// 	JNIEnv *env = attachThread();
// 	if (!env) return 0.0;
// 	CallbackData* cd = (CallbackData*) userData;
// 	
// 	jmethodID mid = getMethod(env, cd->obj, "pull", "()F");
// 	(*env)->ExceptionClear(env);
// 	jfloat value = (*env)->CallFloatMethod(env, cd->obj, mid);
// 	handleException(env);
// 	
// 	detachThread();
// 	disableSignals();
// 	return value;
// }
// 
// void measurementPushCallback(Real32_t value, CPointer userData)
// {
// 	enableSignals();
// 	JNIEnv *env = attachThread();
// 	if (!env) return;
// 	CallbackData* cd = (CallbackData*) userData;
// 	
// 	if (cd->obj) {
// 		jmethodID mid = getMethod(env, cd->obj, "push", "(F)V");
// 		(*env)->ExceptionClear(env);
// 		(*env)->CallVoidMethod(env, cd->obj, mid, value);
// 		handleException(env);
// 	}
// 	
// 	detachThread();
// 	disableSignals();
// }
// 
// JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsMeasurementSum
// 		(JNIEnv* env, jclass cl, jint handle, jobject handler)
// {
// 	CallbackData* cd = newCallbackData(env, handler);
// 	disableSignals();
// 	jboolean res = bs_measurement_sum(handle, measurementPullCallback,
// 			cd, measurementPushCallback, cd);
// 	enableSignals();
// 	// TODO free cd somewhere
// 	return res;
// }
// 
// JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsMeasurementFree
// 		(JNIEnv* env, jclass cl, jint handle)
// {
// 	disableSignals();
// 	jboolean res = bs_measurement_free(handle);
// 	enableSignals();
// 	return res;
// }

//
// ID
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsIdFromHash
		(JNIEnv* env, jclass cl, jbyteArray data)
{
	jsize dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_id_from_hash(dataPtr, dataLen);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsIdFromRandom
		(JNIEnv* env, jclass cl)
{
	disableSignals();
	jint res = bs_id_from_random();
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsIdFromBytes
		(JNIEnv* env, jclass cl, jbyteArray data)
{
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	if (!dataPtr) return -1;
	disableSignals();
	jint res = bs_id_from_bytes(dataPtr);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataPtr, 0);
	return res;
}

JNIEXPORT jbyteArray JNICALL Java_net_bubblestorm_jni_BSJni_bsIdToBytes
		(JNIEnv* env, jclass cl, jint handle)
{
	Int32_t len;
	disableSignals();
	const void* data = bs_id_to_bytes(handle, &len);
	enableSignals();
	if (len >= 0) {
		jbyteArray res = (*env)->NewByteArray(env, len);
		if (!res) return NULL;
		void* arrayData = (*env)->GetPrimitiveArrayCritical(env, res, NULL);
		if (!arrayData) return NULL;
		memcpy(arrayData, data, len);
		(*env)->ReleasePrimitiveArrayCritical(env, res, arrayData, 0);
		return res;
	} else
		return NULL;
}

JNIEXPORT jstring JNICALL Java_net_bubblestorm_jni_BSJni_bsIdToString
		(JNIEnv* env, jclass cl, jint handle)
{
	Int32_t len;
	disableSignals();
	char* strData = (char*) bs_id_to_string(handle, &len);
	enableSignals();
	if (len >= 0) {
		char* str = (char*) malloc(len + 1);
		memcpy(str, strData, len);
		str[len] = 0;
		jstring res = (*env)->NewStringUTF(env, str);
		free(str);
		return res;
	} else
		return NULL;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsIdEquals
		(JNIEnv* env, jclass cl, jint aHandle, jint bHandle)
{
	disableSignals();
	jint res = bs_id_equals(aHandle, bHandle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsIdHash
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = (jint) bs_id_hash(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsIdFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_id_free(handle);
	enableSignals();
	return res;
}

//
// Notification
//

void notificationResultHandler(Int32_t resultHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "resultReceiver", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, resultHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationNew
		(JNIEnv* env, jclass cl, jint epHandle, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = bs_notification_new(epHandle, notificationResultHandler, cd);
	enableSignals();
	// TODO delete cd!
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationClose
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_notification_close(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationMaxEncodedLength
		(JNIEnv* env, jclass cl)
{
	disableSignals();
	jint res = bs_notification_max_encoded_length();
	enableSignals();
	return res;
}

JNIEXPORT jbyteArray JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationEncode
		(JNIEnv* env, jclass cl, jint handle, jint localAddrHandle)
{
	Int32_t dataLen;
	disableSignals();
	Vector(WordU8_t) data = bs_notification_encode(handle, localAddrHandle, &dataLen);
	if (dataLen > 0) {
		enableSignals();
		
		jbyteArray bufArray = (*env)->NewByteArray(env, dataLen);
		if (!bufArray) return NULL;
		jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, bufArray, NULL);
		if (!bufData) return NULL;
		memcpy(bufData, data, (size_t) dataLen);
		(*env)->ReleasePrimitiveArrayCritical(env, bufArray, bufData, 0);
		
		enableSignals();
		return bufArray;
	} else {
		enableSignals();
		return NULL;
	}
}

JNIEXPORT jlong JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationDecode
		(JNIEnv* env, jclass cl, jbyteArray data, jint epHandle)
{
	Int32_t dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataBuf = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_notification_decode(dataBuf, &dataLen, epHandle);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataBuf, 0);
	return ((jlong) res) | (((jlong) dataLen) << 32);
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_notification_free(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationResultId
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_notification_result_id(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationResultPayload
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_notification_result_payload(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationResultCancel
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = bs_notification_result_cancel(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationResultFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_notification_result_free(handle);
	enableSignals();
	return res;
}

void notificationGetDataHandler(Int32_t osHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "getData", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, osHandle);
	handleException(env);
	
	deleteCallbackData(env, cd);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationSendFn
		(JNIEnv* env, jclass cl, jint handle, jint idHandle, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = bs_notification_sendfn(handle, idHandle, notificationGetDataHandler, cd);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationSendFnImmediate
		(JNIEnv* env, jclass cl, jint handle, jint idHandle, jbyteArray data)
{
	Int32_t dataLen = (*env)->GetArrayLength(env, data);
	jbyte* dataBuf = (*env)->GetPrimitiveArrayCritical(env, data, NULL);
	disableSignals();
	jint res = bs_notification_sendfn_immediate(handle, idHandle, dataBuf, dataLen);
	enableSignals();
	(*env)->ReleasePrimitiveArrayCritical(env, data, dataBuf, 0);
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsNotificationSendFnFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_notification_sendfn_free(handle);
	enableSignals();
	return res;
}


//
// Query
//

void queryResponder(Vector(WordU8_t) data, Int32_t ofs, Int32_t len,
		Int32_t respondHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	if (cd->obj) {
		jbyteArray bufArray = (*env)->NewByteArray(env, len);
		if (!bufArray) return;
		jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, bufArray, NULL);
		if (!bufData) return;
		memcpy(bufData, data + ofs, (size_t) len);
		(*env)->ReleasePrimitiveArrayCritical(env, bufArray, bufData, 0);
		
		jmethodID mid = getMethod(env, cd->obj, "respond", "([BI)V");
		(*env)->ExceptionClear(env);
		(*env)->CallVoidMethod(env, cd->obj, mid, bufArray, respondHandle);
		handleException(env);
	}
	
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsQueryNew
		(JNIEnv* env, jclass cl, jint masterHandle, jint dataBubbleHandle, jint queryBubbleId, jfloat lambda, jobject responder)
{
	CallbackData* cd = newCallbackData(env, responder); // TODO delete cd on free
	disableSignals();
	jint res = bs_query_new(masterHandle, dataBubbleHandle, queryBubbleId, lambda, queryResponder, cd);
	enableSignals();
	return res;
}

void queryResponseCb(Int32_t idHandle, Int32_t streamHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "response", "(II)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, idHandle, streamHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsQueryQuery
		(JNIEnv* env, jclass cl, jint handle, jbyteArray queryData,
		 jobject responseCb)
{
	CallbackData* cd = newCallbackData(env, responseCb); // TODO delete cd somewhere (on abort)
	jsize dataLen = (*env)->GetArrayLength(env, queryData);
	jbyte* dataPtr = (*env)->GetPrimitiveArrayCritical(env, queryData, NULL);
	// !!! need to copy data because BS may recursively call the bubble handler...
	void* dataCopy = malloc(dataLen);
	memcpy(dataCopy, dataPtr, dataLen);
	(*env)->ReleasePrimitiveArrayCritical(env, queryData, dataPtr, 0);
// 	printf("### query (size %u)\n", dataLen); fflush(stdout);
	disableSignals();
	jint res = bs_query_query(handle, dataCopy, dataLen, queryResponseCb, cd);
	enableSignals();
// 	(*env)->ReleasePrimitiveArrayCritical(env, queryData, dataPtr, 0);
	free(dataCopy);
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsQueryFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_query_free(handle);
	enableSignals();
	return res;
}

//
// QueryRespond
//

void queryRespondWriter(Int32_t osHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
// 	printf("### queryRespondWriter %llx %llx\n", (unsigned long long) cd, (unsigned long long) cd->obj); fflush(stdout);
	jmethodID mid = getMethod(env, cd->obj, "write", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, osHandle);
	handleException(env);
	
	deleteCallbackData(env, cd);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJni_bsQueryRespond
		(JNIEnv* env, jclass cl, jint handle, jint idHandle, jobject writer)
{
	CallbackData* cd = newCallbackData(env, writer);
// 	printf("### queryRespond %llx %llx\n", (unsigned long long) cd, (unsigned long long) cd->obj); fflush(stdout);
	disableSignals();
	jint res = bs_query_respond(handle, idHandle, queryRespondWriter, cd);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJni_bsQueryRespondFree
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = bs_query_respond_free(handle);
	enableSignals();
	return res;
}
