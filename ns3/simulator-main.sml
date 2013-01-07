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

structure SimulatorMain :>
   sig
      include MAIN
      val getApp : string -> (unit -> unit) option
   end
=
   struct
      structure Event = NodeEvent

      (* application table *)
      structure StringHash =
         struct
            type t = string
            val op == = op =
            val hash = Hash.string
         end
      structure AppTable = HashTable(StringHash)
      val appTable = AppTable.new ()

      datatype rehook = UNHOOK | REHOOK

      fun signal (s, handler) =
         let
            (* TODO fire SIGINT for gracefully stopping an application *)
            fun unhook () = false
         in
            unhook
         end

      (* pass the main function to the churn manager *)
      fun run (name, mainFun) =
         AppTable.add (appTable, name, mainFun)

      (* kill the current node *)
      fun stop () =
         ()
      
      fun getApp name =
         AppTable.get (appTable, name)
      
end
