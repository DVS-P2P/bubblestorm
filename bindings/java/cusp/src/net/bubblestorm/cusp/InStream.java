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

package net.bubblestorm.cusp;

import java.io.IOException;
import java.io.InputStream;
import java.util.concurrent.Callable;

import net.bubblestorm.BSError;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;

/**
 * A stream for receiving data. The most Java-like way of reading data from the
 * stream is to obtain an {@link InputStream} via the {@link #getInputStream()}
 * method.
 * 
 * @author Max Lehn
 */
public class InStream extends BaseObject {

	//
	// fields
	//

	boolean isEOF = false;

	//
	// public interface
	//

	public enum State {
		IS_ACTIVE, IS_SHUTDOWN, IS_RESET
	};

	/**
	 * @return the stream's current state (active, shut down or reset)
	 * @throws BSError
	 */
	public State state() throws BSError {
		return CUSPJni.call(new Callable<State>() {
			@Override
			public State call() throws Exception {
				int s = CUSPJni.checkResult(CUSPJni.cuspOutstreamState(getHandle()));
				switch (s) {
				case 0:
					return State.IS_ACTIVE;
				case 1:
					return State.IS_SHUTDOWN;
				case 2:
					return State.IS_RESET;
				default:
					throw new BSError("Unknown stream state: " + Integer.toString(s));
				}
			}
		});
	}

	public int queuedOutOfOrder() throws BSError {
		return CUSPJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspInstreamQueuedOutOfOrder(getHandle()));
			}
		});
	}

	public int queuedUnread() throws BSError {
		return CUSPJni.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspInstreamQueuedUnread(getHandle()));
			}
		});
	}

	public long bytesReceived() throws BSError {
		return CUSPJni.call(new Callable<Long>() {
			@Override
			public Long call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspInstreamBytesReceived(getHandle()));
			}
		});
	}

	/**
	 * Resets the stream, i.e., aborts any pending read operations.
	 * 
	 * @throws BSError
	 */
	public void reset() throws BSError {
		isEOF = true;
		CUSPJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				CUSPJni.checkResult(CUSPJni.cuspInstreamReset(getHandle()));
				return null;
			}
		});
	}

	/**
	 * Reads up to <code>len</code> bytes, returns the number of bytes read.
	 * 
	 * @param buf
	 *            the buffer that receives the data
	 * @param ofs
	 *            the offset in the buffer at which the data starts
	 * @param len
	 *            the maximum number of bytes to read
	 * @return the number of bytes actually read
	 */
	public int read(final byte[] buf, final int ofs, final int len) throws BSError {
		CUSPJni.checkAllowBlockingOperation();
		final int[] res = new int[1];
		synchronized (res) {
			Runnable reader = new Runnable() {
				@Override
				public void run() {
					Object callback = new Object() {
						@SuppressWarnings("unused")
						protected void readCallback(int count) {
							synchronized (res) {
								res[0] = count;
								res.notifyAll();
							}
						}
					};
					CUSPJni.cuspInstreamRead(getHandle(), buf, ofs, len, callback);
				}
			};
			CUSPJni.invoke(reader);
			try {
				res.wait();
			} catch (InterruptedException e) {
				return 0;
			}
		}
		if (res[0] >= 0) {
			return res[0];
		} else {
			isEOF = true;
			return -1;
		}
	}

	public boolean readShutdown() throws BSError {
		CUSPJni.checkAllowBlockingOperation();
		final boolean[] res = new boolean[1];
		synchronized (res) {
			Runnable reader = new Runnable() {
				@Override
				public void run() {
					Object callback = new Object() {
						@SuppressWarnings("unused")
						protected void readCallback(boolean success) {
							synchronized (res) {
								res[0] = success;
								res.notifyAll();
							}
						}
					};
					CUSPJni.cuspInstreamReadShutdown(getHandle(), callback);
				}
			};
			CUSPJni.invoke(reader);
			try {
				res.wait();
			} catch (InterruptedException e) {
				return false;
			}
		}
		return res[0];
	}

	/**
	 * @return an InputStream to read data from the stream
	 */
	public InputStream getInputStream() {
		return new InpStream();
	}

	//
	// protected
	//

	public InStream(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspInstreamFree(handle);
	}

	//
	// inner classes
	//

	private class InpStream extends InputStream {

		@Override
		public int available() throws IOException {
			try {
				return queuedUnread();
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		@Override
		public void close() throws IOException {
			// ignore close() call; there is no shutdown, and reset is bad
			// (causes exceptions at the other end)
		}

		@Override
		public int read() throws IOException {
			try {
				if (isEOF)
					return -1;
				byte[] buf = new byte[1];
				// int r = 0;
				// while ((r == 0) /*&& !(isEOF())*/) {
				// r = InStream.this.read(buf, 0, 1);
				// }
				// return (r == 1) ? (int) buf[0] & 0xFF : -1;
				if (InStream.this.read(buf, 0, 1) == 1)
					return (int) buf[0] & 0xFF;
				else
					return -1;
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		@Override
		public int read(byte[] buf) throws IOException {
			try {
				if (isEOF)
					return -1;
				return InStream.this.read(buf, 0, buf.length);
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		@Override
		public int read(byte[] buf, int ofs, int len) throws IOException {
			try {
				if (isEOF)
					return -1;
				return InStream.this.read(buf, ofs, len);
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		@Override
		public long skip(long n) throws IOException {
			if (n > Integer.MAX_VALUE)
				throw new IOException("Cannot skip more than " + Integer.MAX_VALUE + " bytes.");
			try {
				return (long) InStream.this.read(null, 0, (int) n);
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		// protected boolean isEOF() throws BSError {
		// return (InStream.this.state() != State.IS_ACTIVE) &&
		// (InStream.this.queuedUnread() == 0);
		// }

	}

}
