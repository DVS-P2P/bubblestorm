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

local
   val seed =
      case ConfigCommandLine.seed () of
         SOME x => x
       | NONE =>
            let
               val x = Entropy.get 4
               val { fromVector, ... } = Serial.methods Serial.word32l
            in
               fromVector x
            end
   val random = MersenneTwister.new seed
in
   fun getTopLevelRandom () = random
end

(* (* old hand-made entropy *)
val random = 
   let
      val now = Time.now ()
      val now = Time.- (now, Time.fromSeconds (Time.toSeconds now))
      val x1 = Word32.fromInt (LargeInt.toInt (Time.toNanoseconds now))
      val pid = Word32.fromLarge o SysWord.toLarge o Posix.Process.pidToWord 
                o Posix.ProcEnv.getpid
      val x2 = pid ()
      val seed = Word32.orb (x1, 0w1) * x2
   in
      MersenneTwister.new seed
   end
*)