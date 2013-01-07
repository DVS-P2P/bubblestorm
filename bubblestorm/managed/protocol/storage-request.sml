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

structure StorageRequest :> STORAGE_REQUEST =
   struct
      datatype t =
         INSERT of BasicBubbleType.t * ID.t * Word8Vector.vector * (unit -> unit)
       | UPDATE of BasicBubbleType.t * ID.t * Word8Vector.vector * (unit -> unit)
       | DELETE of BasicBubbleType.t * ID.t * (unit -> unit)

      exception InvalidBubbleType
      
      (* complete callback *)
      local
         open CUSP
         open Conversation
         open Serial
      in
         datatype complete = COMPLETE
         fun completeTy x = Method.new {
            name     = "complete",
            datatyp  = COMPLETE,
            ackInfo  = AckInfo.callback,
            duration = Duration.oneShot,
            qos      = QOS.static (Config.maintainerPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME Stats.sentManagedComplete,
            receiveStatistics = SOME Stats.receivedManagedComplete
         } `unit $ x

         (* prepare to receive confirmation *)
         fun awaitResponse (conversation, callback) =
            #1 (Conversation.response (conversation, {
               methodTy = completeTy,
               method   = callback
            }))
      end

      local
         open Serial
      in
         (* description (bubbletype, id, complete) *)
         val body = aggregate tuple3 `int32l `ID.t `completeTy $
         val { toVector, parseSlice, length, ... } = methods body
      end
         
      (* serialization of requests *)
      fun encode (conversation, request) =
         let
            val btype = BasicBubbleType.typeId
            fun write (bubble, id, done) =
               toVector (btype bubble, id, awaitResponse (conversation, done))
         in
            case request of
               INSERT (bubble, id, data, done) =>
                  Word8Vector.concat [ write (bubble, id, done), data ]
             | UPDATE (bubble, id, data, done) =>
                  Word8Vector.concat [ write (bubble, id, done), data ]
             | DELETE (bubble, id, done) =>
                  write (bubble, id, done)
         end
         
      (* wait an operation and reset the conversation,
         if it does not complete in time. returns a method to remove the 
         timer when the operation completes. *)
      fun setTimeout conversation =
         let
            val canceled = ref false
            fun kill _ = if !canceled then () else Conversation.reset conversation
            val event = Main.Event.new kill
            val () = Main.Event.scheduleIn (event, Config.RPCTimeout)
         in
            fn () => canceled := true
         end
      (* decode the request's content (bubble, id, data, done) *)
      fun decode (state, conversation, data) =
         let
            (* extract bubbletype, id, complete *)
            val desc = Word8ArraySlice.subslice (data, 0, SOME length)
            val (bubbleID, id, done) = parseSlice desc

            (* retrieve the bubbletype by its numeric ID *)
            val bubble =
               case IDHashTable.get (BasicBubbleType.bubbletypes state, bubbleID) of
                  NONE => raise InvalidBubbleType
                | SOME bubble =>
                     case BasicBubbleType.class bubble of
                        BasicBubbleType.MANAGED _ => bubble
                      | _ => raise InvalidBubbleType
 
            (* set a timeout on the complete callback *)
            fun done' () =
               let
                  val cancel = setTimeout conversation
                  (* true = successfully delivered, false = got a reset *)
                  fun delivered true = cancel ()
                     | delivered false = Conversation.reset conversation
               in
                  done delivered ()
               end

            (* extract data *)
            val tail = Word8ArraySlice.subslice (data, length, NONE)
         in
            (bubble, id, Word8ArraySlice.vector tail, done')
         end
            

      fun decodeInsert x = INSERT (decode x)
      fun decodeUpdate x = UPDATE (decode x)
      fun decodeDelete x =
         let
            val (bubble, id, _, done) = decode x
         in
            DELETE (bubble, id, done)
         end
      
      local
         fun body (bubble, id) = 
            " bubble=" ^ BasicBubbleType.toString bubble ^ " id=" ^ ID.toString id
         fun tail data = " length=" ^ Int.toString (Word8Vector.length data)
      in
         fun toString (INSERT (bubble, id, data, _)) =
            "INSERT" ^ body (bubble, id) ^ tail data
           | toString (UPDATE (bubble, id, data, _)) =
            "UPDATE" ^ body (bubble, id) ^ tail data
           | toString (DELETE (bubble, id, _)) =
            "DELETE" ^ body (bubble, id)
      end
      
   end
