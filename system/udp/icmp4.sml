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

structure ICMP4 : ICMP =
   struct
      type address = INetSock.sock_addr
      
      type t = { 
         close : unit -> unit,
         recv  : Word8ArraySlice.slice -> {
                    UDPto    : address,
                    reporter : address,
                    code     : Word16.word,
                    data     : Word8ArraySlice.slice
                 } option,
         send  : {
                    UDPto   : address,
                    UDPfrom : address,
                    code    : Word16.word,
                    data    : Word8ArraySlice.slice
                 } -> unit
      }
      
      fun close ({ close, ... } : t) = close ()
      fun recv ({ recv, ... } : t, args) = recv args
      fun send ({ send, ... } : t, args) = send args
      
      (* Sending/receiving ICMP is problematic for two reasons:
       * 1. It's not portable and we need to use low-level C system APIs
       * 2. On many platforms it requires super-user priveledges.
       * 
       * The best solution (if possible) is access ICMP via direct C FFI.
       * This is possible if users can do SOCK_RAW or the OS provides another
       * way to access related ICMP (linux IP_RECVERR for example).
       * 
       * If ICMP send/recv requires super-user access, we need a helper tool.
       * The setuid method spawns child processes to gain the needed access.
       * 
       * However, not all systems support setuid (windows). 
       * Then we proxy over a daemon loaded with the required priveledges.
       *)
      datatype method = DAEMON | SETUID | FFI | NULL
      datatype z = datatype MLton.Platform.OS.t
      
      val methods =
         case MLton.Platform.OS.host of
            AIX     => (SETUID, SETUID)
          | Cygwin  => (DAEMON, DAEMON)
          | Darwin  => (SETUID, SETUID)
          | FreeBSD => (SETUID, SETUID)
          | HPUX    => (SETUID, SETUID)
          | Hurd    => (SETUID, SETUID)
          | Linux   => (FFI,    SETUID)
          | MinGW   => (DAEMON, DAEMON)
          | NetBSD  => (SETUID, SETUID)
          | OpenBSD => (SETUID, SETUID)
          | Solaris => (SETUID, SETUID)
      
      fun pure new = 
         let
            val { close, newR, newS } = new
            val { closeR, recv } = newR ()
            val { closeS, send } = newS ()
         in
            { send  = send,
              recv  = recv,
              close = close o closeR o closeS
            }
         end
      
      fun mixed (newR, newS) = 
         let
            val { close=closeR', newR, newS=_ } = newR
            val { close=closeS', newR=_, newS } = newS
            val { closeR, recv } = newR ()
            val { closeS, send } = newS ()
         in
            { send  = send,
              recv  = recv,
              close = closeR' o closeS' o closeR o closeS
            }
         end
      
      fun get x = fn
         DAEMON => (ICMP4Daemon.new x
                    handle _ => (print "Unable to use ICMP daemon, ICMP support disabled.\n" (* FIXME cannot use Log here... *)
                    ;ICMP4Null.new x))
       | SETUID => (ICMP4SetUID.new x
                    handle _ => (print "Unable to use ICMP helper, ICMP support disabled.\n" (* FIXME cannot use Log here... *)
                    ;ICMP4Null.new x))
       | FFI    => ICMP4FFI.new x
       | NULL   => ICMP4Null.new x
      
      fun new x =
         case methods of
            (DAEMON, DAEMON) => pure  (get x DAEMON)
          | (SETUID, SETUID) => pure  (get x SETUID)
          | (FFI,    FFI)    => pure  (get x FFI)
          | (r,      s)      => mixed (get x r, get x s)
   end
