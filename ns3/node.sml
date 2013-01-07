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

structure Node =
   struct
      datatype t = T of {
         context : MLton.Pointer.t,
         id : int,
         appName : string,
         args : string list,
         printBuffer : string list ref,
         cleanupFunctions : (unit -> unit) Ring.t
      }
      val nodeBucket : t IdBucket.t = IdBucket.new ()
      
      val current : t option ref = ref NONE
      
      fun context (T { context, ... }) = context
      fun id (T { id, ... }) = id
      fun appName (T { appName, ... }) = appName
      fun args (T { args, ... }) = args
      fun printBuffer (T { printBuffer, ... }) = printBuffer
      
      fun currentNode () =
         case !current of
            SOME node => node
          | NONE => raise Fail "Not in a node context"
      
      fun currentNodeOpt () =
         !current
      
      fun runInContext (node, f : unit -> unit) =
         (current := node (* TODO check for Node.current==NONE? *)
         ; f ()
         ; current := NONE)
      
      (* adds a function to be invoked on cleanup *)
      fun addCleanupFunction (T { cleanupFunctions, ... }, cleanupFn) =
         let
            val el = Ring.wrap cleanupFn
            val () = Ring.add (cleanupFunctions, el)
         in
            el
         end
      
      type cleanupFnRef = (unit -> unit) Ring.element
      
      (* removes a previously registered cleanup function *)
      fun removeCleanupFunction cleanupEl =
         Ring.remove cleanupEl
      
      (* runs all registered cleanup funcrtions *)
      fun cleanup (T { cleanupFunctions, ... }) =
         let
            open Iterator
            val it = (fromList o toList o Ring.iterator) cleanupFunctions
         in
            app (fn elem => (Ring.unwrap elem) ()) it
         end
      
      fun start (appContext, id, appMain, appName, args) =
         let
(*             val () = print ("Start app " ^ name ^ " " ^ (List.hd args) ^ "\n") *)
            val n =
               T {
                  context = appContext,
                  id = id,
                  appName = appName,
                  args = args,
                  printBuffer = ref nil,
                  cleanupFunctions = Ring.new ()
               }
            val () = current := SOME n
            val nodeHandle = IdBucket.alloc (nodeBucket, n)
            val () = appMain ()
         in
            nodeHandle
         end
      
      fun stop nodeHandle =
         case IdBucket.sub (nodeBucket, nodeHandle) of
            SOME node => (runInContext (SOME node, fn () => cleanup node); true)
          | NONE => false
      
   end
