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

(* Process command-line arguments:
 *   @config --seed 42 --database data/log.db --logInterval 1 --filter 2:cusp --
 *
 *   -filter level:path
 *   for example "--filter 2:cusp" enables cusp messages at level STDOUT or higher
 *)
signature CONFIG_COMMAND_LINE =
   sig
      include COMMAND_LINE
      datatype logMode = STDOUT | SQLITE of SQL.db
      val logDatabase  : unit -> logMode
      val logInterval  : unit -> Time.t option
      val logFilters   : unit -> (string * LogLevels.severity) list
      val seed         : unit -> Word32.word option
      val experimentID : unit -> int
      val nodeID       : unit -> int option
      val nodeAddress  : unit -> string
   end
