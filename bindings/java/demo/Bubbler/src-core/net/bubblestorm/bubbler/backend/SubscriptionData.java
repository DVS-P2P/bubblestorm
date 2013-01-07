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

public class SubscriptionData implements Serializable {

	private static final long serialVersionUID = -2039898993274713447L;

	//
	// fields
	//

	private final byte[] subscriberData;

	private final String filter;

	private final long timestamp;

	//
	// public methods
	//

	public SubscriptionData(byte[] subscriberData, String filter, long timestamp) {
		this.subscriberData = subscriberData;
		this.filter = filter;
		this.timestamp = timestamp;
	}

	public byte[] getSubscriberData() {
		return subscriberData;
	}

	public String getFilter() {
		return filter;
	}

	public long getTimestamp() {
		return timestamp;
	}

}
