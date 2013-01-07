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

#include "bufferedoutstream.h"

#include "stdlib.h"
#include "string.h"
#include "assert.h"

#define BUF_MIN_ALLOC 1024

namespace BS {
namespace CUSP {

//
// public methods
//

BufferedOutStream::BufferedOutStream(const OutStream& _os, Handler* _handler)
	: os(_os), ready(true), buf(NULL), bufSize(0), bufAlloc(0), handler(_handler), shutdownRequest(NULL)
{
	assert(os.isValid());
	assert(handler);
}

BufferedOutStream::~BufferedOutStream()
{
	reset();
}

void BufferedOutStream::write(const void* data, int size)
{
	if (ready) {
		// write directly
		ready = false;
		os.write(data, size, this);
	} else {
		// append buffer
		appendBuf((const unsigned char*) data, (size_t) size);
	}
}

float BufferedOutStream::getPriority() const
{
	return os.getPriority();
}

void BufferedOutStream::setPriority(float priority)
{
	os.setPriority(priority);
}

size_t BufferedOutStream::getBufferedSize() const
{
	return bufSize;
}

void BufferedOutStream::shutdown(OutStream::ShutdownHandler* handler)
{
	shutdownRequest = handler;
	if (ready) {
		os.shutdown(handler);
	} // (else: wait for onReady())
}

void BufferedOutStream::reset()
{
	ready = false;
	if (buf) {
		free(buf);
		buf = NULL;
		bufSize = 0;
		bufAlloc = 0;
	}
	os.reset();
}

//
// private methods
//

void BufferedOutStream::allocBuf(size_t size)
{
	if (bufAlloc < size) {
		size_t newAlloc = (bufAlloc < BUF_MIN_ALLOC) ? BUF_MIN_ALLOC : bufAlloc;
		while (newAlloc < size)
			newAlloc *= 2;
		buf = (unsigned char*) realloc(buf, newAlloc);
		assert(buf);
		bufAlloc = newAlloc;
	}
}

void BufferedOutStream::appendBuf(const unsigned char* data, size_t len)
{
	size_t newSize = bufSize + len;
	allocBuf(newSize);
	memcpy(buf + bufSize, data, len);
	bufSize = newSize;
}

void BufferedOutStream::onReady()
{
	if (bufSize > 0) {
		// write buffer
		os.write(buf, bufSize, this);
		// clear buffer
		bufSize = 0;
	} else {
		if (shutdownRequest)
			os.shutdown(shutdownRequest);
		else
			ready = true;
	}
}

void BufferedOutStream::onReset()
{
	handler->onReset();
}

}} // namespace BS::CUSP
