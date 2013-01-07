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

import net.bubblestorm.DurableBubbleType.DataStore;
import net.bubblestorm.PersistentBubbleType.BubbleHandlerWithId;

/**
 * The bubble baster allows the creation of bubble types.
 * 
 * @author Max Lehn
 */
public interface BubbleMaster extends IBaseObject {

	/**
	 * Creates an instant bubble type.
	 * 
	 * @param name
	 *            human-readable bubble type name (for debugging only)
	 * @param id
	 *            the bubble type ID, which uniquely identifies the new bubble type
	 * @param priority
	 *            the bubble priority
	 * @return the new bubble type
	 * @throws BSError
	 */
	InstantBubbleType newInstant(String name, int id, float priority) throws BSError;

	/**
	 * Creates an instant bubble type with default priority.
	 * 
	 * @param name
	 *            human-readable bubble type name (for debugging only)
	 * @param id
	 *            the bubble type ID, which uniquely identifies the new bubble type
	 * @return the new bubble type
	 * @throws BSError
	 */
	InstantBubbleType newInstant(String name, int id) throws BSError;

	/**
	 * Creates a fading bubble type.
	 * 
	 * @param name
	 *            human-readable bubble type name (for debugging only)
	 * @param id
	 *            the bubble type ID, which uniquely identifies the new bubble type
	 * @param priority
	 *            the bubble priority
	 * @param storeHandler
	 *            handles incoming bubbles, i.e., stores the bubble content to the application
	 *            backend
	 * @return the new bubble type
	 * @throws BSError
	 */
	FadingBubbleType newFading(String name, int id, float priority, BubbleHandlerWithId storeHandler)
			throws BSError;

	/**
	 * Creates a fading bubble type with default priority.
	 * 
	 * @param name
	 *            human-readable bubble type name (for debugging only)
	 * @param id
	 *            the bubble type ID, which uniquely identifies the new bubble type
	 * @param storeHandler
	 *            handles incoming bubbles, i.e., stores the bubble content to the application
	 *            backend
	 * @return the new bubble type
	 * @throws BSError
	 */
	FadingBubbleType newFading(String name, int id, BubbleHandlerWithId storeHandler)
			throws BSError;

	/**
	 * Creates a managed bubble type.
	 * 
	 * @param name
	 *            human-readable bubble type name (for debugging only)
	 * @param id
	 *            the bubble type ID, which uniquely identifies the new bubble type
	 * @param priority
	 *            the bubble priority
	 * @param backend
	 *            the backend data store
	 * @return the new bubble type
	 * @throws BSError
	 */
	ManagedBubbleType newManaged(String name, int id, float priority,
			ManagedBubbleType.DataStore backend) throws BSError;

	/**
	 * Creates a fading bubble type with default priority.
	 * 
	 * @param name
	 *            human-readable bubble type name (for debugging only)
	 * @param id
	 *            the bubble type ID, which uniquely identifies the new bubble type
	 * @param backend
	 *            the backend data store
	 * @return the new bubble type
	 * @throws BSError
	 */
	ManagedBubbleType newManaged(String name, int id, ManagedBubbleType.DataStore backend)
			throws BSError;

	DurableBubbleType newDurable(String name, int id, float priority, DataStore backend)
			throws BSError;

	DurableBubbleType newDurable(String name, int id, DataStore backend) throws BSError;

}
