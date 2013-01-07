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

structure LifetimeDistribution :> LIFETIME_DISTRIBUTION =
   struct
      datatype t =
         ALWAYS_ON
       | EXPONENTIAL of (Time.t * Time.t)

      datatype state = ONLINE of Time.t | OFFLINE of Time.t

      fun exponential () =
         let
            val random = Experiment.random ()
            val convert = Real32.fromLarge IEEEReal.TO_NEAREST o Real.toLarge
         in
            convert (Random.exponential random)
         end

      fun sessionDuration ALWAYS_ON = Time.fromDays 1000 (* ~2.7 years *)
        | sessionDuration (EXPONENTIAL (online, _)) =
         Time.multReal32 (online, exponential ())

      fun intersessionDuration ALWAYS_ON = Time.zero
        | intersessionDuration (EXPONENTIAL (_, offline)) =
         Time.multReal32 (offline, exponential ())

      fun initialState ALWAYS_ON = ONLINE (Time.fromDays 1000) (* ~2.7 years *)
        | initialState (this as (EXPONENTIAL (online, offline))) =
         let
            val random = Experiment.random ()
            val chanceOnline = Time.toSecondsReal32 online /
                               Time.toSecondsReal32 (Time.+ (online, offline))
         in
            if Random.real32 random < chanceOnline
               then ONLINE (sessionDuration this)
            else OFFLINE (intersessionDuration this)
         end

      fun onlineRatio ALWAYS_ON = 1.0
        | onlineRatio (EXPONENTIAL (onlineTime, offlineTime)) =
         let
            val onlineSec = Time.toSecondsReal32 onlineTime
            val offlineSec = Time.toSecondsReal32 offlineTime
         in
            onlineSec / (onlineSec + offlineSec)
         end

      fun newAlwaysOn () = ALWAYS_ON
      fun newExponential (online, offline) = EXPONENTIAL (online, offline)
   end
