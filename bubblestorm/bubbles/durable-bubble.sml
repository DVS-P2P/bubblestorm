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

structure DurableBubble :> DURABLE_BUBBLE =
   struct
      datatype t' = T of {
         bubble  : BubbleType.durable,         
         id      : ID.t,
         version : Version.t,
         data    : Word8Vector.vector
      }
      type t = t' ref
      
      fun id (ref (T { id, ... })) = id
      fun data (ref (T { data, ... }))  = data
      
      fun new (bubble, id) =
         ref (T { 
            bubble  = bubble,
            id      = id,
            version = Version.new (),
            data    = Word8Vector.fromList []
         })
         
      fun replace (this as ref (T { bubble, id, ... })) (version, data) =
         this := T {
            bubble  = bubble,
            id      = id,
            version = version,
            data    = data
         }
      
      fun update { bubble = this, data=newData } =
         let
            val T { bubble, id, version, ... } = !this
            val newVersion = Version.increase version
            val () = replace this (newVersion, newData)
            val request = {
               bubble  = BubbleType.basicDurable bubble,
               id      = id,
               version = newVersion
            }
         in            
            DurableReplication.store (BubbleType.durableReplication bubble, 
                                      request, newData)
         end

      fun create { typ, id, data } =
         let
            val this = new (typ, id)
            val () = update { bubble = this, data = data }
         in
            this
         end
            
      fun delete this = update { bubble = this, data = Word8Vector.fromList [] }
         
      fun lookup { typ, id, receive } =
         let
            val this = new (typ, id)
         in
            DurableReplication.lookup (BubbleType.durableReplication typ, {
               bubble  = BubbleType.basicDurable typ,
               id      = id,
               receive = fn x => ( replace this x ; receive this )
            })
         end
   end
