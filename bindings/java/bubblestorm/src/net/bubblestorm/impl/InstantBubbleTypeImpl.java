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
import net.bubblestorm.InstantBubbleType;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class InstantBubbleTypeImpl extends BaseObject implements
		InstantBubbleType {

	//
	// public interface
	//

	public static InstantBubbleType create(final BubbleMaster master,
			final String name, final int id, final float priority)
			throws BSError {
		return BSJni.call(new Callable<InstantBubbleTypeImpl>() {
			@Override
			public InstantBubbleTypeImpl call() throws Exception {
				// TODO name
				int h = BSJni.bsBubbleMasterNewInstant(master.getHandle(), id,
						priority);
				return new InstantBubbleTypeImpl(BSJni.checkResult(h));
			}
		});
	}

	@Override
	public void createBubble(final byte[] data) throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni
						.bsBubbleInstantCreate(getHandle(), data));
				return null;
			}
		});
	}

	@Override
	public void match(PersistentBubbleType with, double lambda,
			BubbleHandler bubbleHandler) throws BSError {
		basic.match(with, lambda, bubbleHandler);
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

	protected InstantBubbleTypeImpl(int handle) throws BSError {
		super(handle);
		final int basicHandle = BSJni.checkResult(BSJni.bsBubbleTypeInstantBasic(handle));
		basic = new BasicBubbleTypeImpl(basicHandle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleTypeInstantFree(handle);
	}

	//
	// private
	//

	private BasicBubbleTypeImpl basic;

}
