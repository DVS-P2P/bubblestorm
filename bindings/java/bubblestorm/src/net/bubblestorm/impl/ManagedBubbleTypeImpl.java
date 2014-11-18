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
import net.bubblestorm.BubbleMaster;
import net.bubblestorm.ID;
import net.bubblestorm.ManagedBubble;
import net.bubblestorm.ManagedBubbleType;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class ManagedBubbleTypeImpl extends BaseObject implements ManagedBubbleType {

	//
	// public
	//

	public static ManagedBubbleTypeImpl create(final BubbleMaster master, final String name,
			final int id, final float priority, final DataStore backend) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void insert(final int idHandle, final byte[] data, final boolean bucket) {
				final ID id = new ID(idHandle);
				try {
					BSJni.call(new Callable<Void>() {
						@Override
						public Void call() {
							backend.insert(id, data, bucket);
							return null;
						}
					});
				} catch (BSError e) {
					// TODO what do here?
					e.printStackTrace();
				}
			}

			@SuppressWarnings("unused")
			protected void update(final int idHandle, final byte[] data) {
				final ID id = new ID(idHandle);
				try {
					BSJni.call(new Callable<Void>() {
						@Override
						public Void call() {
							backend.update(id, data);
							return null;
						}
					});
				} catch (BSError e) {
					// TODO what do here?
					e.printStackTrace();
				}
			}

			@SuppressWarnings("unused")
			protected void delete(final int idHandle) {
				final ID id = new ID(idHandle);
				try {
					BSJni.call(new Callable<Void>() {
						@Override
						public Void call() {
							backend.delete(id);
							return null;
						}
					});
				} catch (BSError e) {
					// TODO what do here?
					e.printStackTrace();
				}
			}

			@SuppressWarnings("unused")
			protected void flush(final boolean bucket) {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						backend.flush(bucket);
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

		return BSJni.call(new Callable<ManagedBubbleTypeImpl>() {
			@Override
			public ManagedBubbleTypeImpl call() throws Exception {
				// TODO name
				int h = BSJni.bsBubbleMasterNewManaged(master.getHandle(), id, priority, handler);
				return new ManagedBubbleTypeImpl(BSJni.checkResult(h));
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
	public ManagedBubble insertBubble(final ID id, final byte[] data, final CompletionHandler done)
			throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void done() {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (done != null)
							done.onComplete();
					}
				});
			}
		};
		return BSJni.call(new Callable<ManagedBubbleImpl>() {
			@Override
			public ManagedBubbleImpl call() throws Exception {
				int h = BSJni.bsBubbleManagedInsert(getHandle(), id.getHandle(), data, handler);
				return new ManagedBubbleImpl(BSJni.checkResult(h));
			}
		});
	}

	//
	// protected
	//

	protected ManagedBubbleTypeImpl(int handle) throws BSError {
		super(handle);
		final int basicHandle = BSJni.checkResult(BSJni.bsBubbleTypeManagedBasic(handle));
		final int persistentHandle = BSJni.checkResult(BSJni.bsBubbleTypeManagedPersistent(handle));
		persistent = new PersistentBubbleTypeImpl(persistentHandle, basicHandle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleTypeManagedFree(handle);
	}

	//
	// private
	//

	private final PersistentBubbleTypeImpl persistent;

}
