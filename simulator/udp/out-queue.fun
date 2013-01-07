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

functor OutQueue(Base : IP_STACK) :> IP_STACK =
   struct
      open Time

      type t =
         { congestion : Time.t ref,
           base       : Base.t }

      exception BadSendTime

      (* add a queuing delay to the sent data's timestamp,
       * compute the queuing delay based on sent data.
       * (no event decoupling necessary).
       *)
      fun send { stack = { congestion as ref avail, base },
                 port, receiver, data, size, when } =
         let
            val node = SimulatorNode.current ()
            val connection = NodeDefinition.connection (SimulatorNode.definition node)
            val upstream = ConnectionProperties.upstream connection
            val sendBuffer = ConnectionProperties.sendBuffer connection

            val now = Experiment.Event.time ()
            val () = if when == now then () else raise BadSendTime
            val sendStart = if now < avail then avail else now
            val delay = Bandwidth.delay (upstream, size)
            val maxDelay = Bandwidth.delay (upstream, sendBuffer)
            val threshold = now + maxDelay
            val sendEnd = sendStart + delay
         in
            if sendEnd < threshold
               then (congestion := sendEnd
                     ; Base.send { stack = base,
                                   port = port,
                                   receiver = receiver,
                                   data = data,
                                   size = size,
                                   when = sendEnd })
            else (* message dropped *)
               Log.log (Log.DEBUG, "simulator/udp/out-queue",
                  fn () => "Message dropped.")
         end

      fun bind cb = {
         congestion = ref (Experiment.Event.time ()),
         base = Base.bind cb
      }
      
      fun close { congestion=_, base } = Base.close base

   end