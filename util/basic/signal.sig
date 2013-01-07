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

(* Signals are an abstraction of a data line.
 * 
 * At any given time, a signal is either ON and provides some value type,
 * or the signal is OFF and provides nothing. A signal handler is informed
 * (possibly many times) of the current status of the signal line.
 *
 * Signal sources, for example a network read, modify signal state. To
 * achieve this, they must be given a signal with which to report state 
 * changes that correspond to the events they produce.
 *
 * Unlike competing approaches (eg libsigc++, kde, gnome, etc), the signal
 * is not created at the event source, but rather at the event consumer.
 * The reasoning behind this is that  a signal handler might in turn change
 * the state of other, previously defined, signals. By creating signal lines 
 * at the event consumer, a handler can only refer to signals created earlier. 
 * This means that the program execution itself is a topological sort of the 
 * signal handlers. It is thus impossible for an event cycle to appear.
 *
 * Of course, the preceding reasoning breaks down if signals setON signals
 * or if there is mutable state. Therefore, whenever possible avoid these.
 *
 * In the rare cases where a signal loop is desired, use the newLoop method
 * as it will protect against infinite recursion. Instead of firing the handler
 * immediately, it defers execution to an Event scheduled to fire as soon as
 * the current event handler completes.
 *)
signature SIGNAL =
   sig
      type 'a t
      
      (* Construct a signal line from the function which handles it *) 
      val new: ('a -> unit) -> 'a t
      
      (* Make a new box signal line. The state arrives into a variable. *)
      val newBox: 'a -> 'a t * 'a ref 
      
      (* Change the state of a signal line *)
      val set: 'a t -> 'a -> unit
      
      (* Apply a function to the signal line to transform it's value *)
      val map: ('a -> 'b) -> 'b t -> 'a t
      
      (* Create a new signal line which affects more than one signal *)
      val combine: 'a t * 'a t -> 'a t
      val all: 'a t list -> 'a t
      
      (********** The below functions all require hidden state ***********)
      
      (* The function is used to combine values from the signal lines.
       * The initial values of the two output signal lines must be specified.
       *)
      val split : 'a t * ('b * 'c -> 'a) * ('b * 'c) -> 'b t * 'c t
      val splitNoInit : 'a t * ('b * 'c -> 'a) * ('b * 'c) -> 'b t * 'c t
      
      (* Dampen the signal handler -- only report actual state changes
       * using the comparison function. Provide the initial value.
       *)
      val dampen : ('a * 'a -> bool) * 'a -> 'a t -> 'a t
   end
