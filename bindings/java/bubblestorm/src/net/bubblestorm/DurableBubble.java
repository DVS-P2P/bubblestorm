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

/**
 * This interface allows for the manipulation of existing durable bubbles.
 * <p>
 * Use {@link DurableBubbleType} to lookup and create bubbles.
 * </p>
 * 
 * @author Max Lehn
 */
public interface DurableBubble extends PersistentBubble {

	/**
	 * Updates the bubble data.
	 * 
	 * @param data
	 *            the new data
	 * @throws BSError
	 */
	void update(byte[] data) throws BSError;

	/**
	 * Deletes the bubble.
	 * 
	 * @throws BSError
	 */
	void delete() throws BSError;

}
