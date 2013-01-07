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

public class OutStreamIterator extends BaseObject implements Iterator<OutStream> {

	@Override
	public boolean hasNext() {
		try {
			return CUSPJni.call(new Callable<Boolean>() {
				@Override
				public Boolean call() throws BSError {
					return CUSPJni.checkResult(CUSPJni.cuspOutstreamIteratorHasNext(getHandle())) != 0;
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	@Override
	public OutStream next() {
		try {
			return CUSPJni.call(new Callable<OutStream>() {
				@Override
				public OutStream call() throws BSError {
					return new OutStream(CUSPJni.checkResult(CUSPJni
							.cuspOutstreamIteratorNext(getHandle())));
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	@Override
	public void remove() {
		throw new UnsupportedOperationException("OutStreamIterator does not support remove()");
	}

	//
	// protetced
	//

	protected OutStreamIterator(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspOutstreamIteratorFree(handle);
	}

}
