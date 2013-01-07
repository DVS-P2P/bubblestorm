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

signature OPTIMIZER =
   sig
      exception InfeasibleStart
      exception EmptyInterior
      exception UnusedVariable
      
      type map = Constraint.var -> Real64.real
      type solution = map * (unit -> unit)
      
      (* Solve the optimization problem:
       *   min (sum_v cost_v * v)
       *   subject to <constraints>
       *          and |x_v| <= bound, for all v
       *
       * Labels and interior are computed from the helper methods below.
       * If a bad interior is specified, InfeasibleStart is raised.
       *)
      val solve : {
         constraints : Constraint.t Iterator.t,
         costs       : map,
         interior    : solution,
         bound       : Real64.real option
      } -> solution
      
      (* Find an feasible start.
       * Raises EmptyInterior if the constraints can not be satisified.
       *)
      val interior : {
        constraints : Constraint.t Iterator.t,
        bound       : Real64.real
      } -> solution
   end
