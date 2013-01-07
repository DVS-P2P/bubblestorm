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

functor TimelineStatistics (Statistics : STATISTICS) :> TIMELINE_STATISTICS
      where type Statistics.t = Statistics.t
      where type Statistics.histogram = Statistics.histogram
=
   struct
      structure Statistics = Statistics
      
      type t = Statistics.t * Statistics.t Vector.vector
      
      fun new (config, size, childLabel) =
         let
            val { name, units, histogram, persistent, ... } = config
            val root = Statistics.new config
            val parent = [ (root, Statistics.aggregate) ]
            fun makeChild pos =
               Statistics.new {
                  parents = parent,
                  name = name ^ "/" ^ Int.toString pos,
                  units = units,
                  label = childLabel pos,
                  histogram = histogram,
                  persistent = persistent
               }
         in
            (root, Vector.tabulate (size, makeChild))
         end

      fun get ((_, children), pos) = Vector.sub (children, pos)
      
      fun addPoll ((root, _), poll) = Statistics.addPoll (root, poll)
      
      fun add this pos value = Statistics.add (get (this, pos)) value
   end
