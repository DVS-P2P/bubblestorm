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

(* Want to minimize:
 *  a*x + b*y
 * with the constraint:
 *  (1 - exp(-x*wm)) * (1 - exp(-y*wm)) >= 1 - exp(-l*wm*wm/Sw2)
 *
 * First step, pull the coefficients -1/D2 out of 
 * the constraints and into the goal function.
 *              
 * (1 - exp(-x*wm)) * (1 - exp(-y*wm))
 * >= (1 - exp(j)) * (1 - exp(k))          j >= -x*wm
 * >= (-n) * (-m)                          exp(j)-1 <= n
 * >= p * q                                -n >= p
 * >= exp(a) * exp(b)                      p >= exp(a)
 * >= exp(log(RHS))                        a+b >= lRHS
 * = RHS
 * = 1 - exp(-l*wm*wm*T)
 *)
structure Balancer : BALANCER =
   struct   
      fun module () = "bubblestorm/bubble/basic/balancer"

      (* find the maximum lambda used *)
      fun maxLambda bubbles =
         let
            open BasicBubbleType
            fun getLambda (MATCH {lambda, ...}) = lambda
            fun bubbleLambda typ =
               Iterator.fromList (List.map getLambda (matches typ))
            val lambdas = Iterator.concat (Iterator.map bubbleLambda bubbles)
         in
            Iterator.fold Real64.max 1.0 lambdas
         end
         
      structure VariableTable = HashTable
      (
         struct
            type t = BasicBubbleType.t
            fun == (a, b) = BasicBubbleType.typeId a = BasicBubbleType.typeId b
            fun hash x = Hash.int (BasicBubbleType.typeId x)
         end
      )
      
      (* create an optimizer variable for each bubble type and store them in a 
         hash table so we can find them by their type *)
      fun createVariables bubbles =
         let
            val table = VariableTable.new ()            
            fun createVar typ =
               VariableTable.add (table, typ, Constraint.newVariable ())
            val () = Iterator.app createVar bubbles
         in
            table
         end
         
      (* sort bubble types into maximum bubble types and normal bubble types. 
         maximum types have different constraints.
         maximum constraints depend on the intersection constraints
         (the initial size of a max bubble depends on the initial size of
         the bubbles it is constrained by). Thus we have to set up the
         intersection constraints before the maximum constraints. *)
      fun partitionTypes bubbles =
         let
            fun isMaximum typ =
               case BasicBubbleType.class typ of
                  BasicBubbleType.MAXIMUM _ => true
                | _ => false

            val { true=maximum, false=normal } =
               Iterator.partition isMaximum bubbles
         in
            { normal=normal, maximum=maximum }
         end

      fun getVariable varTable typ =
         case VariableTable.get (varTable, typ) of
            SOME var => var
          | NONE => raise At (module (), Fail "could not find variable")
      
      exception BalancerVarNotInitialized
      
      (* every variable needs an initial value *)
      val { get=getInitial, set=setInitial, remove=_ } =
         Property.getSet (Constraint.plist, 
            Property.initRaise (At (module (), BalancerVarNotInitialized)))
      
      (* store the global cost of a bubble in a property of its balancer 
         variable *)
      val {get=getCost, set=setCost, remove=_} =
         Property.getSetOnce (Constraint.plist, Property.initConst 0.0)

      (* read the cost from the bubble cost measurement and store it 
         in a property of the balancer variable *)
      fun setCosts measurement (bubble, variable) =
         let
            val bubbleCost = BasicBubbleType.costMeasurement bubble
            val cost = BubbleCostMeasurement.get (bubbleCost, measurement)
            (* cost has to be > 0 *)
            val cost = Real64.max (cost, 1.0)
            (* Show the input to the optimizer *)
            val () = Log.logExt (Log.DEBUG, module,
                     fn () => "Bubble " ^ BasicBubbleType.toString bubble ^ 
                              " cost = " ^ Real64.toString cost)
         in
            setCost (variable, cost)
         end
    
      (* set the minimum constraints for bubbles with a "constant" minimum size *)
      fun setMinimums constraints (bubble, variable) =
         let
            val min = BasicBubbleType.computeMinimum bubble
            open Constraint
            val () = constraints := (* x + -min >= 0 *)
               SUM  { a = 1.0, x = SOME variable, b = ~min, y = NONE, 
                      c = 0.0, z = NONE } :: !constraints
         in
            setInitial (variable, min * 2.0)
         end
         
      (* we use temporary variables to represent the match constraints in a form
       * the optimizer can handle them. The temporary variables form a 
       * chain of constraints and the last temporary variable is stored 
       * in a property of the bubble. That way, the temporary variables 
       * are created only once and only for bubble types that actually 
       * intersect other types.
       *)
      fun setupTempVar (constraints, wm, maxLogRHS) balancerVar =
         let
            open Constraint
            val j = newVariable ()
            val n = newVariable ()
            val p = newVariable ()
            val a = newVariable ()                  

            val () = constraints :=
               (* x*wm >= -j    *) SUM  { a = wm, x = SOME balancerVar, b = 0.0, 
                                          y = NONE, c = 1.0, z = SOME j } ::
               (* n >= exp(j)-1 *) EXP1 { x = n, y = j } ::
               (* -n >= p       *) SUM  { a = 0.0, x = NONE, b = ~1.0,
                                          y = SOME n, c = ~1.0, z = SOME p } ::
               (* p >= exp(a)   *) EXP  { x = p, y = a } ::
                                    !constraints
            
            (* set initial values *)
            val set = setInitial
            val get = getInitial
            (* a<0    a >= lRHS/2   *) val () = set (a, maxLogRHS/4.0)
            (* 0<p<1  p >= exp(a)   *) val () = set (p, (1.0 + Real64.Math.exp (get a)) / 2.0)
            (* -1<n<0 -n >= p       *) val () = set (n, ~ (1.0 + get p) / 2.0)
            (* j<0    n >= exp(j)-1 *) val () = set (j, 2.0 * Real64.Math.ln (get n + 1.0))
            (* x>0    x >= -j/wm    *) val initial = 2.0 * ~(get j) / wm
            (* balancerVar already has an initial value from min constraint *)
            val () = set (balancerVar, Real64.max (get balancerVar, initial))
         in
            a
         end

      (* convert all match constraints from the bubble types to optimizer 
         constraints *)
      fun matchConstraints (bubbles, getTempVar, wm, Sw2) =
         let
            fun convertConstraint bubble 
               (BasicBubbleType.MATCH { object, lambda, ... }) =
               let
                  open Constraint
                  val tempA  = getTempVar bubble
                  val tempB  = getTempVar object
                  val RHS    = ~ (Exp1.f (~lambda * wm * wm / Sw2))
                  val logRHS = Real64.Math.ln RHS
               in
                  (* a + b >= lambda  *) 
                  SUM { a = 1.0, x = SOME tempA, b = 1.0, 
                        y = SOME tempB, c = ~logRHS, z = NONE }
               end            

            fun convertBubble bubble =
               List.map (convertConstraint bubble) (BasicBubbleType.matches bubble)
         in
            (List.concat o Iterator.toList o (Iterator.map convertBubble)) bubbles
         end
      
      (* create constraints for maximum bubbles and set their initial size *)
      fun maximumConstraints (varTable, bubbles) =
         let
            fun convertConstraint maxVar otherVar =
               (* a - b >= 0 *)
               Constraint.SUM { a = 1.0, x = SOME maxVar, b = ~1.0, 
                                 y = SOME otherVar, c = 0.0, z = NONE  }
            
            (* a maximum bubble type must have a larger initial size than 
               all the bubble types it is a maximum of *)
            fun setMaximumInitial (maxVar, otherVars) =
               let
                  fun maxValue (var, cur) = Real64.max (getInitial var, cur)
                  val maxValue = List.foldl maxValue 1.0 otherVars
               in
                  setInitial (maxVar, maxValue * 2.0)
               end
                                          
            fun convertBubble bubble =
               case BasicBubbleType.class bubble of
                  BasicBubbleType.MAXIMUM { withBubbles, ... } =>
                     let
                        val var = getVariable varTable bubble
                        val others = List.map (getVariable varTable) (!withBubbles)
                        val () = setMaximumInitial (var, others)
                     in               
                        List.map (convertConstraint var) others
                     end
                  | _ => raise At (module (), Fail "non-maximum bubble in maximum list")
         in
            (List.concat o Iterator.toList o (Iterator.map convertBubble)) bubbles
         end
         
      (* update bubble sizes. if no constraints exist for a bubble type,
         * there is no solution (domain exception). thus, we set the bubble 
         * size to the minimum of 0. *)
      fun updateBubbleSizes solution (bubble, variable) =
         let
            val result = solution variable
               handle Optimizer.UnusedVariable => 0.0 (* bubble type is unconstrained *)
         in
            BasicBubbleType.setNewSize (bubble, result)
         end

      (*
      - set up balancer variables
      - partition out maximum bubbles
      - set up temporary variables
      - set up initial values
      - set up cost
      - set up constraints for intersection
      - set up constraints for maximums
      - Optimizer.solve
      - update bubble sizes
      *)
      fun solve state (_, _, measurement) =
         let
            val bubbles =
               (Iterator.map #2 o IDHashTable.iterator o BasicBubbleType.bubbletypes) state
            val sysStats = BasicBubbleType.stats state

            (* the network stats *)
            val d1 = SystemStats.d1 sysStats
            val d2 = SystemStats.d2 sysStats
            val dm = SystemStats.dMax sysStats
            
            (* some derived stats *)
            val wm = dm / d1
            val Sw2 = d2/(d1*d1) (* sum_u w_u^2 *)
            val maxLambda = maxLambda bubbles
            val maxRHS    = ~ (Exp1.f (~maxLambda * wm * wm / Sw2))
            val maxLogRHS = Real64.Math.ln maxRHS
            
            (*
            val () = Log.logExt (Log.DEBUG, module, fn () => "d1 = " ^ (Real64.toString d1))
            val () = Log.logExt (Log.DEBUG, module, fn () => "d2 = " ^ (Real64.toString d2))
            val () = Log.logExt (Log.DEBUG, module, fn () => "dm = " ^ (Real64.toString dm))
            val () = Log.logExt (Log.DEBUG, module, fn () => "wm = " ^ (Real64.toString wm))
            val () = Log.logExt (Log.DEBUG, module, fn () => "Sw2 = " ^ (Real64.toString Sw2))
            val () = Log.logExt (Log.DEBUG, module, fn () => "maxLambda = " ^ (Real64.toString maxLambda))
            val () = Log.logExt (Log.DEBUG, module, fn () => "maxRHS = " ^ (Real64.toString maxRHS))
            val () = Log.logExt (Log.DEBUG, module, fn () => "maxLogRHS = " ^ (Real64.toString maxLogRHS))
            *)
            
            (* the list of constraints for the optimizer *)
            val constraints = ref []
            
            (* create variables & set costs *)
            val varTable = createVariables bubbles
            val { normal, maximum } = partitionTypes bubbles
            val () = Iterator.app (setCosts measurement) (VariableTable.iterator varTable)
            
            (* set constant minimum sizes *)
            val () = Iterator.app (setMinimums constraints) (VariableTable.iterator varTable)
            
            (* property to store temporary variables in a variable *)
            local
               val {get, remove=_} = Property.get (Constraint.plist, 
                  Property.initFun (setupTempVar (constraints, wm, maxLogRHS))
               )
            in
               fun getTempVar typ =
                  case VariableTable.get (varTable, typ) of
                     SOME var => get var
                   | NONE => raise At (module (), Fail "could not find temporary variable")
            end
            
            (* set up constraints for matching bubbles *) 
            val matches = matchConstraints (normal, getTempVar, wm, Sw2)
            val () = constraints := (!constraints) @ matches
            
            (* set up constraints for maximum bubbles *)
            val maximums = maximumConstraints (varTable, maximum)
            val () = constraints := (!constraints) @ maximums

            (*
            fun printInitial (typ, var) =
               Log.logExt (Log.DEBUG, module, fn () =>
                  "Bubble " ^ (BasicBubbleType.toString typ) ^ 
                  " initial size = " ^ (Real64.toString (getInitial var)))
               handle _ =>
                  Log.logExt (Log.DEBUG, module, fn () =>
                     "Bubble " ^ (BasicBubbleType.toString typ) ^ 
                     " initial size = not set")
      
            val () = Log.logExt (Log.DEBUG, module, fn () => "-----------------")            
            val () = Iterator.app printInitial (VariableTable.iterator varTable)
            val () = Log.logExt (Log.DEBUG, module, fn () => "-----------------")            
            *)
            
            (* solve the problem *)
            val (solution, _) =
               Optimizer.solve {
                  constraints = Iterator.fromList (!constraints),
                  costs       = getCost,
                  interior    = (getInitial, fn () => ()),
                  bound       = NONE
               }
         in
            (* set the new bubble sizes *)
            Iterator.app (updateBubbleSizes solution) (VariableTable.iterator varTable)
         end

      fun init state =
         let
            val measurement = BasicBubbleType.measurement state
         in
            (* set a notification to run the balancer every time a new 
               measurement result has arrived *)
            Measurement.addNotification (measurement, solve state)
         end
   end
