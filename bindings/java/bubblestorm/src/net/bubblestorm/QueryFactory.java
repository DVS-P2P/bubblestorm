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

import net.bubblestorm.impl.QueryImpl;

/**
 * The query factory creates {@link Query} instances.
 * 
 * @author Max Lehn
 */
public class QueryFactory {

	/**
	 * Creates a new Query object. Internally creates a new query bubble type.
	 * 
	 * @param master
	 *            the bubble master
	 * @param dataBubble
	 *            the (persistent) data bubble against which the query bubble is matched
	 * @param queryBubbleName
	 *            human-readable query bubble type name (for debugging only)
	 * @param queryBubbleId
	 *            the ID of the newly createdquery bubble type
	 * @param lambda
	 *            the matching factor (see
	 *            {@link BasicBubbleType#match(PersistentBubbleType, double, BasicBubbleType.BubbleHandler)}
	 *            )
	 * @param responder
	 *            the responder object that provides responses to incoming queries (i.e., the
	 *            backend implementation)
	 * @return the new Query object
	 * @throws BSError
	 */
	public static Query create(BubbleMaster master, PersistentBubbleType dataBubble,
			String queryBubbleName, int queryBubbleId, float lambda, Query.Responder responder)
			throws BSError {
		return QueryImpl.create(master, dataBubble, queryBubbleName, queryBubbleId, lambda,
				responder);
	}

}
