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

package net.bubblestorm.util;

public class Mailbox<Value, Exn extends Exception> {

	private enum Status {
		EMPTY, VALUE, EXCEPTION
	};

	private Status status = Status.EMPTY;

	private Object value = null;

	public void put(Value v) {
		synchronized (this) {
			value = v;
			status = Status.VALUE;
			this.notifyAll();
		}
	}

	public void exception(Exn ex) {
		synchronized (this) {
			value = ex;
			status = Status.EXCEPTION;
			this.notifyAll();
		}
	}

	@SuppressWarnings("unchecked")
	public Value waitFor() throws Exn, InterruptedException {
		synchronized (this) {
			while (status == Status.EMPTY)
				this.wait();
			if (status == Status.VALUE)
				return (Value) value;
			else
				throw (Exn) value;
		}
	}
}
