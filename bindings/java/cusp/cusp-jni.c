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

#include "cusp-jni.h"
#ifndef LIBCUSP_H_INCLUDED
#include <libcusp.h>
#endif
#include "../common/main-jni.c"

//
// EndPoint
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointNew
		(JNIEnv *env, jclass cl, jint port, jboolean encrypt)
{
	disableSignals();
	int hKey = cusp_privatekey_new();
	jint res = cusp_endpoint_new(port, hKey, encrypt,
		cusp_suiteset_publickey_defaults(), cusp_suiteset_symmetric_defaults());
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointDestroy
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_endpoint_destroy(handle);
	enableSignals();
	return res;
}

JNIEXPORT jlong JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointBytesSent
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jlong res = cusp_endpoint_bytes_sent(handle);
	enableSignals();
	return res;
}

JNIEXPORT jlong JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointBytesReceived
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jlong res = cusp_endpoint_bytes_received(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointChannels
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_endpoint_channels(handle);
	enableSignals();
	return res;
}

void endpointContactCallback(Int32_t hostHandle, Int32_t osHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* ad = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, ad->obj, "contactCallback", "(II)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, ad->obj, mid, hostHandle, osHandle);
	handleException(env);
	
	deleteCallbackData(env, ad);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointContact
		(JNIEnv *env, jclass cl, jint handle, jint addrHandle, jshort service,
		 jobject contactHandler)
{
	CallbackData* ad = newCallbackData(env, contactHandler);
	disableSignals();
	jint res = cusp_endpoint_contact(handle, addrHandle, service,
		endpointContactCallback, ad);
	enableSignals();
	return res;
}
  
void endpointAdvertiseCallback(Int32_t hostHandle, Int32_t isHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* ad = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, ad->obj, "connectCallback", "(II)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, ad->obj, mid, hostHandle, isHandle);
	handleException(env);
	
	// (don't free ad!)
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointAdvertise
		(JNIEnv *env, jclass cl, jint handle, jshort service,
		 jobject contactHandler)
{
	CallbackData* ad = newCallbackData(env, contactHandler);
	disableSignals();
	jint res = cusp_endpoint_advertise(handle, service, endpointAdvertiseCallback, ad);
	enableSignals();
	// TODO free ad on un-advertise
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointCanReceiveUDP
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_endpoint_can_receive_udp(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointCanSendOwnICMP
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_endpoint_can_send_own_icmp(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspEndpointFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_endpoint_free(handle);
	enableSignals();
	return res;
}

//
// Address
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspAddressFromString
		(JNIEnv *env, jclass cl, jstring str)
{
	jsize len = (*env)->GetStringUTFLength(env, str);
	const char* strBytes = (*env)->GetStringUTFChars(env, str, NULL);
	disableSignals();
	jint res = cusp_address_from_string((Objptr) strBytes, len);
	enableSignals();
	(*env)->ReleaseStringUTFChars(env, str, strBytes);
	return res;
}

JNIEXPORT jstring JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspAddressToString
		(JNIEnv* env, jclass cl, jint handle)
{
	Int32_t len;
	disableSignals();
	char* strData = (char*) cusp_address_to_string(handle, &len);
	enableSignals();
	return makeJString(env, strData, len);
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspAddressFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_address_free(handle);
	enableSignals();
	return res;
}

//
// Host
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspHostAddress
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_host_address(handle);
	enableSignals();
	return res;
}

JNIEXPORT jstring JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspHostToString
		(JNIEnv* env, jclass cl, jint handle)
{
	Int32_t len;
	disableSignals();
	char* strData = (char*) cusp_host_to_string(handle, &len);
	enableSignals();
	return makeJString(env, strData, len);
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspHostInstreams
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_host_instreams(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspHostOutstreams
		(JNIEnv* env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_host_outstreams(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspHostFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_host_free(handle);
	enableSignals();
	return res;
}

//
// ChannelIterator
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspChannelIteratorHasNext
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_channel_iterator_has_next(handle);
	enableSignals();
	return res;
}

JNIEXPORT jlong JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspChannelIteratorNext
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	Int32_t hostHandle;
	Int32_t addrHandle = cusp_channel_iterator_next(handle, &hostHandle);
	enableSignals();
	return ((jlong) addrHandle) | (((jlong) hostHandle) << 32);
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspChannelIteratorFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_channel_iterator_free(handle);
	enableSignals();
	return res;
}


//
// InStream
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamQueuedOutOfOrder
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_instream_queued_out_of_order(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamQueuedUnread
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_instream_queued_unread(handle);
	enableSignals();
	return res;
}

JNIEXPORT jlong JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamBytesReceived
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_instream_bytes_received(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamState
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_instream_state(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamReset
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_instream_reset(handle);
	enableSignals();
	return res;
}

void instreamReadCallback(Int32_t count, Int32_t ofs, Vector(WordU8_t) data, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	DataCallbackData* cd = (DataCallbackData*) userData;
	
	if ((count >= 0) && cd->buffer) {
		jbyte* bufData = (*env)->GetPrimitiveArrayCritical(env, cd->buffer, NULL);
		if (bufData) {
			memcpy(bufData + cd->ofs, data + ofs, (size_t) count);
			(*env)->ReleasePrimitiveArrayCritical(env, cd->buffer, bufData, 0);
		} else
			count = -3;
	}
	
	jmethodID mid = getMethod(env, cd->obj, "readCallback", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, (jint) count);
	handleException(env);
	
	deleteDataCallbackData(env, cd);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamRead
		(JNIEnv *env, jclass cl, jint handle, jbyteArray buffer, jint ofs, jint len,
		 jobject readHandler)
{
	DataCallbackData* cd = newDataCallbackData(env, readHandler, buffer, ofs, len);
	disableSignals();
	jint res = cusp_instream_read(handle, len, instreamReadCallback, cd);
	enableSignals();
	return res;
}

void instreamReadShutdownCallback(Bool_t success, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* cd = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, cd->obj, "readCallback", "(Z)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, cd->obj, mid, success);
	handleException(env);
	
	deleteCallbackData(env, cd);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamReadShutdown
		(JNIEnv *env, jclass cl, jint handle, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = cusp_instream_read_shutdown(handle, instreamReadShutdownCallback, cd);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_instream_free(handle);
	enableSignals();
	return res;
}


//
// InStreamIterator
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamIteratorHasNext
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_instream_iterator_has_next(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamIteratorNext
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_instream_iterator_next(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspInstreamIteratorFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_instream_iterator_free(handle);
	enableSignals();
	return res;
}


//
// OutStream
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamState
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_outstream_state(handle);
	enableSignals();
	return res;
}

void outstreamShutdownCallback(Bool_t success, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* ad = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, ad->obj, "shutdownCallback", "(Z)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, ad->obj, mid, (jboolean) success);
	handleException(env);
	
	deleteCallbackData(env, ad);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamShutdown
		(JNIEnv *env, jclass cl, jint handle, jobject shutdownHandler)
{
	CallbackData* ad = newCallbackData(env, shutdownHandler);
	disableSignals();
	jint res = cusp_outstream_shutdown(handle, outstreamShutdownCallback, ad);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamReset
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_outstream_reset(handle);
	enableSignals();
	return res;
}

void outstreamWriteCallback(Int32_t status, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* ad = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, ad->obj, "writeCallback", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, ad->obj, mid, (jint) status);
	handleException(env);
	
	deleteCallbackData(env, ad);
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamWrite
		(JNIEnv *env, jclass cl, jint handle, jbyteArray buffer, jint ofs, jint len,
		 jobject writeHandler)
{
	CallbackData* ad = newCallbackData(env, writeHandler);
	jbyte* data = (*env)->GetPrimitiveArrayCritical(env, buffer, NULL);
	if (!data) return JNI_FALSE;
	// !!! need to copy data because BS may recursively call the bubble handler...
	void* dataCopy = malloc(len);
	memcpy(dataCopy, data + ofs, len);
	(*env)->ReleasePrimitiveArrayCritical(env, buffer, data, 0);
	disableSignals();
// 	jint res = cusp_outstream_write(handle, data + ofs, len, outstreamWriteCallback, ad);
	jint res = cusp_outstream_write(handle, dataCopy, len, outstreamWriteCallback, ad);
	enableSignals();
// 	(*env)->ReleasePrimitiveArrayCritical(env, buffer, data, 0);
	free(dataCopy);
	return res;
}

JNIEXPORT jfloat JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamGetPriority
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_outstream_get_priority(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamSetPriority
		(JNIEnv *env, jclass cl, jint handle, jfloat priority)
{
	disableSignals();
	jint res = cusp_outstream_set_priority(handle, priority);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_outstream_free(handle);
	enableSignals();
	return res;
}


//
// OutStreamIterator
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamIteratorHasNext
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_outstream_iterator_has_next(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamIteratorNext
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = cusp_outstream_iterator_next(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_CUSPJni_cuspOutstreamIteratorFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = cusp_outstream_iterator_free(handle);
	enableSignals();
	return res;
}
