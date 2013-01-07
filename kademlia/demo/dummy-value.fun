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

functor DummyValue (
      structure Id : ID
      val defaultExpiration : Time.t
   ) :
   sig
      include VALUE
      val createRandom : unit -> t
      val fromString : string -> t option
   end
   =
   struct
      structure Id = ID
      
      structure Z = OrderFromCompare(type t = Word64.word
                                     val compare = Word64.compare)
      open Z
      val t = Serial.word64l
      
      fun createRandom () =
         Random.word64 (getTopLevelRandom (), NONE)
      
      val hash = Hash.word64
      val toString = Word64.toString
      val fromString = Word64.fromString
      
      local
         val { toVector, ... } = Serial.methods t
         val { fromVector, ... } = Serial.methods Id.t
      in
         fun id this = fromVector (toVector this)
      end
      
(*       val defaultExpiration = Time.fromHours 24 *)
      fun expires _ = defaultExpiration
   end
