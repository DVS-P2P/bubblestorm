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
 * The Query object automates the query-response process. Query assumes a pair of bubble types for
 * data and query. Query bubbles are managed by this class, while local storage of data has to be
 * handled by the application. When a query bubble is received, the query is passed to the
 * application that queries its local data store and and passes the results, if any, back to the
 * Query object. The Query object cares about the callback and the transmission of the results to
 * the querier.
 * <p>
 * This class should be preferred over a manual bubblecast/callback mechanism where applicable.
 * </p>
 * <p>
 * Instances of this class are created using {@link QueryFactory}.
 * </p>
 * 
 * @author Max Lehn
 */
public interface Query extends IBaseObject {

	/**
	 * Responds to incoming queries.
	 * 
	 * @see QueryFactory#create(BubbleMaster, PersistentBubbleType, String, int, float, Query.Responder)
	 */
	public interface Responder {
		void respond(byte[] queryData, QueryResponder respond);
	}

	/**
	 * Notifies of incoming query responses.
	 * 
	 * @see Query#query(byte[], ResponseReceiver)
	 */
	public interface ResponseReceiver {
		void onResponse(ID id, InStream stream);
	}

	/**
	 * Starts a query, i.e., creates a query bubble with the specifies query payload.
	 * 
	 * @param queryData
	 *            the application-specific query payload
	 * @param receiver
	 *            the object receiving query results
	 * @return a Stoppable for stopping the query when no further results are desired
	 */
	Abortable query(byte[] queryData, ResponseReceiver receiver) throws BSError;

}
