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
import net.bubblestorm.ID;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class PersistentBubbleTypeImpl extends BaseObject implements PersistentBubbleType {

	@Override
	public void match(PersistentBubbleType with, double lambda, BubbleHandler bubbleHandler)
			throws BSError {
		basic.match(with, lambda, bubbleHandler);
	}

	@Override
	public void matchWithId(final PersistentBubbleType with, final double lambda,
			final BubbleHandlerWithId bubbleHandler) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void handle(int idHandle, final byte[] data) {
				final ID id = new ID(idHandle);
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (bubbleHandler != null)
							bubbleHandler.onBubble(id, data);
					}
				});
			}
		};
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleTypePersistentMatchWithId(getHandle(), with
						.getHandle(), lambda, handler));
				return null;
			}
		});
	}

	@Override
	public int defaultSize() throws BSError {
		return basic.defaultSize();
	}

	@Override
	public int typeId() throws BSError {
		return basic.typeId();
	}

	//
	// protected
	//

	protected PersistentBubbleTypeImpl(int handle, int basicHandle) {
		super(handle);
		basic = new BasicBubbleTypeImpl(basicHandle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleTypePersistentFree(handle);
	}

	//
	// private
	//

	private final BasicBubbleTypeImpl basic;

}
