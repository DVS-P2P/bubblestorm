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

structure WorkloadConfig :> WORKLOAD_CONFIG =
   struct
      val module = "kv/config/workload"

      datatype t = T of { 
         args : string list,
         coordinator : CUSP.Address.t,
         keepAlive : Time.t,
         queryTimeout : Time.t
      } 
      
      fun readConfig (map, tail) =
         let
            fun optional x = ArgumentParser.optional map x
            fun parseAddress x = case CUSP.Address.fromString x of
                  nil => NONE
                | x => SOME x
         in
            (map, T {
               args     = tail,
               coordinator  = Option.getOpt (Option.map hd (optional ("coordinator", #"c", parseAddress)), KVConfig.defaultCoordinator),
               keepAlive    = Option.getOpt (optional ("keep-alive", #"t", Time.fromString), KVConfig.defaultKeepAlive),
               queryTimeout = Option.getOpt (optional ("query-timeout", #"q", Time.fromString), KVConfig.defaultQueryTimeout)
            })
         end
         handle exn => raise At (module, exn)

      fun readArgs () =
         let
            val args = CommandLine.arguments ()

            val (map, this) = case args of
               "@workload" :: tail => readConfig (ArgumentParser.new (tail, SOME "--"))
             | _ => readConfig (ArgumentParser.empty (), args)

            val fold = List.foldl (fn (a,b) => b ^ " " ^ a) ""
            val () = case ArgumentParser.complainUnused map of
               nil => ()
             | x => raise At (module, Fail ("Unknown @workload parameters: " ^ fold x))
         in
            this
         end         

      fun arguments (T { args, ... }) = args
      fun coordinator  (T { coordinator, ... })  = coordinator
      fun keepAlive    (T { keepAlive, ... })    = keepAlive 
      fun queryTimeout (T { queryTimeout, ... }) = queryTimeout 
   end
