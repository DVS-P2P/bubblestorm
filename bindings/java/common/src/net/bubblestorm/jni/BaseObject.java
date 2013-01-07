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

import net.bubblestorm.IBaseObject;

/**
 * The base object for all BS/SML interface objects. Contains the object's handle and takes care of
 * object finalization.
 * 
 * @author Max Lehn
 */
public abstract class BaseObject implements IBaseObject {

	private int handle;

	/*
	 * @see net.bubblestorm.jni.IBaseObject#getHandle()
	 */
	public int getHandle() {
		return handle;
	}

	protected BaseObject(int handle) {
		this.handle = handle;
	}

	/**
	 * (only for serialization!)
	 */
	protected BaseObject() {
		this.handle = -1;
	}

	protected void setHandle(int handle) {
		this.handle = handle;
	}

	// protected void checkThread() {
	// if (Thread.currentThread().getId() != CUSP.getMainThreadId())
	// throw new ConcurrentModificationException(
	// "Asynchronous CUSP function called from outside the main thread");
	// }

	protected abstract boolean free(int handle);

	/**
	 * Deallocates the object's handle by calling {@link #free(int)} in the proper thread.
	 */
	protected void dealloc() {
		if (handle >= 0) {
			if (BSJniBase.isMainThread()) {
				free(handle);
			} else {
				final int h = handle;
				BSJniBase.invoke(new Runnable() {
					@Override
					public void run() {
						if (!free(h)) {
							throw new RuntimeException("Internal error while freeing BS object "
									+ ((Object) BaseObject.this).toString());
							// (use Object.toString() to prevent further exceptions in toString())
						}
					}
				});
			}
			handle = -1;
		}
	}

	@Override
	protected void finalize() throws Throwable {
		// System.out.println("BaseObject.finalize(): " + this);
		try {
			dealloc();
		} finally {
			super.finalize();
		}
	}

}
