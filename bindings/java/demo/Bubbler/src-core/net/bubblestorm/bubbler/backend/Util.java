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

package net.bubblestorm.bubbler.backend;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;

public class Util {

	public static byte[] serializeObject(Object obj) throws IOException {
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		serializeObject(obj, bos);
		return bos.toByteArray();
	}

	public static void serializeObject(Object obj, OutputStream stream) throws IOException {
		ObjectOutputStream oos = new ObjectOutputStream(stream);
		oos.writeObject(obj);
		oos.flush();
	}

	public static Object deserializeObject(byte[] data) throws IOException, ClassNotFoundException {
		return deserializeObject(new ByteArrayInputStream(data));
	}

	public static Object deserializeObject(byte[] data, int ofs, int len) throws IOException,
			ClassNotFoundException {
		return deserializeObject(new ByteArrayInputStream(data, ofs, len));
	}

	public static Object deserializeObject(InputStream stream) throws IOException,
			ClassNotFoundException {
		ObjectInputStream ois = new ObjectInputStream(stream);
		Object obj = ois.readObject();
		ois.close();
		return obj;
	}

}
