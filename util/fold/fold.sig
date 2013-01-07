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

signature FOLD =
   sig
      type ('a0, 'az, 'r) t
      type ('a0, 'ay, 'az, 'r) fold
      type ('a0, 'a1, 'ay, 'az, 'r) step0
      type ('b, 'a0, 'a1, 'ay, 'az, 'r) step1
      type ('b, 'c, 'a0, 'a1, 'ay, 'az, 'r) step2
      
      val fold : ('a0, 'ay, 'az) t -> ('a0, 'ay, 'az, 'r) fold
      val post : ('a0, 'ax, 'ay, 'r) fold * ('ay -> 'az) -> ('a0, 'ax, 'az, 'r) fold
      val step0 : ('a0 -> 'a1) -> ('a0, 'a1, 'ay, 'az, 'r) step0
      val step1 : ('b * 'a0 -> 'a1) -> ('b, 'a0, 'a1, 'ay, 'az, 'r) step1
      val step2 : ('b * 'c * 'a0 -> 'a1) -> ('b, 'c, 'a0, 'a1, 'ay, 'az, 'r) step2
   end

signature FOLDR =
   sig
      type ('a0, 'az, 'r) t
      type ('a0, 'ay, 'az, 'r) fold
      type ('a0, 'ax, 'ay, 'az, 'r) step0
      type ('b, 'ax, 'ay, 'a0, 'az, 'r) step1
      type ('b, 'c, 'ax, 'ay, 'a0, 'az, 'r) step2
      
      val fold : ('a0, 'ay, 'az) t -> ('a0, 'ay, 'az, 'r) fold
      val post : ('a0, 'ax, 'ay, 'r) fold * ('ay -> 'az) -> ('a0, 'ax, 'az, 'r) fold
      val step0 : ('ax -> 'ay) -> ('ax, 'ay, 'a0, 'az, 'r) step0
      val step1 : ('b * 'ax -> 'ay) -> ('b, 'ax, 'ay, 'a0, 'az, 'r) step1
      val step2 : ('b * 'c * 'ax -> 'ay) -> ('b, 'c, 'ax, 'ay, 'a0, 'az, 'r) step2
   end
