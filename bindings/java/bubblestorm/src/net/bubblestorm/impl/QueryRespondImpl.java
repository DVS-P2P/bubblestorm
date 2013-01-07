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
import net.bubblestorm.QueryResponder;
import net.bubblestorm.cusp.OutStream;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class QueryRespondImpl extends BaseObject implements QueryResponder {

	//
	// public interface
	//

	@Override
	public void respond(final ID id, final Writer writer) throws BSError {
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				final Object writerCb = new Object() {
					@SuppressWarnings("unused")
					protected void write(int osHandle) {
						if (osHandle >= 0) {
							final OutStream os = new OutStream(osHandle);
							BSJni.invokeInThread(new Runnable() {
								@Override
								public void run() {
									writer.write(os);
								}
							});
						} else {
							BSJni.invokeInThread(new Runnable() {
								@Override
								public void run() {
									writer.abort();
								}
							});
						}
					}
				};
				BSJni.bsQueryRespond(getHandle(), id.getHandle(), writerCb);
				return null;
			}
		});
	}

	//
	// protected
	//

	public QueryRespondImpl(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsQueryRespondFree(handle);
	}

}
