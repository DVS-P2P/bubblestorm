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

package net.bubblestorm.impl;

import java.util.concurrent.Callable;

import net.bubblestorm.BSError;
import net.bubblestorm.ID;
import net.bubblestorm.NotificationReceiver;
import net.bubblestorm.NotificationResult;
import net.bubblestorm.NotificationSender;
import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.cusp.InStream;
import net.bubblestorm.cusp.OutStream;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.util.Pair;

public class NotificationReceiverImpl extends BaseObject implements NotificationReceiver {

	//
	// static
	//

	public static NotificationReceiver create(final EndPoint ep, final Handler handler) throws BSError {
		final Object handlerObj = new Object() {
			// @SuppressWarnings("unused")
			// protected int getLocalAddr() {
			// Address addr = handler.getLocalAddress();
			// return (addr != null) ? addr.getHandle() : -1;
			// // F-IXME? there could be a problem when the GC finalizes the
			// // address object, and thus invalidates the handle, before
			// // returning!
			// }

			@SuppressWarnings("unused")
			protected void resultReceiver(int resultHandle) {
				final NotificationResult result = new Result(resultHandle);
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (handler != null)
							handler.onNotify(result);
					}
				});
			}
		};
		return new NotificationReceiverImpl(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsNotificationNew(ep.getHandle(), handlerObj));
			}
		}));
	}

	public static Pair<NotificationSender, Integer> decode(final byte[] data,
			final EndPoint endpoint) throws BSError {
		long res = BSJni.call(new Callable<Long>() {
			@Override
			public Long call() throws Exception {
				return BSJni.bsNotificationDecode(data, endpoint.getHandle());
			}
		});
		NotificationSender sender = new Sender(BSJni.checkResult((int) (res & 0xffffffff)));
		int length = (int) (res >> 32);
		return new Pair<NotificationSender, Integer>(sender, length);
	}

	//
	// public interface
	//

	@Override
	public void close() throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsNotificationClose(getHandle()));
				return null;
			}
		});
	}

	@Override
	public int maxEncodedLength() throws BSError {
		return BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsNotificationMaxEncodedLength());
			}
		});
	}

	@Override
	public byte[] encode(final Address localAddress) throws BSError {
		return BSJni.call(new Callable<byte[]>() {
			@Override
			public byte[] call() throws Exception {
				return BSJni.checkResult(BSJni.bsNotificationEncode(getHandle(), localAddress
						.getHandle()));
			}
		});
	}

	//
	// protected
	//

	public NotificationReceiverImpl(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsNotificationFree(handle);
	}

	//
	// inner classes
	//

	public static class Result extends BaseObject implements NotificationResult {

		@Override
		public ID id() throws BSError {
			return new ID(BSJni.call(new Callable<Integer>() {
				@Override
				public Integer call() throws Exception {
					return BSJni.checkResult(BSJni.bsNotificationResultId(getHandle()));
				}
			}));
		}

		@Override
		public InStream payload() throws BSError {
			return new InStream(BSJni.call(new Callable<Integer>() {
				@Override
				public Integer call() throws Exception {
					return BSJni.checkResult(BSJni.bsNotificationResultPayload(getHandle()));
				}
			}));
		}

		@Override
		public void cancel() throws BSError {
			BSJni.call(new Callable<Void>() {
				@Override
				public Void call() throws Exception {
					BSJni.checkResult(BSJni.bsNotificationResultCancel(getHandle()));
					return null;
				}
			});
		}

		//
		// protected
		//

		public Result(int handle) {
			super(handle);
		}

		@Override
		protected boolean free(int handle) {
			return BSJni.bsNotificationResultFree(handle);
		}

	}

	public static class Sender extends BaseObject implements NotificationSender {

		@Override
		public void send(final ID id, final SendHandler handler) throws BSError {
			final Object handlerObj = new Object() {
				@SuppressWarnings("unused")
				protected void getData(final int osHandle) {
					final OutStream os = (osHandle >= 0) ? new OutStream(osHandle) : null;
					BSJni.invokeInThread(new Runnable() {
						@Override
						public void run() {
							if (os != null)
								handler.getData(os);
							else
								handler.abort();
						}
					});
				}
			};
			BSJni.call(new Callable<Void>() {
				@Override
				public Void call() throws Exception {
					BSJni.checkResult(BSJni.bsNotificationSendFn(getHandle(), id.getHandle(),
							handlerObj));
					return null;
				}
			});
		}

		@Override
		public void sendImmmediate(final ID id, final byte[] data) throws BSError {
			BSJni.call(new Callable<Void>() {
				@Override
				public Void call() throws Exception {
					BSJni.checkResult(BSJni.bsNotificationSendFnImmediate(getHandle(), id
							.getHandle(), data));
					return null;
				}
			});
		}

		//
		// protected
		//

		public Sender(int handle) {
			super(handle);
		}

		@Override
		protected boolean free(int handle) {
			return BSJni.bsNotificationSendFnFree(handle);
		}

	}

}
