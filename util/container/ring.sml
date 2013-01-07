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
** $Id: ring.sml 5301 2007-02-23 01:41:53Z wesley $
*)
structure Ring :> RING =
   struct
      datatype 'a link =
         NULL | T of 'a t | ELT of 'a element
      withtype 'a t = {
         prev : 'a link,
         next : 'a link } ref
      and 'a element = {
         prev  : 'a link,
         next  : 'a link,
         value : 'a } ref
      
      fun complain () = raise Fail "Impossible. Broken ring."
      
      fun new () = 
         let
            val self = ref { prev = NULL, next = NULL }
            val () = self := { prev = T self, next = T self }
         in
            self
         end
      
      fun wrap value =
         ref { value = value, prev = NULL, next = NULL }
      
      fun unwrap elt =
         let
            val { value, prev=_, next=_ } = !elt
         in
            value
         end
      
      fun update (elt, value) =
         let
            val { value=_, prev, next } = !elt
         in
            elt := { value=value, prev=prev, next=next }
         end
      
      fun isSolo elt =
         let
            val { value=_, prev, next=_ } = !elt
         in
            case prev of NULL => true | _ => false
         end
      
      fun isEmpty head =
         let
            val { prev=_, next } = !head
         in
            case next of T _ => true | _ => false
         end
      
      fun remove self =
         let
            val { value, prev=prev, next=next } = !self
            val () = 
               case prev of
                  NULL => ()
                | ELT (elt as ref {value,prev,next=_}) => 
                     elt := {value=value,prev=prev,next=next}
                | T (head as ref {prev,next=_}) =>
                     head := {prev=prev,next=next}
            val () = 
               case next of
                  NULL => ()
                | ELT (elt as ref {value,prev=_,next}) => 
                     elt := {value=value,prev=prev,next=next}
                | T (head as ref {prev=_,next}) =>
                     head := {prev=prev,next=next}
         in
            self := { value=value, prev=NULL, next=NULL }
         end
      
      fun add (head, elt) =
         let
            val () = remove elt
            val { prev, next } = !head
            val { value, next=_, prev=_ } = !elt
            val () = elt := { value=value, prev=T head, next=next }
            val () = head := { prev=prev, next=ELT elt}
         in
            (* read next after writing prev, in case they are the same *)
            case next of
               NULL => complain ()
             | ELT (next as ref { value, prev=_, next=nextnext }) => 
                  next := { value=value, prev=ELT elt, next=nextnext }
             | T (head as ref { prev=_, next }) =>
                  head := { prev=ELT elt, next=next }
         end
      
      fun addTail (head, elt) =
         let
            val () = remove elt
            val { prev, next } = !head
            val { value, next=_, prev=_ } = !elt
            val () = elt := { value=value, prev=prev, next=T head }
            val () = head := { prev=ELT elt, next=next}
         in
            (* read prev after writing next, in case they are the same *)
            case prev of
               NULL => complain ()
             | ELT (prev as ref { value, prev=prevprev, next=_ }) => 
                  prev := { value=value, prev=prevprev, next=ELT elt }
             | T (head as ref { prev, next=_ }) =>
                  head := { prev=prev, next=ELT elt }
         end
      
      fun head (ref {prev=_, next}) =
         case next of
            NULL => complain ()
          | ELT x => SOME x
          | T _ => NONE
            
      fun tail (ref {prev, next=_}) =
         case prev of
            NULL => complain ()
          | ELT x => SOME x
          | T _ => NONE
      
      fun next (ref {value=_, prev=_, next}) =
         case next of
            NULL => complain ()
          | ELT x => SOME x
          | T _ => NONE
                  
      fun prev (ref {value=_, prev, next=_}) =
         case prev of
            NULL => complain ()
          | ELT x => SOME x
          | T _ => NONE
                  
      fun clear head =
         let
            val rec loop = fn
               NULL => complain ()
             | T _ => ()
             | ELT (next as ref {value, prev=_, next=nextnext }) =>
                  (next := { value=value, prev=NULL, next=NULL }
                   ; loop nextnext)
            val {prev=_, next} = !head
            val () = loop next
         in
            head := { prev = T head, next = T head }
         end
      
      fun iterator head =
         let
            val rec loop = fn
               NULL => complain ()
             | T _ => Iterator.EOF
             | ELT elt =>
               let
                  val { value=_, next, prev=_ } = !elt
               in
                  Iterator.VALUE (elt, fn () => loop next)
               end
            val { next, prev=_ } = !head
         in
            loop next
         end
      
      fun app f ring =
         let
            val elts = Iterator.toList (iterator ring)
            fun exec r = if isSolo r then () else f r
         in
            List.app exec elts
         end
   end

(*
val a = Ring.new 7
val b = Ring.add (a, 9)
val c = Ring.add (a, 11)
val d = Ring.add (b, 13)
val () = print (Int.toString (Ring.get b) ^ "\n")
val () = Ring.update (b, 10)
val () = print (Int.toString (MLton.size a) ^ "\n")
val () = Ring.remove c 
val () = Iterator.app (fn x => print (Int.toString x ^ "\n")) (Ring.iterator a)
*)
