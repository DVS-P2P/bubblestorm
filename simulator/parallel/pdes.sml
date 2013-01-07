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

structure PDES :> PDES =
   struct         
      val module = "simulator/parallel/pdes"
      
      type initFn = {
         database : string,
         experiment : string,
         realtime : bool,
         id : int option,
         idCount : int
      } -> unit
      
      structure UDP = BufferUDP(
         structure Base = UDP4
         structure Event = Main.Event
      )
      
      structure CUSP = CUSP(
         structure Log = Log
         structure UDP = PeerUDP(UDP)
         structure Event = Main.Event
      )
      
      structure Conversation = Conversation(
         structure CUSP = CUSP
         structure Event = Main.Event
         structure Log = Log
         structure Statistics = Statistics
      )

      val registerMaster = 0w6970
      val conversationStartingPoint = 0w7069
   
      (* TODO: improve error handling *)
      fun cuspErrorHandler exn = raise At (module, Fail (General.exnMessage exn))
      
      open CUSP
      
      fun createEndPoint port = EndPoint.new { 
         port    = port,
         handler = cuspErrorHandler,
         entropy = Entropy.get,
         key     = Crypto.PrivateKey.new { entropy = Entropy.get },
         options = NONE 
      }
   
      open Conversation                                                                              
      
      fun hostname conversation =
         let
            val host = host conversation
            val address = Option.map Address.toString (Host.remoteAddress host)
         in
            " <" ^ getOpt (address, "???") ^ ">"
         end
      
      fun getHostAddress conversation =
         case Host.remoteAddress (host conversation) of
            NONE => raise At (module, Fail ("could not retrieve address from conversation"))
          | SOME address => address 

      local
         open Serial
      in
         datatype initLP = INIT_LP
         fun initLPTy x = Method.new {
            name     = "initLP",
            datatyp  = INIT_LP,
            ackInfo  = AckInfo.silent,
            duration = Duration.oneShot,
            qos      = QOS.static (Priority.default, Reliability.reliable),
            tailData = TailData.vector {maxLength = 10000},
            sendStatistics =  NONE,
            receiveStatistics = NONE
         } `int32l `int32l `int32l $ x 
            
         datatype startConversationPoint = START_CONVERSATION_POINT
         fun startConversationPointTy x = Entry.new {
            name     = "Conversation Starting Point",
            datatyp  = START_CONVERSATION_POINT,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Priority.default, Reliability.reliable),
            tailData = TailData.vector {maxLength = 10000},
            sendStatistics = NONE,
            receiveStatistics = NONE
         } $ x
            
         datatype registerLP = REGISTER_LP
         fun registerLPTy x = Entry.new {
            name     = "connectMaster",
            datatyp  = REGISTER_LP,
            ackInfo  = AckInfo.silent,
            duration = Duration.permanent,
            qos      = QOS.static (Priority.default, Reliability.reliable),
            tailData = TailData.none,
            sendStatistics =  NONE,
            receiveStatistics = NONE
         } `initLPTy `startConversationPointTy $ x
      end

      datatype lpInfoTable =  LPINFOTABLE of {
         id : int,
         networkAddress : CUSP.Address.t,
         entryPoint :  startConversationPoint Conversation.Entry.t
      }

      fun id (LPINFOTABLE fields) = #id fields
                                          
      local
         open Serial
         val serialForm = aggregate tuple3 `int32l `Address.t `startConversationPointTy $
         val { toVector, parseVector, length, ... } = methods serialForm
      in
         fun lpInfoTableToVector lpList =
            let
               fun lpInfoToVector (LPINFOTABLE { id, networkAddress, entryPoint }) =
                  toVector (id, networkAddress, entryPoint)
            in
               Word8Vector.concat (List.map lpInfoToVector lpList)
            end
   
         fun lpInfoTableFromVectorSlice slice =
            let
               val totalLength = Word8VectorSlice.length slice
               
               fun split pos =
                  if pos + length > totalLength then [] else
                     Word8VectorSlice.subslice (slice, pos, SOME length)
                     :: split (pos + length)
   
               fun lpInfoFromSlice slice =
                  let
                     val (id, networkAddress, entryPoint) = parseVector slice
                  in
                     LPINFOTABLE {
                        id = id,
                        networkAddress = networkAddress,
                        entryPoint = entryPoint
                     }
                  end
            in
               List.map lpInfoFromSlice (split 0)
            end
      end
   
      fun startMaster { database, experiment, realtime=_, port, slaveCount } =  
         let
            val idCounter = ref 0
            val lpList = ref []
               
            fun addLPTable (address, entryPoint, respond) = 
               let
                  val id  = !idCounter
                  val () = idCounter := !idCounter + 1
               in
                  lpList := (LPINFOTABLE {
                     id = id,
                     networkAddress = address,
                     entryPoint = entryPoint
                  }, respond) :: !lpList
               end
         
   
            val () = print "\n\n\t In Master Mode\n\n\t"
            val endpoint = createEndPoint (SOME port)
              val () = print "\n\n\t Master endPoint Created\n\n\t"
                 
            fun islimitExceeds conversation =
               if (!idCounter >= slaveCount) then 
                  let
                     val () = print ("\n\n\t Limit to connect with Master (i-e " ^
                        Int.toString slaveCount ^ ") has already reached")
                  in
                     OS.Process.exit OS.Process.failure
                  end
               else
                  print ("\n\n Registering the LP: " ^ hostname conversation ^ "\n\n")
            
            fun initLP (tableLength, dbLength, tail) (lpList, respondLP) = 
               respondLP (id lpList) tableLength dbLength tail
               
            fun checkResponsePoint () =
               if (!idCounter = slaveCount) then
                  let
                     val table = lpInfoTableToVector (List.map #1 (!lpList))
                     val tableLength = Word8Vector.length table
                     val dbLength = String.size database
                     val tail = Word8Vector.concat (
                        table :: (Byte.stringToBytes database) :: 
                        (Byte.stringToBytes experiment) :: nil
                     )
                  in
                     List.app (initLP (tableLength, dbLength, tail)) (!lpList)
                  end
               else ()
            
            fun registerLP conversation respond conversationStartPoint = 
               let
                  val _ = islimitExceeds(conversation)
                  val address = getHostAddress conversation
                  val () = addLPTable(address, conversationStartPoint, respond)
               in
                  checkResponsePoint ()
               end   
            
            val _ = advertise (endpoint, {
               service = SOME registerMaster,
               entryTy = registerLPTy, 
               entry   = registerLP
            })
         in  
            ()   
         end 
         
      fun startSlave (master, init : initFn) = 
         let
            val master = case CUSP.Address.fromString master  of
                  [] => raise At (module, Fail ("Unparseable master address " ^ master))
                | address :: _ => address
         
            val lpList = ref []
            val () = print "\n\n\t In Slave Mode\n\n\t"
            val endpoint = createEndPoint NONE
            val () = print "\n\n\t Slave endPoint Created\n\n\t"
            
            fun onStartConversation _ _ =
            (*fun onStartConversation conversation=_ tailData=_ =*)
               print "\n\n\t Conversation starting point is created: \n"
            
            val startConversation = #1 (advertise (endpoint, {
               service = SOME conversationStartingPoint,
               entryTy =  startConversationPointTy, 
               entry =  onStartConversation
            }))
            
            fun onResponse id tableLen dbLen tail =
               let
                  val lpTableSlice = Word8VectorSlice.slice (tail, 0, SOME tableLen)
                  val lpTable = lpInfoTableFromVectorSlice lpTableSlice
                  val () = lpList := lpTable
                  val totalLPs = List.length (!lpList)
                  val dbNameSlice = Word8VectorSlice.slice (tail, tableLen, SOME dbLen)
                  val dbNameWord = Word8VectorSlice.vector dbNameSlice
                  val dbName = Byte.bytesToString(dbNameWord)
                  val expNameSlice = Word8VectorSlice.slice (tail, tableLen + dbLen, NONE)
                  val expNameWord = Word8VectorSlice.vector expNameSlice
                  val expName = Byte.bytesToString(expNameWord)
                  val () = print ("\n\n Total number of LPs: " ^ Int.toString totalLPs ^ "\n\n")
               in
                  (* print ("\n\n\t id : " ^ Int.toString(id) ^ " and dbName: " ^ dbName ^ " and expName: " ^ expName)*)
                  init {
                     database = dbName,
                     experiment = expName,
                     realtime = false,
                     id = SOME id,
                     idCount = totalLPs
                  } 
               end
            
            fun onConnectMaster NONE = print "could not connect\n"
              | onConnectMaster (SOME (conversation, registerLP)) =
               let
                  (*val () = print("\n\n\t Slave has been registered with: " ^ hostname conversation^ " \n")*)
                  val respondMethod = #1 (Conversation.response (conversation, {
                     methodTy = initLPTy,
                     method   = onResponse
                  }))   
               in
                  registerLP respondMethod startConversation
               end
            
            val () = print ("connecting to master " ^ (Address.toString master) ^ "\n")
            val _ = associate(endpoint, master, {   
               entry    = Entry.fromWellKnownService registerMaster,
               entryTy  = registerLPTy,
               complete = onConnectMaster
            })
         in
            ()
         end
   end
