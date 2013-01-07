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

structure ManagedBubble :> MANAGED_BUBBLE =
   struct
      datatype t = T of {
         typ : BubbleType.managed,         
         id : ID.t,
         getData : unit -> Word8Vector.vector
      }

      fun new (typ, id) getData =
         T {
            typ = typ,
            id  = id,
            getData = getData
         }
      
      fun id (T { id, ... }) = id
      fun data (T { getData, ... }) = getData ()
      
      fun insert { typ, id, data, done } =
         new (typ, id) (
            ManagedReplication.insert (BubbleType.managedReplication typ, {
               bubble = BubbleType.basicManaged typ,
               id     = id,
               data   = data,
               done   = done
            })
         )

      fun update { bubble=T { typ, id, ... }, data, done } =
         ManagedReplication.update (BubbleType.managedReplication typ, {
            bubble = BubbleType.basicManaged typ,
            id     = id,
            data   = data,
            done   = done
         })

      fun delete { bubble=T { typ, id, ... }, done } =
         ManagedReplication.delete (BubbleType.managedReplication typ, {
            bubble = BubbleType.basicManaged typ,
            id     = id,
            done   = done
         })
         
      fun get { typ, id } =
         Option.map (new (typ, id)) (
            ManagedReplication.get (BubbleType.managedReplication typ, {
               bubble = BubbleType.basicManaged typ,
               id     = id
            })
         )
   end
