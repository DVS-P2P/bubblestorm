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
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;

/**
 * Represents a remote host
 * 
 * @author Max Lehn
 */
public class Host extends BaseObject {

	/**
	 * @return the Host's remote address or <code>null</code> if the address is
	 *         unavailable
	 * @throws BSError
	 */
	public Address address() throws BSError {
		return CUSPJni.call(new Callable<Address>() {
			@Override
			public Address call() throws Exception {
				int handle = CUSPJni.cuspHostAddress(getHandle());
				return (handle != -2) ? new Address(CUSPJni.checkResult(handle)) : null;
			}
		});
	}

	@Override
	public String toString() {
		try {
			return CUSPJni.call(new Callable<String>() {
				@Override
				public String call() throws Exception {
					return CUSPJni.checkResult(CUSPJni.cuspHostToString(getHandle()));
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e);
		}
	}

	public InStreamIterator inStreams() throws BSError {
		return CUSPJni.call(new Callable<InStreamIterator>() {
			@Override
			public InStreamIterator call() throws Exception {
				return new InStreamIterator(CUSPJni.checkResult(CUSPJni
						.cuspHostInstreams(getHandle())));
			}
		});
	}

	public OutStreamIterator outStreams() throws BSError {
		return CUSPJni.call(new Callable<OutStreamIterator>() {
			@Override
			public OutStreamIterator call() throws Exception {
				return new OutStreamIterator(CUSPJni.checkResult(CUSPJni
						.cuspHostOutstreams(getHandle())));
			}
		});
	}

	//
	// protected
	//

	protected Host(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspHostFree(handle);
	}

}
