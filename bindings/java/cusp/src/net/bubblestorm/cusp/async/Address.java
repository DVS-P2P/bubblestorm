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

package net.bubblestorm.cusp.async;

import net.bubblestorm.jni.BaseObject;
import net.bubblestorm.jni.CUSPJni;

/**
 * Note: The async version of CUSP is unsupported and should not be used.
 */
@Deprecated
public class Address extends BaseObject {

	//
	// public interface
	//

	public static Address fromString(String str) {
		return new Address(CUSPJni.cuspAddressFromString(str));
	}

	//
	// protected
	//

	public Address(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return CUSPJni.cuspAddressFree(handle);
	}

}
