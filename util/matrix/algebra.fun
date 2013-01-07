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

functor Algebra(Element : ELEMENT) : ALGEBRA where type Element.t = Element.t =
   struct
      structure Element = Element
      structure Vector = 
         struct
            datatype rep =
               VECTOR of Element.t array
             | LAZY of int -> Element.t
            datatype t = T of {
               start  : int,
               finish : int,
               rep    : rep }
            
            fun raw (T { rep = LAZY f, ... }, i) = f i
              | raw (T { rep = VECTOR V, start, ... }, i) = Array.sub (V, i - start)
              
            fun sub (this as T { start, finish, ... }) i =
                if i < start orelse i >= finish then Element.zero else raw (this, i)
            
            val zero = Array.tabulate (0, fn _ => raise Domain)
            val zero = T { start = 0, finish = 0, rep = VECTOR zero }
            
            fun tabulate { start, length, fetch } =
               T { start  = start,
                   finish = start + length,
                   rep    = VECTOR (Array.tabulate (length, fn i => fetch (i + start))) }

            datatype order = TOP_DOWN | BOTTOM_UP
            fun unfold { start, length, order, fetch } =
               let
                  val A = Array.array (length, Element.zero)
                  val out = T { start = start, finish = start+length, rep = VECTOR A }
                  
                  val loop = Iterator.fromInterval { start = 0, stop = length, step = 1 }
                  fun reverse i = (length-1) - i
                  
                  val loop = 
                     case order of
                        TOP_DOWN => loop
                      | BOTTOM_UP => Iterator.map reverse loop
                  
                  fun fill i = Array.update (A, i, fetch (out, i))
                  val () = Iterator.app fill loop
               in
                  out
               end

            fun fromArray (a, l) = 
               if l < 0 then zero else
               if l > Array.length a then raise Subscript else
               T { start = 0, finish = l, rep = VECTOR a }
            
            fun scale (this as T { start, finish, ... }, scale) =
               let
                  fun get i = Element.* (raw (this, i + start), scale)
                  val V = Array.tabulate (finish-start, get)
               in
                  T { start = start, finish = finish, rep = VECTOR V }
               end
            
            fun mapi f (this as T { start, finish, ... }) =
               let
                  fun get i = f (i + start, raw (this, i + start))
                  val V = Array.tabulate (finish-start, get)
               in
                  T { start = start, finish = finish, rep = VECTOR V }
               end
            fun map f v = mapi (fn (_, x) => f x) v
            
            fun max (this as T { start, finish, ... }) =
               let
                  fun acc (i, r) = 
                     let
                        val v = raw (this, i)
                     in
                        if Element.< (r, v) then v else r
                     end
                  val loop = Iterator.fromInterval { start = start, stop = finish, step = 1 }
               in
                  Iterator.fold acc Element.zero loop
               end
            
            fun min (this as T { start, finish, ... }) =
               let
                  fun acc (i, r) = 
                     let
                        val v = raw (this, i)
                     in
                        if Element.< (v, r) then v else r
                     end
                  val loop = Iterator.fromInterval { start = start, stop = finish, step = 1 }
               in
                  Iterator.fold acc Element.zero loop
               end
            
            fun sum (this as T { start, finish, ... }) =
               let
                  fun acc (i, r) = Element.+ (r, raw (this, i))
                  val loop = Iterator.fromInterval { start = start, stop = finish, step = 1 }
               in
                  Iterator.fold acc Element.zero loop
               end
            
            fun makeMax f (A as T { start=sA, finish=fA, ... },
                        B as T { start=sB, finish=fB, ... }) =
               let
                  val start  = Int.min (sA, sB)
                  val finish = Int.max (fA, fB)
                  fun fetch i = f (sub A i, sub B i)
               in
                  tabulate {
                     start  = start,
                     length = finish-start,
                     fetch  = fetch }
               end
            fun makeMin f (A as T { start=sA, finish=fA, ... },
                        B as T { start=sB, finish=fB, ... }) =
               let
                  val start  = Int.max (sA, sB)
                  val finish = Int.min (fA, fB)
                  fun fetch i = f (raw (A, i), raw (B, i))
               in
                  if start >= finish then zero else
                  tabulate {
                     start  = start,
                     length = finish-start,
                     fetch  = fetch }
               end
            fun dot (A as T { start=sA, finish=fA, ... },
                     B as T { start=sB, finish=fB, ... }) =
               let
                  val start = Int.max (sA, sB)
                  val finish = Int.min (fA, fB)
                  fun acc (i, r) = 
                     Element.+ (r, Element.* (raw (A, i), raw (B, i)))
                  val loop = Iterator.fromInterval { start = start, stop = finish, step = 1 }
               in
                  Iterator.fold acc Element.zero loop
               end
            
            val op + = makeMax Element.+
            val op - = makeMax Element.-
            val op * = makeMin Element.*
         end
      
      structure Matrix =
         struct
            datatype rep =
               FULL of Element.t array
             | BANDED of Element.t array
               
            datatype t = T of {
               dimension : int * int, (* (rows, cols)   *)
               bandwidth : int * int, (* (width, under) *)
               symmetric : bool,
               rep : rep
            }

            fun bandwidth (T { bandwidth = (width, under), ... }) =
               (under, width - under - 1)
            fun dimension (T { dimension, ... }) =
               dimension
            fun symmetric (T { symmetric, ... }) =
               symmetric
            
            fun inBand (T { bandwidth = (width, under), ... }) (row, column) =
               row-column <= under andalso column-row < width-under
            fun inBounds (T { dimension = (rows, columns), ... }) (row, column) =
               row    >= 0 andalso row    < rows     andalso
               column >= 0 andalso column < columns
                
            fun sub this rc =
               if inBounds this rc andalso inBand this rc 
               then subRep this rc
               else Element.zero
            and subRep (T { rep = FULL A, dimension = (_, columns), ... }) (row, column) =
                  Array.sub (A, row * columns + column)
              | subRep (T { rep = BANDED A, bandwidth = (width, under), ... }) (row, column) =
                  Array.sub (A, row * width + under + (column - row))
            
            fun rawUpdate this (r, c, v) =
               if inBounds this (r, c) andalso inBand this (r, c)
               then subUpdate this (r, c, v)
               else raise Subscript
            and subUpdate (T { rep = FULL A, dimension = (_, columns), ... }) (row, column, v) =
                  Array.update (A, row * columns + column, v)
              | subUpdate (T { rep = BANDED A, bandwidth = (width, under), ... }) (row, column, v) =
                  Array.update (A, row * width + under + (column - row), v)
            
            fun update this (r, c, v) =
               rawUpdate this (r, c, v)
            
            fun row (T { rep, bandwidth = (width, under), dimension = (rows, columns), ... }) row =
               if row >= rows then Vector.zero else
               let
                  val start = Int.max (row - under, 0)
                  val finish = Int.min (row + width - under, columns)
                  val (A, off) =
                     case rep of
                        FULL A => (A, row * columns)
                      | BANDED A => (A, row * width + under - row)
               in
                  Vector.T {
                     start  = start,
                     finish = finish,
                     rep    = Vector.LAZY (fn column => Array.sub (A, off + column))
                  }
               end
            
            fun column (T { rep, bandwidth = (width, under), dimension = (rows, columns), ... }) column =
               if column >= columns then Vector.zero else
               let
                  val start  = Int.max (column - (width - under - 1), 0)
                  val finish = Int.min (column + under + 1, rows)
                  val (A, off, skip) =
                     case rep of
                        FULL A => (A, column, columns)
                      | BANDED A => (A, column + under, width - 1)
               in
                  Vector.T {
                     start  = start,
                     finish = finish,
                     rep    = Vector.LAZY (fn row => Array.sub (A, off + row * skip))
                  }
               end
            
            fun unfold { dimension = (rows, columns), bandwidth = (lower, upper), symmetric, fetch } =
               let
                  val lower = if symmetric then Int.min (lower, upper) else lower
                  val upper = if symmetric then Int.min (lower, upper) else upper
                  
                  val width = lower + upper + 1
                  val under = lower
                  val bandedSize = width * rows
                  val fullSize = rows * columns
                  
                  val rep =
                     if bandedSize*2 < fullSize 
                     then BANDED (Array.array (bandedSize, Element.zero))
                     else FULL   (Array.array (fullSize,   Element.zero))
                  val out =
                     T { dimension = (rows, columns),
                         bandwidth = (width, under),
                         symmetric = symmetric,
                         rep = rep }
                  
                  val fetch = 
                     if not symmetric then fetch else
                     fn (out, r, c) =>
                     if c >= r then fetch (out, r, c) else subRep out (c, r)

                  fun setFull (i, _) =
                     let
                        val (row, column) = (i div columns, i mod columns)
                     in
                        if inBand out (row, column)
                        then fetch (out, row, column)
                        else Element.zero
                     end
                  fun setBanded (i, _) =
                     let
                        val (row, offset) = (i div width, i mod width)
                        val column = row + offset - under
                     in
                        if column >= 0 andalso column < columns 
                        then fetch (out, row, column)
                        else Element.zero
                     end
                  
                  val () =
                     case rep of
                        BANDED A => Array.modifyi setBanded A
                      | FULL A   => Array.modifyi setFull   A
               in
                  out
               end
            
            fun tabulate { dimension, bandwidth, symmetric, fetch } =
               unfold { dimension = dimension, bandwidth = bandwidth,
                        symmetric = symmetric, fetch = fn (_, r, c) => fetch (r,c) }
            
            fun transpose A =
               let
                  val (columns, rows) = dimension A
                  val (upper, lower)  = bandwidth A
                  val symmetric = symmetric A
                  fun get (r, c) = subRep A (c, r)
               in
                  tabulate {
                     dimension = (rows, columns),
                     bandwidth = (lower, upper),
                     symmetric = symmetric,
                     fetch = get
                  }
               end
            
            fun map (A, x) =
               let
                  val (lower, upper)  = bandwidth A
                  val (rows, _) = dimension A
                  val Vector.T { start, finish, ... } = x
                  val start  = Int.max (0, start - lower)
                  val finish = Int.min (rows, finish + upper)
                  fun g i =
                     Vector.dot (row A i, x)
               in
                  Vector.tabulate {
                     start  = start,
                     length = finish-start,
                     fetch  = g
                  }
               end
            
            fun make f (A, B) =
               let
                  val (rA, cA) = dimension A
                  val (rB, cB) = dimension B
                  val (lA, uA) = bandwidth A
                  val (lB, uB) = bandwidth B
                  val sA = symmetric A
                  val sB = symmetric B
                  val r = Int.max (rA, rB)
                  val c = Int.max (cA, cB)
                  val l = Int.max (lA, lB)
                  val u = Int.max (uA, uB)
                  val s = sA andalso sB
                  fun g rc = f (sub A rc, sub B rc)
               in
                  tabulate {
                     dimension = (r, c),
                     bandwidth = (l, u),
                     symmetric = s,
                     fetch = g
                  }
               end
            
            fun toIterator A = 
               let
                  val (rows, columns) = dimension A
                  val rows    = Iterator.fromInterval { start = 0, stop = rows,    step = 1 }
                  val columns = Iterator.fromInterval { start = 0, stop = columns, step = 1 }
                  val indexes = Iterator.cross (rows, columns)
                  fun get (r, c) = 
                     if inBand A (r, c)
                     then (r, c, subRep A (r, c))
                     else (r, c, Element.zero)
               in
                  Iterator.map get indexes
               end
            
            fun toBandedIterator A =
               let
                  val (rows, columns) = dimension A
                  val symmetric = symmetric A
                  val (lower, upper) = bandwidth A
                  val upper = if symmetric then 0 else upper
                  
                  val rows = Iterator.fromInterval { start = 0, stop = rows, step = 1 }
                  fun row i = 
                     let
                        val start = Int.max (0, i-lower)
                        val stop = Int.min (columns, i+upper+1)
                        val it = Iterator.fromInterval { start = start, stop = stop, step = 1}
                     in
                        Iterator.map (fn j => (i, j, subRep A (i, j))) it
                     end
               in
                  Iterator.concat (Iterator.map row rows)
               end

            fun A * B =
               let
                  val (r, _) = dimension A
                  val (_, c) = dimension B
                  val (lA, uA) = bandwidth A
                  val (lB, uB) = bandwidth B
                  val sA = symmetric A
                  val sB = symmetric B
                  val l = Int.min (lA + lB, r-1)
                  val u = Int.min (uA + uB, c-1)
                  val s = sA andalso sB
                  fun g (r, c) = Vector.dot (row A r, column B c)
               in
                  tabulate {
                     dimension = (r, c),
                     bandwidth = (l, u),
                     symmetric = s,
                     fetch = g
                  }
               end
            
            val op + = make Element.+
            val op - = make Element.-
            
            fun rows A =
               let 
                  val (_, rows) = dimension A
                  val rows = Iterator.fromInterval { start = 0, stop = rows, step = 1 }
               in
                  Iterator.map (fn i => (i, row A i)) rows
               end
               
            fun columns A =
               let 
                  val (columns, _) = dimension A
                  val columns = Iterator.fromInterval { start = 0, stop = columns, step = 1 }
               in
                  Iterator.map (fn i => (i, column A i)) columns
               end
            
            fun toString toString A =
               let
                  val (columns, rows) = dimension A
                  
                  (* Create a string matrix *)
                  val output = Array.tabulate (rows, fn _ => Array.array (columns, ""))
                  fun set (i, j, x) = Array.update (Array.sub (output, i), j, toString x)
                  fun get (i, j) = Array.sub (Array.sub (output, i), j)
                  val () = Iterator.app set (toIterator A)
                  
                  (* Compute the padding needed by each column *)
                  val rows = Iterator.fromInterval { start = 0, stop = columns, step = 1 }
                  fun sizes column = Iterator.map (fn row => String.size (get (row, column))) rows
                  fun width column = Iterator.fold Int.max 0 (sizes column)
                  val widths = IntVector.tabulate (columns, width)
                  
                  (* Put the output into a list *)
                  fun pad i = CharVector.tabulate (i, fn _ => #" ")
                  fun dumpColumn (column, value, tail) = 
                     let
                        val width = Int.+ (IntVector.sub (widths, column), 1)
                        val size = String.size value
                        val pad = pad (Int.- (width, size))
                     in
                        value :: pad :: tail
                     end
                  fun dumpRow (row, tail) =
                   "[ " :: Array.foldri dumpColumn ("]\n" :: tail) row
               in
                  concat (Array.foldr dumpRow [] output)
               end
         end
   end
