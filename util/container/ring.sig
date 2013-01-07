(*
** 2007 February 18
**
** The author disclaims copyright to this source code.  In place of
** a legal notice, here is a blessing:
**
**    May you do good and not evil.
**    May you find forgiveness for yourself and forgive others.
**    May you share freely, never taking more than you give.
**
*************************************************************************
** $Id: ring.sig 5301 2007-02-23 01:41:53Z wesley $
*)
signature RING =
   sig
      (* The ring container type *)
      type 'a t
      (* handle to an element in the ring *)
      eqtype 'a element
      
      (* Create a new empty ring container *)
      val new    : unit -> 'a t
      
      (* Package up an element for storing it in a ring *)
      val wrap   : 'a -> 'a element
      
      (* Retrieve the value in this link *)
      val unwrap : 'a element -> 'a
      
      (* Update the contents of a wrapped element *)
      val update : 'a element * 'a -> unit
      
      (* Add a value as the first element to the ring (removes it from its old location) *)
      val add    : 'a t * 'a element -> unit
      
      (* Add a value as the last element to the ring (removes it from its old location) *)
      val addTail : 'a t * 'a element -> unit
      
      val head    : 'a t -> 'a element option
      val tail    : 'a t -> 'a element option
      val next    : 'a element -> 'a element option
      val prev    : 'a element -> 'a element option
      
      (* Remove the element from whatever ring it might be in *)
      val remove : 'a element -> unit
      
      (* Removes all elements from the ring *)
      val clear : 'a t -> unit
      
      (* Is this the only element in the ring? *)
      val isSolo : 'a element -> bool
      (* Is the ring empty? *)
      val isEmpty : 'a t -> bool
      
      (* Get an iterator that walks the ring in arbitrary order. *)
      val iterator: 'a t -> 'a element Iterator.t
      
      (* Safely execute a method on a ring.
       * Elements added during/after the app call are NOT run.
       * An element is only passed if it is still in the ring.
       *)
      val app : ('a element -> unit) -> 'a t -> unit
   end
