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

#include "singlemessageoutstream.h"

#include <assert.h>

namespace BS {
namespace CUSP {

SingleMessageOutStream::SingleMessageOutStream(OutStream& _os,
		const std::string& msg, Handler* _handler)
	: os(_os), handler(_handler)
{
	assert(handler);
	os.write(msg.data(), msg.size(), this);
}

SingleMessageOutStream::SingleMessageOutStream(Host& host, ServiceId service,
		const std::string& msg, Handler* _handler, float priority)
	: handler(_handler)
{
	assert(handler);
	os = host.connect(service);
	if (priority != 0.0f)
		os.setPriority(priority);
	os.write(msg.data(), msg.size(), this);
}

SingleMessageOutStream::~SingleMessageOutStream()
{
	os.reset();
}

void SingleMessageOutStream::onReady()
{
	os.shutdown(this);
}

void SingleMessageOutStream::onReset()
{
	handler->onMessageSent(this, false);
}

void SingleMessageOutStream::onShutdown(bool success)
{
	handler->onMessageSent(this, success);
}

}} // namespace BS::CUSP
