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

package net.bubblestorm.bubbler.backend;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

import net.bubblestorm.BSError;
import net.bubblestorm.DurableBubbleType;
import net.bubblestorm.ID;
import net.bubblestorm.ManagedBubbleType;
import net.bubblestorm.NotificationFactory;
import net.bubblestorm.NotificationSender;
import net.bubblestorm.Time;
import net.bubblestorm.DurableBubbleType.Item;
import net.bubblestorm.PersistentBubbleType.BubbleHandlerWithId;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.cusp.OutStream;
import net.bubblestorm.util.Pair;

/**
 * This class stores and matches publications and subscriptions and thus serves as the BubbleStorm
 * back-end.
 * 
 * @author mlehn
 */
public class Store {

	//
	// fields
	//

	private final EndPoint endpoint;

	private final Map<ID, Pair<PublicationData, DurableBubbleType.Item>> publications;

	private final Map<ID, Pair<SubscriptionData, Boolean>> subscriptions;

	private final SubscriptionStore subscriptionBackend;

	private final PublicationStore publicationBackend;

	// private final BubbleHandlerWithId publishHandler;

	// private final BubbleHandlerWithId subscribeHandler;

	private final BubbleHandlerWithId publicationMatchHandler;

	private final BubbleHandlerWithId subscriptionMatchHandler;

	//
	// public methods
	//

	/**
	 * Creates the pub/sub store.
	 * 
	 * @param endpoint
	 *            the CUSP end point used for notifications
	 */
	public Store(EndPoint endpoint) {
		this.endpoint = endpoint;
		publications = new HashMap<ID, Pair<PublicationData, DurableBubbleType.Item>>();
		subscriptions = new HashMap<ID, Pair<SubscriptionData, Boolean>>();
		subscriptionBackend = new SubscriptionStore();
		publicationBackend = new PublicationStore();
		// publishHandler = new PublishHandler();
		// subscribeHandler = new SubscribeHandler();
		publicationMatchHandler = new PublicationMatchHandler();
		subscriptionMatchHandler = new SubscriptionMatchHandler();
	}

	public ManagedBubbleType.DataStore getSubscriptionBackend() {
		return subscriptionBackend;
	}

	public DurableBubbleType.DataStore getPublicationBackend() {
		return publicationBackend;
	}

	// /**
	// * @return the publication bubble handler
	// */
	// public BubbleHandlerWithId getPublishHandler() {
	// return publishHandler;
	// }

	// /**
	// * @return the subscription bubble handler
	// */
	// public BubbleHandlerWithId getSubscribeHandler() {
	// return subscribeHandler;
	// }

	/**
	 * @return the publish bubble match handler (processes an incoming publication)
	 */
	public BubbleHandlerWithId getPublishMatchHandler() {
		return publicationMatchHandler;
	}

	/**
	 * @return the subscribe bubble match handler (processes an incoming subscription)
	 */
	public BubbleHandlerWithId getSubscribeMatchHandler() {
		return subscriptionMatchHandler;
	}

	//
	// protected
	//

	/**
	 * Checks all stored publications and notifies subscriber if given subscription matches.
	 */
	protected void matchPublications(final SubscriptionData sub) throws BSError {
		final String filter = sub.getFilter();
		final NotificationSender sender = NotificationFactory.decode(sub.getSubscriberData(),
				endpoint).getA();
		synchronized (publications) {
			for (Map.Entry<ID, Pair<PublicationData, DurableBubbleType.Item>> e : publications
					.entrySet()) {
				final ID id = e.getKey();
				final PublicationData pub = e.getValue().getA();
				if (pub.getContent().contains(filter)) {
					sender.send(id, new SendHandler(pub));
				}
			}
		}
	}

	/**
	 * Checks all stored subscriptions and notifies respective subscriber if given publication
	 * matches.
	 */
	protected void matchSubscriptions(final ID pubId, final PublicationData pub) throws BSError {
		try {
			ByteArrayOutputStream bos = new ByteArrayOutputStream();
			Util.serializeObject(pub, bos);
			bos.close();
			final byte[] data = bos.toByteArray();
			synchronized (subscriptions) {
				for (Map.Entry<ID, Pair<SubscriptionData, Boolean>> e : subscriptions.entrySet()) {
					final SubscriptionData sub = e.getValue().getA();
					if (pub.getContent().contains(sub.getFilter())) {
						final NotificationSender sender = NotificationFactory.decode(
								sub.getSubscriberData(), endpoint).getA();
						sender.sendImmmediate(pubId, data);
					}
				}
			}
		} catch (IOException ex) {
			throw new BSError(ex.getMessage(), ex);
		}
	}

	//
	// inner classes
	//

	private class SubscriptionStore implements ManagedBubbleType.DataStore {

		// ManagedBubbleType.BackendDataStore impl

		@Override
		public void insert(ID id, byte[] data, boolean bucket) {
			synchronized (subscriptions) {
				// if (subscriptions.containsKey(id))
				// return false;
				try {
					SubscriptionData sub = (SubscriptionData) Util.deserializeObject(data);
					subscriptions.put(id, new Pair<SubscriptionData, Boolean>(sub, bucket));
				} catch (Exception e) {
					e.printStackTrace();
					// FIXME returning false here is not really clean since it means the key exists
					// return false;
				}
				// return true;
			}
		}

