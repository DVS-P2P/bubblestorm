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

import net.bubblestorm.cusp.InStream;

/**
 * Represents a received notification result. The payload of a notification does
 * not need to be sent immediately. Instead, the receiver may decide, based on
 * the notification ID, whether the payload is actually desired. This is
 * typically used for duplicate result detection.
 * <p>
 * <b>Note:</b> Once obtained an instance of this class, you <i>must</i> exactly
 * one of the methods {@link #payload()} and {@link #cancel()} to release the
 * associated resources.
 * </p>
 * 
 * @author Max Lehn
 */
public interface NotificationResult {

	/**
	 * @return the ID associated with the notification payload
	 * @throws BSError
	 */
	ID id() throws BSError;

	/**
	 * Notifies the sender that we want to get the payload and returns the
	 * stream for reading the data.
	 * <p>
	 * <b>Note:</b> The application <i>must</i> read all data from the stream
	 * until it receives a shutdown (or reset). Otherwise the stream will remain
	 * open!
	 * </p>
	 * 
	 * @return the stream to read the payload data from
	 * @throws BSError
	 */
	InStream payload() throws BSError;

	/**
	 * Indicates that the payload is not needed and releases all associated
	 * resources.
	 * 
	 * @throws BSError
	 */
	void cancel() throws BSError;

}
