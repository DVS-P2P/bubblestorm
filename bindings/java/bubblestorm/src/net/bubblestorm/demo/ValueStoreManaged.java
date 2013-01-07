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
import net.bubblestorm.ManagedBubbleType.DataStore;
import net.bubblestorm.Query;
import net.bubblestorm.QueryResponder;
import net.bubblestorm.cusp.OutStream;

public class ValueStoreManaged implements Query.Responder, DataStore {

	private HashMap<ID, Object> bucket0 = new HashMap<ID, Object>();
	private HashMap<ID, Object> bucket1 = new HashMap<ID, Object>();

	@Override
	public void respond(byte[] queryData, QueryResponder respond) {
		// System.out.println("BSTest: " + "respond");
		try {
			ID id = ID.fromBytes(queryData);
			Object i = bucket0.get(id);
			if (i == null)
				i = bucket1.get(id);
			final Object j = i;
			if (j != null) {
				QueryResponder.Writer writer = new QueryResponder.Writer() {
					@Override
					public void write(OutStream os) {
						try {
							ObjectOutputStream oos = new ObjectOutputStream(os.getOutputStream());
							oos.writeObject(j);
							oos.close();
						} catch (IOException e) {
							System.out.println("BSTest: " + "Error writing the data:");
							e.printStackTrace();
						}
					}

					@Override
					public void abort() {
						System.out.println("The querier doesn't want the data.");
					}
				};
				respond.respond(id, writer);
			}
		} catch (BSError e) {
			e.printStackTrace();
		}
	}

	@Override
	public void insert(ID id, byte[] data, boolean bucket) {
		// System.out.println("BSTest: " + "store");
		try {
			ObjectInputStream ois = new ObjectInputStream(new ByteArrayInputStream(data));
			Object obj = ois.readObject();
			ois.close();
			if (!bucket)
				bucket0.put(id, obj);
			// return (bucket0.put(id, obj) != null);
			else
				bucket1.put(id, obj);
			// return (bucket1.put(id, obj) != null);
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		// return false;
	}

	@Override
	public void update(ID id, byte[] data) {
		// System.out.println("BSTest: " + "update");
		try {
			ObjectInputStream ois = new ObjectInputStream(new ByteArrayInputStream(data));
			Object obj = ois.readObject();
			ois.close();
			if (bucket0.containsKey(id)) {
				System.out.println("BSTest: " + "bucket0 " + (bucket0.put(id, obj) != null));
				bucket0.put(id, obj);
				// return (bucket0.put(id, obj) != null);
			}
			if (bucket1.containsKey(id)) {
				System.out.println("BSTest: " + "bucket1 " + (bucket1.put(id, obj) != null));
				bucket1.put(id, obj);
				// return (bucket1.put(id, obj) != null);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		// return false;
	}

	@Override
	public void delete(ID id) {
		// System.out.println("BSTest: " + "delete");
		bucket0.remove(id);
		bucket1.remove(id);
		// if (bucket0.containsKey(id))
		// return (bucket0.remove(id) != null);
		// if (bucket1.containsKey(id))
		// return (bucket1.remove(id) != null);
		// return false;
	}

	@Override
	public void flush(boolean bucket) {
		// System.out.println("BSTest: " + "flush");
		if (!bucket)
			bucket0.clear();
		else
			bucket1.clear();
	}

	@Override
	public int size() {
		// System.out.println("BSTest: " + "size");
		return bucket0.size() + bucket1.size();
	}

}
