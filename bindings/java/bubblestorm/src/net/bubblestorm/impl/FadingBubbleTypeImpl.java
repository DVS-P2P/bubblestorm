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
import net.bubblestorm.FadingBubbleType;
import net.bubblestorm.ID;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class FadingBubbleTypeImpl extends BaseObject implements FadingBubbleType {

	//
	// public
	//

	public static FadingBubbleType create(final BubbleMaster master, final String name,
			final int id, final float priority, final BubbleHandlerWithId bubbleHandler)
			throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void handle(final int idHandle, final byte[] data) {
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
		return BSJni.call(new Callable<FadingBubbleTypeImpl>() {
			@Override
			public FadingBubbleTypeImpl call() throws Exception {
				// TODO name
				int h = BSJni.bsBubbleMasterNewFading(master.getHandle(), id, priority, handler);
				return new FadingBubbleTypeImpl(BSJni.checkResult(h));
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
	public void createBubble(final ID id, final byte[] data) throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleFadingCreate(getHandle(), id.getHandle(), data));
				return null;
			}
		});
	}

	//
	// protected
	//

	protected FadingBubbleTypeImpl(int handle) throws BSError {
		super(handle);
		int basicHandle = BSJni.checkResult(BSJni.bsBubbleTypeFadingBasic(handle));
		int persistentHandle = BSJni.checkResult(BSJni.bsBubbleTypeFadingPersistent(handle));
		persistent = new PersistentBubbleTypeImpl(persistentHandle, basicHandle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleTypeFadingFree(handle);
	}

	//
	// private
	//

	private final PersistentBubbleTypeImpl persistent;

}
