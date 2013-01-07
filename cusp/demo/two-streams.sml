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

open CUSP

fun handler exn =
   Log.log (Log.WARNING, "cusp/demo/two-streams", fn () => General.exnMessage exn)

val zeros = Word8Vector.tabulate (32768, fn _ => 0w0)

fun send stream =
    let
       fun next OutStream.READY = OutStream.write (stream, zeros, next)
         | next OutStream.RESET = print "Reset??\n"
    in
       OutStream.write (stream, zeros, next)
    end

fun ok NONE = print "Failed to connect\n"
  | ok (SOME (h, stream)) =
    let
       val () = print "Connected!\n"
       (* second stream starts in 20 seconds from now *)
       val evt = Main.Event.new (fn _ => send (Host.connect (h, 0w23)))
       val _ = Main.Event.scheduleIn (evt, Time.fromSeconds 20)
    in
       (* first stream starts immediately *)
       send stream
    end

fun main () =
   let
      val host = 
         case Address.fromString (hd (CommandLine.arguments ())) of
            [x] => x
          | _ => (print "Couldn't resolve target name!\n"; raise Option)
      
      val t = 
         EndPoint.new { 
            port    = NONE, 
            key     = Crypto.PrivateKey.new { entropy = Entropy.get },
            handler = handler,
            entropy = Entropy.get,
            options = NONE }
      
      val () = print ("Contacting " ^ Address.toString host ^ "...\n")
      val _ = EndPoint.contact (t, host, 0w23, ok)
   in
      ()
   end

val () = Main.run ("two-streams", main)
