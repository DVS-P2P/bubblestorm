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

package net.bubblestorm.jni;

import java.util.ConcurrentModificationException;
import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import net.bubblestorm.BSError;

public class BSJniBase {

	//
	// public
	//

	/**
	 * Runs the main loop in the current thread. Does not return before the main loop is stopped.
	 */
	public static void mainLoop() {
		synchronized (mainThreadSync) {
			synchronized (mainThreadIdSync) {
				if (mainThreadId >= 0)
					throw new ConcurrentModificationException("Cannot run main loop twice");
				mainThreadId = Thread.currentThread().getId();
				mainThreadIdSync.notifyAll();
			}
			evtMain();
			synchronized (mainThreadIdSync) {
				mainThreadId = -1;
			}
		}
	}

	/**
	 * Starts the main loop in a separate thread.
	 */
	public static void startMainThread() {
		synchronized (mainThreadIdSync) {
			// don't start twice
			if (mainThreadId >= 0)
				return;
			// CUSP thread
			Thread t = new Thread("BS event loop") {
				@Override
				public void run() {
					System.out.println("Starting main loop.");
					// process already queued tasks
					asyncCallback();
					// CUSP main loop
					mainLoop();
					//
					System.out.println("Main loop thread terminating.");
				}
			};
			t.start();
			// wait for thread start
			try {
				mainThreadIdSync.wait();
			} catch (InterruptedException e) {
			}
		}
	}

	/**
	 * Stops the main loop.
	 */
	public static void stopMainLoop() {
		invoke(new Runnable() {
			@Override
			public void run() {
				evtStopMain();
			}
		});
	}

	/**
	 * Dispatches a task in the main thread and returns immediately.
	 * 
	 * @param task
	 *            the task to invoke
	 */
	public static void invoke(Runnable task) {
		if (Thread.currentThread().getId() == mainThreadId) {
			task.run();
		} else {
			invokeInternal(task);
		}
	}

	/**
	 * Dispatches a task in the main thread, waits for execution and returns the result. If the
	 * current thread is the main thread, the task is called directly.
	 * 
	 * @param <Result>
	 *            the task's result type
	 * @param task
	 *            the task to execute
	 * @return the task's result value
	 * @throws BSError
	 *             if the task call throws an exception
	 */
	public static <Result> Result call(final Callable<Result> task) throws BSError {
		if (Thread.currentThread().getId() == mainThreadId) {
			// direct (synchronous) execution
			try {
				return task.call();
			} catch (BSError ex) {
				throw ex;
			} catch (Exception ex) {
				throw new BSError(ex.getMessage(), ex);
			}
		} else {
			// async caller class
			class AsyncCaller<T extends Result> implements Runnable {
				public Result result = null;
				public Throwable error = null;

				@Override
				public void run() {
					synchronized (this) {
						try {
							result = task.call();
						} catch (Throwable t) {
							error = t;
						}
						this.notifyAll();
					}
				}
			}
			AsyncCaller<Result> ac = new AsyncCaller<Result>();
			// invoke and wait
			synchronized (ac) {
				invokeInternal(ac);
				try {
					ac.wait();
				} catch (InterruptedException ex) {
					throw new BSError("Invocation was interrupted", ex);
				}
			}
			// check exception
			if (ac.error != null) {
				if (ac.error instanceof BSError)
					throw (BSError) ac.error;
				else
					throw new BSError(ac.error.getMessage(), ac.error);
			}
			// return result
			return ac.result;
		}
	}

	/**
	 * Asynchronously invokes the given task in a separate thread from a thread pool.
	 * 
	 * @param task
	 *            task to run
	 */
	public static void invokeInThread(Runnable task) {
		threadPool.submit(task);
	}

	/**
	 * @return the ID of the main loop thread
	 */
	public static long getMainThreadId() {
		return mainThreadId;
	}

	/**
	 * @return <code>true</code> if this is the main loop thread, <code>false</code> otherwise
	 */
	public static boolean isMainThread() {
		return (Thread.currentThread().getId() == mainThreadId);
	}

	/**
	 * Throws an exception if we're in the main thread since we cannot perform blocking operations
	 * there.
	 * 
	 * @throws BSError
	 *             if the current thread is the main loop thread
	 */
	public static void checkAllowBlockingOperation() throws BSError {
		if (Thread.currentThread().getId() == mainThreadId)
			throw new BSError("Blocking operation not allowed in BubbleStorm main thread");
	}

	/**
	 * Throws a runtime exception if <code>res</code> is <code>false</code>.
	 * 
	 * @param res
	 *            the value to check
	 * @throws BSError
	 */
	public static void checkResult(boolean res) throws BSError {
		if (!res) {
			String msg = bsLastErrorMsg();
			if ((msg != null) && (!msg.isEmpty()))
				throw new BSError("BubbleStorm run-time exception: " + msg);
			else
				throw new BSError("Internal error in BubbleStorm bindings");
		}
	}

