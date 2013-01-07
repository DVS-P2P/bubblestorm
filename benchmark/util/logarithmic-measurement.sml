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

structure LogarithmicMeasurement =
   struct
      (* base = lifetime^(1/steps) *)
      fun getBase (lifetime, steps) =
         Real32.Math.pow (Time.toSecondsReal32 lifetime, 1.0 / (Real32.fromInt (steps-1)))

      (* base^x + cooldown *)
      fun calc (base, cooldown) step = Time.+ (
         Time.fromSecondsReal32 (Real32.Math.pow (base, Real32.fromInt step) - 1.0),
         cooldown
      )
   end
