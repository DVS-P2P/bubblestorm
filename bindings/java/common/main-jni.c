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

#include "main-jni.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#ifndef __WIN32__
#include <unistd.h>
#include <sys/socket.h>
#else
#include <winsock2.h>
#endif

#ifndef LIBRARY_NAME
#error "LIBRARY_NAME is not set. Set it to e.g., 'cusp' or 'bubblestorm'."
#endif
#define LIB_FUNCTION_PASTER(x,y) x ## _ ## y
#define LIB_FUNCTION_EVALUATOR(x,y) LIB_FUNCTION_PASTER(x,y)
#define LIB_FUNCTION(fun) LIB_FUNCTION_EVALUATOR(LIBRARY_NAME, fun)


typedef struct {
	jobject obj;
} CallbackData;

typedef struct {
	jobject obj;
	jbyteArray buffer;
	int ofs;
	int len;
} DataCallbackData;

// static data
#ifdef DISABLE_SIGNALS
static sigset_t sigAll;
static sigset_t sigSave;
#endif
static JavaVM* jvm;
static jclass cuspClass;
static int asyncHandle;
static int asyncFD;

// library open/close handler functions, not used here
void bs_lib_opened() {}
void bs_lib_closed() {}

//
// helper functions
//

inline void disableSignals()
{
#ifdef DISABLE_SIGNALS
 	sigprocmask(SIG_BLOCK, &sigAll, &sigSave);
#endif
}

inline void enableSignals()
{
#ifdef DISABLE_SIGNALS
 	sigprocmask(SIG_SETMASK, &sigSave, NULL);
#endif
}

CallbackData* newCallbackData(JNIEnv* env, jobject obj)
{
	CallbackData* ad = malloc(sizeof(CallbackData));
	ad->obj = (*env)->NewGlobalRef(env, obj);
	return ad;
}

void deleteCallbackData(JNIEnv* env, CallbackData* ad)
{
	if (ad) {
		(*env)->DeleteGlobalRef(env, ad->obj);
		free(ad);
	}
}

DataCallbackData* newDataCallbackData(JNIEnv* env, jobject obj, jbyteArray buffer,
		int ofs, int len)
{
	DataCallbackData* ad = malloc(sizeof(DataCallbackData));
	ad->obj = (*env)->NewGlobalRef(env, obj);
	ad->buffer = (buffer) ? (*env)->NewGlobalRef(env, buffer) : NULL;
	ad->ofs = ofs;
	ad->len = len;
	return ad;
}

void deleteDataCallbackData(JNIEnv* env, DataCallbackData* ad)
{
	if (ad) {
		(*env)->DeleteGlobalRef(env, ad->obj);
		if (ad->buffer)
			(*env)->DeleteGlobalRef(env, ad->buffer);
		free(ad);
	}
}

inline JNIEnv* attachThread()
{
	JNIEnv *env;
	if ((*jvm)->AttachCurrentThread(jvm, (void**) &env, NULL) == JNI_OK) {
		return env;
	} else {
		printf("AttachCurrentThread FAILED\n");
		fflush(stdout);
		return NULL;
	}
}

inline void detachThread()
{
	// (TODO necessary?)
// 	if ((*jvm)->DetachCurrentThread(jvm) != 0) {
// 		printf("DetachCurrentThread FAILED\n");
// 		fflush(stdout);
// 	}
}

jmethodID getMethod(JNIEnv* env, jobject obj, const char* name, const char* signature)
{
	jclass cls = (*env)->GetObjectClass(env, obj);
	jmethodID mid = (*env)->GetMethodID(env, cls, name, signature);
	if (mid)
		return mid;
	else {
		char buf[256];
		sprintf(buf, "Method %s:%s not found", name, signature);
		(*env)->FatalError(env, buf);
		return 0;
	}
}

inline void handleException(JNIEnv* env)
{
	if ((*env)->ExceptionCheck(env)) {
		printf("Exception in BS callback handler!\n");
		fflush(stdout);
		(*env)->ExceptionDescribe(env);
		(*env)->ExceptionClear(env);
	}
}

void asyncHandler(CPointer data)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	
	jmethodID mid = (*env)->GetStaticMethodID(env, cuspClass, "asyncCallback", "()V");
	(*env)->ExceptionClear(env);
	(*env)->CallStaticVoidMethod(env, cuspClass, mid);
	handleException(env);
	
	detachThread();
	disableSignals();
}

