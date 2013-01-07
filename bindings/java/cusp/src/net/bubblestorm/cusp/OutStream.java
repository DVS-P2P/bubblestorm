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
import java.io.OutputStream;
import java.util.concurrent.Callable;

import net.bubblestorm.BSError;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;
import net.bubblestorm.util.Mailbox;

/**
 * A stream for sending data. The most Java-like way of reading data from the
 * stream is to obtain an {@link OutputStream} via the
 * {@link #getOutputStream()}
 * 
 * @author Max Lehn
 */
public class OutStream extends BaseObject {

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

	/**
	 * Shuts down the stream, i.e., signals that no more data will be written.
	 * This method has to be used to gracefully close a stream.
	 * 
	 * @return whether the shutdown was successful or the stream was reset on
	 *         the other end
	 * @throws BSError
	 */
	public boolean shutdown() throws BSError {
		CUSPJni.checkAllowBlockingOperation();
		final Mailbox<Boolean, BSError> mb = new Mailbox<Boolean, BSError>();
		CUSPJni.call(new Callable<Void>() {
			@Override
			public Void call() throws BSError {
				Object callback = new Object() {
					@SuppressWarnings("unused")
					protected void shutdownCallback(boolean status) {
						mb.put(status);
					}
				};
				CUSPJni.checkResult(CUSPJni.cuspOutstreamShutdown(getHandle(), callback));
				return null;
			}
		});
		try {
			return mb.waitFor();
		} catch (InterruptedException ex) {
			throw new BSError("Blocking operation was interrupted", ex);
		}
	}

	/**
	 * Resets, i.e., forcibly closes the stream.
	 * 
	 * @throws BSError
	 */
	public void reset() throws BSError {
		CUSPJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				CUSPJni.checkResult(CUSPJni.cuspOutstreamReset(getHandle()));
				return null;
			}
		});
	}

	/**
	 * Writes data to the stream.
	 * 
	 * @param buf
	 *            the buffer containing the data to write
	 * @param ofs
	 *            the start offset of the data in the buffer
	 * @param len
	 *            the length of the data to be written
	 * @throws BSError
	 */
	public void write(final byte[] buf, final int ofs, final int len) throws BSError {
		CUSPJni.checkAllowBlockingOperation();
		final Mailbox<Void, BSError> mb = new Mailbox<Void, BSError>();
		CUSPJni.invoke(new Runnable() {
			@Override
			public void run() {
				Object callback = new Object() {
					@SuppressWarnings("unused")
					protected void writeCallback(int status) {
						if (status == 0)
							mb.put(null);
						else if (status == -1)
							mb.exception(new BSError("Stream was reset at the remote end"));
						else
							mb.exception(new BSError("Invalid status code in writeCallback"));
					}
				};
				CUSPJni.cuspOutstreamWrite(getHandle(), buf, ofs, len, callback);
			}
		});
		try {
			mb.waitFor();
		} catch (InterruptedException ex) {
			throw new BSError("Blocking operation was interrupted", ex);
		}
	}

	/**
	 * @return the stream's priority
	 * @throws BSError
	 */
	public float getPriority() throws BSError {
		return CUSPJni.call(new Callable<Float>() {
			@Override
			public Float call() throws Exception {
				return CUSPJni.checkResult(CUSPJni.cuspOutstreamGetPriority(getHandle()));
			}
		});
	}

	/**
	 * Sets the stream's priority.
	 * 
	 * @param priority
	 *            the new priority
	 * @throws BSError
	 */
	public void setPriority(final float priority) throws BSError {
		CUSPJni.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				CUSPJni.checkResult(CUSPJni.cuspOutstreamSetPriority(getHandle(), priority));
				return null;
			}
		});
	}

	/**
	 * @return an OutputStream for writing to the stream
	 */
	public OutputStream getOutputStream() {
		return new OutpStream();
	}

	//
	// protected
	//

	public OutStream(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspOutstreamFree(handle);
	}

	//
	// inner classes
	//

	private class OutpStream extends OutputStream {

		@Override
		public void close() throws IOException {
			try {
				if (state() == State.IS_ACTIVE) {
					if (!shutdown())
						throw new IOException("Shutdown failed");
				}
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		@Override
		public void write(byte[] buf) throws IOException {
			try {
				OutStream.this.write(buf, 0, buf.length);
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		@Override
		public void write(byte[] buf, int ofs, int len) throws IOException {
			try {
				OutStream.this.write(buf, ofs, len);
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

		@Override
		public void write(int b) throws IOException {
			byte[] buf = new byte[] { (byte) b };
			try {
				OutStream.this.write(buf, 0, 1);
			} catch (BSError ex) {
				throw new IOException(ex.getMessage(), ex.getCause());
			}
		}

	}

}
