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

structure Arguments :> ARGUMENTS =
   struct
      val module = "simulator/arguments"
            
      datatype arg = IP | PORT | GROUP of string | TEXT of string
      
      datatype t = T of {
         cmd : arg list,
         args : arg list list
      }
      
      exception AliasNotFound of string
      
      local
         open General
         fun fmt (AliasNotFound s) = SOME (concat [ "group name \"",s,"\" unknown" ])
           | fmt _ = NONE
      in
         val () = MLton.Exn.addExnMessager fmt
      end
      
      val toLower = String.map Char.toLower
      
      (* the global map for the group alias -> IP list directory *)
      structure StringKey : HASH_KEY = struct
         type t = string
         val hash = Hash.string
         val op == = op =
      end
      structure AliasTable = HashTable(StringKey)
      val aliases = AliasTable.new ()

      fun registerGroup (name, addresses) =
         let
            fun toString (addr, result) = result ^ Address.Ip.toString addr ^ ","
            val addrString = List.foldl toString "" addresses
            (*val () = print (toLower name ^ " = " ^ addrString ^ "\n")*)
         in         
            AliasTable.add (aliases, toLower name, addrString)
            handle AliasTable.KeyExists =>
               raise At (module, Fail ("Duplicate group name \"" ^ toLower name ^ "\""))
         end
               
      fun getAlias name =
         case AliasTable.get (aliases, name) of
            SOME x => x
          | NONE => raise At (module, AliasNotFound name)
            
      fun toString (ip, port, T { cmd, args } ) = 
         let
            fun argToString (IP, x) = x ^ Address.Ip.toString ip
              | argToString (PORT, x) = x ^ Word16.fmt StringCvt.DEC port
              | argToString (GROUP group, x) = x  ^ (getAlias group)
              | argToString (TEXT text, x) = x ^ text
            val ArgToString = List.foldl argToString ""
            val ArgListToString = List.map ArgToString
         in
            (ArgToString cmd, ArgListToString args)
         end
      
      fun isPrefix (test, (text, pos)) =
         String.isPrefix (toLower test) (toLower (String.extract (text, pos, NONE)))
      
      fun parseVar (text, pos) =
         case String.sub (text, pos) of
            #"[" =>
               let
                  val remainder = String.extract (text, pos+1, NONE)
                  val name = case String.fields (fn c => c = #"]") remainder of
                     x :: _ => toLower x
                   | nil => raise At (module, Fail ("Empty group name in command \"" ^ text ^ "\""))
                  val len = String.size name + 2
               in
                  (GROUP name, pos+len)
               end
          | _ =>
            if isPrefix ("ip", (text, pos)) then (IP, pos+2)
            else if isPrefix ("port", (text, pos)) then (PORT, pos+4)
            else raise At (module, Fail ("Unknown variable in command \"" ^ text ^ "\""))

      fun makeText chars = TEXT (CharVector.fromList (List.rev chars))
      
      fun parseText chars (text, pos) =
         (case String.sub (text, pos) of
            (* remove backslash escape sequence *)
            #"\\" => (parseText (String.sub (text, pos) :: chars) (text, pos+2)
            handle Subscript =>
               raise At (module, Fail ("Command \"" ^ text ^ "\" ends with \\")))
            (* found whitespace, return *)
          | #" "  => (makeText chars, pos)
          | #"$"  => (makeText chars, pos)
          | #"\"" => (makeText chars, pos)
            (* read another ordinary character *)
          | x => parseText (x::chars) (text, pos+1)
         (* reached the end of the argument string? *)
         ) handle Subscript => (makeText chars, pos)
      val parseText = parseText nil

      fun parseArg (text, pos, result, quoted) =
         let
            fun addElem  (elem, pos)  = (text, pos, elem :: result, quoted)
            fun addElems (elems, pos) = (text, pos, elems @ result, quoted)
            (* Debug output
            fun toString IP = "IP "
              | toString PORT = "PORT"
              | toString (GROUP x) = "GROUP [" ^ x  ^ "]"
              | toString (TEXT x) = x
            fun toString1 x = (toString x) ^ "\n"
            fun toStringN x = (List.foldr (fn (a, b) => b ^ toString a ^ " ") "" x) ^ "\n"
            fun addElem  (elem, pos)  = (print (Int.toString pos ^ "  " ^ toString1 elem) ; (text, pos, elem :: result, quoted))
            fun addElems (elems, pos) = (print (Int.toString pos ^ "  " ^ toStringN elems) ; (text, pos, elems @ result, quoted))
            *)
         in
            case String.sub (text, pos) of
               #" "  => 
                  if result = nil orelse quoted
                     then parseArg (text, pos+1, result, quoted) (* ignore *)
                     else (List.rev result, pos+1) (* delimiter *)
             | #"\"" =>
                  if quoted 
                     (* exit quoted mode *)
                     then (List.rev result, pos+1)
                     (* enter quoted mode *)
                     else parseArg (addElems (parseArg (text, pos+1, nil, true)))
             | #"$"  => parseArg (addElem (parseVar (text, pos+1)))
             | _     => parseArg (addElem (parseText (text, pos)))
         end
         handle Subscript => (List.rev result, pos)
      val parseArg = fn (text, pos) => parseArg (text, pos, nil, false)
      
      fun parse (args, pos) text =
         if pos >= String.size text then List.rev args
         else case parseArg (text, pos) of (arg, pos) => parse (arg :: args, pos) text
      val parse = parse (nil, 0)
      
      fun fromString text =
         case parse text of
            cmd :: args => T { cmd = cmd, args = args }
          | nil => raise At (module, Fail ("Unparseable command '" ^ text ^ "'"))
   end
