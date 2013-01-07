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

signature MAIN =
   sig
      structure Event : EVENT
      
      (* Run a main event loop that processes sockets and events.
       * Takes the name and main function of the application. The main 
       * function will be executed by run to start the application.
       *)
      val run : string * (unit -> unit) -> unit
      
      (* Stop the run function soon.
       * Does NOT promise to stop after the current event.
       * Does promise to stop before the run function would sleep again.
       *)
      val stop : unit -> unit
      
      (* Callback methods can unhook themselves for convenience *)
      datatype rehook = UNHOOK | REHOOK
      
      (* Hook a signal handler to be run on delivery of a signal.
       * 
       * After the unhook is called, the signal handler is restored.
       * If this is the first unhook, then true is returned, else false.
       *)
      val signal : Posix.Signal.signal * (unit -> rehook) -> (unit -> bool) 
      
   end

 signature MAIN_EXTRA =
   sig
      include MAIN

      (* Returns true if running (i.e. in the event loop of the run() function),
       * false otherwise
       *)
      val isRunning : unit -> bool
      
      (* Run the event loop only long enough to catch up to real-time *)
      val poll : unit -> unit
      
      (* Register a socket to be polled, returning an unhook function.
       * Promises to call the callback only if the socket is read/write ready.
       * Promises not to sleep until the callback has been called.
       *
       * After the unhook function is called, poll callback will never be run.
       * If this is the first unhook, then true is returned, else false.
       *)
      val registerSocketForRead  : Socket.sock_desc * (unit -> rehook) -> (unit -> bool)
      val registerSocketForWrite : Socket.sock_desc * (unit -> rehook) -> (unit -> bool)
   end
