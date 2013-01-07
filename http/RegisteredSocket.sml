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


fun log (severity, msg) = Log.logExt (severity, fn () => "http", msg)

structure RegisteredSocket = struct
   type ('af, 'socktype) t = {
      sock: ('af, 'socktype) Socket.sock,
      unregisterRead: (unit -> bool) ref,
      unregisterWrite: (unit -> bool) ref
   }

   fun fromSock (sock : ('a, 'b) Socket.sock) =
      { sock = sock, unregisterRead = ref (fn _ => true), unregisterWrite = ref (fn _ => true) }

   fun sock { sock, unregisterRead, unregisterWrite } = sock

   fun desc { sock, unregisterRead, unregisterWrite } = Socket.sockDesc sock

   fun fdStr { sock, unregisterRead, unregisterWrite } =
      (SysWord.toString o Posix.FileSys.fdToWord o valOf o Posix.FileSys.iodToFD o Socket.ioDesc) sock

   fun fdStr2 sock  =
      (SysWord.toString o Posix.FileSys.fdToWord o valOf o Posix.FileSys.iodToFD o Socket.ioDesc) sock

   fun registerForRead ({ sock, unregisterRead, unregisterWrite }, read) =
      unregisterRead := Main.registerSocketForRead (Socket.sockDesc sock, read)

   fun registerForWrite ({ sock, unregisterRead, unregisterWrite }, write) =
      unregisterWrite := Main.registerSocketForWrite (Socket.sockDesc sock, write)

   fun shutdown { sock : ('a, 'b) Socket.sock, unregisterRead, unregisterWrite } = (
      log (LogLevels.DEBUG, fn () => "closing socket fd=" ^ fdStr2 sock);
      ignore (!unregisterRead ());
      ignore (!unregisterWrite ());
      Socket.close sock
   )
end
