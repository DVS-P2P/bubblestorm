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
import net.bubblestorm.BubbleStorm;
import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class BubbleStormImpl extends BaseObject implements BubbleStorm {

	//
	// static
	//

	public static void setLanMode(final boolean enable) throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.bsBubbleStormSetLanMode(enable);
				return null;
			}
		});
	}

	public static BubbleStorm create(final float bandwidth, final float minBandwidth,
			final int port, final boolean encrypt) throws BSError {
		return new BubbleStormImpl(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsBubbleStormNew(bandwidth, minBandwidth, port,
						encrypt));
			}
		}));
	}

	public static BubbleStorm createWithEndpoint(final float bandwidth, final float minBandwidth,
			final EndPoint endpoint) throws BSError {
		return new BubbleStormImpl(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsBubbleStormNewWithEndpoint(bandwidth,
						minBandwidth, endpoint.getHandle()));
			}
		}));
	}

	//
	// public interface
	//

	@Override
	public void createRing(final Address localAddr, final JoinHandler createHandler) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void done() {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (createHandler != null)
							createHandler.onJoinComplete();
					}
				});
			}
		};
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleStormCreate(getHandle(), localAddr.getHandle(),
						handler));
				return null;
			}
		});
	}

	@Override
	public void createRing(final Address localAddr) throws BSError {
		createRing(localAddr, null);
	}

	@Override
	public void join(final JoinHandler joinHandler) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void done() {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (joinHandler != null)
							joinHandler.onJoinComplete();
					}
				});
			}
		};
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleStormJoin(getHandle(), handler));
				return null;
			}
		});
	}

	@Override
	public void leave(final LeaveHandler leaveHandler) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void done() {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (leaveHandler != null)
							leaveHandler.onLeaveComplete();
					}
				});
			}
		};
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleStormLeave(getHandle(), handler));
				return null;
			}
		});
	}

	@Override
	public EndPoint endpoint() throws BSError {
		return BSJni.call(new Callable<EndPoint>() {
			@Override
			public EndPoint call() throws Exception {
				int h = BSJni.bsBubbleStormEndpoint(getHandle());
				return new EndPoint(BSJni.checkResult(h));
			}
		});
	}

	@Override
	public BubbleMasterImpl bubbleMaster() throws BSError {
		return BSJni.call(new Callable<BubbleMasterImpl>() {
			@Override
			public BubbleMasterImpl call() throws Exception {
				int h = BSJni.bsBubbleStormBubbleMaster(getHandle());
				return new BubbleMasterImpl(BSJni.checkResult(h));
			}
		});
	}

	@Override
	public Address address() throws BSError {
		return BSJni.call(new Callable<Address>() {
			@Override
			public Address call() throws Exception {
				int h = BSJni.bsBubbleStormAddress(getHandle());
				if (h == -2)
					return null;
				return new Address(BSJni.checkResult(h));
			}
		});
	}

	@Override
	public byte[] saveHostCache() throws BSError {
		return BSJni.call(new Callable<byte[]>() {
			@Override
			public byte[] call() throws Exception {
				return BSJni.checkResult(BSJni.bsBubbleStormSaveHostCache(getHandle()));
			}
		});
	}

	@Override
	public void loadHostCache(final byte[] data, final Address bootstrap) throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				int bootstrapHandle = (bootstrap != null) ? bootstrap.getHandle() : -1;
				BSJni.checkResult(BSJni.bsBubbleStormLoadHostCache(getHandle(), data,
						bootstrapHandle));
				return null;
			}
		});
	}

	//
	// protected
	//

	public BubbleStormImpl(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleStormFree(handle);
	}

}
