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

import java.util.Iterator;
import java.util.concurrent.Callable;

import net.bubblestorm.Abortable;
import net.bubblestorm.BSError;
import net.bubblestorm.BubbleMaster;
import net.bubblestorm.DurableBubble;
import net.bubblestorm.DurableBubbleType;
import net.bubblestorm.ID;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.Time;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.util.Pair;

public class DurableBubbleTypeImpl extends BaseObject implements DurableBubbleType {

	//
	// public
	//

	public static DurableBubbleTypeImpl create(final BubbleMaster master, final String name,
			final int id, final float priority, final DataStore backend) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void store(final int idHandle, final long version, final long time,
					final byte[] data) {
				// System.err
				// .println("store called with " + ((data != null) ? data.length : "(null)"));
				final ID id = new ID(idHandle);
				final Time tm = Time.fromNanoseconds(time);

				BSJni.invoke(new Runnable() {
					@Override
					public void run() {
						backend.store(id, new Item(version, tm, data));
					}
				});
			}

			@SuppressWarnings("unused")
			protected void lookup(final int idHandle, final int cbHandle) {
				final ID id = new ID(idHandle);
				BSJni.invoke(new Runnable() {
					@Override
					public void run() {
						final Item item = backend.lookup(id);
						if (item != null) {
							// asynchronously return datastore result
							BSJni.bsBubbleTypeDurableDatastoreGetCb(cbHandle, item.version,
									item.time.toNanoseconds(), item.data);
						} else {
							// (no result)
							BSJni.bsBubbleTypeDurableDatastoreGetCb(cbHandle, -1, 0, null);
						}
					}
				});
			}

			@SuppressWarnings("unused")
			protected void remove(final int idHandle) {
				final ID id = new ID(idHandle);
				BSJni.invoke(new Runnable() {
					@Override
					public void run() {
						backend.remove(id);
					}
				});
			}

			@SuppressWarnings("unused")
			protected void version(final int idHandle, final int cbHandle) {
				final ID id = new ID(idHandle);
				BSJni.invoke(new Runnable() {
					@Override
					public void run() {
						final Pair<Long, Time> ver = backend.version(id);
						// System.err.println("VERSION " + id + "... " + ver);
						if (ver != null) {
							BSJni.bsBubbleTypeDurableDatastoreVersionCb(cbHandle, ver.getA(), ver
									.getB().toNanoseconds());
						} else {
							BSJni.bsBubbleTypeDurableDatastoreVersionCb(cbHandle, 0, 0);
						}
					}
				});
			}

			@SuppressWarnings("unused")
			protected void iterator(final int cbHandle) {
				// System.err.println("DurableBubbleTypeImpl: list (not implemented)!!");
				BSJni.invoke(new Runnable() {
					@Override
					public void run() {
						final Iterator<Pair<ID, Item>> it = backend.iterator();
						while (it.hasNext()) {
							final Pair<ID, Item> i = it.next();
							final ID id = i.getA();
							final Item item = i.getB();
							// System.err.println("LIST " + id);
							BSJni.bsBubbleTypeDurableDatastoreListCb(cbHandle, id.getHandle(),
									item.version, item.time.toNanoseconds(), item.data);
						}
						// end marker
						// System.err.println("LIST END");
						BSJni.bsBubbleTypeDurableDatastoreListCb(cbHandle, -1, 0, 0, null);
					}
				});
			}

			@SuppressWarnings("unused")
			protected int size() {
				try {
					return BSJni.call(new Callable<Integer>() {
						@Override
						public Integer call() {
							return backend.size();
						}
					});
				} catch (BSError e) {
					// TODO what do here?
					e.printStackTrace();
					return 0;
				}
			}
		};

		return BSJni.call(new Callable<DurableBubbleTypeImpl>() {
			@Override
			public DurableBubbleTypeImpl call() throws Exception {
				// TODO name
				int h = BSJni.bsBubbleMasterNewDurable(master.getHandle(), id, priority, handler);
				return new DurableBubbleTypeImpl(BSJni.checkResult(h));
			}
		});
	}

	@Override
	public void matchWithId(PersistentBubbleType with, double lambda,
			BubbleHandlerWithId bubbleHandler) throws BSError {
		persistent.matchWithId(with, lambda, bubbleHandler);
	}

	@Override
	public void match(PersistentBubbleType with, double lambda, BubbleHandler bubbleHandler)
			throws BSError {
		persistent.match(with, lambda, bubbleHandler);
	}

	@Override
	public int defaultSize() throws BSError {
		return persistent.defaultSize();
	}

	@Override
	public int typeId() throws BSError {
		return persistent.typeId();
	}

	@Override
	public Abortable lookupBubble(final ID id, final LookupHandler lookupHandler) throws BSError {
		return new Abortable(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				Object handler = new Object() {
					@SuppressWarnings("unused")
					protected void receive(int bubbleHandle) {
						final DurableBubble bubble = new DurableBubbleImpl(bubbleHandle);
						BSJni.invokeInThread(new Runnable() {
							@Override
							public void run() {
								lookupHandler.onResponse(bubble);
							}
						});
					}
				};
				int h = BSJni.bsBubbleDurableLookup(getHandle(), id.getHandle(), handler);
				return BSJni.checkResult(h);
			}
		}));
		// final int[] result = new int[1];
		// final Object handler = new Object() {
		// @SuppressWarnings("unused")
		// void receive(int bubbleHandle) {
		// result[0] = bubbleHandle;
		// synchronized (result) {
		// result.notify();
		// }
		// }
		// };
		//
		// synchronized (result) {
		// // call BS
		// BSJni.invoke(new Runnable() {
		// @Override
		// public void run() {
		// try {
		// BSJni.checkResult(BSJni.bsBubbleDurableLookup(getHandle(), id.getHandle(),
		// handler));
		// } catch (BSError e) {
		// // TODO Auto-generated catch block
		// e.printStackTrace();
		// }
		// }
		// });
		//
		// // wait for receive callback
		// try {
		// result.wait();
		// } catch (InterruptedException e) {
		// return null;
		// }
		// return (result[0] >= 0) ? new DurableBubbleImpl(result[0]) : null;
		// }
	}

	@Override
	public DurableBubble createBubble(final ID id, final byte[] data) throws BSError {
		return BSJni.call(new Callable<DurableBubbleImpl>() {
			@Override
			public DurableBubbleImpl call() throws Exception {
				int h = BSJni.bsBubbleDurableCreate(getHandle(), id.getHandle(), data);
				return new DurableBubbleImpl(BSJni.checkResult(h));
			}
		});
	}

	//
	// protected
	//

	protected DurableBubbleTypeImpl(int handle) throws BSError {
		super(handle);
		final int basicHandle = BSJni.checkResult(BSJni.bsBubbleTypeDurableBasic(handle));
		final int persistentHandle = BSJni.checkResult(BSJni.bsBubbleTypeDurablePersistent(handle));
		persistent = new PersistentBubbleTypeImpl(persistentHandle, basicHandle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleTypeDurableFree(handle);
	}

	//
	// private
	//

	private final PersistentBubbleTypeImpl persistent;

}
