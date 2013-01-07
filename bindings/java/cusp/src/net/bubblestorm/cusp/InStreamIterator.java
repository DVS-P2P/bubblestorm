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

public class InStreamIterator extends BaseObject implements Iterator<InStream> {

	@Override
	public boolean hasNext() {
		try {
			return CUSPJni.call(new Callable<Boolean>() {
				@Override
				public Boolean call() throws BSError {
					return CUSPJni.checkResult(CUSPJni.cuspInstreamIteratorHasNext(getHandle())) != 0;
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	@Override
	public InStream next() {
		try {
			return CUSPJni.call(new Callable<InStream>() {
				@Override
				public InStream call() throws BSError {
					return new InStream(CUSPJni.checkResult(CUSPJni
							.cuspInstreamIteratorNext(getHandle())));
				}
			});
		} catch (BSError e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	@Override
	public void remove() {
		throw new UnsupportedOperationException("InStreamIterator does not support remove()");
	}

	//
	// protetced
	//

	protected InStreamIterator(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspInstreamIteratorFree(handle);
	}

}
