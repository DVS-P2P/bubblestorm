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

package net.bubblestorm;

import java.io.IOException;
import java.io.Serializable;
import java.util.concurrent.Callable;

import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

/**
 * A 160-bit identifier that is used for identifying objects stored in BubbleStorm, and may also be
 * used as an object identifier by the application.
 * 
 * <p>
 * <b>Note: </b> The implementation of this class, as all other BubbleStorm classes, internally only
 * stores a handle, not the actual data on the Java side. The Java serialization methods are
 * implemented, but using object databases, such as DB4O, requires you to manually serialize and
 * deserialize the IDs.
 * </p>
 * 
 * @author Max Lehn
 */
public class ID extends BaseObject implements Serializable {

	/**
	 * The length of an ID, in bytes.
	 */
	public static final int LENGTH = 20;

	private static final long serialVersionUID = (long) LENGTH;

	//
	// public interface
	//

	/**
	 * Creates an ID from the hash of the given data.
	 * 
	 * @param data
	 *            the data to be hashed
	 * @return the hashed ID
	 * @throws BSError
	 */
	public static ID fromHash(final byte[] data) throws BSError {
		return new ID(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsIdFromHash(data));
			}
		}));
	}

	/**
	 * Creates a random ID.
	 * 
	 * @return the random ID
	 * @throws BSError
	 */
	public static ID fromRandom() throws BSError {
		return new ID(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsIdFromRandom());
			}
		}));
	}

	/**
	 * Creates an ID from the given data (20 bytes).
	 * 
	 * @param bytes
	 *            the ID's raw data
	 * @return the created ID
	 * @throws BSError
	 */
	public static ID fromBytes(final byte[] bytes) throws BSError {
		if (bytes.length != LENGTH)
			throw new BSError("ID bytes must have a length of " + Integer.toString(LENGTH));
		return new ID(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsIdFromBytes(bytes));
			}
		}));
	}

	/**
	 * @return the raw bytes of the ID
	 * @throws BSError
	 */
	public byte[] toBytes() throws BSError {
		return BSJni.call(new Callable<byte[]>() {
			@Override
			public byte[] call() throws Exception {
				return BSJni.checkResult(BSJni.bsIdToBytes(getHandle()));
			}
		});
	}

	/**
	 * @return a hexadecimal string representation of the ID
	 */
	@Override
	public String toString() {
		try {
			return BSJni.call(new Callable<String>() {
				@Override
				public String call() throws Exception {
					return BSJni.checkResult(BSJni.bsIdToString(getHandle()));
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e);
		}
	}

	//
	// Object
	//

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof ID) {
			ID id = (ID) obj;
			final int aHandle = id.getHandle();
			final int bHandle = this.getHandle();
			if (aHandle == bHandle)
				return true;
			else {
				try {
					return BSJni.call(new Callable<Boolean>() {
						@Override
						public Boolean call() throws Exception {
							return BSJni.checkResult(BSJni.bsIdEquals(aHandle, bHandle)) != 0;
						}
					});
				} catch (BSError e) {
					throw new RuntimeException(e.getMessage(), e);
				}
			}
		} else
			return false;
	}

	@Override
	public int hashCode() {
		try {
			return BSJni.call(new Callable<Integer>() {
				@Override
				public Integer call() throws Exception {
					return BSJni.bsIdHash(getHandle());
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e);
		}
	}

	//
	// Serializable
	//

	private void writeObject(java.io.ObjectOutputStream out) throws IOException {
		try {
			out.write(toBytes());
		} catch (BSError e) {
			throw new IOException(e.getMessage(), e);
		}
	}

	private void readObject(java.io.ObjectInputStream in) throws IOException,
			ClassNotFoundException {
		final byte[] bytes = new byte[LENGTH];
		in.readFully(bytes);
		try {
			setHandle(BSJni.call(new Callable<Integer>() {
				@Override
				public Integer call() throws Exception {
					return BSJni.checkResult(BSJni.bsIdFromBytes(bytes));
				}
			}));
		} catch (BSError e) {
			throw new IOException(e.getMessage(), e);
		}
	}

	//
	// protected
	//

	public ID(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsIdFree(handle);
	}

}
