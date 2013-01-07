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

package net.bubblestorm.cusp;

import java.util.concurrent.Callable;

import net.bubblestorm.BSError;
import net.bubblestorm.Abortable;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;
import net.bubblestorm.util.Mailbox;
import net.bubblestorm.util.Pair;

/**
 * An EndPoint is the local connection point of CUSP.
 * 
 * @author Max Lehn
 */
public class EndPoint extends BaseObject {

	//
	// public interface
	//

	/**
	 * Notification interface for outgoing contact attempts.
	 * 
	 * @see EndPoint#contact(Address, int, ContactHandler) contact()
	 */
	public interface ContactHandler {
		void onContact(Host host, OutStream os);

		void onContactFail();
	}

	/**
	 * Notification interface for incoming connections.
	 * 
	 * @see EndPoint#advertise(int, AdvertiseHandler) advertise()
	 */
	public interface AdvertiseHandler {
		void onConnect(Host host, InStream is);
	}

	/**
	 * Creates an EndPoint using the specified UDP port.
	 * 
	 * @param port
	 *            the UDP port
	 * @return the new EndPoint
	 * @throws BSError
	 */
	public static EndPoint create(final int port, final boolean encrypt) throws BSError {
		CUSPJni.init();
		return CUSPJni.call(new Callable<EndPoint>() {
			@Override
			public EndPoint call() throws BSError {
				int handle = CUSPJni.cuspEndpointNew(port, encrypt);
				if (handle == -2)
					throw new PortInUseException();
				return new EndPoint(CUSPJni.checkResult(handle));
			}
		});
	}
	
	public static EndPoint create(int port) throws BSError {
		return create(port, false);
	}

	/**
	 * Destroys the EndPoint.
	 * 
	 * @throws BSError
	 */
	public void destroy() throws BSError {
		CUSPJni.call(new Callable<Void>() {
			@Override
			public Void call() throws BSError {
				CUSPJni.checkResult(CUSPJni.cuspEndpointDestroy(getHandle()));
				return null;
			}
		});
	}

	/**
	 * @return the total number of bytes sent by the end point
	 * @throws BSError
	 */
	public long bytesSent() throws BSError {
		return CUSPJni.call(new Callable<Long>() {
			@Override
			public Long call() throws BSError {
				return CUSPJni.checkResult(CUSPJni.cuspEndpointBytesSent(getHandle()));
			}
		});
	}

	/**
	 * @return the total number of bytes received by the end point
	 * @throws BSError
	 */
	public long bytesReceived() throws BSError {
		return CUSPJni.call(new Callable<Long>() {
			@Override
			public Long call() throws BSError {
				return CUSPJni.checkResult(CUSPJni.cuspEndpointBytesReceived(getHandle()));
			}
		});
	}

	public ChannelIterator channels() throws BSError {
		return CUSPJni.call(new Callable<ChannelIterator>() {
			@Override
			public ChannelIterator call() throws BSError {
				return new ChannelIterator(CUSPJni.checkResult(CUSPJni
						.cuspEndpointChannels(getHandle())));
			}
		});
	}

	/**
	 * Asynchronously contacts a remote host.
	 * 
	 * @param addr
	 *            the remote host's address
	 * @param service
	 *            the service ID to connect to
	 * @param contactHandler
	 *            is notified on contact success or failure
	 * @return a Stoppable object to abort the operation
	 * @throws BSError
	 */
	public Abortable contact(final Address addr, final int service,
			final ContactHandler contactHandler) throws BSError {
		return CUSPJni.call(new Callable<Abortable>() {
			@Override
			public Abortable call() throws BSError {
				Object callback = new Object() {
					@SuppressWarnings("unused")
					protected void contactCallback(int hostHandle, int osHandle) {
						if (hostHandle >= 0) {
							final Host host = new Host(hostHandle);
							final OutStream os = new OutStream(osHandle);
							CUSPJni.invokeInThread(new Runnable() {
								@Override
								public void run() {
									contactHandler.onContact(host, os);
								}
							});
						} else {
							CUSPJni.invokeInThread(new Runnable() {
								@Override
								public void run() {
									contactHandler.onContactFail();
								}
							});
						}
					}
				};
				return new Abortable(CUSPJni.checkResult(CUSPJni.cuspEndpointContact(getHandle(),
						addr.getHandle(), (short) service, callback)));
			}
		});
	}

	/**
	 * Synchronously contacts a remote host.
	 * 
	 * @param addr
	 *            the remote host's address
	 * @param service
	 *            the service ID to connect to
	 * @return the remote Host object and an OutStream
	 * @throws BSError
	 */
	public Pair<Host, OutStream> contact(final Address addr, final int service) throws BSError {
		CUSPJni.checkAllowBlockingOperation();
		final Mailbox<Pair<Host, OutStream>, BSError> mb = new Mailbox<Pair<Host, OutStream>, BSError>();

		CUSPJni.call(new Callable<Void>() {
			@Override
			public Void call() throws BSError {
				Object callback = new Object() {
					@SuppressWarnings("unused")
					protected void contactCallback(int hostHandle, int osHandle) {
						if (hostHandle >= 0) {
							Host host = new Host(hostHandle);
							OutStream os = new OutStream(osHandle);
							mb.put(new Pair<Host, OutStream>(host, os));
						} else {
							mb.exception(new BSError("Contact failed"));
						}
					}
				};
				CUSPJni.checkResult(CUSPJni.cuspEndpointContact(getHandle(), addr.getHandle(),
						(short) service, callback));
				return null;
			}
		});

		try {
			return mb.waitFor();
		} catch (InterruptedException ex) {
			throw new BSError("Blocking operation was interrupted", ex);
		}
	}

	/**
	 * Advertises a given service ID. Advertise is comparable to TCP's listen
	 * operation.
	 * 
	 * @param service
	 *            the public service ID
	 * @param advertiseHandler
	 *            receives a notification on incoming connections
	 * @throws BSError
	 */
	public void advertise(final int service, final AdvertiseHandler advertiseHandler)
			throws BSError {
		CUSPJni.call(new Callable<Void>() {
			@Override
			public Void call() throws BSError {
				Object callback = new Object() {
					@SuppressWarnings("unused")
					protected void connectCallback(int hostHandle, int osHandle) {
						final Host host = new Host(hostHandle);
						final InStream is = new InStream(osHandle);
						CUSPJni.invokeInThread(new Runnable() {
							@Override
							public void run() {
								advertiseHandler.onConnect(host, is);
							}
						});
					}
				};
				CUSPJni.checkResult(CUSPJni.cuspEndpointAdvertise(getHandle(), (short) service,
						callback));
				return null;
			}
		});
	}

	public boolean canReceiveUDP() throws BSError {
		return CUSPJni.call(new Callable<Boolean>() {
			@Override
			public Boolean call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspEndpointCanReceiveUDP(getHandle())) != 0;
			}
		});
	}

	public boolean canSendOwnICMP() throws BSError {
		return CUSPJni.call(new Callable<Boolean>() {
			@Override
			public Boolean call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspEndpointCanSendOwnICMP(getHandle())) != 0;
			}
		});
	}

	//
	// protected methods
	//

	public EndPoint(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspEndpointFree(handle);
	}

}
