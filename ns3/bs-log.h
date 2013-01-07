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

#ifndef BS_LOG_H
#define BS_LOG_H

#include <string>

class Log
{
	public:
		enum Level {
			DEBUG = 0,
			INFO = 1,
			STDOUT = 2,
			WARNING = 3,
			ERROR = 4,
			BUG = 5
		};
		static void addFilter(const std::string& module, Level level);
};

#endif