	/**
	 * Throws a runtime exception if <code>res</code> is less than zero.
	 * 
	 * @param res
	 *            the value to check
	 * @throws BSError
	 */
	public static int checkResult(int res) throws BSError {
		if (res >= 0) {
			return res;
		} else {
			String msg = bsLastErrorMsg();
			if ((msg != null) && (!msg.isEmpty()))
				throw new BSError("BubbleStorm run-time exception: " + msg);
			else
				throw new BSError("Internal error in BubbleStorm bindings");
		}
	}

	/**
	 * Throws a runtime exception if <code>res</code> is less than zero.
	 * 
	 * @param res
	 *            the value to check
	 * @throws BSError
	 */
	public static long checkResult(long res) throws BSError {
		if (res >= 0) {
			return res;
		} else {
			String msg = bsLastErrorMsg();
			if (!msg.isEmpty())
				throw new BSError("BubbleStorm run-time exception: " + msg);
			else
				throw new BSError("Internal error in BubbleStorm bindings");
		}
	}

	/**
	 * Throws a runtime exception if <code>res</code> is NaN.
	 * 
	 * @param res
	 *            the value to check
	 * @throws BSError
	 */
	public static float checkResult(float res) throws BSError {
		if (!Float.isNaN(res)) {
			return res;
		} else {
			String msg = bsLastErrorMsg();
			if (!msg.isEmpty())
				throw new BSError("BubbleStorm run-time exception: " + msg);
			else
				throw new BSError("Internal error in BubbleStorm bindings");
		}
	}

	/**
	 * Throws a runtime exception if <code>res</code> is <code>null</code>.
	 * 
	 * @param res
	 *            the value to check
	 */
	public static <T> T checkResult(T res) {
		if (res != null)
			return res;
		else
			throw new RuntimeException("Internal error (string==null) in BubbleStorm bindings");
	}

	//
	// protected
	//

	protected static synchronized void init() {
		// create asynchronous invocation structures
		asyncTaskQ = new LinkedList<Runnable>();
		// limit thread count to avoid issues with too many worker threads,
		// e.g., when a lot of notifications arrive at once.
		// TODO the number of threads value might need to be optimized depending on the application
		// TODO a limitation in the number of threads could cause deadlocks (?)
		threadPool = Executors.newFixedThreadPool(16);

		// init BS library
		System.out.println("Initializing BubbleStorm SML library.");
		if (!libInit())
			throw new RuntimeException("Failed to initialize BubbleStorm SML library");
	}

	protected static synchronized void shutdown() {
		// stop main loop
		stopMainLoop();
		threadPool.shutdown();
		// wait for termination and shut down library
		synchronized (mainThreadSync) {
			asyncTaskQ = null;
			threadPool = null;
			System.out.println("Closing BubbleStorm SML library.");
			libShutdown();
		}

	}

	protected static void invokeInternal(Runnable task) {
		if (asyncTaskQ != null) {
			if (mainThreadId < 0)
				startMainThread();
			synchronized (asyncTaskQ) {
				boolean first = asyncTaskQ.isEmpty();
				try {
					// System.out.println("Add to Q: " + task);
					asyncTaskQ.add(task);
				} catch (Throwable t) {
					t.printStackTrace();
				}
				if (first)
					evtAsyncInvoke();
			}
		} else {
			// (this should only happen on shutdown or before initialization)
			task.run();
		}
	}

	//
	// private
	//

	/**
	 * The ID of the thread in which the CUSP main loop is currently running, -1 if it is not
	 * running;
	 */
	private static long mainThreadId = -1;

	private static Object mainThreadIdSync = new Object();

	private static Object mainThreadSync = new Object();

	private static Queue<Runnable> asyncTaskQ;

	private static ExecutorService threadPool;

	// callback for invocation of tasks within the main loop thread
	private static void asyncCallback() {
		synchronized (asyncTaskQ) {
			// System.out.println("Async callback");
			for (Runnable task : asyncTaskQ) {
				try {
					// System.out.println("Task: " + task);
					task.run();
				} catch (Throwable t) {
					t.printStackTrace();
				}
			}
			asyncTaskQ.clear();
			asyncTaskQ.notifyAll();
		}
	}

	//
	// native declarations
	//

	private static native boolean libInit();

	private static native void libShutdown();

	private static native String bsLastErrorMsg();

	private static native void evtMain();

	private static native void evtStopMain();

	private static native void evtAsyncInvoke();

	// Time

	public static native long evtTimeFromString(String str);

	public static native String evtTimeToString(long time);

	public static native String evtTimeToAbsoluteString(long time);

	public static native String evtTimeToRelativeString(long time);

	// Event

	public static native long evtEventTime();

	public static native int evtEventNew(Object handler);

	public static native int evtEventScheduleAt(int handle, long time);

	public static native int evtEventScheduleIn(int handle, long time);

	public static native int evtEventCancel(int handle);

	public static native int evtEventIsScheduled(int handle);

	public static native boolean evtEventFree(int handle);

	// Abortable

	public static native int evtAbortableStop(int handle);

	public static native boolean evtAbortableFree(int handle);

	// Log

	public static native int sysLogLog(int severity, String module, String msg);

	public static native int sysLogAddFilter(String module, int severity);

	public static native int sysLogRemoveFilter(String module);

}
