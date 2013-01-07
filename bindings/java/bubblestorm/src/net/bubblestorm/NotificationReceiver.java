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

/**
 * Receives incoming notifications.
 * <p>
 * For the more information on notifications, refer to
 * {@link NotificationFactory}.
 * </p>
 * 
 * @author Max Lehn
 */
public interface NotificationReceiver extends IBaseObject {

	/**
	 * Interface implemented by the application receiving incoming
	 * notifications.
	 */
	public interface Handler {

		/**
		 * Incoming notification.
		 * 
		 * @param result
		 *            the notification data
		 */
		void onNotify(NotificationResult result);

	}

	/**
	 * Encodes the notification callback information to a byte array to be sent
	 * to a remote node.
	 * 
	 * @param localAddress
	 *            the local node's address to be used for call-back
	 * @return the encoded callback data
	 * @throws BSError
	 */
	byte[] encode(Address localAddress) throws BSError;

	/**
	 * @return the maximum number of bytes required to encode the notifiction
	 *         callback information
	 * @throws BSError
	 * @see #encode(Address)
	 */
	int maxEncodedLength() throws BSError;

	/**
	 * Closes the notification object, i.e., does not accept (and deliver) any
	 * further notifications.
	 * 
	 * @throws BSError
	 */
	void close() throws BSError;

}
