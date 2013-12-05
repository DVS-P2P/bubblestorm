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

#ifndef BUFFEREDOUTSTREAM_H
#define BUFFEREDOUTSTREAM_H

#include <cusp.h>

namespace BS {
namespace CUSP {

class BufferedOutStream : private OutStream::WriteHandler
{
	public:
		class Handler
		{
			public:
				virtual void onReset() = 0;
		};
		
		BufferedOutStream(const OutStream& os, Handler* handler);
		virtual ~BufferedOutStream();

		void write(const void* data, int size);
		float getPriority() const;
		void setPriority(float priority);
		size_t getBufferedSize() const;
		void shutdown(OutStream::ShutdownHandler* handler);
		void reset();
	
	private:
		OutStream os;
		bool ready;
		unsigned char* buf;
		size_t bufSize;
		size_t bufAlloc;
		Handler* handler;
		OutStream::ShutdownHandler* shutdownRequest;
		
		void allocBuf(size_t size);
		void appendBuf(const unsigned char* data, size_t len);
		
		// OutStream::WriteHandler imeplementation
		virtual void onReady();
		virtual void onReset();
};

}} // namespace BS::CUSP

#endif
