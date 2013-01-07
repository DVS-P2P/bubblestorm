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
 * The most generic (abstract) bubble type.
 * 
 * <p>
 * Direct descendants are {@link InstantBubbleType} and (the abstract) {@link PersistentBubbleType}.
 * Persistent bubble type implementations are {@link FadingBubbleType} and {@link ManagedBubbleType}
 * .
 * </p>
 * 
 * @author Max Lehn
 */
public interface BasicBubbleType extends IBaseObject {

	/**
	 * Notifies of incoming bubbles.
	 * 
	 * @see BasicBubbleType#match(PersistentBubbleType, double, BubbleHandler)
	 */
	interface BubbleHandler {
		void onBubble(byte[] data);
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
	void match(PersistentBubbleType with, double lambda, BubbleHandler bubbleHandler)
			throws BSError;

	/**
	 * @return the current size of the bubble
	 * @throws BSError
	 */
	int defaultSize() throws BSError;

	/**
	 * @return the bubble type ID
	 * @throws BSError
	 */
	int typeId() throws BSError;

}
