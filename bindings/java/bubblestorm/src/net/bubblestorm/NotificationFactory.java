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

package net.bubblestorm;

import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.impl.NotificationReceiverImpl;
import net.bubblestorm.util.Pair;

/**
 * Creates instances of {@link NotificationReceiver} and decodes notification information to obtain
 * {@link NotificationSender}s.
 * 
 * <p>
 * Off-the-band notification and result delivery is simplified using the Notification mechanism.
 * </p>
 * <p>
 * The typical notification use case:
 * <ol>
 * <li>Node A: create a notification receiver instance, see
 * {@link NotificationFactory#create(net.bubblestorm.cusp.EndPoint, NotificationReceiver.Handler)}</li>
 * <li>Node A: encode the call-back information (address, port, ...) and send it to Node B, see
 * {@link NotificationReceiver#encode(Address)}</li>
 * <li>Node B: decode the received notification information, obtain a notification sender, see
 * {@link NotificationFactory#decode(byte[], net.bubblestorm.cusp.EndPoint)}</li>
 * <li>Node B: send a notification, see {@link NotificationSender}</li>
 * <li>Node A: notification handler is invoked, see {@link NotificationReceiver.Handler}</li>
 * <li>Node A: (eventually) close notification receiver, see {@link NotificationReceiver#close()}</li>
 * </ol>
 * </p>
 * 
 * @author Max Lehn
 */
public class NotificationFactory {

	/**
	 * Creates a new notification receiver object.
	 * 
	 * @param ep
	 *            the CUSP end point to be used for comunication
	 * @param handler
	 *            the notification handler
	 * @return the new notification receiver object
	 * @throws BSError
	 */
	public static NotificationReceiver create(EndPoint ep, NotificationReceiver.Handler handler)
			throws BSError {
		return NotificationReceiverImpl.create(ep, handler);
	}

	/**
	 * Decodes notification callback information and creates a notification sender.
	 * 
	 * @param data
	 *            the encoded notification callback data
	 * @param endpoint
	 *            the CUSP end point to be used for communication
	 * @return the notification sender instance and the number of bytes actually read from data
	 * @throws BSError
	 */
	public static Pair<NotificationSender, Integer> decode(byte[] data, EndPoint endpoint)
			throws BSError {
		return NotificationReceiverImpl.decode(data, endpoint);
	}

}
