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

package net.bubblestorm.demo;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import net.bubblestorm.BSError;
import net.bubblestorm.BubbleMaster;
import net.bubblestorm.BubbleStorm;
import net.bubblestorm.BubbleStormFactory;
import net.bubblestorm.DurableBubble;
import net.bubblestorm.DurableBubbleType;
import net.bubblestorm.ID;
import net.bubblestorm.Query;
import net.bubblestorm.QueryFactory;
import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.cusp.InStream;

/**
 * This is a simple BubbleStorm for Java demo application.
 * 
 * @author Max Lehn
 */
public class BSTestDurable {

	final static float MIN_BANDWIDTH = 128000.0f;

	public static void main(String[] args) throws BSError, InterruptedException {
		System.out.println("BubbleStorm for Java test");

		// check command line
		if (args.length < 2) {
			System.err.println("Invalid args.");
			System.err.println("Usage: BSTest bootstrap|join <address> [<bind port>]");
			// TODO some explanation
			System.exit(1);
		}

		// we need to call this explicitly to prevent CUSPJni from being
		// initialized first...
		BubbleStormFactory.init();

		// set log level
		// Log.addFilter("notification", Log.Level.DEBUG);

		// enable LAN mode to make bubble balancing faster
		BubbleStormFactory.setLanMode(true);

		// end point
		int port = (args.length >= 3) ? Integer.parseInt(args[2]) : 8585;
		EndPoint endpoint = EndPoint.create(port);

		// the BubbleStorm object is the hub for accessing all BubbleStorm
		// functionality
		final BubbleStorm bs = BubbleStormFactory.createWithEndpoint(MIN_BANDWIDTH, MIN_BANDWIDTH,
				endpoint);

		// get bootstrap/local address
		final Address bootstrapAddr = Address.fromString(args[1]);
		bs.loadHostCache(null, bootstrapAddr);

		// the BubbleMaster is needed for creating and connecting bubble types
		final BubbleMaster bm = bs.bubbleMaster();

		// value store, the local back end
		final ValueStoreDurable valueStore = new ValueStoreDurable();

		// data bubble type
		final DurableBubbleType dataBubble = bm.newDurable("data", 1, valueStore);

		// query; internally creates and matches a query bubble type
		final Query query = QueryFactory.create(bm, dataBubble, "query", 2, 4.0f, valueStore);

		// // measurements
		// final Measurement measurement =
		// Measurement.create(Time.fromSeconds(5));
		// measurement.sum(new Measurement.PullHandler() {
		// @Override
		// public float pull() {
		// return 1.0f;
		// }
		// }, new Measurement.PushHandler() {
		// @Override
		// public void push(float value) {
		// System.out.println("measurement: " + value);
		// }
		// });
		// Measurement[] measurements = new Measurement[] { measurement };

		// join-complete handler: executed after successfully joining the
		// network (after using join())
		BubbleStorm.JoinHandler joinHandler = new BubbleStorm.JoinHandler() {
			@Override
			public void onJoinComplete() {
				try {
					System.out.println("Join complete.");
					System.out.println("My external address is " + bs.address());
					// store a document
					ID id = ID.fromRandom();
					byte[] data = serializeObject("Hello!");
					System.out.println("Store: " + id.toString());
					System.out.println("  store size: " + dataBubble.defaultSize());
					dataBubble.createBubble(id, data);

					// retrieve bubble
					Thread.sleep(1000);
					System.out.println("Looking up bubble...");
					dataBubble.lookupBubble(id, new DurableBubbleType.LookupHandler() {
						@Override
						public void onResponse(DurableBubble bubble) {
							try {
								System.out.println("Got bubble " + bubble.getId());
								final Object obj = deserializeObject(bubble.getData());
								System.out.println("  object: " + obj.toString());
								
								// update object
								System.out.println("Updating bubble");
								bubble.update(serializeObject("Hello modified!"));
							} catch (Exception e) {
								e.printStackTrace();
							}
						}
					});

					// query for document
					Thread.sleep(1000);
					System.out.println("Querying...");
					query.query(id.toBytes(), new Query.ResponseReceiver() {
						@Override
						public void onResponse(ID id, InStream stream) {
							try {
								ObjectInputStream ois = new ObjectInputStream(stream
										.getInputStream());
								Object obj = ois.readObject();
								ois.close();
								System.out.println("Response (" + id.toString() + "): "
										+ obj.toString());
							} catch (Exception e) {
								e.printStackTrace();
							}
						}
					});
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		};

		// bootstrap/join
		if (args[0].equals("bootstrap")) {
			bs.createRing(Address.fromString(args[1]));
		} else {
			bs.join(joinHandler);
		}
	}

	/**
	 * Helper method for serializing Java objects t obyte arrays.
	 * 
	 * @param obj
	 *            the input object
	 * @return the serialized byte array
	 * @throws IOException
	 */
	private static byte[] serializeObject(Object obj) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream(bos);
		oos.writeObject(obj);
		oos.close();
		return bos.toByteArray();
	}

	private static Object deserializeObject(byte[] data) throws IOException, ClassNotFoundException {
		ByteArrayInputStream bis = new ByteArrayInputStream(data);
		ObjectInputStream ois = new ObjectInputStream(bis);
		final Object obj = ois.readObject();
		ois.close();
		return obj;
	}

}
