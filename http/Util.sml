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


structure Util = struct
   (* Split string str on delimiter string delim. Return at most limit tokens. *)
   fun splitString (delim, str, limit) =
      let
         val () = if (getOpt(limit, 2) < 2) then raise Fail("invalid limit") else ()
         val tmp = Substring.position delim (Substring.full str)
         val prefix = Substring.string (#1 tmp)
         (* Substring.slice thinks it needs to throw exceptions when asked
          * to produce an empty string, so handle that case separately *)
         val suffix = if (Substring.size (#2 tmp) - String.size delim > 0)
            then Substring.string (Substring.slice ((#2 tmp), String.size delim, NONE))
            else Substring.string (#2 tmp)

         (*val () = print ("#1: " ^ Substring.string (#1 tmp) ^ " #2: " ^ Substring.string (#2 tmp) ^ "\n")*)
         (*val () = print ("delim: " ^ delim ^ " str: " ^ str ^ "\n")*)
         (*val () = print ("prefix: " ^ prefix ^ " suffix: " ^ suffix ^ "\n")*)
      in
         if (suffix = "")
            then [prefix]
         else if (getOpt(limit, 0) = 2)
            then [prefix, suffix]
         else
            prefix :: splitString (delim, suffix, case limit of SOME(x) => SOME(x - 1) | NONE => NONE)
      end

   fun escapeSpecialChar #"\a" = "\\a"
     | escapeSpecialChar #"\b" = "\\b"
     | escapeSpecialChar #"\f" = "\\f"
     | escapeSpecialChar #"\n" = "\\n"
     | escapeSpecialChar #"\r" = "\\r"
     | escapeSpecialChar #"\t" = "\\t"
     | escapeSpecialChar #"\v" = "\\v"
     | escapeSpecialChar #"\\" = "\\"
     | escapeSpecialChar c = String.str c

   fun escapeSpecialChars str = String.translate escapeSpecialChar str
   fun escapeSpecialCharsSub str = Substring.translate escapeSpecialChar str
end
