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

import java.io.IOException;
import java.util.Collection;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

import net.bubblestorm.BSError;
import net.bubblestorm.BubbleMaster;
import net.bubblestorm.BubbleStorm;
import net.bubblestorm.BubbleStormFactory;
import net.bubblestorm.DurableBubbleType;
import net.bubblestorm.ID;
import net.bubblestorm.ManagedBubbleType;
import net.bubblestorm.NotificationFactory;
import net.bubblestorm.NotificationReceiver;
import net.bubblestorm.NotificationResult;
import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.cusp.InStream;

/**
 * This class provides the pub/sub functionality to the application. It's the application back-end
 * but the BubbleStorm front-end.
 * 
 * @author mlehn
 */
public class Core {

	final static float MIN_BANDWIDTH = 128000.0f;
	
	//
	// fields
	//

	private EndPoint endpoint = null;

	private BubbleStorm bs = null;

	private DurableBubbleType publishBubbleType = null;

	private ManagedBubbleType subscribeBubbleType = null;

	//
	// public interface
	//

	/**
	 * Initializes the BubbleStorm library.
	 * 
	 * @throws BSError
	 */
	public Core() throws BSError {
		// we need to call this explicitly to prevent CUSPJni from being
		// initialized first...
		BubbleStormFactory.init();

		// enable LAN mode to make bubble balancing faster
		BubbleStormFactory.setLanMode(true);
	}

	/**
	 * Closes the BubbleStorm library.
	 */
	public void shutdown() {
		BubbleStormFactory.shutdown();
	}

	/**
	 * Connects to the BubbleStorm network.
	 * 
	 * @param bootstrapAddr
	 *            bootstrap node address
	 * @param port
	 *            local bind port
	 * @param createRing
	 *            whether to start a new network
	 * @param joinHandler
	 *            join completion callback
	 * @throws BSError
	 */
	public void connect(String bootstrapAddr, int port, boolean createRing,
			BubbleStorm.JoinHandler joinHandler) throws BSError {
		// BubbleStorm
		Address bootstrap = (bootstrapAddr != null) ? Address.fromString(bootstrapAddr) : null;
		bs = BubbleStormFactory.create(MIN_BANDWIDTH, MIN_BANDWIDTH, port, false);
		bs.loadHostCache(null, bootstrap);
		endpoint = bs.endpoint();
		final BubbleMaster bm = bs.bubbleMaster();

		// backend store
		final Store store = new Store(endpoint);

		// bubble types
		// publications are durable, thus use fading bubble (durable bubble is not implemented yet)
		publishBubbleType = bm.newDurable("publish", 1, store.getPublicationBackend());
		// subscriptions are managed bubbles
		subscribeBubbleType = bm.newManaged("subscribe", 2, store.getSubscriptionBackend());
		// match incoming publications with stored subscriptions
		publishBubbleType.matchWithId(subscribeBubbleType, 4.0, store.getPublishMatchHandler());
		// match incoming subscriptions with stored publications
		subscribeBubbleType.matchWithId(publishBubbleType, 4.0, store.getSubscribeMatchHandler());

		// bootstrap/join
		if (createRing) {
			bs.createRing(bootstrap, joinHandler);
		} else {
			bs.join(joinHandler);
		}
	}

	/**
	 * Publishes content.
	 * 
	 * @param author
	 *            the content's author identification
	 * @param content
	 *            the content
	 * @return the created publication object
	 * @throws BSError
	 * @throws IOException
	 *             on serialization failures
	 */
	public Publication publish(String author, String content) throws BSError, IOException {
		long timestamp = (new Date()).getTime();
		PublicationData pub = new PublicationData(author, content, timestamp);
		byte[] data = Util.serializeObject(pub);
		ID id = ID.fromRandom();
		publishBubbleType.createBubble(id, data);
		return new ImplPublication(id, pub);
	}

