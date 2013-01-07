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

import java.util.Iterator;

import net.bubblestorm.util.Pair;

/**
 * TODO doc
 * <p>
 * Use {@link BubbleMaster} to create instances of this class.
 * </p>
 * 
 * @author Max Lehn
 */
public interface DurableBubbleType extends PersistentBubbleType {

	/**
	 * TODO doc
	 */
	class Item {
		public Item(long version, Time time, byte[] data) {
			this.version = version;
			this.time = time;
			this.data = data;
		}

		public final long version;
		public final Time time;
		public final byte[] data;

		public String toString() {
			return "Item (" + ((data != null) ? Integer.toString(data.length) : "null")
					+ " bytes, version " + Long.toString(version) + " from " + time + ")";
		}
	}

	interface DataStore {

		/**
		 * FIXME doc Store a new item in the backend. Returns true if no item of this ID existed
		 * before and the item has been stored successfully. Otherwise it returns false. The bucket
		 * parameter selects the bucket to store the item in (see flush).
		 * 
		 * @param id
		 *            the bubble ID
		 * @param data
		 *            the bubble data
		 * @param bucket
		 *            the bucket where that data has to be stored (<code>false</code>->#0,
		 *            <code>true</code>->#1)
		 * @return whether the operation was successful
		 */
		void store(ID id, Item item);

		/**
		 * Returns the item, if found, <code>null</code> otherwise.
		 * 
		 * @param id
		 * @return
		 */
		Item lookup(ID id);

		/**
		 * FIXME doc Delete an existing item in the backend. Returns true if an item of this ID
		 * existed and has been deleted. Otherwise it returns false.
		 * 
		 * @param id
		 *            the bubble ID
		 * @return whether the operation was successful
		 */
		void remove(ID id);

		/**
		 * TODO doc
		 * 
		 * @param id
		 * @return the (version, time) pair of the stored item with the given ID
		 */
		Pair<Long, Time> version(ID id);

		/**
		 * TODO doc
		 */
		Iterator<Pair<ID, Item>> iterator();

		/**
		 * Returns the number of elements currently stored in the backend. Should be implemented
		 * with O(1) complexity (i.e. constant time).
		 * 
		 * @return the number of elements stored
		 */
		int size();
		
	}

	interface LookupHandler {
		
		void onResponse(DurableBubble bubble);
		
	}
	
	/**
	 * Performs a durable bubble lookup. Use the returned {@link DurableBubble} instance to update
	 * or delete the bubble.
	 * 
	 * @param id
	 *            the bubble ID
	 * @return the bubble object if bubble was found, <code>null</code> otherwise
	 * @throws BSError
	 */
	Abortable lookupBubble(ID id, LookupHandler handler) throws BSError;

	/**
	 * Creates a durable bubble. Use the returned {@link DurableBubble} instance to update or delete
	 * the bubble.
	 * 
	 * @param id
	 *            the bubble ID
	 * @param data
	 *            the bubble data
	 * @return the bubble object
	 * @throws BSError
	 */
	DurableBubble createBubble(ID id, byte[] data) throws BSError;

}
