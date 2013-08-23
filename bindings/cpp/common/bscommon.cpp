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

#include "common/bscommon.h"

//
// SML library initialization notification
//

bool bsLibInitialized = false;

extern "C" {
	void bs_lib_opened() {
		bsLibInitialized = true;
	}
	void bs_lib_closed() {
		bsLibInitialized = false;
	}
}

namespace BS {

//
// Main loop functions
//

void evtMain()
{
#ifndef BS_SIM
	evt_main();
#endif
}

void evtMainSigInt()
{
#ifndef BS_SIM
	evt_main_sigint();
#endif
}

bool evtMainRunning()
{
#ifndef BS_SIM
	return evt_main_running();
#else
	return true;
#endif
}

void evtStopMain()
{
#ifndef BS_SIM
	evt_stop_main();
#endif
}

void evtProcessEvents()
{
#ifndef BS_SIM
	evt_process_events();
#endif
}


//
// Time
//

Time Time::fromString(const std::string& str)
{
	int64_t t = checkResult(evt_time_from_string((char*) str.data(), str.size()));
	return Time(t);
}

std::string Time::toString() const
{
	Int32_t len;
	const char* s = (const char*) evt_time_to_string(time, &len);
	checkResult(len);
	return std::string(s, len);
}

//
// Event
//

Event Event::create(Handler* handler)
{
	assert(handler);
	Handle handle = checkResult(evt_event_new((void*) eventCallback, handler));
	return Event(handle);
}

Time Event::time()
{
	return Time(checkResult(evt_event_time()));
}

Event::Event()
   : handle(HANDLE_NONE)
{
}

Event::Event(Handle handle)
   : handle(handle)
{
	ASSERT_HANDLE(handle);
}

Event::Event(const Event& evt)
{
	if (IS_VALID_HANDLE(evt.handle)) {
		handle = evt_event_dup(evt.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

Event::~Event()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(evt_event_free(handle));
}

void Event::swap(Event& e)
{
	std::swap(e.handle, handle);
}

Event& Event::operator =(const Event& e)
{
	Event event(e);
	swap(event);
	return *this;
}

bool Event::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void Event::scheduleAt(const Time& time)
{
	ASSERT_HANDLE(handle);
	checkResult(evt_event_schedule_at(handle, time));
}

void Event::scheduleIn(const Time& time)
{
	ASSERT_HANDLE(handle);
	checkResult(evt_event_schedule_in(handle, time));
}

void Event::cancel()
{
	ASSERT_HANDLE(handle);
	checkResult(evt_event_cancel(handle));
}

Time Event::timeOfExecution() const
{
   ASSERT_HANDLE(handle);
   int64_t t = checkResult(evt_event_time_of_execution(handle));
   return Time(t);
}

Time Event::timeTillExecution() const
{
   ASSERT_HANDLE(handle);
   int64_t t = checkResult(evt_event_time_till_execution(handle));
   return Time(t);
}

bool Event::isScheduled() const
{
   ASSERT_HANDLE(handle);
   return (bool) checkResult(evt_event_is_scheduled(handle));
}

void Event::eventCallback(Handle eventHandle, void* userData)
{
   assert(userData);
   Event evt(eventHandle);
   ((Handler*) userData)->onEvent(evt);
}

//
// Abortable
//

Abortable::Abortable()
   : handle(HANDLE_NONE)
{
}

Abortable::Abortable(const Abortable& a)
{
   if (IS_VALID_HANDLE(a.handle)) {
      handle = evt_abortable_dup(a.handle);
      ASSERT_HANDLE(handle);
   } else
      handle = HANDLE_NONE;
}

Abortable::Abortable(Handle handle)
   : handle(handle)
{
   ASSERT_HANDLE(handle);
}

Abortable::~Abortable()
{
   if (IS_VALID_HANDLE(handle))
      ASSERT_CALL_TRUE(evt_abortable_free(handle));
}

void Abortable::swap(Abortable& a)
{
   std::swap(a.handle, handle);
}

Abortable& Abortable::operator =(const Abortable& a)
{
   Abortable ab(a);
   swap(ab);
   return *this;
}

bool Abortable::isValid() const
{
   return IS_VALID_HANDLE(handle);
}

void Abortable::abort()
{
   ASSERT_HANDLE(handle);
   checkResult(evt_abortable_abort(handle));
}


//
// Log
//

void Log::log(Severity severity, const std::string& module, const std::string& msg)
{
	checkResult(sys_log_log((int)severity, (char*) module.data(), module.size(),
			(char*) msg.data(), msg.size()));
}


//
// Statistics
//

Statistics Statistics::create(const std::string& name,
		const std::string& unit,
		Statistics parent, ParentMode parentMode,
		HistogramMode hist, float histParam,
		bool persistent)
{
	Handle parentHandle = parent.isValid() ? parent.handle : -1;
	Handle h = sys_statistics_new((char*) name.data(), name.size(),
			(char*) unit.data(), unit.size(),
			parentHandle, parentMode, hist, histParam, persistent);
	checkResult(h);
	return Statistics(h);
}

Statistics::Statistics()
   : handle(HANDLE_NONE)
{
}

Statistics::Statistics(const Statistics& a)
{
	if (IS_VALID_HANDLE(a.handle)) {
		handle = sys_statistics_dup(a.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

Statistics::Statistics(Handle handle)
   : handle(handle)
{
	ASSERT_HANDLE(handle);
}

Statistics::~Statistics()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(sys_statistics_free(handle));
}

void Statistics::swap(Statistics& a)
{
	std::swap(a.handle, handle);
}

Statistics& Statistics::operator =(const Statistics& a)
{
	Statistics ab(a);
	swap(ab);
	return *this;
}

bool Statistics::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void Statistics::addPoll(PollHandler* handler)
{
	ASSERT_HANDLE(handle);
	assert(handler);
	checkResult(sys_statistics_addpoll(handle, (void*) pollCallback, handler));
}

void Statistics::add(float value)
{
	ASSERT_HANDLE(handle);
	checkResult(sys_statistics_add(handle, value));
}

void Statistics::pollCallback(void* userData)
{
   assert(userData);
   ((PollHandler*) userData)->pollStatistics();
}


//
// SimultaneousDump
//

SimultaneousDump SimultaneousDump::create(const std::string& name,
		const std::string& header, const std::string& footer,
		const Time& interval)
{
	Handle h = sys_simultaneousdump_new((char*) name.data(), name.size(),
			(char*) header.data(), header.size(), (char*) footer.data(), footer.size(),
			interval);
	checkResult(h);
	return SimultaneousDump(h);
}

SimultaneousDump::SimultaneousDump()
   : handle(HANDLE_NONE)
{
}

SimultaneousDump::SimultaneousDump(const SimultaneousDump& a)
{
	if (IS_VALID_HANDLE(a.handle)) {
		handle = sys_simultaneousdump_dup(a.handle);
		ASSERT_HANDLE(handle);
	} else
		handle = HANDLE_NONE;
}

SimultaneousDump::SimultaneousDump(Handle handle)
   : handle(handle)
{
	ASSERT_HANDLE(handle);
}

SimultaneousDump::~SimultaneousDump()
{
	if (IS_VALID_HANDLE(handle))
		ASSERT_CALL_TRUE(sys_simultaneousdump_free(handle));
}

void SimultaneousDump::swap(SimultaneousDump& a)
{
	std::swap(a.handle, handle);
}

SimultaneousDump& SimultaneousDump::operator =(const SimultaneousDump& a)
{
	SimultaneousDump ab(a);
	swap(ab);
	return *this;
}

bool SimultaneousDump::isValid() const
{
	return IS_VALID_HANDLE(handle);
}

void SimultaneousDump::addDumper(Dumper* dumper)
{
	ASSERT_HANDLE(handle);
	assert(dumper);
	checkResult(sys_simultaneousdump_adddumper(handle, (void*) dumpCallback, dumper));
}

void SimultaneousDump::dumpCallback(void* userData)
{
	assert(userData);
	std::string dump = ((Dumper*) userData)->dump();
	bs_return_string((char*) dump.data(), dump.size());
}


//
// BSException
//

BSException::BSException()
   : handle(HANDLE_NONE)
{
}

BSException::BSException(const BSException& e)
{
   if (IS_VALID_HANDLE(e.handle)) {
      handle = bs_exception_dup(e.handle);
      ASSERT_HANDLE(handle);
   } else
      handle = HANDLE_NONE;
}

BSException::BSException(Handle handle)
   : handle(handle)
{
   ASSERT_HANDLE(handle);
   // get name and message
   Int32_t strLen; const char* str;
   str = (const char*) bs_exception_name(handle, &strLen);
   checkResult(strLen);
   nameStr = std::string(str, (size_t)strLen);
   str = (const char*) bs_exception_message(handle, &strLen);
   checkResult(strLen);
   messageStr = std::string("BubbleStorm: ") + std::string(str, (size_t)strLen);
}

BSException::~BSException() throw()
{
   if (IS_VALID_HANDLE(handle))
      ASSERT_CALL_TRUE(bs_exception_free(handle));
}

void BSException::swap(BSException& e)
{
   std::swap(e.handle, handle);
}

BSException& BSException::operator =(const BSException& e)
{
   BSException ex(e);
   swap(ex);
   return *this;
}

bool BSException::isValid() const
{
   return IS_VALID_HANDLE(handle);
}

const char* BSException::name() const throw()
{
	return nameStr.c_str();
}

const char* BSException::what() const throw()
{
	return messageStr.c_str();
}

BSException BSException::fromLastException() {
	Handle h = bs_last_exception();
	if (IS_VALID_HANDLE(h))
		return BSException(h);
	else
		return BSException();
}


}; // namespace BS
