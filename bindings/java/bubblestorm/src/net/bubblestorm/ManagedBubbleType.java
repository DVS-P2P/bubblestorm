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
 * A managed bubble is maintained by a single owner, and its validity is only ensured as long as the
 * owner is alive. Managed bubbles are usually used for data that is bound to the lifetime of a
 * peer, e.g. presence information or subscriptions.
 * <p>
 * Use {@link BubbleMaster} to create instances of this class.
 * </p>
 * 
 * @author Max Lehn
 */
public interface ManagedBubbleType extends PersistentBubbleType {

	/**
	 * The backend is a data storage facility provided by the application for a managed bubble type.
	 * All bubbles the peer receives from the network are stored here. This data can be used to
	 * implement match functions with query bubble types, but the data store's conent must NEVER be
	 * modified by the application itself, neither adding, nor modifying, nor deleting any item. The
	 * given functions will be used by BubbleStorm to fill and maintain the data store with data
	 * from the network. Each bubble type needs a separate backend data store. The backend must not
	 * be mixed with the frontend data. The data store is not persistent between sessions. Upon
	 * startup a completely empty data store must be presented to BubbleStorm.
	 * 
	 * @see BubbleMaster#newManaged(String, int, float, ManagedBubbleType.BackendDataStore)
	 * @see BubbleMaster#newManaged(String, int, ManagedBubbleType.BackendDataStore)
	 */
	interface DataStore {

		/**
		 * Store a new item in the backend. Returns true if no item of this ID existed before and
		 * the item has been stored successfully. Otherwise it returns false. The bucket parameter
		 * selects the bucket to store the item in (see flush).
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
		void insert(ID id, byte[] data, boolean bucket);

		/**
		 * Update an already existing item in the backend. Returns true if an item of this ID
		 * already existed and has been updated with the given data. Otherwise it returns false.
		 * 
		 * @param id
		 *            the bubble ID
		 * @param data
		 *            the new bubble data
		 * @return whether the operation was successful
		 */
		void update(ID id, byte[] data);

		/**
		 * Delete an existing item in the backend. Returns true if an item of this ID existed and
		 * has been deleted. Otherwise it returns false.
		 * 
		 * @param id
		 *            the bubble ID
		 * @return whether the operation was successful
		 */
		void delete(ID id);

		/**
		 * Delete all elements that had the given bucket set when they were stored. This is used to
		 * periodically clean the data store of outdated data before fresh data is loaded from the
		 * network.
		 * 
		 * @param bucket
		 *            the bucket which has to be flushed (<code>false</code>->#0, <code>true</code>
		 *            ->#1)
		 */
		void flush(boolean bucket);

		/**
		 * Returns the number of elements currently stored in the backend. Should be implemented
		 * with O(1) complexity (i.e. constant time).
		 * 
		 * @return the number of elements stored
		 */
		int size();

	}

	/**
	 * Notifies of the completion of certain actions.
	 */
	interface CompletionHandler {

		void onComplete();

	}

	/**
	 * Creates a managed bubble. Use the returned {@link ManagedBubble} instance to update or delete
	 * the bubble.
	 * 
	 * @param id
	 *            the bubble ID
	 * @param data
	 *            the bubble data
	 * @param done
	 *            is notified when the bubble is complete, i.e., when all peers in the bubble have
	 *            received the data (optional)
	 * @return the bubble object
	 * @throws BSError
	 */
	ManagedBubble insertBubble(ID id, byte[] data, CompletionHandler done) throws BSError;

}
