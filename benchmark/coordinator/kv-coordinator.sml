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

structure KVCoordinator =
   struct
      val module = "kv/coordinator"
      
      fun usage () =
         print ("Supported arguments are:\n\
         \ \n\
         \-p x, --port x     UDP port to use locally\n\
         \-s x, --size x     size of created items in bytes\n\
         \-r x, --rate x     created items per minute and client\n\
         \-l x, --lifetime x lifetime of an item\n\
         \-m, --managed      turns on managed mode (tracking publisher availability)\n")
      
      fun readArgs () =
         let
            val (args, _) = ArgumentParser.new (CommandLine.arguments (), NONE)
            fun get (x, y) = Option.getOpt (ArgumentParser.optional args x, y)
      
            val port     = get (("port",  #"p", Int.fromString), KVConfig.defaultPort)
            val size     = get (("size", #"i", Int.fromString), KVConfig.defaultItemSize)
            val rate     = get (("rate",  #"r", Real32.fromString), KVConfig.defaultRate)
            val cooldown = get (("cooldown",  #"c", Time.fromString), KVConfig.defaultCooldown)
            val phases   = get (("phases",  #"u", Int.fromString), KVConfig.defaultPhases)
            val delPhases = get (("del-phases",  #"d", Int.fromString), KVConfig.defaultPhases)
            val steps    = KVConfig.defaultSteps
            val phaseDelay = KVConfig.defaultQueryTimeout
            val lifetime = get (("lifetime",  #"b", Time.fromString), KVConfig.defaultLifetime)
            val keepalive = get (("keepalive",  #"k", Time.fromString), KVConfig.defaultKeepAlive)
            val managed  = ArgumentParser.flag args ("managed", #"m")
            val base = LogarithmicMeasurement.getBase (lifetime, steps)
      
            val fold = List.foldl (fn (a,b) => b ^ " " ^ a) ""
            val () = case ArgumentParser.complainUnused args of
                  nil => ()
                | x => (usage () ; raise Fail ("Illegal parameters: " ^ fold x))
      in
         ( port, size, rate, cooldown, phases, delPhases, phaseDelay, steps, 
           base, managed, keepalive )
      end
           
      fun main () =
         let
            val () = Log.logExt (Log.INFO, fn () => module, fn () => "coordinator started")
      
            (* parse args *)
            val ( port, size, rate, cooldown, phases, delPhases, phaseDelay, 
                  steps, base, managed, keepalive ) = readArgs ()
            
            (* create event generator *)
            val generator = WorkloadGenerator.new {
               itemSize = size,
               rate = rate,
               cooldown = cooldown,
               phases = phases,
               delPhases = delPhases,
               phaseDelay = phaseDelay,
               steps = steps,
               base = base,
               managed = managed
            }
            
            (* create endpoint *)
            fun cuspErrorHandler exn =
               Log.logExt (Log.INFO, fn () => module ^ "/endpoint", fn () => General.exnMessage exn)
            val endpoint = CUSP.EndPoint.new {
               port    = SOME port,
               handler = cuspErrorHandler,
               entropy = Entropy.get,
               key     = CUSP.Crypto.PrivateKey.new { entropy = Entropy.get },
               options = SOME {
                  encrypt   = false,
                  publickey = CUSP.Suite.PublicKey.defaults,
                  symmetric = CUSP.Suite.Symmetric.defaults
               }
            }
         in
            (* setup service for clients *)
            KVProtocol.create {
               endpoint = endpoint,
               register = WorkloadGenerator.register generator,
               keepAlive = keepalive
            }
         end

      val () = Main.run ("kv-coordinator", main)
   end