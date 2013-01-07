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

package net.bubblestorm.cusp.async;

import net.bubblestorm.BSError;
import net.bubblestorm.cusp.PortInUseException;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;

/**
 * Note: The async version of CUSP is unsupported and should not be used.
 */
@Deprecated
public class EndPoint extends BaseObject {

	//
	// public interface
	//

	public interface ContactHandler {
		void onContact(Host host, OutStream os);

		void onContactFail();
	}

	public interface AdvertiseHandler {
		void onConnect(Host host, InStream is);
	}

	public static EndPoint create(int port, boolean encrypt) throws BSError {
		CUSPJni.init();
		int handle = CUSPJni.cuspEndpointNew(port, encrypt);
		if (handle == -2)
			throw new PortInUseException();
		return new EndPoint(CUSPJni.checkResult(handle));
	}

	public static EndPoint create(int port) throws BSError {
		return create(port, false);
	}

	public void destroy() {
		CUSPJni.cuspEndpointDestroy(getHandle());
	}

	public void contact(Address addr, int service, final ContactHandler contactHandler) {
		Object callback = new Object() {
			@SuppressWarnings("unused")
			protected void contactCallback(int hostHandle, int osHandle) {
				if (hostHandle >= 0) {
					Host host = new Host(hostHandle);
					OutStream os = new OutStream(osHandle);
					contactHandler.onContact(host, os);
				} else {
					contactHandler.onContactFail();
				}
			}
		};
		CUSPJni.cuspEndpointContact(getHandle(), addr.getHandle(), (short) service, callback);
	}

	public void advertise(int service, final AdvertiseHandler advertiseHandler) {
		Object callback = new Object() {
			@SuppressWarnings("unused")
			protected void connectCallback(int hostHandle, int osHandle) {
				Host host = new Host(hostHandle);
				InStream is = new InStream(osHandle);
				advertiseHandler.onConnect(host, is);
			}
		};
		CUSPJni.cuspEndpointAdvertise(getHandle(), (short) service, callback);
	}

	//
	// protected methods
	//

	protected EndPoint(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspEndpointFree(handle);
	}

}
