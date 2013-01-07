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

(* buffers a message in the given buffer until a linefeed #"\n" is
   encountered. Then calls the given writer function with the message
   up until the linefeed (not including it). Everything after the 
   last linefeed is buffered in the buffer. *) 
fun printBuffered (
      buf : string list ref, 
      writer : string -> unit,
      msg : string
   ) =
   let
      fun output (msg, pos) = 
         let
            (* write up to newline *)
            val old = String.concat (List.rev (!buf))
	         val () = buf := nil
            val () = writer (old ^ Substring.string (Substring.substring (msg, 0, pos)))
         in
            if String.size msg <= pos 
               then ()
            (* repeat after newline *)
            else printBuffered (buf, writer, Substring.string (Substring.extract (msg, pos+1, NONE)))
        end 
   in
      case CharVector.findi (fn (_, x) => x = #"\n") msg of
         (* buffer it *)
         NONE => buf := msg :: (!buf)
         (* write up to newline recursively *) 
       | SOME (pos, _) => output (msg, pos)
   end
