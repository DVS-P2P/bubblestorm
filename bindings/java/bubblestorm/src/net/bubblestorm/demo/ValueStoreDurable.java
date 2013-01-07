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

import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;

import net.bubblestorm.BSError;
import net.bubblestorm.DurableBubbleType;
import net.bubblestorm.DurableBubbleType.Item;
import net.bubblestorm.ID;
import net.bubblestorm.Query;
import net.bubblestorm.QueryResponder;
import net.bubblestorm.Time;
import net.bubblestorm.cusp.OutStream;
import net.bubblestorm.util.Pair;

public class ValueStoreDurable implements DurableBubbleType.DataStore, Query.Responder {

	private HashMap<ID, Item> values = new HashMap<ID, Item>();

	//
	// DurableBubbleType.DataStore implementation
	//

	@Override
	public void store(ID id, Item item) {
		values.put(id, item);
	}

	@Override
	public Item lookup(ID id) {
		return values.get(id);
	}

	@Override
	public void remove(ID id) {
		values.remove(id);
	}

	@Override
	public Pair<Long, Time> version(ID id) {
		final Item i = values.get(id);
		if (i != null) {
			return new Pair<Long, Time>(i.version, i.time);
		} else {
			return null;
		}
	}

	@Override
	public Iterator<Pair<ID, Item>> iterator() {
		final Iterator<Entry<ID, Item>> it = values.entrySet().iterator();
		return new Iterator<Pair<ID, Item>>() {

			@Override
			public void remove() {
				throw new UnsupportedOperationException();
			}

			@Override
			public Pair<ID, Item> next() {
				final Entry<ID, Item> el = it.next();
				return new Pair<ID, Item>(el.getKey(), el.getValue());
			}

			@Override
			public boolean hasNext() {
				return it.hasNext();
			}

		};
	}

	@Override
	public int size() {
		return values.size();
	}

	//
	// Query.Responder implementation
	//

	@Override
	public void respond(byte[] queryData, QueryResponder respond) {
		try {
			final ID id = ID.fromBytes(queryData);
			System.out.println("Store: Received query for ID " + id.toString());
			final Item item = values.get(id);
			if (item != null) {
				System.out.println("Store: Found doc: " + item.toString());
				QueryResponder.Writer writer = new QueryResponder.Writer() {
					@Override
					public void write(OutStream os) {
						System.out.println("  Writing the data.");
						try {
							final OutputStream s = os.getOutputStream();
							s.write(item.data);
							s.close();
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
