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
// Common basics for the BubbleStorm/CUSP C++ bindings
//
// Author: Max Lehn
//

#ifndef BSCOMMON_H
#define BSCOMMON_H

#include <inttypes.h>
#include <string>
#include <exception>
#include <cassert>

//
// Basic types
//

/// (Internal use only) Handle to any SML structure.
typedef int32_t Handle;

//
// Handle utilities (for internal use)
//

extern bool bsLibInitialized;

#ifdef NDEBUG
#define ASSERT_CALL_TRUE(x) x
#else
#define ASSERT_CALL_TRUE(x) assert(x)
#endif

#define HANDLE_NONE -1
#define IS_VALID_HANDLE(h) (bsLibInitialized && (h >= 0))
#define ASSERT_HANDLE(h) assert(h >= 0)

#define RESULT_EXCEPTION -3

namespace BS {

//
// Main loop functions
//
// Main loop functions are not available when compiling for simulation.
// Define BS_SIM to replace them with fake versions.

/// Runs the BubbleStorm/CUSP main loop.
/// \relates Event
void evtMain();

/// Runs the BubbleStorm/CUSP main loop with a SIGINT handler.
/// On a SIGINT (e.g. pressing CTRL+C in the console), the event loop terminates.
/// \relates Event
void evtMainSigInt();

/// Returns whether the main loop (cuspMain()) is running.
/// \relates Event
bool evtMainRunning();

/// Stops the main loop.
/// It is not guaranteed that the main loop terminates immediately;
/// it may continue processing a few events before terminating.
/// \relates Event
void evtStopMain();

/// Processes CUSP library tasks. This function has to be called regularly if the application
/// does not use the main loop cuspMain().
/// \relates Event
void evtProcessEvents();

//
// Classes
//

class Time
{
	public:
		static Time fromNanoseconds(int64_t ns)
			{ return Time(ns); };
		static Time fromMicroseconds(int ms)
			{ return Time(ms * 1000LL); };
		static Time fromMilliseconds(int ms)
			{ return Time(ms * 1000000LL); };
		static Time fromSeconds(int64_t s)
			{ return Time(s * 1000000000LL); };
		
		static Time zero()
			{ return Time(0); };
		static Time maxTime()
			{ return Time(0x7fffffffffffffffLL); };
		
		static Time fromString(const std::string& str);
		std::string toString() const;
		
		int64_t toNanoseconds() const
			{ return time; };
		int toMicroseconds() const
			{ return (int) (time / 1000LL); };
		int toMilliseconds() const
			{ return (int) (time / 1000000LL); };
		
		Time operator +(const Time& t) const
			{ return Time(time + t.time); }
		Time operator -(const Time& t) const
			{ return Time(time - t.time); }
		Time operator *(const float& f) const
			{ return Time(time * f); }
		
		bool operator ==(const Time& t) const
			{ return (time == t.time); }
		bool operator !=(const Time& t) const
			{ return (time != t.time); }
		bool operator <(const Time& t) const
			{ return (time < t.time); }
		bool operator >(const Time& t) const
			{ return (time > t.time); }
		bool operator <=(const Time& t) const
			{ return (time <= t.time); }
		bool operator >=(const Time& t) const
			{ return (time >= t.time); }
		
		Time()
			: time(0LL) {};
		Time(int64_t time)
			: time(time) {};
		operator int64_t () const
			{ return time; };
	
	private:
		int64_t time;
};

/// The Event class allows using CUSP's eventing system for
/// application purposes.
class Event
{
	public:
		/// Event handler.
		class Handler
		{
			public:
				virtual void onEvent(Event& event) = 0;
		};
		
		/// Creates a new (unscheduled) event.
		static Event create(Handler* handler);
		/// Returns the current time.
		static Time time();
		
		Event();
		Event(Handler* handler);
		Event(const Event& e);
		~Event();
		void swap(Event& e);
		Event& operator =(const Event& e);
		bool isValid() const;
		
		/// (Re-)Schedules the event (absolute time).
		void scheduleAt(const Time& time);
		/// (Re-)Schedules the event (relative time).
		void scheduleIn(const Time& time);
		/// Unschedules the event.
		void cancel();
		/// Returns the event's time of execution.
		Time timeOfExecution() const;
		/// Returns the event's time till execution.
		Time timeTillExecution() const;
		/// Returns whether the event is scheduled.
		bool isScheduled() const;
	
	private:
		Handle handle;
		Event(Handle handle);
		static void eventCallback(Handle eventHandle, void* userData);
};


/// Allows to stop/abort certain operations.
/// Objects of this class are returned on stoppable operation calls
/// and may be ignored if a particular operation is never intended to be
/// stopped.
class Abortable
{
	public:
		/// Uninitialized constructor.
		Abortable();
		/// Copy constructor. Creates a new handle on SML side.
		Abortable(const Abortable& a);
		/// Create from handle. For internal use only.
		Abortable(Handle handle);
		/// Destructor. Frees SML handle.
		~Abortable();
		/// Swaps the given object with this one.
		void swap(Abortable& a);
		/// Asignment operator.
		Abortable& operator =(const Abortable& a);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		
		/// Aborts the operation.
		void abort();
	
