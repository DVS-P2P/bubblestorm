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

functor Log (structure Event : EVENT
             structure Writer : LOG_WRITER
             val node : unit -> int option
             val address : unit -> string
             val printBuffer : unit -> string list ref)
   :> LOG =
   struct
      datatype severity = datatype LogLevels.severity
      
      val filters = ref [ ("", LogLevels.toInt STDOUT) ]
      
      fun removeFilter prefix =
         let
            fun keep (pre, _) = not (prefix = pre)
         in
            filters := List.filter keep (!filters)
         end
      
      fun addFilter (prefix, level) =
         let
            val () = removeFilter prefix
         in
            filters := List.rev ((prefix, LogLevels.toInt level) :: (!filters))
         end
         
      fun logExt (level, module, msg) =
         let
            val intLevel = LogLevels.toInt level
            fun filter (pre, lvl) = 
               intLevel >= lvl andalso String.isPrefix pre (module ())
         in
            if List.exists filter (!filters)
               then Writer.write {
                       time = Event.time (), 
                       node = node (),
                       address = address (),
                       level = level,
                       module = module (), 
                       message = msg ()
                    }
            else ()
         end

      fun log (level, module, msg) = logExt (level, fn () => module, msg)

      fun print msg = printBuffered (printBuffer (),
         fn msg => logExt (STDOUT, fn () => "console", fn () => msg), msg)
   end
