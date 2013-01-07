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

functor InQueue(Base : IP_STACK) :> IP_STACK =  
   struct
      val module = "simulator/udp/in-queue"
      
      structure Event = Experiment.Event
      
      type t =
         { base         : Base.t,
           receiveEvent : Event.t }

      structure Heap = Heap(Time)
      
      (* forward sent data transparently to the next level *)
      fun send { stack = { base, receiveEvent=_ }, 
                 port, receiver, data, size, when } = 
         Base.send { stack = base,
                     port = port,
                     receiver = receiver,
                     data = data,
                     size = size,
                     when = when }

      (* schedules event for receiving the next message *)
      fun scheduleNext (context as {node, lastDownload, msgQueue, ...}) msgReceivedEvent = 
         case Heap.peek msgQueue of
            (SOME (enteredQueueAt, message)) =>
               let
                  val connection = NodeDefinition.connection (SimulatorNode.definition node)
                  val downstream = ConnectionProperties.downstream connection
                  val receiveBuffer = ConnectionProperties.receiveBuffer connection                                              
                  (* maximum queuing time before discard *)
                  val maxDelay = Bandwidth.delay (downstream, receiveBuffer)

                  (* calculation of the download delay *)
                  val downloadTime = Bandwidth.delay (downstream, #size message)
                  val downloadStart = Time.max (!lastDownload, enteredQueueAt)
                  val arrival = Time.+ (downloadStart, downloadTime)
                  val delay = Time.- (arrival, enteredQueueAt)
               in
                  if Time.< (delay, maxDelay)
                  then
                     Event.scheduleAt (msgReceivedEvent, arrival)
                  else
                     let
                        val _ = Heap.pop msgQueue (* discard outdated message *)
                        val () = SimulatorNode.setCurrent (node, fn () =>
                           Log.log (Log.DEBUG, module, fn () => "Message dropped."))
                     in
                        (* go to next message in queue *)
                        scheduleNext context msgReceivedEvent
                     end
                end
          | NONE => ()
      
      (* event handler, calls receiver handler and schedules next receive *)
      fun receive (context as { node, lastDownload, msgQueue, callback }) msgReceivedEvent =
         case Heap.pop msgQueue of
            (SOME (_, { sender, port, data, size })) => 
               let
                  val () = lastDownload := Event.time () 
                  val () = scheduleNext context msgReceivedEvent
                  (* push message to higher layer *)
                  fun deliverMessage () =
                     callback { 
                        when = Event.time (),
                        sender = sender,
                        port = port,
                        data = data,
                        size = size
                     }
               in
                  SimulatorNode.setCurrent (node, deliverMessage)
               end
          | NONE => raise At (module ^ "/receive", Fail "Cannot receive from empty inqueue")
      
      (* handler for new incoming messages: 
         - puts message in queue
         - scheduleAts receive event if new message is head
       *)
      fun addMessage (context as { msgQueue, ... }) msgReceivedEvent
                     { sender, port, data, size, when } =
         let
            val () = Heap.push (msgQueue, when, {
                        sender = sender,
                        port = port,
                        data = data,
                        size = size
                     })
         in
            (* reschedule receive event because new message might have 
               overtaken the previously queued messages *)
            scheduleNext context msgReceivedEvent
         end

      (* decouple receive callback by putting an event triggered queue in between *)
      fun bind cb = 
         let
            val context = {
               node = SimulatorNode.current (),
               lastDownload = ref (Event.time ()), (* receive time of last message *)
               msgQueue = Heap.new (), (* buffered incoming messages *)
               callback = cb
            }
         
            (* event that is triggered when the next message has been downloaded *) 
            val msgReceivedEvent = Event.new (receive context)
         in
            {
               base = Base.bind (addMessage context msgReceivedEvent),
               receiveEvent = msgReceivedEvent
            }
         end

      fun close { base, receiveEvent } =
         let
            val () = Log.log (Log.DEBUG, module ^ "/close", fn () => "Closing in-queue.")
            val () = Event.cancel receiveEvent
         in
            Base.close base
         end
   end
