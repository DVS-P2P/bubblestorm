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

(* Simulator main code for BS Demo *)

(* fake transport_open and transport_close for C++ bindings *)
fun nothing () = ()
val () = _export "bubblestorm_open" : (unit -> unit) -> unit; nothing
val () = _export "bubblestorm_close" : (unit -> unit) -> unit; nothing

open CUSP

(* call C++ node start code *)
fun main () =
	let
		val startNode = _import "startNode" : string * int -> unit;
		val bootstrapAddr = case CommandLine.arguments () of
			["bootstrap"] => ""
			| ["join", addr] => Address.toString (valOf (Address.fromString addr))
			| ["join"] => Address.toString (HostCache.get (HostCache.new (0, 0)))
			| _ => raise At ("bs-sim/main", Fail ("Invalid command line"))
(* 		val () = Log.log(Log.INFO, "starting node " ^ peer) *)
	in
		startNode (bootstrapAddr, String.size bootstrapAddr)
	end

(* global startup *)
val startGlobal = _import "startGlobal" : unit -> unit;
val () = startGlobal ()

(* run *)
val () = GlobalLog.print "Running simulator.\n"
val () = Main.run ("bs-sim", main)
