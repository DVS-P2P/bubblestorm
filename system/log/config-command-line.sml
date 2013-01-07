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

structure ConfigCommandLine :> CONFIG_COMMAND_LINE =
   struct
      val module = "system/log/config-command-line"
      
      datatype logMode = STDOUT | SQLITE of SQL.db

      val name = CommandLine.name
      
      val args = CommandLine.arguments ()

      (* parse n:module strings into (module, level) tuples *)
      fun parseFilter filter =
          case String.fields (fn #":" => true | _ => false) filter of
             [level, module] =>
               (case Option.mapPartial LogLevels.fromInt (Int.fromString level) of
                   SOME level => SOME (module, level)
                 | NONE =>
                     case LogLevels.fromString level of
                         SOME level => SOME (module, level)
                       | NONE => NONE
               )
           | _ => raise At (module, Fail "Expected exactly one ':' in --filter\n")

      fun readConfig (map, tail) =
         let
            fun optional x = ArgumentParser.optional map x
            fun any x = ArgumentParser.any map x
         in
            {
               map      = map,
               args     = tail,
               logDB    = case optional ("db", #"d", fn x => SOME x) of
                             SOME db => SQLITE (SQL.openDB db)
                           | NONE => STDOUT,
               interval = optional ("log", #"l", Time.fromString),
               filters  = any      ("filter", #"f", parseFilter),
               rseed    = optional ("seed", #"s", Word32.fromString)
            }
         end
         handle exn => raise At (module, exn)
         
      val { map, args, logDB, interval, filters, rseed } = 
         case args of
            "@config" :: tail => readConfig (ArgumentParser.new (tail, SOME "--"))
          | _ => readConfig (ArgumentParser.empty (), args)
      
      val fold = List.foldl (fn (a,b) => b ^ " " ^ a) ""
      val () = case ArgumentParser.complainUnused map of
         nil => ()
       | x => raise At (module, Fail ("Unknown @config parameters: " ^ fold x))
      
      fun arguments    () = args
      fun logDatabase  () = logDB
      fun logInterval  () = interval
      fun logFilters   () = filters
      fun seed         () = rseed
      fun experimentID () = 0
      fun nodeID       () = SOME 0
      fun nodeAddress  () = "unknown"
   end
