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

signature BASIC_BUBBLE_TYPE =
   sig
      exception BubbleIdInUse 
 
      type t
      type bubbleState
      datatype bubbleClass =
         INSTANT
       | FADING of {
            store : ID.t * Word8VectorSlice.slice -> unit
         }
       | MANAGED of {
            cache     : ManagedDataCache.t,
            datastore : ManagedDataStore.t
         }
       | DURABLE of {
            datastore : DurableDataStore.t
         }
       | MAXIMUM of {
            withBubbles : t list ref,
            handler     : int * Word8VectorSlice.slice -> unit
         }
 
      val new : {
         state       : bubbleState,
         name        : string,
         typeId      : int,
         class       : bubbleClass,
         priority    : Real32.real,
         reliability : Real32.real
      } -> t

      val typeId : t -> int
      val name : t -> string
      val toString : t -> string
      val priority : t -> Real32.real
      val reliability : t -> Real32.real
      val state : t -> bubbleState
      val class : t -> bubbleClass

      datatype matchConstraint = MATCH of {
         object  : t,
         lambda  : Real64.real,
         handler : ID.t * Word8VectorSlice.slice -> unit
      }     
      val match : {
         subject : t,
         object  : t,
         lambda  : Real64.real,
         handler : ID.t * Word8VectorSlice.slice -> unit
      } -> unit
      val matches : t -> matchConstraint list
      (*val intersects : matchConstraint * int -> bool*)
      (* do rendezvous matching with other bubbletypes *)
      val doMatching : t * int -> ID.t * Word8VectorSlice.slice -> unit
      
      (* the size a bubblecast for this bubble should have. it is the maximum 
         of the target size and the previous target size (for a smooth 
         transition without decreasing recall. *)
      val defaultSize : t -> int
      val defaultSizeReal : t -> Real64.real
      (* the size a bubble should have eventually (this is a moving target...) *)
      val targetSize : t -> int
      val targetSizeReal : t -> Real64.real
      val oldSize : t -> int
      val oldSizeReal : t -> Real64.real
      val setNewSize : t * Real64.real -> unit

      (* for bubble types that compute their own minimum size *)
      val setMinimum : t * (t -> Real64.real) -> unit
      val computeMinimum : t -> Real64.real
      
      val bubblecast : {
         bubbleType : t,
         size       : int,
         data       : Word8Vector.vector
      } -> unit
      val slicecast : {
         bubbleType : t,
         size       : int
      } -> ({
         data  : Word8Vector.vector,
         start : int,
         stop  : int
      } -> unit)

      val costMeasurement : t -> BubbleCostMeasurement.t

      val setSizeStat : t * Statistics.t option -> unit
      val setCostStat : t * Statistics.t option -> unit

      (* the node is not connected to the overlay and can thus not determine its 
         own network address. raised by address (). *)
      exception NotConnected

      val newBubbleState : Topology.t * NodeAttributes.t -> bubbleState
      val endpoint    : bubbleState -> CUSP.EndPoint.t
      val address     : bubbleState -> CUSP.Address.t (* raises NotConnected *)
      val topology    : bubbleState -> Topology.t
      val measurement : bubbleState -> Measurement.t
      val attributes  : bubbleState -> NodeAttributes.t
      val stats       : bubbleState -> SystemStats.t
      val bubbletypes : bubbleState -> t IDHashTable.t      
   end
