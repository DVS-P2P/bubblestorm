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

import java.io.OutputStream;

import net.bubblestorm.cusp.OutStream;

/**
 * The query responder is provided to send responses to a query on the backend.
 * 
 * @author Max Lehn
 */
public interface QueryResponder extends IBaseObject {

	public interface Writer {
		/**
		 * Requests the payload, which has to be written into the provided stream. You have to close
		 * the stream (using {@link OutStream#shutdown()} or {@link OutputStream#close()}) when
		 * done.
		 * 
		 * @param os
		 *            the payload out stream
		 */
		void write(OutStream os);

		/**
		 * Indicates that the payload will not be requested. Any associated resources can be freed.
		 */
		void abort();
	}

	/**
	 * Call this method for each result found in the local backend.
	 * 
	 * @param id
	 *            the result (e.g., document) ID
	 * @param writer
	 *            interface that receives the indication for sending the result payload
	 * @throws BSError
	 */
	void respond(ID id, Writer writer) throws BSError;

}
