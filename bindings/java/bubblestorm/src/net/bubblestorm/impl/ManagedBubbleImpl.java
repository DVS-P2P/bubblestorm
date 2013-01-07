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
import net.bubblestorm.ManagedBubble;
import net.bubblestorm.ManagedBubbleType.CompletionHandler;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class ManagedBubbleImpl extends BaseObject implements ManagedBubble {

	//
	// public
	//

	@Override
	public ID getId() throws BSError {
		return BSJni.call(new Callable<ID>() {
			@Override
			public ID call() throws BSError {
				final int h = BSJni.bsBubbleManagedId(getHandle());
				return new ID(BSJni.checkResult(h));
			}
		});
	}

	@Override
	public byte[] getData() throws BSError {
		return BSJni.call(new Callable<byte[]>() {
			@Override
			public byte[] call() throws BSError {
				return BSJni.checkResult(BSJni.bsBubbleManagedData(getHandle()));
			}
		});
	}

	@Override
	public void update(final byte[] data, final CompletionHandler done) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void done() {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (done != null)
							done.onComplete();
					}
				});
			}
		};
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleManagedUpdate(getHandle(), data, handler));
				return null;
			}
		});
	}

	@Override
	public void delete(final CompletionHandler done) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void done() {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (done != null)
							done.onComplete();
					}
				});
			}
		};
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleManagedDelete(getHandle(), handler));
				return null;
			}
		});
	}

	//
	// protected
	//

	protected ManagedBubbleImpl(int handle) throws BSError {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleManagedFree(handle);
	}

}
