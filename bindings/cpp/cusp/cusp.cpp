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

#include "cusp/cusp.h" 

#include <assert.h>
#include "cusp/libcusp.h"

#include "common/bscommon.cpp"
#include "cusp/cusp-base.cpp"

namespace BS {

//
// Library open & close functions
//

unsigned int openCounter = 0;

void cuspInit()
{
	if (openCounter == 0) {
		// HACK: pass one argument as a workaround for LogCommandLine bug
		const char* argv[] = { "", NULL };
		cusp_open(1, argv);
	}
	openCounter++;
}

void cuspInit(int argc, const char** argv)
{
	// parameters can only be bassed in first open call
	assert(openCounter == 0);
	cusp_open(argc, argv);
	openCounter++;
}

void cuspShutdown()
{
	assert(openCounter > 0);
	openCounter--;
	if (openCounter == 0) {
		cusp_close();
	}
}

}; // namespace BS
