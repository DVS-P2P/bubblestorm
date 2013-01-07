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

import java.io.IOException;
import java.io.Serializable;
import java.util.concurrent.Callable;

import net.bubblestorm.BSError;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;

/**
 * A CUSP Address is a pair of IP address and port number.
 * 
 * @author Max Lehn
 */
public class Address extends BaseObject implements Serializable {

	private static final long serialVersionUID = 1892497026235303303L;

	//
	// public interface
	//

	/**
	 * Parses the given string to an Address. The sting has to be an IP address or host name with an
	 * optional port number separated by a colon ("127.0.0.1", "localhost", "127.0.0.1:8585",
	 * "localhost:8585").
	 * 
	 * @return the parsed address
	 * @throws BSError
	 */
	public static Address fromString(final String str) throws BSError {
		if (str == null)
			throw new NullPointerException("null address string");
		return new Address(CUSPJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspAddressFromString(str));
			}
		}));
	}

	/**
	 * Creates an invalid address.
	 * 
	 * @return an invalid address.
	 * @throws BSError
	 */
	public static Address none() throws BSError {
		return new Address();
	}

	public String toStringEx() throws BSError {
		return CUSPJni.call(new Callable<String>() {
			@Override
			public String call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspAddressToString(getHandle()));
			}
		});
	}

	@Override
	public String toString() {
		try {
			return toStringEx();
		} catch (BSError e) {
			throw new RuntimeException(e);
		}
	}

	//
	// Serializable impl
	//

	private void writeObject(java.io.ObjectOutputStream out) throws IOException {
		try {
			// write address as string
			if (getHandle() >= 0)
				out.writeObject(toStringEx());
			else
				out.writeObject("");
		} catch (BSError e) {
			throw new IOException(e.getMessage(), e);
		}
	}

	private void readObject(java.io.ObjectInputStream in) throws IOException,
			ClassNotFoundException {
		try {
			// deallocate previous handle (if necessary)
			dealloc();
			// read address string
			final Object str = in.readObject();
			if (!(str instanceof String))
				throw new IOException("Did not read an address string");
			// convert to handle
			setHandle(CUSPJni.call(new Callable<Integer>() {
				@Override
				public Integer call() throws Exception {
					return CUSPJni.checkResult(CUSPJni.cuspAddressFromString((String) str));
				}
			}));
		} catch (BSError e) {
			throw new IOException(e.getMessage(), e);
		}
	}

	//
	// protected
	//

	/**
	 * (for serialization only)
	 */
	protected Address() {
		super(-1);
	}

	public Address(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspAddressFree(handle);
	}

}
