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

import java.util.Iterator;
import java.util.concurrent.Callable;

import net.bubblestorm.BSError;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;
import net.bubblestorm.util.Pair;

public class ChannelIterator extends BaseObject implements Iterator<Pair<Address, Host>> {

	@Override
	public boolean hasNext() {
		try {
			return CUSPJni.call(new Callable<Boolean>() {
				@Override
				public Boolean call() throws BSError {
					return CUSPJni.checkResult(CUSPJni.cuspChannelIteratorHasNext(getHandle())) != 0;
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	/**
	 * @return the next pair of (address, host), where host is optional and my
	 *         be <code>null</code>
	 */
	@Override
	public Pair<Address, Host> next() {
		try {
			return CUSPJni.call(new Callable<Pair<Address, Host>>() {
				@Override
				public Pair<Address, Host> call() throws BSError {
					long l = CUSPJni.cuspChannelIteratorNext(getHandle());
					int addrHandle = (int) (l & 0xffffffff);
					int hostHandle = (int) (l >> 32);
					Address addr = new Address(CUSPJni.checkResult(addrHandle));
					Host host = (hostHandle >= 0) ? new Host(hostHandle) : null;
					return new Pair<Address, Host>(addr, host);
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	@Override
	public void remove() {
		throw new UnsupportedOperationException("ChannelIterator does not support remove()");
	}

	//
	// protetced
	//

	protected ChannelIterator(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspChannelIteratorFree(handle);
	}

}
