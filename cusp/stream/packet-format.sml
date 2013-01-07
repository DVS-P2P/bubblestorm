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

structure PacketFormat =
   struct
      (* Segments have this layout [4 type] [12 reserved] [16 id] *)
      
      datatype segment =
         READER of reader * { id: Word16.word }
       | WRITER of writer * { id: Word16.word, seq: int }
       | CREATE of create * { service: Word16.word, seq: int }
       | CORRUPT
      and reader =
         DATA of { eof: bool, offset: bool, length: int }
       | READER_CTL of reader_ctl
      and reader_ctl =
         WRITER_RESETS
      and writer =
         WRITER_CTL of writer_ctl
      and writer_ctl =
         READER_RESETS
       | READER_BARRIER (* followed by 4-byte barrier *)
      and create =
         CONNECT
      
      infix 6 || &&
      infix 7 << >>
      val op || = Word32.xorb
      val op && = Word32.andb
      val op << = Word32.<<
      val op >> = Word32.>>
      
      val from16 = Word32.fromLarge o Word16.toLarge
      val to16   = Word16.fromLarge o Word32.toLarge
      val fromInt = Word32.fromInt
      val toInt   = Word32.toInt
      
      val { writeSlice, parseSlice, align, ... } = 
         Serial.methods Serial.word32b
      
      fun parse data =
         if Word8ArraySlice.length data = 0 then CORRUPT else
         let
            val command = parseSlice data
            val ty = command >> 0w28
            val seq = toInt (command >> 0w24 && 0wxf)
            val id  = to16  (command && 0wxffff)
            val len = toInt (command >> 0w16 && 0wxfff)
         in
            case ty of
               0wx0 => READER (DATA { eof=false, offset=false, length = len }, { id = id })
             | 0wx1 => READER (DATA { eof=true,  offset=false, length = len }, { id = id })
             | 0wx2 => READER (DATA { eof=false, offset=true,  length = len }, { id = id })
             | 0wx3 => READER (DATA { eof=true,  offset=true,  length = len }, { id = id })
             | 0wx4 => READER (READER_CTL WRITER_RESETS,   { id = id })
             | 0wx5 => WRITER (WRITER_CTL READER_RESETS,   { id = id, seq = seq })
             | 0wx6 => WRITER (WRITER_CTL READER_BARRIER,  { id = id, seq = seq })
             | 0wx7 => CREATE (CONNECT, { service = id, seq = seq })
             | _ => CORRUPT
         end
      
      val write = fn
         (data, READER (DATA { eof, offset, length }, { id })) =>
            let
               val ty = 
                  case (eof, offset) of
                     (false, false) => 0w0
                   | (true,  false) => 0w1
                   | (false, true)  => 0w2
                   | (true,  true)  => 0w3
               val () = if length >= 4096 then raise Overflow else ()
               val len = fromInt length
               val id = from16 id
            in
               writeSlice (data, ty << 0w28 || len << 0w16 || id)
            end
       | (data, READER (READER_CTL WRITER_RESETS, { id })) =>
            let
               val ty = 0wx4
               val id = from16 id
            in
               writeSlice (data, ty << 0w28 || id)
            end
       | (data, WRITER (WRITER_CTL READER_RESETS, { id, seq })) =>
            let
               val ty = 0wx5
               val () = if seq >= 16 then raise Overflow else ()
               val id = from16 id
               val seq = fromInt seq
            in
               writeSlice (data, ty << 0w28 || seq << 0w24 || id)
            end
       | (data, WRITER (WRITER_CTL READER_BARRIER, { id, seq })) =>
            let
               val ty = 0wx6
               val () = if seq >= 16 then raise Overflow else ()
               val id = from16 id
               val seq = fromInt seq
            in
               writeSlice (data, ty << 0w28 || seq << 0w24 || id)
            end
       | (data, CREATE (CONNECT, { service, seq })) =>
            let
               val ty = 0wx7
               val () = if seq >= 16 then raise Overflow else ()
               val service = from16 service
               val seq = Word32.fromInt seq
            in
               writeSlice (data, ty << 0w28 || seq << 0w24 || service)
            end
       | (_, CORRUPT) => raise Fail "impossible"
      
      val alignMask = Word32.fromInt align - 0w1
      fun align x =
         Word32.toInt (Word32.andb (Word32.fromInt x + alignMask, 
                                    Word32.notb alignMask))
      
      val debug = fn
         READER (DATA { eof, offset, length }, { id }) =>
            [ " data          id=", Word16.toString id,
              " eof=", Bool.toString eof,
              " offset=", (if offset then "?" else "0"),
              " length=", Int.toString length ]
       | READER (READER_CTL WRITER_RESETS, { id }) => 
            [ " writer resets id=", Word16.toString id ]
       | WRITER (WRITER_CTL READER_RESETS, { id, seq }) =>
            [ " reader reset  id=", Word16.toString id,
              " seq=", Int.toString seq ]
       | WRITER (WRITER_CTL READER_BARRIER, { id, seq }) =>
            [ " reader barrier  id=", Word16.toString id, 
              " seq=", Int.toString seq ]
       | CREATE (CONNECT, { service, seq }) =>
            [ " attach   service=", Word16.toString service,
              " seq=", Int.toString seq ]
       | CORRUPT => 
            [ " CORRUPT" ]
   end
