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
import net.bubblestorm.DurableBubble;
import net.bubblestorm.ID;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class DurableBubbleImpl extends BaseObject implements DurableBubble {

	//
	// public
	//

	@Override
	public ID getId() throws BSError {
		return BSJni.call(new Callable<ID>() {
			@Override
			public ID call() throws BSError {
				final int h = BSJni.bsBubbleDurableId(getHandle());
				return new ID(BSJni.checkResult(h));
			}
		});
	}

	@Override
	public byte[] getData() throws BSError {
		return BSJni.call(new Callable<byte[]>() {
			@Override
			public byte[] call() throws BSError {
				return BSJni.checkResult(BSJni.bsBubbleDurableData(getHandle()));
			}
		});
	}

	@Override
	public void update(final byte[] data) throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleDurableUpdate(getHandle(), data));
				return null;
			}
		});
	}

	@Override
	public void delete() throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleDurableDelete(getHandle()));
				return null;
			}
		});
	}

	//
	// protected
	//

	protected DurableBubbleImpl(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleDurableFree(handle);
	}

}
