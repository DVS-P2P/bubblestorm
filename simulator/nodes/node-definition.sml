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

structure NodeDefinition :> NODE_DEFINITION =
   struct

      datatype t = T of {
         id : int,
         name : string,
         connection : ConnectionProperties.t,
         cmdLine : Arguments.t,
         lifetime : LifetimeDistribution.t,
         crashRatio : Real32.real,
         workload : string
      }

      fun id          (T fields) = #id fields
      fun name        (T fields) = #name fields
      fun connection  (T fields) = #connection fields
      fun cmdLine     (T fields) = #cmdLine fields
      fun lifetime    (T fields) = #lifetime fields
      fun crashRatio  (T fields) = #crashRatio fields
      fun workload    (T fields) = #workload fields
      
      fun new fields = T fields
   end
