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

import java.util.concurrent.Callable;

import net.bubblestorm.jni.BSJniBase;
import net.bubblestorm.jni.BaseObject;

public class Event extends BaseObject {

	//
	// public interface
	//

	public interface Handler {
		void onEvent(Event event);
	}

	public static Time time() throws BSError {
		return BSJniBase.call(new Callable<Time>() {
			@Override
			public Time call() throws Exception {
				return new Time(BSJniBase.checkResult(BSJniBase.evtEventTime()));
			}
		});
	}

	public static Event create(final Handler handler) throws BSError {
		final Object callback = new Object() {
			@SuppressWarnings("unused")
			protected void event(int evtHandle) {
				Event evt = new Event(evtHandle);
				handler.onEvent(evt);
			}
		};
		return new Event(BSJniBase.call(new Callable<Integer>() {
			@Override
			public Integer call() throws Exception {
				return BSJniBase.checkResult(BSJniBase.evtEventNew(callback));
			}
		}));
	}

	public void scheduleAt(Time time) throws BSError {
		// TODO problem: if invoking async, time could be over!
		throw new UnsupportedOperationException(
				"Event.scheduleAt unsupported. Consider using scheduleIn.");
	}

	public void scheduleIn(final Time time) throws BSError {
		BSJniBase.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJniBase.checkResult(BSJniBase.evtEventScheduleIn(getHandle(), time
						.toNanoseconds()));
				return null;
			}
		});
	}

	public void cancel() throws BSError {
		BSJniBase.call(new Callable<Void>() {
			@Override
			public Void call() throws Exception {
				BSJniBase.checkResult(BSJniBase.evtEventCancel(getHandle()));
				return null;
			}
		});
	}

	public boolean isScheduled() throws BSError {
		return BSJniBase.call(new Callable<Boolean>() {
			@Override
			public Boolean call() throws Exception {
				return BSJniBase.checkResult(BSJniBase.evtEventIsScheduled(getHandle())) != 0;
			}
		});
	}

	//
	// protected
	//

	protected Event(int handle) {
		super(handle);
	}

	@Override
	protected boolean free(int handle) {
		return BSJniBase.evtEventFree(handle);
	}

}
