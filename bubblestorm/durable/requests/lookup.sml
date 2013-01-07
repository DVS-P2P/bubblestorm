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

structure Lookup :> LOOKUP =
   struct
      val module = "bubblestorm/bubble/durable/lookup-bubble"
      fun log msg = Log.logExt (Log.DEBUG, fn () => module, msg)

      structure Notification = Notification(Version)

      type request = {
         bubble  : BasicBubbleType.t,
         id      : ID.t,
         receive : Version.t * Word8Vector.vector -> unit
      }

      type t = ID.t * int * Notification.callback
      
      exception IllegalBubbleType

      local
         open Serial
      in
         val t = aggregate tuple3 `ID.t `int32l `Notification.callback $
         val { parseVector=fromVectorSlice, toVector, ... } = methods t
      end

      fun start { bubble, id, receive } =
         let
            val () = log (fn () => "starting lookup for " ^ ID.toString id)
            val state = BasicBubbleType.state bubble
            (* the newest version returned so far *)
            val currentVersion = ref NONE

            (* fetch the actual data from the InStream *)
            fun readResult result =
               let
                  open CUSP
                  val version = Notification.Result.id result
                  val () = currentVersion := SOME version
                  val stream = Notification.Result.payload result
                  fun read data = InStream.read (stream, ~1, readDone data)
                  and readDone data (InStream.DATA slice) =
                     read ((Word8ArraySlice.vector slice) :: data)
                  |  readDone data InStream.SHUTDOWN =
                     let
                        val () = InStream.reset stream
                        val () = log (fn () => 
                           "received result for " ^ ID.toString id)
                     in
                        receive (version, Word8Vector.concat (List.rev data))
                     end
                  |  readDone _ InStream.RESET = InStream.reset stream
               in
                  read []
               end

            (* compare with previously returned version, return only if newer *)
            fun onResult result =
               case !currentVersion of
                  NONE => readResult result
                | SOME myVersion =>
                     if Version.> (Notification.Result.id result, myVersion)
                        then readResult result
                        else Notification.Result.cancel result
            
            (* set up the notifcation *)
            val notifier = Notification.new {
                  endpoint = BasicBubbleType.endpoint state,
                  resultReceiver = onResult
               }
            val address = BasicBubbleType.address state
            val request = (id,
                           BasicBubbleType.typeId bubble,
                           Notification.provideCallback (notifier, address))
            val close = fn () => Notification.close notifier
         in
            (request, close)
         end

      (* TODO: avoid code duplication, code is also used in Record *)      
      fun getBubble state bubble =
         case IDHashTable.get (BasicBubbleType.bubbletypes state, bubble) of
            NONE => raise IllegalBubbleType
          | SOME bubble =>
               case BasicBubbleType.class bubble of
                  BasicBubbleType.DURABLE _ => bubble
                | _ => raise IllegalBubbleType

      fun receive (state, (id, bubble, callback)) =
         let
            val () = log (fn () => 
               "received lookup request for " ^ ID.toString id)

            (* decode the request *)
            val bubble = getBubble state bubble
            val endpoint = BasicBubbleType.endpoint state
            val send = Notification.receiveCallback (callback, endpoint)

            (* send an answer to the requester *)
            fun done stream CUSP.OutStream.RESET = 
               CUSP.OutStream.reset stream
               | done stream CUSP.OutStream.READY =
               CUSP.OutStream.shutdown (stream, fn _ => ())

            fun write _ NONE = () (* request was canceled *)
               | write data (SOME stream) = (* send data *)
               CUSP.OutStream.write (stream, data, done stream)

            fun respond (version, data) = 
               send (version, Notification.ON_REQUEST (write data))
         in
            {
               bubble  = bubble,
               id      = id,
               receive = respond
            }
         end
   end      
