(*
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
*)

signature TIME =
   sig
      include SERIALIZABLE
      
      val fromNanoseconds   : int -> t
      val fromMicroseconds  : int -> t
      val fromMilliseconds  : int -> t
      val fromSeconds       : int -> t
      val fromMinutes       : int -> t
      val fromHours         : int -> t
      val fromDays          : int -> t
      val fromSecondsReal32 : Real32.real -> t
      val fromNanoseconds64 : Int64.int -> t
      
      val toNanoseconds   : t -> LargeInt.int
      val toNanoseconds64 : t -> Int64.int
      val toSecondsReal32 : t -> Real32.real
      
      val fromString : string -> t option
      (* [~][[[D+ ]HH:]MM:]SS[.N+] *)
      val toRelativeString : t -> string
      (* YYYY-MM-DD HH:MM:SS[.N+] *)
      val toAbsoluteString : t -> string
      (* Automatically choose toRelative string if within +/- 1 day of zero *)
      (* val toString : t -> string *)(* already included in SERIALIZABLE *)
      
      val zero    : t
      val maxTime : t
      
      val + : t * t -> t
      val - : t * t -> t
      
      val *   : t * int -> t
      val div : t * t -> int
      val div64 : t * t -> Int64.int
      val divInt : t * int -> t
      val divInt64 : t * Int64.int -> t
      val multReal32 : t * Real32.real -> t
   end
 
signature TIME_EXTRA =
   sig
      include TIME
            
      (**
       * Returns current system time. You most probably want 
       * Event.time for timestamp of current event instead!
       * !!!! Cannot be used by simulated programs !!!!
       *)
      val realTime : unit -> t
   end
