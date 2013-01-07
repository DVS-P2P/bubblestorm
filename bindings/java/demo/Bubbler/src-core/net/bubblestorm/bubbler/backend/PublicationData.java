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

import java.io.Serializable;

public class PublicationData implements Serializable {

	private static final long serialVersionUID = -255928037130913589L;

	//
	// fields
	//

	private final String author;

	private final String content;

	private final long timestamp;

	//
	// public methods
	//

	public PublicationData(String author, String content, long timestamp) {
		this.author = author;
		this.content = content;
		this.timestamp = timestamp;
	}

	public String getAuthor() {
		return author;
	}

	public String getContent() {
		return content;
	}

	public long getTimestamp() {
		return timestamp;
	}

}
