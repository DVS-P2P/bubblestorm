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

structure Element =
   struct
      type t = Real.real
      val zero = Real.fromInt 0
      val one = Real.fromInt 1
      val op * = Real.*
      val op / = Real./
      val op + = Real.+
      val op - = Real.-
      val op < = Real.<
   end
structure Algebra = Algebra(Element)
structure Cholesky = Cholesky(Algebra)

(* Read a white-space delimited matrix from stdIn *)
fun slurp () =
   case TextIO.inputLine TextIO.stdIn of
      NONE => []
    | SOME x => x :: slurp ()
val lines = slurp ()
val matrix = map (String.tokens Char.isSpace) lines

(* Convert the matrix to reals *)
fun cvt s = 
   case Real.fromString s of
      NONE => (TextIO.output (TextIO.stdErr, "Invalid real: " ^ s ^ "\n"); 1.0)
    | SOME x => x
val matrix = map (map cvt) matrix

(* Make sure the matrix is square *)
val dimension = length matrix
fun fix l = 
   case Int.compare (length l, dimension) of
      EQUAL => l
    | GREATER => 
        (TextIO.output (TextIO.stdErr, "Row too long!\n")
         ; List.take (l, dimension))
    | LESS => 
        (TextIO.output (TextIO.stdErr, "Row too short!\n")
         ; l @ List.tabulate (dimension - length l, fn _ => 1.0))
val matrix = List.map fix matrix

(* Convert the matrix into an algebraic matrix *)
val matrix = Vector.fromList (map Vector.fromList matrix)
val A = 
   Algebra.Matrix.tabulate {
      dimension = (dimension, dimension),
      bandwidth = (dimension, dimension),
      symmetric = true,
      fetch = fn (i, j) => Vector.sub (Vector.sub (matrix, j), i)
   }

(* Factor the matrix *)
local
   open Algebra
   val { D, L } = Cholesky.f A
   val A = Matrix.* (Matrix.* (L, D), Matrix.transpose L)
   
   val toString = Real.toString
in
   (* Pretty print the matrix *)
   val () = print "A = \n"
   val () = print (Matrix.toString toString A)
   val () = print "D = \n"
   val () = print (Matrix.toString toString D)
   val () = print "L = \n"
   val () = print (Matrix.toString toString L)
end

(*
local 
   open Algebra
in
   val w = 15
   val A = 
      Matrix.tabulate {
         dimension = (w, w),
         bandwidth = (4, 6),
         symmetric = true,
         fetch = get
      }
   val (D, L) = Cholesky.f A
   val B = Matrix.* (Matrix.* (L, D), Matrix.transpose L)
   val X = Matrix.- (A, B)

   fun out (_, c, x) = (print (Real.toString x); print (if c = w-1 then "\n" else " "))
   val () = Iterator.app out (Matrix.toIterator A)
   val () = Iterator.app out (Matrix.toIterator L)
   val () = Iterator.app out (Matrix.toIterator D)
   val () = Iterator.app out (Matrix.toIterator B)
   val () = print "\nError:\n"
   val () = Iterator.app out (Matrix.toIterator X)
end
*)
