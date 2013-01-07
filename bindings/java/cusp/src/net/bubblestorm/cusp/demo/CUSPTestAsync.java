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

package net.bubblestorm.cusp.demo;

import net.bubblestorm.BSError;
import net.bubblestorm.cusp.async.EndPoint;
import net.bubblestorm.cusp.async.Host;
import net.bubblestorm.cusp.async.InStream;
import net.bubblestorm.cusp.async.EndPoint.AdvertiseHandler;
import net.bubblestorm.cusp.async.InStream.ReadHandler;
import net.bubblestorm.jni.CUSPJni;

public class CUSPTestAsync {

	public static void main(String[] args) throws BSError {
		System.out.println("CUSP test (async)");
		
		EndPoint ep = EndPoint.create(8585);
		AdvertiseHandler advertiseHandler = new AdvertiseHandler() {
			@Override
			public void onConnect(Host host, InStream is) {
				System.out.println("Someone connected.");
				readStream(is);
			}
		};
		ep.advertise(23, advertiseHandler);

		// bytes-received-thread
		(new Thread() {
			public void run() {
				while (true) {
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e) {
					}
					System.out.println("Bytes received: " + byteCounter);
					byteCounter = 0;
				}
			}
		}).start();

		CUSPJni.mainLoop();
	}

	private static int byteCounter;

	private static void readStream(final InStream is) {
		final byte[] buffer = new byte[65536];
		ReadHandler readHandler = new ReadHandler() {
			@Override
			public void onReceive(int count) {
				// String str = new String(data);
				// System.out.println("Stream read " + data.length + " bytes: "
				// + str);
				byteCounter += count;
				is.read(buffer, 0, buffer.length, this);
			}

			@Override
			public void onReset() {
				System.out.println("Stream was reset.");
			}

			@Override
			public void onShutdown() {
				System.out.println("Stream was shut down.");
			}

		};
		is.read(buffer, 0, buffer.length, readHandler);
	}

}
