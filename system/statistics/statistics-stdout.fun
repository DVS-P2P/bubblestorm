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

functor StatisticsStdout (Event : EVENT) :> STATISTICS_WRITER =
   struct
      fun init () = ()
   
      fun createWriter { name, units=_, label=_, node, collector, histogram=_ } =
         fn () =>
            let
               val () = print (Time.toString (Event.time ()))
               val () = print (" " ^ name)
               val () = print (" " ^ (Int.toString node))
               val () = print ("\t" ^ (Int.toString (Collector.count collector)))
               val () = print ("\t" ^ (Real32.toString (Collector.min collector)))
               val () = print ("\t" ^ (Real32.toString (Collector.max collector)))
               val () = print ("\t" ^ (Real64.toString (Collector.sum collector)))
               val () = print ("\t" ^ (Real32.toString (Collector.avg collector)))
               val () = print ("\t" ^ (Real32.toString (Collector.stdDev collector)))
               val () = print "\n"
               val () = Collector.reset collector
            in
               ()
            end
   end
