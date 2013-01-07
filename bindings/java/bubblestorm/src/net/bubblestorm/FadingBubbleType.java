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
 * A fading bubble contains data that can be persisted but whose replication is not maintained
 * (fire-and-forget). Persistent data thus has to be regularly refreshed by the application, and old
 * data should be deleted.
 * <p>
 * Use {@link BubbleMaster} to create instances of this class.
 * </p>
 * 
 * @author Max Lehn
 */
public interface FadingBubbleType extends PersistentBubbleType {

	/**
	 * Creates a bubble, i.e., pushes the data into the network.
	 * 
	 * @param id
	 *            the payload ID
	 * @param data
	 *            the bubble's payload data4
	 * @throws BSError
	 */
	public void createBubble(ID id, byte[] data) throws BSError;

}
