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

import net.bubblestorm.ManagedBubbleType.CompletionHandler;

/**
 * This interface allows for the modification of existing managed bubbles.
 * <p>
 * Use {@link ManagedBubbleType} to create bubbles.
 * </p>
 * 
 * @author Max Lehn
 */
public interface ManagedBubble extends PersistentBubble {

	/**
	 * Updates the bubble data.
	 * 
	 * @param data
	 *            the new data
	 * @param done
	 *            is notified when the update is complete, i.e., when all peers in the bubble have
	 *            received the new data (optional)
	 * @throws BSError
	 */
	void update(byte[] data, CompletionHandler done) throws BSError;

	/**
	 * Deletes the bubble.
	 * 
	 * @param done
	 *            is notified when then deletion is complete.
	 * @throws BSError
	 */
	void delete(CompletionHandler done) throws BSError;

}
