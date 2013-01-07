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

structure Address :> ADDRESS_EXTRA =
   struct

      structure Ip =
         struct
            structure Z = OrderFromCompare(type t = Word32.word
                                           val compare = Word32.compare)
            open Z

            val hash = Hash.word32
            val invalid = 0w0
            fun fromWord32 x = x
            fun toWord32 x = x

            fun toBytes w32 =
               let
                  val w32t8 = Word8.fromLarge o Word32.toLarge
                  val (w3, w32) = (w32t8 w32, Word32.>> (w32, 0w8))
                  val (w2, w32) = (w32t8 w32, Word32.>> (w32, 0w8))
                  val (w1, w32) = (w32t8 w32, Word32.>> (w32, 0w8))
                  val (w0, _)   = (w32t8 w32, Word32.>> (w32, 0w8))
               in
                  (w0, w1, w2, w3)
               end
      
            fun fromBytes (w0, w1, w2, w3) = 
               let
                  val w8t32 = Word32.fromLarge o Word8.toLarge
                  val w32 = 0w0
                  val w32 = Word32.<< (w32, 0w8) + w8t32 w0
                  val w32 = Word32.<< (w32, 0w8) + w8t32 w1
                  val w32 = Word32.<< (w32, 0w8) + w8t32 w2
                  val w32 = Word32.<< (w32, 0w8) + w8t32 w3
               in
                  w32
               end      

            fun toString x =
               let
                  val (w0, w1, w2, w3) = toBytes x
               in
                  concat [ 
                     Word8.fmt StringCvt.DEC w0, ".",
                     Word8.fmt StringCvt.DEC w1, ".",
                     Word8.fmt StringCvt.DEC w2, ".",
                     Word8.fmt StringCvt.DEC w3
                  ]
               end

            fun scan readChar s =
               let
                  val readWord8 = Word8.scan StringCvt.DEC readChar
               in
                  case readWord8 s of
                     NONE => NONE
                   | SOME (w0, s) => 
                        (case readChar s of
                           SOME (#".", s) =>
                              (case readWord8 s of
                                 NONE => NONE
                               | SOME (w1, s) => 
                                    (case readChar s of
                                       SOME (#".", s) =>
                                          (case readWord8 s of
                                             NONE => NONE
                                           | SOME (w2, s) => 
                                                (case readChar s of
                                                   SOME (#".", s) =>
                                                      (case readWord8 s of
                                                         NONE => NONE
                                                       | SOME (w3, s) =>                                                      
                                                            SOME (fromBytes (w0, w1, w2, w3), s))
                                                 | _ => NONE)
                                          )
                                     | _ => NONE)
                              )
                         | _ => NONE)
               end
               
            local
               open Serial
               (* we have the "ip" type -- 4 word8s (not 32-bit aligned)
                * This tuple tuple is used opaquely with to/from a vector.
                * We use a pickle writer here b/c it is a super-fast way
                * to convert the 4 word8 tuple into a vector.
                *)
               val t = aggregate tuple4 `word8 `word8 `word8 `word8 $
            in
               val t = map {
                    store = toBytes,
                    load  = fromBytes,
                    extra = fn _ => ()
                 } t
            end
         end
         
      type port = Word16.word

      type t = Ip.t * port
      
      val portZero = 0w0 : Word16.word
      
      fun fix { incomplete = (ip, port), using = (ip2, port2) } =
         let
            val ip = if ip = Ip.invalid then ip2 else ip
            val port = if port = portZero then port2 else port
         in
            (ip, port)
         end

      fun invalidIP port = (Ip.invalid, port)
      fun invalidPort ip = (ip, portZero)
      val invalid = invalidPort Ip.invalid
      
      fun fromIpPort x = x
      fun ip (x, _) = x
      fun port (_, x) = x
            
      val defaultPort : port ref = ref 0w8585
      (*fun setDefaultPort port = defaultPort := port*)

      fun hash (ip, port) = Hash.word32 ip o Hash.word16 port
       
      fun compare ((aip, aport), (bip, bport)) =
         case Word32.compare (aip, bip) of
            LESS => LESS
            | GREATER => GREATER
            | EQUAL => Word16.compare (aport, bport)
      structure Z = OrderFromCompare(type t = t val compare = compare)
      open Z

      fun toString (ip, port) =
         let
            val (w0, w1, w2, w3) = Ip.toBytes ip
         in
            concat [ 
               Word8.fmt StringCvt.DEC w0, ".",
               Word8.fmt StringCvt.DEC w1, ".",
               Word8.fmt StringCvt.DEC w2, ".",
               Word8.fmt StringCvt.DEC w3, ":",
               Word16.fmt StringCvt.DEC port
            ]
         end

      fun scan readChar s =
         let
            val readWord16 = Word16.scan StringCvt.DEC readChar
         in
            case Ip.scan readChar s of
               NONE => NONE
             | SOME (ip, s as s') => 
                  (case readChar s of
                      SOME (#":", s) =>
                         (case readWord16 s of
                            NONE => SOME ((ip, !defaultPort), s')
                          | SOME (port, s) => SOME ((ip, port), s))
                    | _ => SOME ((ip, !defaultPort), s'))
         end
         
      fun fromString s =
         case StringCvt.scanString scan s of
            SOME x => [x]
          | NONE => []

      local
         (* We pull some scary shit here to make addresses 16-bit
          * aligned only (so 2* an address fit nicely) and to make
          * certain we can parse relatively quickly.
          *)
         open Serial
      in
         (* An address is fundamentally an (ip, port) *)
         val t = aggregate tuple2 `Ip.t `word16l $
      end

      val defaultPort = fn () => !defaultPort      
   end
