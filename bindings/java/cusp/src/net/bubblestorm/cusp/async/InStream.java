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

package net.bubblestorm.cusp.async;

import net.bubblestorm.BSError;
import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;


public class InStream extends BaseObject {

	//
	// public interface
	//

	public interface ReadHandler {
		/** Invoked when data is received. */
		void onReceive(int count);

		/** Invoked when a remote shutdown is received. */
		void onShutdown();

		/**
		 * Invoked when the stream is reset. No more reading can be done after
		 * that.
		 */
		void onReset();
	};

	public void read(byte[] buf, int ofs, int len, final ReadHandler readHandler) {
		Object callback = new Object() {
			@SuppressWarnings("unused")
			protected void readCallback(int count) throws BSError {
				if (count >= 0) {
					readHandler.onReceive(count);
				} else if (count == -2) {
					readHandler.onShutdown();
				} else if (count == -1) {
					readHandler.onReset();
				} else
					throw new BSError("Error in readCallback");
			}
		};
		if (CUSPJni.cuspInstreamRead(getHandle(), buf, ofs, len, callback) < 0)
			throw new RuntimeException("Internal error in cuspInstreamRead");
	}

	//
	// protected
	//

	protected InStream(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspInstreamFree(handle);
	}

}
