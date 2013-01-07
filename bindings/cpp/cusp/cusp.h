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

//
// C++ wrapper for the CUSP C-bindings
//
// Author: Max Lehn
//

#ifndef CUSP_H
#define CUSP_H

#include "common/bscommon.h"
#include "cusp/cusp-base.h"

namespace BS {

//
// Library open & close functions
//

/// Initializes the CUSP library by setting up the SML part.
/// This function may be called multiple times, but each call must have a corresponding
/// cuspShutdown() call (of which the last one terminates the SML part).
/// \relates EndPoint
void cuspInit();

/// Initializes the CUSP library passing parameters to SML.
/// This function is only allowed to be called if no other cuspInit() call has been
/// done before.
/// argc and argv specify command line parameters that are passed to the SML part.
/// \relates EndPoint
void cuspInit(int argc, const char** argv);

/// Shuts down the CUSP library.
/// Warning: All objects of the CUSP API must be freed before calling this
/// function. Access to any of these objects will result in a segementation fault.
/// \relates EndPoint
void cuspShutdown();

}; // namespace BS

#endif
