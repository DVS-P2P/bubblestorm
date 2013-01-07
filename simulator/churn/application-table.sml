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

(* hashtable to store the main functions of simulated applications *)
structure ApplicationTable :> APPLICATION_TABLE =
   struct
      structure StringHash =
         struct
            type t = string
            val op == = op =
            val hash = Hash.string
         end

      structure HashTable = HashTable(StringHash)
      val table = HashTable.new ()
   
      fun add (cmd, startFn) =
         HashTable.add (table, cmd, startFn) handle HashTable.KeyExists =>
            raise At ("simulator/churn/application-table/add",
               Fail ("Two applications with name " ^ cmd))

      fun get cmd =
         case HashTable.get (table, cmd) of
            NONE =>
               raise At ("simulator/churn/application-table/get",
                  Fail ("Command \"" ^ cmd ^
                        "\" is not a valid simulator application."))
            | SOME x => x
   end   
