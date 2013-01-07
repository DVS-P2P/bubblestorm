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
import net.bubblestorm.BasicBubbleType;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.jni.BSJni;
import net.bubblestorm.jni.BaseObject;

public class BasicBubbleTypeImpl extends BaseObject implements BasicBubbleType {

	//
	// public interface
	//

	@Override
	public void match(final PersistentBubbleType with, final double lambda,
			final BubbleHandler bubbleHandler) throws BSError {
		final Object handler = new Object() {
			@SuppressWarnings("unused")
			protected void handle(final byte[] data) {
				BSJni.invokeInThread(new Runnable() {
					@Override
					public void run() {
						if (bubbleHandler != null)
							bubbleHandler.onBubble(data);
					}
				});
			}
		};
		BSJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJni.checkResult(BSJni.bsBubbleTypeBasicMatch(getHandle(), with.getHandle(),
						lambda, handler));
				return null;
			}
		});
	}

	public int typeId() throws BSError {
		return BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsBubbleTypeBasicTypeId(getHandle()));
			}
		});
	}

	public int defaultSize() throws BSError {
		return BSJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJni.checkResult(BSJni.bsBubbleTypeBasicDefaultSize(getHandle()));
			}
		});
	}

	// /**
	// * @see BubbleType#create(StorageHandler, float) create()
	// */
	// public interface StorageHandler {
	// void onStore(ID id, byte[] data);
	// }
	//
	// /**
	// * @see BubbleType#match(BubbleType, float, MatchHandler) match()
	// */
	// public interface MatchHandler {
	// void onMatch(ID id, byte[] data);
	// }
	//
	// /**
	// * Creates a bubble type.
	// *
	// * @param storageHandler
	// * the (optional) storage handler that is called on incoming
	// * bubbles. Note: this handler is only supposed to be used for
	// * store operations. Query matches have to be handled by the
	// * {@link MatchHandler} given to the
	// * {@link #match(BubbleType, float, MatchHandler) match()}
	// * method.
	// * @param priority
	// * the bubble type's transport priority (default:
	// * <code>1000.0f</code>)
	// * @return the new bubble type
	// * @throws BSError
	// */
	// public static BubbleType create(final StorageHandler storageHandler,
	// final float priority)
	// throws BSError {
	// BSJni.init();
	// final Object handler = new Object() {
	// @SuppressWarnings("unused")
	// protected void handle(int idHandle, final byte[] data) {
	// final ID id = new ID(idHandle);
	// BSJni.invokeInThread(new Runnable() {
	// @Override
	// public void run() {
	// if (storageHandler != null)
	// storageHandler.onStore(id, data);
	// }
	// });
	// }
	// };
	// return new BubbleType(BSJni.call(new Callable<Integer>() {
	// @Override
	// public Integer call() throws Exception {
	// return BSJni.checkResult(BSJni.bsBubbletypeNew(handler, priority));
	// }
	// }));
	// }
	//
	// /**
	// * Matches a bubble against another. This makes the bubble balancer to
	// * adjust the bubble sizes so that the two bubbles intersect at expected
	// * <code>lambda</code> nodes. The probability of at least one match is
	// * <code>1-exp(-lambda)</code>. Typical values are 3 and 4 (95.02% and
	// * 98.17%). The <code>matchHandler</code> is invoked whenever there is an
	// * incoming bubble of this type that has to be matched with
	// * <code>intersects</code>-type bubble.
	// * <p>
	// * A typical use case consists of two bubbles, one for the data to store
	// * (say <code>dataBubble</code>) and one for the query on the data (say
	// * <code>queryBubble</code>).
	// * <ul>
	// * <li>
	// * The <code>dataBubble</code>'s storage handler (see
	// * {@link #create(StorageHandler, float) create()}) stores the payload
	// data
	// * to its local database.</li>
	// * <li>
	// * The <code>queryBubble</code> is matched against the
	// * <code>dataBubble</code> using this function (
	// * <code>queryBubble.match(dataBubble, ...)</code>)</li> and the match
	// * handler queries the local database for the requested criteria and sends
	// * the results back to the querier (i.e., the sender of the bubblecast).
	// * </ul>
	// * Note that for this kind of scenario it is highly recommended to use the
	// * {@link Query} class which takes care about the sending of the query
	// * results.
	// * </p>
	// *
	// * @param intersects
	// * the intersecting bubble type
	// * @param lambda
	// * the desired number of nodes at which
	// * @param matchHandler
	// * matches the two bubbles
	// * @throws BSError
	// */
	// public void match(final BubbleType intersects, final float lambda,
	// final MatchHandler matchHandler) throws BSError {
	// final Object handler = new Object() {
	// @SuppressWarnings("unused")
	// protected void handle(int idHandle, final byte[] data) {
	// final ID id = new ID(idHandle);
	// BSJni.invokeInThread(new Runnable() {
	// @Override
	// public void run() {
	// matchHandler.onMatch(id, data);
	// }
	// });
	// }
	// };
	// BSJni.call(new Callable<Void>() {
	// @Override
	// public Void call() throws Exception {
	// BSJni.checkResult(BSJni.bsBubbletypeMatch(getHandle(),
	// intersects.getHandle(),
	// lambda, handler));
	// return null;
	// }
	// });
	// }

	//
	// protected
	//

	protected BasicBubbleTypeImpl(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJni.bsBubbleTypeBasicFree(handle);
	}

}
