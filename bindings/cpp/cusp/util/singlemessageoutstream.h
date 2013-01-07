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

#ifndef SINGLEMESSAGEOUTSTREAM_H
#define SINGLEMESSAGEOUTSTREAM_H

#include <string>
#include <cusp.h>

namespace BS {
namespace CUSP {

class SingleMessageOutStream : private OutStream::WriteHandler,
		private OutStream::ShutdownHandler
{
	public:
		class Handler
		{
			public:
				virtual void onMessageSent(SingleMessageOutStream* stream,
						bool success) = 0;
		};
		
		SingleMessageOutStream(OutStream& os, const std::string& msg,
				Handler* handler);
		SingleMessageOutStream(Host& host, ServiceId service,
				const std::string& msg, Handler* handler, float priority = 0.0f);
		~SingleMessageOutStream();
	private:
		OutStream os;
		Handler* handler;
		
		virtual void onReady();
		virtual void onReset();
		virtual void onShutdown(bool success);
};

}} // namespace BS::CUSP

#endif
