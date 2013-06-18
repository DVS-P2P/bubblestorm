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

import net.bubblestorm.jni.BSJniBase;

/**
 * The CUSP JNI access class. To be used internally only.
 * 
 * @author Max Lehn
 */
public class CUSPJni extends BSJniBase {

	//
	// public
	//

	/**
	 * Initialize all JNI stuff. Has to be called prior to using any other
	 * method.
	 */
	public static void init() {
		if (!initialized) {
			// load native SQLite and CUSP libraries
			// (cuspjni depends on them, but the OS may not find it if it's not in
			// the search path)
			System.loadLibrary("sqlite3");
			System.loadLibrary("cusp");
			// load native CUSP library
			System.loadLibrary("cuspjni");
			// init super class
			BSJniBase.init();
			//
			initialized = true;
		}
	}

	/**
	 * Shut down the JNI library and terminate all internal threads. Note that
	 * you are not allowed to use any CUSP object after calling this method.
	 */
	public static void shutdown() {
		BSJniBase.shutdown();
	}

	//
	// protected
	//

	protected static boolean initialized = false;

	//
	// native declarations
	//

	// Endpoint

	public static native int cuspEndpointNew(int port, boolean encrypt);

	public static native int cuspEndpointDestroy(int handle);

	public static native long cuspEndpointBytesSent(int handle);

	public static native long cuspEndpointBytesReceived(int handle);

	public static native int cuspEndpointChannels(int handle);

	public static native int cuspEndpointContact(int handle, int addrHandle, short service,
			Object contactHandler);

	public static native int cuspEndpointAdvertise(int handle, short service,
			Object advertiseHandler);

	public static native int cuspEndpointCanReceiveUDP(int handle);
	
	public static native int cuspEndpointCanSendOwnICMP(int handle);
	
	public static native boolean cuspEndpointFree(int handle);

	// Address

	public static native int cuspAddressFromString(String str);

	public static native String cuspAddressToString(int handle);

	public static native boolean cuspAddressFree(int handle);

	// Host

	public static native int cuspHostAddress(int handle);

	public static native String cuspHostToString(int handle);

	public static native int cuspHostInstreams(int handle);
	
	public static native int cuspHostOutstreams(int handle);
	
	public static native boolean cuspHostFree(int handle);

	// ChannelIterator

	public static native int cuspChannelIteratorHasNext(int handle);

	public static native long cuspChannelIteratorNext(int handle);

	public static native boolean cuspChannelIteratorFree(int handle);

	// InStream

	public static native int cuspInstreamState(int handle);

	public static native int cuspInstreamQueuedOutOfOrder(int handle);

	public static native int cuspInstreamQueuedUnread(int handle);

	public static native long cuspInstreamBytesReceived(int handle);

	public static native int cuspInstreamReset(int handle);

	public static native int cuspInstreamRead(int handle, byte[] buf, int ofs, int len,
			Object readHandler);

	public static native int cuspInstreamReadShutdown(int handle, Object handler);

	public static native boolean cuspInstreamFree(int handle);

	// InStreamIterator

	public static native int cuspInstreamIteratorHasNext(int handle);

	public static native int cuspInstreamIteratorNext(int handle);

	public static native boolean cuspInstreamIteratorFree(int handle);

	// OutStream

	public static native int cuspOutstreamState(int handle);

	public static native int cuspOutstreamShutdown(int handle, Object shutdownHandler);

	public static native int cuspOutstreamReset(int handle);

	public static native int cuspOutstreamWrite(int handle, byte[] buf, int ofs, int len,
			Object writeHandler);

	public static native float cuspOutstreamGetPriority(int handle);

	public static native int cuspOutstreamSetPriority(int handle, float priority);

	public static native boolean cuspOutstreamFree(int handle);

	// OutStreamIterator

	public static native int cuspOutstreamIteratorHasNext(int handle);

	public static native int cuspOutstreamIteratorNext(int handle);

	public static native boolean cuspOutstreamIteratorFree(int handle);

}
