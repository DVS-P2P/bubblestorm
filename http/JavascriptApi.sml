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


structure JavascriptApi = struct
   val funmap = StringMap.new () : (JSON.value -> JSON.value) StringMap.t

   fun call (funname, args) =
      case StringMap.get (funmap, funname) of
         SOME func => SOME (func args)
       | NONE => NONE


   (* implementation of a counter api for testing *)
   val testcounter = ref 0

   fun incrementCounter _ =
      let
         val () = testcounter := !testcounter + 1
         val json = JSON.OBJECT([("counter", JSON.INT(!testcounter))])
         val () = PushQueue.push json
      in
         json
      end

   fun resetCounter _ =
      let
         val () = testcounter := 0
         val json = JSON.OBJECT([("counter", JSON.INT(!testcounter))])
         val () = PushQueue.push json
      in
         json
      end
end

val () = StringMap.set (JavascriptApi.funmap, "incrementCounter", JavascriptApi.incrementCounter)
val () = StringMap.set (JavascriptApi.funmap, "resetCounter", JavascriptApi.resetCounter)