inline jstring makeJString(JNIEnv *env, const char* str, int len)
{
	if (len >= 0) {
		char* buf = (char*) malloc(len + 1);
		memcpy(buf, str, len);
		buf[len] = 0;
		jstring res = (*env)->NewStringUTF(env, buf);
		free(buf);
		return res;
	} else
		return NULL;
}

// ----------------------------------------------------------------------------
//   JNI functions
// ----------------------------------------------------------------------------

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
	// init static data
#ifdef DISABLE_SIGNALS
	sigfillset(&sigAll);
	sigfillset(&sigSave);
#endif
	jvm = vm;
	
	return JNI_VERSION_1_4;
}

//
// BubbleStorm library functions
//

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJniBase_libInit
		(JNIEnv *env, jclass cl)
{
	cuspClass = (*env)->NewGlobalRef(env, cl);
	disableSignals();
	
	// init BubbleStorm lib
	const char* argv[] = { "", NULL };
	// HACK: giving one argument works around bug in CommandLine.arguments ()
	LIB_FUNCTION(open)(1, argv);
	
	// create async handler
	asyncHandle = evt_asynchandler_create(asyncHandler, NULL);
	if (asyncHandle < 0) return JNI_FALSE;
	asyncFD = evt_asynchandler_get_socket(asyncHandle);
	if (asyncFD < 0) return JNI_FALSE;
	
	enableSignals();
	return JNI_TRUE;
}

JNIEXPORT void JNICALL Java_net_bubblestorm_jni_BSJniBase_libShutdown
		(JNIEnv *env, jclass cl)
{
	disableSignals();
	
	evt_asynchandler_delete(asyncHandle);
	evt_asynchandler_free(asyncHandle);
	LIB_FUNCTION(close)();
	
	(*env)->DeleteGlobalRef(env, cuspClass);
	cuspClass = NULL;
	
	enableSignals();
}

JNIEXPORT jstring JNICALL Java_net_bubblestorm_jni_BSJniBase_bsLastErrorMsg
		(JNIEnv *env, jclass cl)
{
	// emulate old error message passing behavior
	disableSignals();
/*	Int32_t strLen;
	char* strPtr = (char*) bs_last_error_msg(&strLen);*/
	Int32_t exnHandle = bs_last_exception();
	char* strPtr; Int32_t strLen;
	if (exnHandle >= 0) {
		strPtr = (char*) bs_exception_message(exnHandle, &strLen);
	} else {
		strPtr = NULL;
		strLen = -1;
	}
	enableSignals();
	return makeJString(env, strPtr, strLen);
}

JNIEXPORT void JNICALL Java_net_bubblestorm_jni_BSJniBase_evtMain
		(JNIEnv *env, jclass cl)
{
	disableSignals();
	evt_main();
	enableSignals();
}

JNIEXPORT void JNICALL Java_net_bubblestorm_jni_BSJniBase_evtStopMain
		(JNIEnv *env, jclass cl)
{
	disableSignals();
	evt_stop_main();
	enableSignals();
}

JNIEXPORT void JNICALL Java_net_bubblestorm_jni_BSJniBase_evtAsyncInvoke
		(JNIEnv *env, jclass cl)
{
	// invoke
	send(asyncFD, "\0", 1, 0);
}

//
// Time
//

JNIEXPORT jlong JNICALL Java_net_bubblestorm_jni_BSJniBase_evtTimeFromString
		(JNIEnv *env, jclass cl, jstring str)
{
	const char* strBytes = (*env)->GetStringUTFChars(env, str, NULL);
	jsize len = (*env)->GetStringUTFLength(env, str);
	disableSignals();
	jlong res = evt_time_from_string((Objptr) strBytes, len);
	enableSignals();
	(*env)->ReleaseStringUTFChars(env, str, strBytes);
	return res;
}

JNIEXPORT jstring JNICALL Java_net_bubblestorm_jni_BSJniBase_evtTimeToString
		(JNIEnv *env, jclass cl, jlong time)
{
	disableSignals();
	Int32_t strLen;
	char* strPtr = (char*) evt_time_to_string(time, &strLen);
	enableSignals();
	return makeJString(env, strPtr, strLen);
}

JNIEXPORT jstring JNICALL Java_net_bubblestorm_jni_BSJniBase_evtTimeToAbsoluteString
		(JNIEnv *env, jclass cl, jlong time)
{
	disableSignals();
	Int32_t strLen;
	char* strPtr = (char*) evt_time_to_absolute_string(time, &strLen);
	enableSignals();
	return makeJString(env, strPtr, strLen);
}

