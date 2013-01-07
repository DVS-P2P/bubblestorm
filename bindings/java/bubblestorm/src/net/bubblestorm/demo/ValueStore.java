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

package net.bubblestorm.demo;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.HashMap;

import net.bubblestorm.BSError;
import net.bubblestorm.ID;
import net.bubblestorm.PersistentBubbleType;
import net.bubblestorm.Query;
import net.bubblestorm.QueryResponder;
import net.bubblestorm.cusp.OutStream;

public class ValueStore implements PersistentBubbleType.BubbleHandlerWithId, Query.Responder {

	private HashMap<ID, Object> values = new HashMap<ID, Object>();

	//
	// PersistentBubbleType.BubbleHandlerWithId implementation
	//

	@Override
	public void onBubble(ID id, byte[] data) {
		System.out.println("Store: Storing " + id.toString());
		try {
			ObjectInputStream ois = new ObjectInputStream(new ByteArrayInputStream(data));
			Object obj = ois.readObject();
			ois.close();
			values.put(id, obj);
		} catch (Exception e) {
			System.err.println("Error processing store request:");
			e.printStackTrace();
		}
	}

	//
	// Query.Responder implementation
	//

	@Override
	public void respond(byte[] queryData, QueryResponder respond) {
		try {
			ID id = ID.fromBytes(queryData);
			System.out.println("Store: Received query for ID " + id.toString());
			final Object obj = values.get(id);
			if (obj != null) {
				System.out.println("Store: Found doc: " + obj.toString());
				QueryResponder.Writer writer = new QueryResponder.Writer() {
					@Override
					public void write(OutStream os) {
						System.out.println("  Writing the data.");
						try {
							ObjectOutputStream oos = new ObjectOutputStream(os.getOutputStream());
							oos.writeObject(obj);
							oos.close();
						} catch (IOException e) {
							System.err.println("Error writing the data:");
							e.printStackTrace();
						}
					}

					@Override
					public void abort() {
						System.out.println("  The querier doesn't want the data.");
					}
				};
				respond.respond(id, writer);
			}
		} catch (BSError e) {
			e.printStackTrace();
		}
	}

}
