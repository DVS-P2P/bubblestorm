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

#ifndef SINGLEMESSAGEINSTREAM_H
#define SINGLEMESSAGEINSTREAM_H

#include <string>
#include <cusp.h>

namespace BS {
namespace CUSP {

class SingleMessageInStream : private InStream::ReadHandler
{
	public:
		class Handler
		{
			public:
				virtual void onMessage(SingleMessageInStream* stream,
						const std::string& msg) = 0;
				virtual void onMessageReset(SingleMessageInStream* stream) = 0;
		};
		
		SingleMessageInStream(const InStream& is, Handler* handler);
		~SingleMessageInStream();
	private:
		InStream is;
		Handler* handler;
		std::string buffer;
		
		virtual void onReceive(const void* data, int size);
		virtual void onShutdown();
		virtual void onReset();
};

}} // namespace BS::CUSP

#endif