		@Override
		public void update(ID id, byte[] data) {
			synchronized (subscriptions) {
				Pair<SubscriptionData, Boolean> val = subscriptions.get(id);
				if (val == null)
					return;
				// return false;
				try {
					SubscriptionData sub = (SubscriptionData) Util.deserializeObject(data);
					subscriptions.put(id, new Pair<SubscriptionData, Boolean>(sub, val.getB()));
				} catch (Exception e) {
					e.printStackTrace();
					// FIXME returning false here is not really clean since it means the key exists
					// return false;
				}
				// return true;
			}
		}

		@Override
		public void delete(ID id) {
			synchronized (subscriptions) {
				subscriptions.remove(id);
				// return (subscriptions.remove(id) != null);
			}
		}

		@Override
		public void flush(boolean bucket) {
			synchronized (subscriptions) {
				Iterator<Entry<ID, Pair<SubscriptionData, Boolean>>> it = subscriptions.entrySet()
						.iterator();
				while (it.hasNext()) {
					Entry<ID, Pair<SubscriptionData, Boolean>> e = it.next();
					if (e.getValue().getB().booleanValue() == bucket)
						it.remove();
				}
			}
		}

		@Override
		public int size() {
			synchronized (subscriptions) {
				return subscriptions.size();
			}
		}

	}

	private class PublicationStore implements DurableBubbleType.DataStore {

		//
		// DurableBubbleType.DataStore impl
		//

		@Override
		public Item lookup(ID id) {
			synchronized (publications) {
				Pair<PublicationData, Item> e = publications.get(id);
				return (e != null) ? e.getB() : null;
			}
		}

		@Override
		public Pair<Long, Time> version(ID id) {
			synchronized (publications) {
				Pair<PublicationData, Item> e = publications.get(id);
				return (e != null) ? new Pair<Long, Time>(e.getB().version, e.getB().time) : null;
			}
		}

		@Override
		public void store(ID id, Item item) {
			System.out.println("Store: Publication " + id.toString());
			try {
				PublicationData pub = (PublicationData) Util.deserializeObject(item.data);
				// store publication
				synchronized (publications) {
					publications.put(id, new Pair<PublicationData, Item>(pub, item));
				}
			} catch (Exception e) {
				System.err.println("Error processing store request:");
				e.printStackTrace();
			}
		}

		@Override
		public void remove(ID id) {
			synchronized (publications) {
				publications.remove(id);
			}
		}

		@Override
		public Iterator<Pair<ID, Item>> iterator() {
			synchronized (publications) {
				final Iterator<Entry<ID, Pair<PublicationData, DurableBubbleType.Item>>> it = publications
						.entrySet().iterator();
				return new Iterator<Pair<ID, Item>>() {

					@Override
					public void remove() {
						throw new UnsupportedOperationException();
					}

					@Override
					public Pair<ID, Item> next() {
						final Entry<ID, Pair<PublicationData, DurableBubbleType.Item>> el = it
								.next();
						return new Pair<ID, Item>(el.getKey(), el.getValue().getB());
					}

					@Override
					public boolean hasNext() {
						return it.hasNext();
					}

				};
			}
		}

		@Override
		public int size() {
			return publications.size();
		}

	}

	// private class PublishHandler implements BubbleHandlerWithId {
	// @Override
	// public void onBubble(ID id, byte[] data) {
	// // System.out.println("Store: Publication " + id.toString());
	// try {
	// PublicationData pub = (PublicationData) Util.deserializeObject(data);
	// // store publication
	// synchronized (publications) {
	// publications.put(id, pub);
	// }
	// // // match subscriptions
	// // matchSubscriptions(id, pub);
	// } catch (Exception e) {
	// System.err.println("Error processing store request:");
	// e.printStackTrace();
	// }
	// }
	// }

	// private class SubscribeHandler implements BubbleHandlerWithId {
	//
	// @Override
	// public void onBubble(ID id, byte[] data) {
	// // System.out.println("Store: Subscription " + id.toString());
	// try {
	// final SubscriptionData sub = (SubscriptionData)
	// Util.deserializeObject(data);
	// synchronized (subscriptions) {
	// subscriptions.put(id, sub);
	// }
	// } catch (Exception e) {
	// System.err.println("Error processing store request:");
	// e.printStackTrace();
	// }
	// }
	//
	// }

	private class PublicationMatchHandler implements BubbleHandlerWithId {
		@Override
		public void onBubble(ID id, byte[] data) {
			try {
				System.out.println("Match publication " + id.toString());
				final PublicationData pub = (PublicationData) Util.deserializeObject(data);
				matchSubscriptions(id, pub);
			} catch (Exception e) {
				System.err.println("Error processing match:");
				e.printStackTrace();
			}
		}
	} // PublicationMatchHandler

	private class SubscriptionMatchHandler implements BubbleHandlerWithId {
		@Override
		public void onBubble(ID id, byte[] data) {
			try {
				final SubscriptionData sub = (SubscriptionData) Util.deserializeObject(data);
				matchPublications(sub);
			} catch (Exception e) {
				System.err.println("Error processing match:");
				e.printStackTrace();
			}
		}
	} // SubscriptionMatchHandler

	private class SendHandler implements NotificationSender.SendHandler {

		private final PublicationData pub;

		public SendHandler(PublicationData pub) {
			this.pub = pub;
		}

		@Override
		public void getData(OutStream os) {
			try {
				Util.serializeObject(pub, os.getOutputStream());
				if (!os.shutdown())
					System.err.println("Store.SendHandler: Shutdown failed");
			} catch (Exception e) {
				System.err.println("Store.SendHandler error:");
				e.printStackTrace();
			}
		}

		@Override
		public void abort() {
			// (done)
		}

	} // SendHandler

}
