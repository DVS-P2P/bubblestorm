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
import net.bubblestorm.ID;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.Query;
import net.bubblestorm.QueryResponder;
import net.bubblestorm.Abortable;
import net.bubblestorm.cusp.InStream;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class QueryImpl extends BaseObject implements Query {

	//
	// static
	//

	public static Query create(final BubbleMaster master, final PersistentBubbleType dataBubble,
			final String queryBubbleName, final int queryBubbleId, final float lambda,
			final Responder responder) throws BSError {
		return new QueryImpl(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				Object respCb = new Object() {
					@SuppressWarnings("unused")
					protected void respond(final byte[] queryData, int respondHandle) {
						final QueryResponder respond = new QueryRespondImpl(respondHandle);
						BSJni.invokeInThread(new Runnable() {
							@Override
							public void run() {
								responder.respond(queryData, respond);
							}
						});
					}
				};
				// TODO queryBubbleName
				return BSJni.checkResult(BSJni.bsQueryNew(master.getHandle(), dataBubble
						.getHandle(), queryBubbleId, lambda, respCb));
			}
		}));
	}

	//
	// public interface
	//

	@Override
	public Abortable query(final byte[] queryData, final ResponseReceiver receiver) throws BSError {
		return new Abortable(BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				Object responseCb = new Object() {
					@SuppressWarnings("unused")
					protected void response(int idHandle, int streamHandle) {
						final ID id = new ID(idHandle);
						final InStream stream = new InStream(streamHandle);
						BSJni.invokeInThread(new Runnable() {
							@Override
							public void run() {
								receiver.onResponse(id, stream);
							}
						});
					}
				};
				int h = BSJni.bsQueryQuery(getHandle(), queryData, responseCb);
				if (h == -2)
					throw new BSError("Cannot query: local address unknown");
				return BSJni.checkResult(h);
			}
		}));
	}

	//
	// protected
	//

	public QueryImpl(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsQueryFree(handle);
	}

}
