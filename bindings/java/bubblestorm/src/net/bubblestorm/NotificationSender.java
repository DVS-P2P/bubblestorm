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

import net.bubblestorm.cusp.OutStream;

/**
 * A notification sender is created from notification callback data using
 * {@link NotificationFactory#decode(byte[], net.bubblestorm.cusp.EndPoint)} and
 * allows sending notifications to the corresponding receiver.
 * <p>
 * For the more information on notifications, refer to
 * {@link NotificationFactory}.
 * </p>
 * 
 * @author Max Lehn
 */
public interface NotificationSender {

	/**
	 * Data request handler. See
	 * {@link NotificationSender#send(ID, SendHandler)}.
	 */
	public interface SendHandler {

		/**
		 * Requests the notification payload, which has to be written in to the
		 * provided stream. The stream <i>must</i> be shut down (see
		 * {@link OutStream#shutdown()}) to indicate the end of data.
		 * 
		 * @param os
		 *            the payload output stream
		 */
		void getData(OutStream os);

		/**
		 * Indicates that the notification payload will not be requested. Any
		 * resources associated to this notification can be released.
		 */
		void abort();

	}

	/**
	 * Sends a notification, but does not immediately transfers the payload. If
	 * the receiver requests the payload, the application is notified via
	 * {@link SendHandler#getData(OutStream)}. {@link SendHandler#abort()}
	 * indicates that the data will not be requested.
	 * 
	 * @param id
	 *            the notification payload ID
	 * @param handler
	 *            the data request handler
	 * @throws BSError
	 */
	void send(ID id, SendHandler handler) throws BSError;

	/**
	 * Sends a notification and immediately transfers the payload. The usage of
	 * this method is only recommended for small payloads.
	 * 
	 * @param id
	 *            the notification payload ID
	 * @param data
	 *            the notification payload
	 * @throws BSError
	 */
	void sendImmmediate(ID id, byte[] data) throws BSError;

}