	/**
	 * Subscribes to content specified by a full-test filter condition.
	 * 
	 * @param filter
	 *            the filter condition, currently a content substring
	 * @param handler
	 *            the subscription handler
	 * @return the created subscription object
	 * @throws BSError
	 * @throws IOException
	 *             on serialization failures
	 */
	public Subscription subscribe(String filter, Subscription.Handler handler) throws BSError,
			IOException {
		return new ImplSubscription(filter, handler);
	}

	/**
	 * @return the associated CUSP end point
	 */
	public EndPoint endpoint() {
		return endpoint;
	}

	/**
	 * @return the current publication bubble size
	 * @throws BSError
	 */
	public int publishBubbleSize() throws BSError {
		return publishBubbleType.defaultSize();
	}

	/**
	 * @return the current subscription bubble size
	 * @throws BSError
	 */
	public int subscribeBubbleSize() throws BSError {
		return subscribeBubbleType.defaultSize();
	}

	public Address localAddress() throws BSError {
		return bs.address();
	}

	//
	// inner classes
	//

	private class ImplPublication implements Publication {

		private final ID id;
		private final PublicationData pubData;

		public ImplPublication(ID id, PublicationData pubData) {
			this.id = id;
			this.pubData = pubData;
		}

		@Override
		public String getAuthor() {
			return pubData.getAuthor();
		}

		@Override
		public String getContent() {
			return pubData.getContent();
		}

		@Override
		public long getTimestamp() {
			return pubData.getTimestamp();
		}

		@Override
		public ID getId() {
			return id;
		}

	} // class ImplPublication

	private class ImplSubscription implements Subscription, NotificationReceiver.Handler {

		//
		// fields
		//

		private final long timestamp;

		private final NotificationReceiver notification;

		private final Handler handler;

		private Map<ID, Publication> publicationsById;

		private Map<Long, Publication> publicationsByTimestamp;

		//
		// public methods
		//

		public ImplSubscription(final String filter, final Handler handler) throws BSError,
				IOException {
			this.handler = handler;
			publicationsById = new HashMap<ID, Publication>();
			publicationsByTimestamp = new TreeMap<Long, Publication>(new Comparator<Long>() {
				@Override
				public int compare(Long o1, Long o2) {
					// reverse timestamp comparator
					long l1 = o1.longValue();
					long l2 = o2.longValue();
					return (l1 < l2) ? 1 : ((l1 > l2) ? -1 : 0);
				}
			});
			timestamp = (new Date()).getTime();
			notification = NotificationFactory.create(endpoint, this);
			byte[] notData = notification.encode(bs.address());
			SubscriptionData sub = new SubscriptionData(notData, filter, timestamp);
			byte[] subData = Util.serializeObject(sub);
			subscribeBubbleType.insertBubble(ID.fromRandom(), subData, null);
		}

		//
		// Subscription impl
		//

		@Override
		public Collection<Publication> getPublications() {
			synchronized (publicationsById) {
				return publicationsByTimestamp.values();
			}
		}

		@Override
		public void close() throws BSError {
			notification.close();
		}

		//
		// Notification.Handler impl
		// 

		@Override
		public void onNotify(NotificationResult result) {
			try {
				ID id = result.id();
				synchronized (publicationsById) {
					if (publicationsById.get(id) == null) {
						InStream is = result.payload();
						PublicationData pubData = (PublicationData) Util.deserializeObject(is
								.getInputStream());
						is.readShutdown();
						Publication pub = new ImplPublication(id, pubData);
						publicationsById.put(id, pub);
						publicationsByTimestamp.put(pubData.getTimestamp(), pub);
						handler.onPublish(pub.getAuthor(), pub.getTimestamp(), pub.getContent());
					} else
						result.cancel();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		// @Override
		// public Address getLocalAddress() {
		// try {
		// return bs.address();
		// } catch (Exception e) {
		// e.printStackTrace();
		// return null; // (what to do here?)
		// }
		// }

	} // class ImplSubscription

}