	private:
		Handle handle;
};


class Log
{
	public:
		/// Log levels.
		enum Severity { LOG_DEBUG=0, LOG_INFO=1, LOG_STDOUT=2, LOG_WARNING=3, LOG_ERROR=4, LOG_BUG=5 };
		
		/// Output a log message.
		static void log(Severity severity, const std::string& module, const std::string& msg);
};


class Statistics
{
	public:
		/// Aggregation mode for child statistics.
		enum ParentMode { MIN=0, MAX=1, SUM=2, AVG=3, STDDEV=4 };
		enum HistogramMode { NO_HISTOGRAM=0, FIXED_BUCKET=1, EXPONENTIAL_BUCKET=2 };
		
		/// Statistics poll handler.
		class PollHandler {
			public:
				virtual void pollStatistics() = 0;
		};
		
		/// Creates a new statistics object.
		static Statistics create(const std::string& name,
				const std::string& unit = "",
				Statistics parent = Statistics(), ParentMode parentMode = AVG,
				HistogramMode hist = NO_HISTOGRAM, float histParam = 0.0f,
				bool persistent = true);
		
		/// Uninitialized constructor.
		Statistics();
		/// Copy constructor. Creates a new handle on SML side.
		Statistics(const Statistics& a);
		/// Create from handle. For internal use only.
		Statistics(Handle handle);
		/// Destructor. Frees SML handle.
		~Statistics();
		/// Swaps the given object with this one.
		void swap(Statistics& a);
		/// Asignment operator.
		Statistics& operator =(const Statistics& a);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		
		/// Add a poll handler.
		void addPoll(PollHandler* handler);
		
		/// Adds a value to the statistics.
		void add(float value);
	
	private:
		Handle handle;
		
		static void pollCallback(void* userData);
};


class SimultaneousDump
{
	public:
		/// Dumper interface to be implemented by the application.
		class Dumper {
			public:
				virtual std::string dump() = 0;
		};
		
		/// Creates a new simultaneous-dump object.
		static SimultaneousDump create(const std::string& name,
				const std::string& header, const std::string& footer,
				const Time& interval);
		
		/// Uninitialized constructor.
		SimultaneousDump();
		/// Copy constructor. Creates a new handle on SML side.
		SimultaneousDump(const SimultaneousDump& a);
		/// Create from handle. For internal use only.
		SimultaneousDump(Handle handle);
		/// Destructor. Frees SML handle.
		~SimultaneousDump();
		/// Swaps the given object with this one.
		void swap(SimultaneousDump& a);
		/// Asignment operator.
		SimultaneousDump& operator =(const SimultaneousDump& a);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		
		/// Add a poll handler.
		void addDumper(Dumper* dumper);
	
	private:
		Handle handle;
		
		static void dumpCallback(void* userData);
};


//
// BSException
//

class BSException : public std::exception
{
	public:
// 		BSError(const std::string& message) : message(message) {}
		/// Uninitialized constructor. For internal use only.
		BSException();
		/// Create from handle. For internal use only.
		BSException(Handle handle);
		/// Copy constructor. Creates a new handle on SML side.
		BSException(const BSException& e);
		/// Destructor. Frees SML handle.
		virtual ~BSException() throw();
		/// Swaps the given object with this one.
		void swap(BSException& e);
		/// Asignment operator.
		BSException& operator =(const BSException& e);
		/// Checks for handle validity. Any methods operating on
		/// the object will only work if this method returns true.
		bool isValid() const;
		
		static BSException fromLastException();
		
		const char* name() const throw();
		virtual const char* what() const throw();
	
	private:
		Handle handle;
		std::string nameStr;
		std::string messageStr;
};

// Result checkers

/// Checks SML result for exception. For internal use only.
inline int32_t checkResult(int32_t res) throw (BSException)
{
	if (res == RESULT_EXCEPTION)
		throw BSException::fromLastException();
	assert(res != -1);
	return res;
}

/// Checks SML result for exception. For internal use only.
inline int64_t checkResult(int64_t res) throw (BSException)
{
	if (res == RESULT_EXCEPTION)
		throw BSException::fromLastException();
	assert(res != -1);
	return res;
}

/// Checks SML result for exception. For internal use only.
inline float checkResult(float res) throw (BSException)
{
	if (res != res) {
		// a 'false' result is not necessarily an exception, so check first
		BSException exn = BSException::fromLastException();
		if (exn.isValid())
			throw exn;
	}
	assert(res == res);
	return res;
}

}; // namespace BS

#endif
