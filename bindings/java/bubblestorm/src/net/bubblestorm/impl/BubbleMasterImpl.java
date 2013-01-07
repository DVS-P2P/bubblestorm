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

import net.bubblestorm.BSError;
import net.bubblestorm.BubbleMaster;
import net.bubblestorm.DurableBubbleType;
import net.bubblestorm.FadingBubbleType;
import net.bubblestorm.InstantBubbleType;
import net.bubblestorm.ManagedBubbleType;
import net.bubblestorm.PersistentBubbleType.BubbleHandlerWithId;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class BubbleMasterImpl extends BaseObject implements BubbleMaster {

	//
	// public interface
	//

	@Override
	public InstantBubbleType newInstant(final String name, final int id, final float priority)
			throws BSError {
		return InstantBubbleTypeImpl.create(this, name, id, priority);
	}

	@Override
	public InstantBubbleType newInstant(final String name, final int id) throws BSError {
		return newInstant(name, id, Float.NaN);
	}

	@Override
	public FadingBubbleType newFading(final String name, final int id, final float priority,
			final BubbleHandlerWithId bubbleHandler) throws BSError {
		return FadingBubbleTypeImpl.create(this, name, id, priority, bubbleHandler);
	}

	@Override
	public FadingBubbleType newFading(final String name, final int id,
			final BubbleHandlerWithId bubbleHandler) throws BSError {
		return newFading(name, id, Float.NaN, bubbleHandler);
	}

	@Override
	public ManagedBubbleType newManaged(final String name, final int id, final float priority,
			final ManagedBubbleType.DataStore backend) throws BSError {
		return ManagedBubbleTypeImpl.create(this, name, id, priority, backend);
	}

	@Override
	public ManagedBubbleType newManaged(String name, int id,
			ManagedBubbleType.DataStore backend) throws BSError {
		return newManaged(name, id, Float.NaN, backend);
	}

	@Override
	public DurableBubbleType newDurable(final String name, final int id, final float priority,
			final DurableBubbleType.DataStore backend) throws BSError {
		return DurableBubbleTypeImpl.create(this, name, id, priority, backend);
	}

	@Override
	public DurableBubbleType newDurable(String name, int id, DurableBubbleType.DataStore backend)
			throws BSError {
		return newDurable(name, id, Float.NaN, backend);
	}

	//
	// protected
	//

	protected BubbleMasterImpl(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleMasterFree(handle);
	}

}
