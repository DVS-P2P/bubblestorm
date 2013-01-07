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

structure StoragePeer :> STORAGE_PEER =
   struct
      fun module () = "bubblestorm/bubble/managed/storage-peer"
      fun log msg = Log.logExt (Log.DEBUG, module, msg)

      datatype t = T of {
         service : StorageService.Description.t,
         storageStream : StorageStream.t
      }

      (* register at a storage peer *)
      fun new { state, service, bucket, position, callback } =
         let
            fun onConnect connection =
               case connection of
                  SOME (conversation, doRegister) => (* successfully connected *)
                     let
                        (* create storage stream and pass it to the frontend *)
                        fun getStream stream =
                           let
                              val () = log (fn () => "established storage peer connection to " ^
                                                   StorageService.Description.toString service)
                              val removeFromFrontend = ref (fn () => ())
                              (* create stream handler *)
                              val storageStream = StorageStream.newStorage {
                                 conversation = conversation,
                                 stream = stream,
                                 whenDead = fn _ => (!removeFromFrontend) ()
                              }
                              val storage = T {
                                 service = service,
                                 storageStream = storageStream
                              }
                           in
                              removeFromFrontend := callback storage
                           end
                     in
                        (* send registration data *)
                        doRegister bucket position getStream
                     end
                | NONE => (* failed to connect *)
                     log (fn () => "could not contact storage peer " ^ 
                                 StorageService.Description.toString service)
            (* connect *)         
            val () = log (fn () => "contacting storage peer " ^ 
                                 StorageService.Description.toString service)
         in
            StorageService.register {
               endpoint = BasicBubbleType.endpoint state,
               service = service,
               complete = onConnect
            }
         end

      fun service (T { service, ... }) = service

      (* send a request to a storage peer *)
      fun send (T { storageStream, ... }, request) =
         StorageStream.send (storageStream, request)
      
      (* notify a storage peer of a position change *)
      fun changePosition (T { storageStream, ... }) pos =
         StorageStream.changePosition (storageStream, pos)

      (* quit a storage peer *)
      fun quit (T { storageStream, ... }) =
         StorageStream.shutdown storageStream
   end
