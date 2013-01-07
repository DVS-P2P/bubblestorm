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

signature CONVERSATION =
   sig
      structure Statistics : STATISTICS
      (* A conversation to a remote system.
       * It tracks all involved streams and bound response methods.
       * A conversation could correspond to an instant messaging association, 
       * a file transfer, or a neighbour in a peer-to-peer network.
       *)
      type conversation
      type t = conversation
      
      (* CUSP types we use *)
      type endpoint
      type instream
      type outstream
      type host
      type address
      type service
      
      val eq : t * t -> bool
      
      (* Access the host on the other end of this conversation *)
      val host : conversation -> host
      val plist : conversation -> PropertyList.t
      
      (* Useful statistics about usage *)
      val traffic : conversation -> Int64.int
      val created : conversation -> Time.t
      
      (* Pretty-print the address *)
      val toString : t -> string
      
      (* Number of active streams *)
      val activeInStreams  : conversation -> int
      val activeOutStreams : conversation -> int
      
      (* Reset all streams and unhook all response methods in conversation. 
       * Also reset the timeout (setTimeout NONE).
       *)
      val reset : conversation -> unit
      
      (* Attempt to close the conversation. 
       * Once activeOutStreams = 0, the callback is fired.
       * Obviously, the caller should stop making new outstreams...
       *)
      val close : conversation * {
         complete : unit -> unit
      } -> unit
      
      (* Set the timeout for this conversation, to fire if no progress is made.
       *   Receiving any data is considered progress.
       *   Acknowledgement of transmitted data is progress.
       *   Adding a new instream  when activeInStreams  = 0 is progress.
       *   Adding a new outstream when activeOutStreams = 0 is progress.
       * If no progress has been made within the specified timeout:
       *    the timeout handler is cleared; like setTimeout (c, NONE)
       *    the dead callback is invoked.
       *
       * Sensible responses include sending a ping, setting a new timeout, or 
       * reseting the conversation. The value of active{In,Out}Streams may be
       * relevant to decide whether to ping or reset.
       *)
      val setTimeout : conversation * {
         limit : Time.t,
         dead  : unit -> unit
      } option -> unit
      
      (* Set the memory limits for this conversation.
       * At most recv/send bytes can be queued and unread/sent.
       * 
       * If the limit is exceeded, streams within the coversation
       * are reset in order of their reliability.
       *
       * Reliability is expressed as a Real32, bigger is more reliable.
       *
       * If only streams requiring full reliablity are left:
       *    the limits are cleared; like setLimits (c, NONE)
       *    the quota function is invoked
       *)
      val setLimits : conversation * {
         recv  : int,
         send  : int,
         quota : unit -> unit
      } option -> unit
      
      structure Priority :
         sig
            type t
            
            (* The default priority is 1000.0 *)
            val default : t
            val fromReal : Real32.real -> t
         end
      
      structure Reliability :
         sig
            type t
            
            val reliable : t
            val fromReal : Real32.real -> t
         end
      
      (* How are the priority and reliability controlled? *)
      structure QOS :
         sig
            type ('a, 'b) t
            
            (* The QOS settings are fixed for all uses of the method *)
            val static : Priority.t * Reliability.t -> ('a, 'a) t
            
            (* Each invocation of the method can change its priority *)
            val dynamic : ('a, Priority.t * Reliability.t -> 'a) t
         end
      
      (* Are senders informed about acknowledgement of their messages? *)
      structure AckInfo :
         sig
            type ('a, 'b) t
            
            (* There is no transport-level confirmation *)
            val silent : ('a, 'a) t
            
            (* The callback is triggered upon completed delivery.
               * False means it was reset, true that it was fully ack'd.
               * The callback will be the first parameter to the function.
               *)
            val callback : ('a, (bool -> unit) -> 'a) t
         end
      
      (* How many times can an exposed method be invoked?
         * It is always possible to unhook an method manually.
         *)
      structure Duration :
         sig
            type 'a t
            datatype hook = REHOOK | UNHOOK  
            exception OneShotUsedTwice of string
            
            (* Exposed methods will be automatically unhooked after use.
               * Attempts to reuse a oneShot method raises a exception.
               *)
            val oneShot : unit t
            
            (* The exposed method will last until manually unhooked. *)
            val permanent : unit t
            
            (* The exposed method must return the hook type.
               * It can thus choose to unhook itself at any time.
               *)
            val custom : hook t
         end
            
      (* Does the method carry information after the arguements?
         * How should this information be managed?
         *)
      structure TailData :
         sig
            type ('a, 'b, 'c) t
            exception StringTooLong of string (* Don't exceed maxLength! *)
            
            val none : (unit, 'a, 'a) t
            val string : {maxLength : int} -> (string -> unit, 'a, string -> 'a) t
            val vector : {maxLength : int} -> (Word8Vector.vector -> unit, 'a, Word8Vector.vector -> 'a) t
            val manual : ((outstream -> unit) -> unit, 'a, instream -> 'a) t
         end
            
      (* Method calls have a policy that controls their behaviour *)
      (*structure Policy :
         sig
            type ('a, 'b, 'c, 'd) t
            val make : {
               ackInfo  : ('e, 'b)     AckInfo.t,
               duration : 'f           Duration.t,
               qos      : ('a, 'e)     QOS.t,
               tailData : ('c, 'f, 'd) TailData.t
            } -> unit -> ('a, 'b, 'c, 'd) t
         end
      *)
      
      
      
      (* Entry points and methods need an description. create a description like this:
       *   datatype foo = FOO
       *   val description = {
       *      name     = "foo",
       *      datatyp  = FOO,
       *      ackInfo  = AckInfo.silent,
       *      duration = Duration.oneShot,
       *      qos      = QOS.static (Priority.default, Reliability.reliable),
       *      tailData = TailData.none,
       *      sendStatistics = Statistics.new ...,
       *      receiveStatistics = Statistics.new ...
       *   }
       *)
      type ('a, 'b, 'c, 'd, 'e, 'f, 'g) description = {
         name     : string,
         datatyp  : 'a,
         ackInfo  : ('f, 'c)     AckInfo.t,
         duration : 'g           Duration.t,
         qos      : ('b, 'f)     QOS.t,
         tailData : ('d, 'g, 'e) TailData.t,
         sendStatistics    : Statistics.t option,
         receiveStatistics : Statistics.t option
      }
      (* An entry point is created as follows:
       *   val foo = Entry.new description `int32 `real32 $
       *      
       *   val (entry, unhook) = 
       *      advertise (endpoint, {
       *         service = NONE,
       *         entryTy = foo,
       *         entry   = fn (conversation, instream) i32 r32 => UNHOOK
       *      })
       *)
      structure Entry :
         sig
            type 'a t
            type ('a, 'b) glue
            type ('a, 'b, 'c) ty = 
               ('a t, 'a t, ('b, conversation -> 'c) glue) Serial.t
            
            val new : ('a, 'b, 'c, 'd, 'e, 'f ,'g) description ->
               (('d, 'd, 'e, 'e) Serial.a,
                ('b, 'd, 'h, 'e) Serial.a,
                ('a, 'c, 'h) ty,
                'i) FoldR.fold
            
            val fromWellKnownService : service -> 'a t
            val toString : 'a t -> string
            val name : ('a, 'b, 'c) ty -> string
         end
      
      (* A method is created as follows:
       *   datatype foo = FOO
       *   val foo = Method.new Policy.service FOO "foo" `int32 `real32 $
       *      
       *   val (method, unhook) = 
       *      response (conversation, {
       *         methodTy = foo,
       *         method   = fn i32 r32 => ()
       *      })
       *)
      structure Method :
         sig
            type 'a t
            type 'a glue
            type ('a, 'b, 'c) ty = 
               ('a t, 'b, 'c glue) Serial.t
            
            val new : ('a, 'b, 'c, 'd, 'e, 'f ,'g) description ->
               (('d, 'd, 'e, 'e) Serial.a,
                ('b, 'd, 'h, 'e) Serial.a,
                ('a, 'c, 'h) ty,
                'i) FoldR.fold

            val name : ('a, 'b, 'c) ty -> string
         end
      
      structure Manual :
         sig
            (* Plug a stream into the conversation for receiving.
             * The cost (in terms of setLimits) of the stream is buffer length.
             * If premature SHUTDOWN/RESET occurs, complete receives false.
             *)
            val recv : t * instream * {
               buffer      : Word8ArraySlice.slice,
               complete    : bool -> unit,
               reliability : Reliability.t
            } -> unit
            
            (* Expect an end to the stream.
             *   Costs nothing against setLimits.
             *   Has full reliablility (since it has no cost).
             *
             * If SHUTDOWN is received, the callback is invoked with true.
             * If DATA/RESET is received, the instream is reset and false returned.
             *)
            val recvShutdown : t * instream * {
               complete : bool -> unit
            } -> unit
            
            (* Plug a stream into the conversation for writing.
             * The cost (in terms of setLimits) of the stream is:
             *   queuedInFlight + queuedToRetransmit + length of passed data.
             * If RESET is received the callback is invoked with false.
             * The stream is removed from the conversation when complete is called.
             * complete is called when CUSP wants more data.
             *)
            val send : t * outstream * {
               buffer      : Word8Vector.vector, 
               complete    : bool -> unit,
               reliability : Reliability.t
            } -> unit
            
            (* Shutdown the stream.
             * The cost (in terms of setLimits) of the stream is:
             *   queuedInFlight + queuedToRetransmit
             * If RESET is received, the callback is invoked with false.
             * complete is called when all data and the shutdown have been acknowledged.
             *)
            val sendShutdown : t * outstream * {
               complete    : bool -> unit,
               reliability : Reliability.t
            } -> unit
         end

      (* Advertise an entry which can be used to start a conversation.
       * A corresponding call to associate will begin the conversation
       * which should then procede by passing response methods between
       * the two participants.
       *)
      val advertise : endpoint * {
         service : service option,
         entryTy : ('a, 'b, 'c) Entry.ty,
         entry   : t -> 'c
      } -> 'a Entry.t * (unit -> unit)
      
      (* Expose a method for receiving responses.
       * The result can (and should) be passed to via RPC functions.
       * Similar to advertise, but a new conversation is not created.
       *)
      val response : t * {
         methodTy : ('a, 'b, 'c) Method.ty,
         method   : 'c
      } -> 'a Method.t * (unit -> unit)
      
      (* Establish a new conversation to an advertised entry point.
       * The complete callback is invoked once the channel is established.
       * It receives the new conversation and a method for remote invocation.
       * The method can be called at most once (on pain of OneShotUsedTwice).
       * If it is not called at all (perhaps the Host public key is bad),
       * then the underlying stream is reset and conversation dies.
       *)
      val associate : endpoint * address * {
         entry    : 'a Entry.t,
         entryTy  : ('a, 'b -> 'c, 'd) Entry.ty,
         complete : (t * ('b -> 'c)) option -> unit
      } -> (unit -> unit)
   end
