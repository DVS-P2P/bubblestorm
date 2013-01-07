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
//package net.bubblestorm;
//
//import java.util.concurrent.Callable;
//
//import net.bubblestorm.jni.BSJni;
//import net.bubblestorm.jni.BaseObject;
//
///**
// * BubbleStorm provides a gossip mechanism that allows gathering global
// * statistics. The Measurement class gives the application access to this
// * functionality.
// * 
// * @author Max Lehn
// */
//public class Measurement extends BaseObject {
//
//	//
//	// public interface
//	//
//
//	/**
//	 * @see Measurement#sum(PullHandler, PushHandler) sum()
//	 * @see Measurement#max(PullHandler, PushHandler) max()
//	 */
//	public interface PullHandler {
//		public float pull();
//	}
//
//	/**
//	 * @see Measurement#sum(PullHandler, PushHandler) sum()
//	 * @see Measurement#max(PullHandler, PushHandler) max()
//	 */
//	public interface PushHandler {
//		public void push(float value);
//	}
//
//	/**
//	 * Creates a new measurement object. One measurement object can measure any
//	 * number of values which are each registered using one of the methods
//	 * {@link #sum(PullHandler, PushHandler) sum()} and
//	 * {@link #max(PullHandler, PushHandler) max()}.
//	 * 
//	 * @param interval
//	 *            the desired measurement round length, i.e., the interval at
//	 *            which new measured values are pushed to the application
//	 * @return the new measurement object
//	 * @throws BSError
//	 */
//	public static Measurement create(final Time interval) throws BSError {
//		BSJni.init();
//		return new Measurement(BSJni.call(new Callable<Integer>() {
//			@Override
//			public Integer call() throws Exception {
//				return BSJni.checkResult(BSJni.bsMeasurementNew(interval.toNanoseconds()));
//			}
//		}));
//	}
//
//	/**
//	 * Adds a <i>sum</i> measurement value.
//	 * 
//	 * @param pullHandler
//	 *            returns the local value for the measurement algorithm
//	 * @param pushHandler
//	 *            receives the calculated global sum once per measurement round
//	 * @throws BSError
//	 */
//	public void sum(final PullHandler pullHandler, final PushHandler pushHandler) throws BSError {
//		final Object handler = new Object() {
//			@SuppressWarnings("unused")
//			protected float pull() {
//				return pullHandler.pull();
//			}
//
//			@SuppressWarnings("unused")
//			protected void push(final float value) {
//				BSJni.invokeInThread(new Runnable() {
//					@Override
//					public void run() {
//						pushHandler.push(value);
//					}
//				});
//			}
//		};
//		BSJni.call(new Callable<Void>() {
//			@Override
//			public Void call() throws Exception {
//				BSJni.checkResult(BSJni.bsMeasurementSum(getHandle(), handler));
//				return null;
//			}
//		});
//	}
//
//	/**
//	 * Adds a <i>maximum</i> measurement value.
//	 * 
//	 * @param pullHandler
//	 *            returns the local value for the measurement algorithm
//	 * @param pushHandler
//	 *            receives the calculated global maximum once per measurement
//	 *            round
//	 * @throws BSError
//	 */
//	public void max(final PullHandler pullHandler, final PushHandler pushHandler) throws BSError {
//		final Object handler = new Object() {
//			@SuppressWarnings("unused")
//			protected float pull() {
//				return pullHandler.pull();
//			}
//
//			@SuppressWarnings("unused")
//			protected void push(final float value) {
//				BSJni.invokeInThread(new Runnable() {
//					@Override
//					public void run() {
//						pushHandler.push(value);
//					}
//				});
//			}
//		};
//		BSJni.call(new Callable<Void>() {
//			@Override
//			public Void call() throws Exception {
//				BSJni.checkResult(BSJni.bsMeasurementMax(getHandle(), handler));
//				return null;
//			}
//		});
//	}
//
//	//
//	// protected
//	//
//
//	protected Measurement(int handle) {
//		super(handle);
//	}
//
//	@Override
//	protected boolean free(int handle) {
//		return BSJni.bsMeasurementFree(handle);
//	}
//
//}
