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

structure Property :> PROPERTY =
   struct
      datatype ('object, 'value) init =
         Constant of 'value
       | Function of 'object -> 'value
      
      
      fun initConst x = Constant x
      fun initFun f = Function f
      fun initRaise e = Function (fn _ => raise e)
      
      fun ('object, 'value) make (plist: 'object -> PropertyList.t,
                              init: ('object, 'value) init) =
         let
            val {add, peek, remove, ...} = PropertyList.newProperty ()
         in {
            remove = remove o plist, 
            get = fn (s: 'object) =>
               let
                  val p = plist s
               in
                  case peek p of
                     SOME v => v
                   | NONE => 
                     case init of
                        Constant c => c
                      | Function f =>
                        let 
                           val v = f s
                           val () = add (p, v)
                        in 
                           v
                        end
               end,
            set = fn (s, none: unit -> 'value, some: 'value -> unit) =>
               let 
                  val p = plist s
               in 
                  case peek p of
                     NONE => add (p, none ())
                   | SOME v => some v
               end
         } end
      
      fun getSetOnce z =
         let
            val { get, remove, set, ... } = make z
            fun setOnce (s, v) =
               set (s, fn _ => v, fn _ => raise Fail "Property.setOnce used twice")
         in 
            { get = get, remove = remove, set = setOnce }
         end

      fun get z =
         let 
            val { get, remove, ... } = getSetOnce z
         in 
            { get = get, remove = remove }
         end

      fun getSet (plist, init) =
         let 
            val init =
               case init of
                  Constant c => Function (fn _ => ref c)
                | Function f => Function (ref o f)
            val {get, remove, set, ...} = make (plist, init)
         in {
            get = ! o get, 
            remove = remove,
            set = fn (s, v) =>
               set (s, fn () => ref v, fn r => r := v)
         } end
   end
