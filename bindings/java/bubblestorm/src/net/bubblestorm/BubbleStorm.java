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

import net.bubblestorm.cusp.Address;
import net.bubblestorm.cusp.EndPoint;

/**
 * This is the main class of a BubbleStorm node.
 * <p>
 * Use {@link BubbleStormFactory} to create instances of this class.
 * </p>
 * 
 * <p>
 * The class {@link net.bubblestorm.demo.BSTest} is a simple BubbleStorm demo application.
 * </p>
 * 
 * <p>
 * This is a quick introduction to using BubbleStorm:
 * <ol>
 * <li>
 * Initialize the BubbleStorm library using {@link BubbleStormFactory#init()}.
 * <p>
 * Optionally enable LAN mode ({@link BubbleStormFactory#setLanMode(boolean)}), which reduces
 * timeouts and increases the frequency of network measurements. This is particularly useful for
 * debugging.
 * </p>
 * </li>
 * <li>
 * Create an instance using {@link BubbleStormFactory#create(float, Address, int, boolean)} or
 * {@link BubbleStormFactory#createWithEndpoint(float, Address, EndPoint)}.</li>
 * <li>
 * Create (data) bubbles using the {@link BubbleMaster} methods (obtain via
 * {@link BubbleStorm#bubbleMaster()}).
 * <ul>
 * <li>
 * {@link InstantBubbleType}</li>
 * <li>
 * {@link FadingBubbleType}</li>
 * <li>
 * {@link ManagedBubbleType}</li>
 * </ul>
 * </li>
 * <li>
 * Alternatively to using query bubbles directly, you can use the {@link Query} facility.
 * <p>
 * If you cannot use Query but need to deliver results, e.g., in a pub/sub use case, you should use
 * the Notification facility (see {@link NotificationFactory}).
 * </p>
 * </li>
 * </ol>
 * </p>
 * 
 * @author Max Lehn
 */
public interface BubbleStorm {

	/**
	 * @see BubbleStorm#join(JoinHandler) join()
	 */
	public interface JoinHandler {
		void onJoinComplete();
	}

	/**
	 * @see BubbleStorm#leave(LeaveHandler) leave()
	 */
	public interface LeaveHandler {
		void onLeaveComplete();
	}

	/**
	 * Starts a new network by creating a ring with itself.
	 * <p>
	 * Note: Ring creation is quick, but not immediate. Any network operations (e.g., creating
	 * bubbles) are allowed only after the operation has completed (i.e., the corresponding handler
	 * method has been invoked). The creation of bubble <i>types</i> is <b>not</b> a network
	 * operations, thus allowed immediately.
	 * </p>
	 * 
	 * @param localAddr
	 *            the local address under which I am reachable by joining nodes
	 * @param createHandler
	 *            invoked when ring creation is complete (optional)
	 * @throws BSError
	 */
	void createRing(Address localAddr, JoinHandler createHandler) throws BSError;

	/**
	 * Starts a new network by creating a ring with itself.
	 * <p>
	 * Note: Ring creation is quick, but not immediate. Any network operations (e.g., creating
	 * bubbles) are allowed only after the operation has completed. It is, thus, recommended to use
	 * the alternate method {@link #createRing(Address, JoinHandler)} instead.
	 * </p>
	 * 
	 * @param localAddr
	 *            the local address under which I am reachable by joining nodes
	 * @throws BSError
	 */
	void createRing(Address localAddr) throws BSError;

	/**
	 * Joins the network using the well-known bootstrap address (see
	 * {@link BubbleStormFactory#create(float, Address, int, boolean)}) and/or addresses from the
	 * host cache.
	 * <p>
	 * Note: Any network operations (e.g., creating bubbles) are allowed only after the operation
	 * has completed (i.e., the corresponding handler method has been invoked). The creation of
	 * bubble <i>types</i> is <b>not</b> a network operations, thus allowed immediately.
	 * </p>
	 * 
	 * @param joinHandler
	 *            invoked when join is complete (optional)
	 * @throws BSError
	 */
	void join(JoinHandler joinHandler) throws BSError;

	/**
	 * Gracefully leaves the network.
	 * 
	 * @param leaveHandler
	 *            invoked when leave is complete (optional)
	 * @throws BSError
	 */
	void leave(LeaveHandler leaveHandler) throws BSError;

	/**
	 * @return the CUSP end point used by this instance
	 * @throws BSError
	 */
	EndPoint endpoint() throws BSError;

	/**
	 * @return the bubble master of this instance, which is used to manage the bubble types
	 * @throws BSError
	 */
	BubbleMaster bubbleMaster() throws BSError;

	/**
	 * @return the best guess of my address as seen by others, or <code>null</code> if unknown
	 * @throws BSError
	 */
	Address address() throws BSError;

	/**
	 * Serializes the host cache, i.e., the addresses of known online nodes, to a byte array for
	 * persistent storage.
	 * 
	 * @return the serialized host cache data
	 * @throws BSError
	 */
	byte[] saveHostCache() throws BSError;

	/**
	 * Loads the host cache from a previously saved state.
	 * 
	 * @param data
	 *            the serialized host cache data
	 * @param bootstrap
	 *            the optional well-known bootstrap address (may be <code>null</code>)
	 * @throws BSError
	 */
	void loadHostCache(byte[] data, Address bootstrap) throws BSError;

	// TODO networkSize()

}
