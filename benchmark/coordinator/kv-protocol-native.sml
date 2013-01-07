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

structure KVProtocol : KV_PROTOCOL =
   struct
      fun module () = "kv/remote-workload"
      
      (* conversation types *)
      local
         open Serial
         open Conversation
      in
         datatype confirm = CONFIRM
         fun confirmTy x  = Method.new {
            name     = "coordinator/confirm",
            datatyp  = CONFIRM,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (KVConfig.workloadPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME KVStats.sentConfirm,
            receiveStatistics = SOME KVStats.receivedConfirm
         } `unit $ x

         datatype insert = INSERT
         fun insertTy x  = Method.new {
            name     = "coordinator/insert",
            datatyp  = INSERT,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (KVConfig.workloadPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME KVStats.sentInsert,
            receiveStatistics = SOME KVStats.receivedInsert
         } `FakeItem.t `confirmTy $ x

         datatype update = UPDATE
         fun updateTy x  = Method.new {
            name     = "coordinator/update",
            datatyp  = UPDATE,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (KVConfig.workloadPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME KVStats.sentUpdate,
            receiveStatistics = SOME KVStats.receivedUpdate
         } `FakeItem.t `confirmTy $ x

         datatype delete = DELETE
         fun deleteTy x  = Method.new {
            name     = "coordinator/delete",
            datatyp  = DELETE,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (KVConfig.workloadPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME KVStats.sentDelete,
            receiveStatistics = SOME KVStats.receivedDelete
         } `ID.t `confirmTy $ x

         datatype find = FIND
         fun findTy x  = Method.new {
            name     = "coordinator/find",
            datatyp  = FIND,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (KVConfig.workloadPriority, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics    = SOME KVStats.sentFind,
            receiveStatistics = SOME KVStats.receivedFind
         } `FakeItem.t `int32l $ x

         datatype register = REGISTER
         fun registerTy x  = Entry.new {
            name     = "coordinator/register",
            datatyp  = REGISTER,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (KVConfig.workloadPriority, Reliability.reliable),
            tailData = TailData.manual,
            sendStatistics    = SOME KVStats.sentRegister,
            receiveStatistics = SOME KVStats.receivedRegister
         } `ID.t `insertTy `updateTy `deleteTy `findTy $ x
      end
      
      fun setupEndpoint () =
         let
            val privateKey = CUSP.Crypto.PrivateKey.new { entropy = Entropy.get }
            fun cuspErrorHandler exn =
               Log.logExt (Log.INFO, module, fn () => General.exnMessage exn)

            fun tryPort port =
               let
                  val endpoint = CUSP.EndPoint.new {
                        port    = SOME port,
                        handler = cuspErrorHandler,
                        entropy = Entropy.get,
                        key     = privateKey,
                        options = SOME {
                           encrypt   = false,
                           publickey = CUSP.Suite.PublicKey.defaults,
                           symmetric = CUSP.Suite.Symmetric.defaults
                        }
                     }
                  val () = CUSP.EndPoint.setRate (endpoint, SOME {
                     rate = KVConfig.bandwidth,
                     burst = KVConfig.bandwidthBurstWindow
                  })
               in
                  endpoint
               end
               handle _ =>              
                  if port < KVConfig.maxPort then tryPort (port+1)
                  else raise At (module (), Fail "no port available")
         in
            tryPort KVConfig.minPort
         end
         
      val nullByte = Word8Vector.tabulate (1, fn _ => 0w0)

      fun register { coordinator, interface={ nodeID, insert, update, delete, find }, keepAlive } =
         let
            val endpoint = setupEndpoint ()
            val close = ref (fn notify => notify ())
            fun destroy notify =
               let
                  val () = close := (fn notify => notify ())
               in
                  ignore (CUSP.EndPoint.whenSafeToDestroy (endpoint, notify))
               end
            val close = ref destroy
            
            (* contact coordinator *)
            fun register NONE = close := destroy
              | register (SOME (conversation, execRegister)) =
               let
                  (* advertise services *)
                  val (insert, closeInsert) = 
                     Conversation.response (conversation, {
                        methodTy = insertTy,
                        method   = fn item => fn cb => insert (item, cb)
                     })
                  val (update, closeUpdate) = 
                     Conversation.response (conversation, {
                        methodTy = updateTy,
                        method   = fn item => fn cb => update (item, cb)
                     })
                  val (delete, closeDelete) = 
                     Conversation.response (conversation, {
                        methodTy = deleteTy,
                        method   = fn id => fn cb => delete (id, cb)
                     })
                  val (find, closeFind) = 
                     Conversation.response (conversation, {
                        methodTy = findTy,
                        method   = fn item => fn step => find (item, step)
                     })
                  val closed = ref false
                  (* setup keep-alive *)
                  fun setupKeepalive stream =
                     let
                        fun reschedule _ CUSP.OutStream.RESET = CUSP.OutStream.reset stream
                          | reschedule (event, time) CUSP.OutStream.READY =
                          if !closed then CUSP.OutStream.reset stream
                                     else Main.Event.scheduleAt (event, time)
                          
                        fun keepalive event =
                           let
                              val time = Time.+ (Main.Event.time (), keepAlive)
                           in
                              CUSP.OutStream.write (stream, nullByte, reschedule (event, time))
                           end
                        
                        val event = Main.Event.new keepalive
                     in
                        Main.Event.scheduleIn (event, keepAlive)
                     end
                  (* update cancel function *)
                  val () = close := (fn notify =>
                     let
                        val () = closeInsert ()
                        val () = closeUpdate ()
                        val () = closeDelete ()
                        val () = closeFind ()
                        val () = closed := true
                     in
                        destroy notify
                     end)
               in
                  execRegister nodeID insert update delete find setupKeepalive
               end
               
            val cancel = Conversation.associate (endpoint, coordinator, {
               entry    = Conversation.Entry.fromWellKnownService KVConfig.registerService,
               entryTy  = registerTy,
               complete = register
            })
            val () = close := (fn notify => ( cancel () ; destroy notify ))
         in
             fn notify => (!close) notify
         end

      fun create { endpoint, register, keepAlive } =
         let
            fun onRegister conversation nodeID insert update delete find stream =
               let
                  val quit = ref (fn () => ())
                  
                  fun confirm callback =
                     #1 (Conversation.response (conversation, {
                        methodTy = confirmTy,
                        method   = callback
                     }))

                  val () = quit := register {
                     nodeID = nodeID,
                     insert = fn (item, cb) => insert item (confirm cb),
                     update = fn (item, cb) => update item (confirm cb),
                     delete = fn (id, cb) => delete id (confirm cb),
                     find = fn (item, step) => find item step
                  }
                  
                  (* detect timeout *)
                  val lastPing = ref (Main.Event.time ())
                  local
                     open Time
                  in
                     fun isDead event = 
                        if !lastPing + keepAlive * 3 < Main.Event.time ()
                           then !quit ()
                           else Main.Event.scheduleIn (event, keepAlive)
                     val event = Main.Event.new isDead
                     val () = Main.Event.scheduleIn (event, keepAlive)
                  end

                  fun read () = CUSP.InStream.read (stream, 1, receive)
                  and receive (CUSP.InStream.DATA _) =
                     ( lastPing := Main.Event.time () ; read () )
                    | receive _ =
                     ( Main.Event.cancel event ; !quit () )
               in
                  read ()
               end
         in
            ignore (Conversation.advertise (endpoint, {
               service = SOME KVConfig.registerService,
               entryTy = registerTy,
               entry   = onRegister
            }))
         end
   end
