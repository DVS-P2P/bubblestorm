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

import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.impl.BubbleStormImpl;
import net.bubblestorm.jni.BSJni;

/**
 * This class provides the static methods for creating {@link BubbleStorm} instances.
 * 
 * @author Max Lehn
 */
public class BubbleStormFactory {

	/**
	 * Initializes the BubbleStorm library.
	 * 
	 * @see BSJni#init()
	 */
	public static void init() {
		BSJni.init();
	}

	/**
	 * Closes the BubbleStorm library. Note that you are not allowed to use any BubbleStorm object
	 * after calling this method.
	 * 
	 * @see BSJni#shutdown()
	 */
	public static void shutdown() {
		BSJni.shutdown();
	}

	/**
	 * A global flag controlling timeouts for all instances of BubbleStorm. When enabled all
	 * timeouts are reduced by a factor 10 (for LAN debugging testbeds).
	 * 
	 * @param enable
	 *            whether to enable LAN mode
	 * @throws BSError
	 */
	public static void setLanMode(final boolean enable) throws BSError {
		BSJni.init();
		BubbleStormImpl.setLanMode(enable);
	}

	/**
	 * Creates a new {@link BubbleStorm} instance using its own {@link EndPoint} .
	 * 
	 * @param bandwidth
	 *            the local node's available upstream bandwidth
	 * @param minBandwidth
	 *            a global system parameter specifying the minimum upstream bandwidth that a node
	 *            needs to become a peer
	 * @param port
	 *            the local UDP bind port
	 * @param encrypt
	 *            enables CUSP encryption
	 * @return the new instance
	 * @throws BSError
	 */
	public static BubbleStorm create(final float bandwidth, final float minBandwidth,
			final int port, final boolean encrypt) throws BSError {
		BSJni.init();
		return BubbleStormImpl.create(bandwidth, minBandwidth, port, encrypt);
	}

	/**
	 * Creates a new {@link BubbleStorm} instance using a given {@link EndPoint} .
	 * 
	 * @param bandwidth
	 *            the local node's available upstream bandwidth
	 * @param minBandwidth
	 *            a global system parameter specifying the minimum upstream bandwidth that a node
	 *            needs to become a peer
	 * @param endpoint
	 *            the CUSP end point to be used
	 * @return the new instance
	 * @throws BSError
	 */
	public static BubbleStorm createWithEndpoint(final float bandwidth, final float minBandwidth,
			final EndPoint endpoint) throws BSError {
		BSJni.init();
		return BubbleStormImpl.createWithEndpoint(bandwidth, minBandwidth, endpoint);
	}

}
