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
 * The base interface for persistent bubble types. Persistent bubbles have a mandatory ID with their
 * payload, which globally identifies the data object.
 * 
 * @author Max Lehn
 */
public interface PersistentBubbleType extends BasicBubbleType {

	/**
	 * Notifies of incoming persistent bubbles.
	 * 
	 * @see PersistentBubbleType#matchWithId(PersistentBubbleType, double, BubbleHandlerWithId)
	 */
	public interface BubbleHandlerWithId {
		void onBubble(ID id, byte[] data);
	}

	/**
	 * Matches this bubble type with another, i.e., ensures that the expected number of rendezvous
	 * nodes of each pair of bubbles is <i>lambda</i>. The probability of at least one rendezvous
	 * node calculates as 1-exp(-lambda).
	 * <p>
	 * The bubble handler method is called on incoming bubbles of <code>this</code> type.
	 * </p>
	 * 
	 * @param with
	 *            the matched bubble type
	 * @param lambda
	 *            the certainty factor
	 * @param bubbleHandler
	 *            handles bubble matches, e.g., queries the local backend database
	 * @throws BSError
	 */
	public void matchWithId(PersistentBubbleType with, double lambda,
			BubbleHandlerWithId bubbleHandler) throws BSError;

}
