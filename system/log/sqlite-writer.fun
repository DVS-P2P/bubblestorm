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

functor SQLiteWriter (val experiment : unit -> int
                      val database : unit -> SQL.db)
   :> LOG_WRITER =
   struct
      val module = "system/log/sqlite-writer"
      
      val insert = ref (fn _ =>
         raise At (module, Fail "database connection not initialized"))
      
      fun init () =
         let
            val database = database ()
            val experiment = experiment ()
            open SQL.Query
      
            (*val () = print "Removing old data from the \"log\" table.\n"*)
            val () = SQL.simpleExec (database, 
               "DELETE FROM log WHERE experiment=" ^ 
               Int.toString experiment ^ ";")

            val insertStatement = prepare database "INSERT INTO log\
               \ (experiment, node, ip, time, level, module, message)\
               \ VALUES ("iI", "iI", "iS", "iS", "iI", "iS", "iS");" $
         in
            insert := (fn (node, address, time, level, module, message) =>
               SQL.exec insertStatement (experiment & node & address & time & 
                                         level & module & message))
         end

      fun write { time, node, address, level, module, message } =
         let
            val node = Option.getOpt (node, ~1) (* -1 = global *)
            val time = Time.toString time
            val level = LogLevels.toInt level
         in
            (!insert) (node, address, time, level, module, message)
         end
   end
