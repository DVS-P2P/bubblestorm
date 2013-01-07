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

signature LIFETIME_DISTRIBUTION =
   sig
      type t

      datatype state = ONLINE of Time.t | OFFLINE of Time.t

      val initialState : t -> state
      val sessionDuration : t -> Time.t
      val intersessionDuration : t -> Time.t
      (* the ratio of online time vs. total (online + offline) time *)
      val onlineRatio : t -> Real32.real

      val newAlwaysOn : unit -> t
      val newExponential : Time.t * Time.t -> t
   end
