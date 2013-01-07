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

import net.bubblestorm.jni.BSJniBase;

public class Log {

	public enum Level {
		DEBUG(0), INFO(1), STDOUT(2), WARNING(3), ERROR(4), BUG(5);

		private final int level;

		Level(int l) {
			this.level = l;
		}

		public int toInt() {
			return level;
		}
	}

	public static void log(final Level severity, final String module, final String msg) {
		BSJniBase.invoke(new Runnable() {
			@Override
			public void run() {
				try {
					BSJniBase.checkResult(BSJniBase.sysLogLog(severity.toInt(), module, msg));
				} catch (BSError e) {
					e.printStackTrace();
				}
			}
		});
	}

	public static void addFilter(final String module, final Level severity) {
		BSJniBase.invoke(new Runnable() {
			@Override
			public void run() {
				try {
					BSJniBase.checkResult(BSJniBase.sysLogAddFilter(module, severity.toInt()));
				} catch (BSError e) {
					e.printStackTrace();
				}
			}
		});
	}

	public static void removeFilter(final String module) {
		BSJniBase.invoke(new Runnable() {
			@Override
			public void run() {
				try {
					BSJniBase.checkResult(BSJniBase.sysLogRemoveFilter(module));
				} catch (BSError e) {
					e.printStackTrace();
				}
			}
		});
	}

}
