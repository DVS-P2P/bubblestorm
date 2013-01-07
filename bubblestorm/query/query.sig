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

signature QUERY =
   sig
      
      type t

      (* Creates a query. *)
      val new : {
         master : BubbleType.master,
         (* The data bubble type against which the query bubble type is matched. *)
         dataBubble : BubbleType.persistent,
         (* The ID of the query bubble type that is created. *)
         queryBubbleId : int,
         queryBubbleName : string,
         (* The expected match count (see BubbleType.match) *)
         lambda : real,
         (* Reliability and Priority *)
         priority    : Real32.real option,
         reliability : Real32.real option,
         (* The responder function processing incoming queries. *)
         responder : {
            (* The query payload *)
            query : Word8VectorSlice.slice,
            (* Function to be called to notify about an answer (i.e., document match).
             * This function has to be called once per result object.
             *)
            respond : {
               (* The document's ID *)
               id : ID.t,
               (* score : Real64.real, *)
               (* The function to be called when the document payload has to be written out.
               * If the data is not required at all, the function is called with NONE.
               * Thus, the function is promises to be called (exactly) once, and when called
               * the application can free any resources associated with the document data.
               *)
               write : CUSP.OutStream.t option -> unit
            } -> unit
         } -> unit
      } -> t
      
      (* Start a query.
       * Returns a function to abort the query.
       *)
      val query : t * {
         (* The query (bubblecast) ID.
          * If NONE, the ID is hashed from the query payload.
          *)
(*          id : ID.t option, *)
         (* The query payload *)
         query : Word8Vector.vector,
         (* Function that is called for each response (matching document) *)
         responseCallback : {
            (* The document's ID *)
            id : ID.t,
            (*score : Real64.t,*)
            (* The stream to read the document from *)
            stream : CUSP.InStream.t
         } -> unit
      } -> unit -> unit

      (* Returns the query's query bubble. Should be used for debugging/statistics only. *)
      val queryBubble : t -> BubbleType.instant

   end
