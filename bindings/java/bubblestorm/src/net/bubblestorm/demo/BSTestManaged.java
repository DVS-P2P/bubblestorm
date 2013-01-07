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

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import net.bubblestorm.BSError;
import net.bubblestorm.BubbleMaster;
import net.bubblestorm.BubbleStorm;
import net.bubblestorm.BubbleStormFactory;
import net.bubblestorm.ID;
import net.bubblestorm.Log;
import net.bubblestorm.ManagedBubble;
import net.bubblestorm.ManagedBubbleType;
import net.bubblestorm.ManagedBubbleType.CompletionHandler;
import net.bubblestorm.Query;
import net.bubblestorm.QueryFactory;
import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.cusp.InStream;

public class BSTestManaged {

	public static void main(String[] args) throws BSError, InterruptedException {
		// check command line
		// bootstrap localhost
		// join localhost 8586
		if (args.length < 2) {
			System.out.println("BSTest: " + "Invalid args.");
			System.exit(1);
		}

		// we need to call this explicitly to prevent CUSPJni from being
		// initialized first...
		BubbleStormFactory.init();
		
		Log.addFilter("notification", Log.Level.DEBUG);

		// enable LAN mode to make bubble balancing faster
		BubbleStormFactory.setLanMode(true);

		// end point
		int port = (args.length >= 3) ? Integer.parseInt(args[2]) : 8585;
		EndPoint endpoint = EndPoint.create(port);

		// the BubbleStorm object is the hub for accessing all BubbleStorm
		// functionality
		final BubbleStorm bs = BubbleStormFactory.createWithEndpoint(128000, 128000, endpoint);

		// get bootstrap/local address
		final Address bootstrapAddr = Address.fromString(args[1]);
		bs.loadHostCache(null, bootstrapAddr);

		// the BubbleMaster is needed for creating and connecting bubble types
		final BubbleMaster bm = bs.bubbleMaster();

		// value store, the local back end
		final ValueStoreManaged valueStore = new ValueStoreManaged();

		// data bubble type
		final ManagedBubbleType dataBubble = bm.newManaged("data", 1, valueStore);

		// query; internally creates and matches a query bubble type
		final Query query = QueryFactory.create(bm, dataBubble, "query", 2, 4.0f, valueStore);

		BubbleStorm.JoinHandler joinHandler = new BubbleStorm.JoinHandler() {
			@Override
			public void onJoinComplete() {
				try {
					final ID id = ID.fromRandom();
					ManagedBubble mb = dataBubble.insertBubble(id, serializeObject("Hello!"),
							new CompletionHandler() {
								@Override
								public void onComplete() {
								}
							});

					Thread.sleep(2000);

					query.query(id.toBytes(), new Query.ResponseReceiver() {
						@Override
						public void onResponse(ID id, InStream stream) {
							try {
								ObjectInputStream ois = new ObjectInputStream(stream
										.getInputStream());
								Object obj = ois.readObject();
								ois.close();
								System.out.println("BSTest: " + "Response1 (" + id.toString()
										+ "): " + obj.toString());
							} catch (Exception e) {
								e.printStackTrace();
							}
						}
					});

					Thread.sleep(2000);

					mb.update(serializeObject("World!"), new CompletionHandler() {
						@Override
						public void onComplete() {
							try {
								query.query(id.toBytes(), new Query.ResponseReceiver() {
									@Override
									public void onResponse(ID id, InStream stream) {
										try {
											ObjectInputStream ois = new ObjectInputStream(stream
													.getInputStream());
											Object obj = ois.readObject();
											ois.close();
											System.out.println("BSTest: " + "Response2 ("
													+ id.toString() + "): " + obj.toString());
										} catch (Exception e) {
											e.printStackTrace();
										}
									}
								});
							} catch (BSError e) {
								e.printStackTrace();
							}
						}
					});

					Thread.sleep(2000);

					query.query(id.toBytes(), new Query.ResponseReceiver() {
						@Override
						public void onResponse(ID id, InStream stream) {
							try {
								ObjectInputStream ois = new ObjectInputStream(stream
										.getInputStream());
								Object obj = ois.readObject();
								ois.close();
								System.out.println("BSTest: " + "Response3 (" + id.toString()
										+ "): " + obj.toString());
							} catch (Exception e) {
								e.printStackTrace();
							}
						}
					});

				} catch (BSError e) {
					e.printStackTrace();
				} catch (InterruptedException e) {
					e.printStackTrace();
				} catch (IOException e) {
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
	 * Helper method for serializing Java objects to byte arrays.
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

}
