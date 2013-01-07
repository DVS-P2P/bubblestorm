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

public class Time {

	//
	// constants
	//

	private static long SECOND = 1000000000;
	private static long M_SECOND = 1000000;
	private static long U_SECOND = 1000;

	//
	// fields
	//

	private long time;

	//
	// public interface
	//

	public static Time fromNanoseconds(long ns) {
		return new Time(ns);
	}

	public static Time fromMicroseconds(int ns) {
		return new Time(((long) ns) * U_SECOND);
	}

	public static Time fromMilliseconds(int ms) {
		return new Time(((long) ms) * M_SECOND);
	}

	public static Time fromSeconds(int s) {
		return new Time(((long) s) * SECOND);
	}

	public static Time zero() {
		return new Time(0);
	}

	public static Time maxTime() {
		return new Time(Long.MAX_VALUE);
	}

	public static Time fromString(String str) {
		return new Time(BSJniBase.evtTimeFromString(str));
	}

	public long toNanoseconds() {
		return time;
	}

	public float toSecondsFloat() {
		return ((float) time) / SECOND;
	}

	public double toSecondsDouble() {
		return ((double) time) / SECOND;
	}

	public Time add(Time t) {
		return new Time(time + t.time);
	}

	public Time sub(Time t) {
		return new Time(time - t.time);
	}

	public Time mult(int v) {
		return new Time(time * v);
	}

	public Time mult(float v) {
		return new Time((long) ((float) time * v));
	}

	public Time mult(double v) {
		return new Time((long) ((double) time * v));
	}

	public Time div(int v) {
		return new Time(time / v);
	}

	public Time div(float v) {
		return new Time((long) ((float) time / v));
	}

	public Time div(double v) {
		return new Time((long) ((double) time / v));
	}

	@Override
	public String toString() {
		try {
			return BSJniBase.call(new Callable<String>() {
				@Override
				public String call() throws Exception {
					return BSJniBase.checkResult(BSJniBase.evtTimeToString(time));
				}
			});
		} catch (BSError e) {
			e.printStackTrace();
			return "(BS call FAILED)";
		}
	}

	public String toAbsoluteString() {
		try {
			return BSJniBase.call(new Callable<String>() {
				@Override
				public String call() throws Exception {
					return BSJniBase.checkResult(BSJniBase.evtTimeToAbsoluteString(time));
				}
			});
		} catch (BSError e) {
			e.printStackTrace();
			return "(BS call FAILED)";
		}
	}

	public String toRelativeString() {
		try {
			return BSJniBase.call(new Callable<String>() {
				@Override
				public String call() throws Exception {
					return BSJniBase.checkResult(BSJniBase.evtTimeToRelativeString(time));
				}
			});
		} catch (BSError e) {
			e.printStackTrace();
			return "(BS call FAILED)";
		}
	}

	//
	// protected
	//

	protected Time(long time) {
		this.time = time;
	}

}
