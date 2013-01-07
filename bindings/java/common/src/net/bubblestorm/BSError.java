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

/**
 * This exception passes exceptions from the BubbleStorm SML library.
 * 
 * @author Max Lehn
 */
public class BSError extends Exception {

	private static final long serialVersionUID = -9094072459389079928L;

	public BSError(String message) {
		super(message);
	}

	public BSError(String message, Throwable cause) {
		super(message, cause);
	}

}
