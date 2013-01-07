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

#include "abortablecontacthandler.h"

namespace BS {
namespace CUSP {

AbortableContactHandler::AbortableContactHandler(EndPoint::ContactHandler& handler)
	: handler(&handler)
{
}

void AbortableContactHandler::abort()
{
	handler = NULL;
}

// EndPoint::ContactHandler implementation

void AbortableContactHandler::onContact(Host& host, OutStream& os)
{
	if (handler)
		handler->onContact(host, os);
	delete this;
}

void AbortableContactHandler::onContactFail()
{
	if (handler)
		handler->onContactFail();
	delete this;
}

}} // namespace BS::CUSP