JNIEXPORT jstring JNICALL Java_net_bubblestorm_jni_BSJniBase_evtTimeToRelativeString
		(JNIEnv *env, jclass cl, jlong time)
{
	disableSignals();
	Int32_t strLen;
	char* strPtr = (char*) evt_time_to_relative_string(time, &strLen);
	enableSignals();
	return makeJString(env, strPtr, strLen);
}

//
// Event
//

JNIEXPORT jlong JNICALL Java_net_bubblestorm_jni_BSJniBase_evtEventTime
		(JNIEnv *env, jclass cl)
{
	disableSignals();
	jlong res = evt_event_time();
	enableSignals();
	return res;
}

void eventHandler(Int32_t evtHandle, CPointer userData)
{
	enableSignals();
	JNIEnv *env = attachThread();
	if (!env) return;
	CallbackData* ad = (CallbackData*) userData;
	
	jmethodID mid = getMethod(env, ad->obj, "event", "(I)V");
	(*env)->ExceptionClear(env);
	(*env)->CallVoidMethod(env, ad->obj, mid, evtHandle);
	handleException(env);
	
	detachThread();
	disableSignals();
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_evtEventNew
		(JNIEnv *env, jclass cl, jobject handler)
{
	CallbackData* cd = newCallbackData(env, handler);
	disableSignals();
	jint res = evt_event_new(eventHandler, cd);
	enableSignals();
	// TODO free cd somewhere
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_evtEventScheduleAt
		(JNIEnv *env, jclass cl, jint handle, jlong time)
{
	disableSignals();
	jint res = evt_event_schedule_at(handle, time);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_evtEventScheduleIn
		(JNIEnv *env, jclass cl, jint handle, jlong time)
{
	disableSignals();
	jint res = evt_event_schedule_in(handle, time);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_evtEventCancel
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = evt_event_cancel(handle);
	enableSignals();
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_evtEventIsScheduled
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = evt_event_is_scheduled(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJniBase_evtEventFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = evt_event_free(handle);
	enableSignals();
	return res;
}

//
// Abortable
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_evtAbortableAbort
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jint res = evt_abortable_abort(handle);
	enableSignals();
	return res;
}

JNIEXPORT jboolean JNICALL Java_net_bubblestorm_jni_BSJniBase_evtAbortableFree
		(JNIEnv *env, jclass cl, jint handle)
{
	disableSignals();
	jboolean res = evt_abortable_free(handle);
	enableSignals();
	return res;
}

//
// Log
//

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_sysLogLog
		(JNIEnv *env, jclass cl, jint severity, jstring module, jstring msg)
{
	const char* moduleBytes = (*env)->GetStringUTFChars(env, module, NULL);
	const jsize moduleLen = (*env)->GetStringUTFLength(env, module);
	const char* msgBytes = (*env)->GetStringUTFChars(env, msg, NULL);
	const jsize msgLen = (*env)->GetStringUTFLength(env, msg);
	disableSignals();
	jint res = sys_log_log(severity, (Objptr) moduleBytes, moduleLen, (Objptr) msgBytes, msgLen);
	enableSignals();
	(*env)->ReleaseStringUTFChars(env, msg, msgBytes);
	(*env)->ReleaseStringUTFChars(env, module, moduleBytes);
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_sysLogAddFilter
		(JNIEnv *env, jclass cl, jstring module, jint severity)
{
	const char* moduleBytes = (*env)->GetStringUTFChars(env, module, NULL);
	const jsize moduleLen = (*env)->GetStringUTFLength(env, module);
	disableSignals();
	jint res = sys_log_addfilter((Objptr) moduleBytes, moduleLen, severity);
	enableSignals();
	(*env)->ReleaseStringUTFChars(env, module, moduleBytes);
	return res;
}

JNIEXPORT jint JNICALL Java_net_bubblestorm_jni_BSJniBase_sysLogRemoveFilter
		(JNIEnv *env, jclass cl, jstring module)
{
	const char* moduleBytes = (*env)->GetStringUTFChars(env, module, NULL);
	const jsize len = (*env)->GetStringUTFLength(env, module);
	disableSignals();
	jint res = sys_log_removefilter((Objptr) moduleBytes, len);
	enableSignals();
	(*env)->ReleaseStringUTFChars(env, module, moduleBytes);
	return res;
}
