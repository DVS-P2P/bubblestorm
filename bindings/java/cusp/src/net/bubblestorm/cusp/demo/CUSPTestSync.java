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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;

import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.cusp.Host;
import net.bubblestorm.cusp.InStream;
import net.bubblestorm.cusp.OutStream;
import net.bubblestorm.jni.CUSPJni;
import net.bubblestorm.util.Pair;

public class CUSPTestSync {

	// private static int byteCounter = 0;

	public static void main(String[] args) throws Exception {
		System.out.println("CUSP test (sync)");

		try {
			EndPoint ep = EndPoint.create(8585);
			System.out.println("Created endpoint.");

			ep.advertise(23, new EndPoint.AdvertiseHandler() {
				public void read(final InStream is) {
					InputStream i = is.getInputStream();
					BufferedReader br = new BufferedReader(new InputStreamReader(i));
					String s;
					try {
						while ((s = br.readLine()) != null) {
							System.out.println("Read \"" + s + "\"");
						}
					} catch (IOException e) {
						e.printStackTrace();
					}
					// try {
					// byte[] buf = new byte[65536 * 4];
					// int count;
					// while ((count = i.read(buf)) >= 0) {
					// byteCounter += count;
					// }
					// } catch (IOException e) {
					// e.printStackTrace();
					// }
					System.out.println("Done reading.");
				}

				@Override
				public void onConnect(Host host, InStream is) {
					System.out.println("Someone connected");
					read(is);
				}
			});
			System.out.println("Listening.");

			// // byte counter thread
			// (new Thread() {
			// public void run() {
			// while (true) {
			// try {
			// Thread.sleep(1000);
			// } catch (InterruptedException e) {
			// }
			// System.out.println("Bytes received: " + byteCounter);
			// byteCounter = 0;
			// }
			// }
			// }).start();

			System.out.println("Connecting...");
			Address addr = Address.fromString("localhost:8585");
			System.out.println("Addr: " + addr);
			Pair<Host, OutStream> p = ep.contact(addr, 23);
			Host host = p.getA();
			OutStream os = p.getB();
			System.out.println("Connect: " + host);
			Writer writer = new OutputStreamWriter(os.getOutputStream(), "UTF-8");
			writer.write("Hello\n");
			writer.close();

			Thread.sleep(1000);
			System.out.println("Shutting down.");
			ep.destroy();
			CUSPJni.shutdown();
		} catch (Throwable ex) {
			ex.printStackTrace();
			CUSPJni.stopMainLoop();
		}
	}

}
