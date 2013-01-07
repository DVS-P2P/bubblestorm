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

(* Like StdoutWriter, but including node ID and log level *)
structure StdoutNodeWriter :> LOG_WRITER =
   struct
      fun init () = ()
   
      fun idToString id =
         case id of
            NONE => "Global"
          | SOME x => Int.toString x
      
      fun write { time, node, address=_, level, module, message } =
         let
            fun toString () =
               Time.toString time ^ " " ^ 
               module ^ " " ^ 
               (idToString node)  ^ " " ^ 
               LogLevels.toString level ^ " " ^
               message ^ "\n"            
         in
            case level of
               LogLevels.ERROR => TextIO.output (TextIO.stdErr, toString ())
             | LogLevels.WARNING => TextIO.output (TextIO.stdErr, toString ())
             | _ => print (toString ())
         end
   end
