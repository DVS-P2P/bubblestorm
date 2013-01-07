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

structure SMLTime = Time (* Keep a backup of the SML idea of time *)

structure Time :> TIME_EXTRA =
   struct
      structure Base =
         struct
            type t = Int64.int
            val op <  : t * t -> bool = op <
            val op == : t * t -> bool = op =
         end
      structure Base = OrderFromLessEqual(Base)
      open Base
      
      val t = Serial.int64l
      
      val op + = Int64.+
      val op - = Int64.-
      
      fun fromNanoseconds   x = Int64.fromInt x
      fun fromMicroseconds  x = Int64.fromInt x * 1000
      fun fromMilliseconds  x = Int64.fromInt x * 1000000
      fun fromSeconds       x = Int64.fromInt x * 1000000000
      fun fromMinutes       x = Int64.fromInt x * 60000000000
      fun fromHours         x = Int64.fromInt x * 3600000000000
      fun fromDays          x = Int64.fromInt x * 86400000000000
      fun fromSecondsReal32 x =
         Int64.fromLarge (Real32.toLargeInt IEEEReal.TO_NEAREST (x * 1000000000.0))
      fun fromNanoseconds64 x = x
      
      val zero : Int64.int = 0
      val maxTime = valOf Int64.maxInt
      
      (* useful constants *)
      val oneDay = fromDays 1
      val oneHour = fromHours 1
      val oneMinute = fromMinutes 1
      val oneSecond = fromSeconds 1
      
      fun toNanoseconds x = Int64.toLarge x
      fun toNanoseconds64 x = x
      fun toSecondsReal32 x = Real32.fromLargeInt (Int64.toLarge x) / 1000000000.0
      fun toSeconds x = Int64.toLarge (x div oneSecond)
      
      val toDate = Date.fromTimeUniv o Time.fromSeconds o toSeconds
      val fromDate = Int64.fromLarge o Time.toNanoseconds o Date.toTime
      
      val zeroChr = Char.ord #"0"
      fun padInt (0, _) tail = tail
        | padInt (digits, x) tail =
             padInt (digits-1, x div 10)
             (Char.chr (Int.+ (zeroChr, x mod 10)) :: tail)
      fun fmtInt' 0 tail = tail
        | fmtInt' value tail =
             fmtInt' (value div 10)
             (Char.chr (Int.+ (zeroChr, value mod 10)) :: tail)
      fun chr c tail = c :: tail
      
      fun fmtInt 0 tail = #"0" :: tail
        | fmtInt x tail = fmtInt' x tail
      
      fun cropLow (i, x) =
         if x mod 10 = 0 
         then cropLow (i-1, x div 10) 
         else (i, x)
         
      fun fmtNano ns tail =
         if ns = 0 then [] else 
         #"." :: padInt (cropLow (9, Int64.toInt ns)) tail
      
      local
         open Date
      in
         val frommonth: month -> int =
           fn Jan => 1 | Feb => 2  | Mar => 3  | Apr => 4
            | May => 5 | Jun => 6  | Jul => 7  | Aug => 8
            | Sep => 9 | Oct => 10 | Nov => 11 | Dec => 12
         val tomonth: int -> month =
           fn 1 => Jan | 2  => Feb | 3  => Mar | 4  => Apr
            | 5 => May | 6  => Jun | 7  => Jul | 8  => Aug
            | 9 => Sep | 10 => Oct | 11 => Nov | 12 => Dec
            | _ => raise Domain
      end
                                 
      fun toAbsoluteString x = 
        let
           open Date
           val date = toDate x
           val month = frommonth o month
           val fmt =
              padInt (4, year   date) o chr #"-" o
              padInt (2, month  date) o chr #"-" o
              padInt (2, day    date) o chr #" " o
              padInt (2, hour   date) o chr #":" o
              padInt (2, minute date) o chr #":" o
              padInt (2, second date) o
              fmtNano (x mod oneSecond)
        in
           String.implode (fmt [])
        end
      
      fun toRelativeString x =
         let
            val (sign, x) = 
               if x < 0 
               then (fn t => #"~" :: t, ~x) 
               else (fn t => t, x)
            
            val (days,    x) = (Int64.toInt (x div oneDay),    x mod oneDay)
            val (hours,   x) = (Int64.toInt (x div oneHour),   x mod oneHour)
            val (minutes, x) = (Int64.toInt (x div oneMinute), x mod oneMinute)
            val (seconds, x) = (Int64.toInt (x div oneSecond), x mod oneSecond)
            
            val padSeconds = padInt (2, seconds) o fmtNano x
            val padMinutes = padInt (2, minutes) o chr #":" o padSeconds
            val padHours   = padInt (2, hours)   o chr #":" o padMinutes
            
            val nopadSeconds = fmtInt seconds o fmtNano x
            val nopadMinutes = fmtInt minutes o chr #":" o padSeconds
            val nopadHours   = fmtInt hours   o chr #":" o padMinutes
            val nopadDays    = fmtInt days    o chr #" " o padHours
            
            val fmt =
               if Int.> (days,    0) then nopadDays    else
               if Int.> (hours,   0) then nopadHours   else
               if Int.> (minutes, 0) then nopadMinutes else
               nopadSeconds
            val fmt = sign o fmt
         in
            String.implode (fmt [])
         end
      
      fun toString x =
         if x < oneDay andalso x > ~oneDay 
         then toRelativeString x
         else toAbsoluteString x
         
      fun scan readChar s =
         let
            val readInt = Int.scan StringCvt.DEC readChar
            fun readPosInt s = 
               Option.mapPartial
               (fn (x, s) => if Int.>= (x, 0) then SOME (x, s) else NONE)
               (readInt s)
            
            (* ---------------- parse the date part ---------------- *)
            
            val readYear  = readPosInt
            val readMonth = readPosInt
            val readDay   = readPosInt

            fun convertDate (year, month, day) =
               let
                 val (extraYear, month) = (month div 12, month mod 12)
                 val year = Int.+ (year, extraYear)
                 val month = tomonth month
               in
                  fromDate (Date.date { 
                     year = year,
                     month = month,
                     day = day,
                     hour = 0,
                     minute = 0,
                     second = 0,
                     offset = SOME(Time.zeroTime)}) (* make it UTC *)
               end
                              
            fun parseDate s =
               case readYear s of
                  NONE => NONE
                | SOME (year, s) => 
                  (case readChar s of
                     SOME (#"-", s) =>
                        (case readMonth s of
                           NONE => NONE
                         | SOME (month, s) =>
                           (case readChar s of
                              SOME (#"-", s) =>
                                 (case readDay s of
                                    SOME (day, s) => SOME (convertDate (year, month, day), s)
                                  | NONE => NONE)
                            | _ => NONE))
                   | _ => NONE)
            
            (* ---------------- parse the time of day part ---------------- *)

            fun convert cvt value =
               let
                  fun apply (data, rem) = (cvt data, rem)
               in
                  Option.map apply value
               end

            val ord64 = Int64.fromInt o Char.ord
            val ord0 = ord64 #"0"
            fun readNano (result, scale, s) =
               case readChar s of
                  NONE => SOME (result, s)
                | SOME (c, s') => 
                    if not (Char.isDigit c) then SOME (result, s) else 
                    readNano (result + (ord64 c - ord0) * scale, scale div 10, s')
            val readHour   = convert fromHours   o readPosInt
            val readMinute = convert fromMinutes o readPosInt
            val readSecond = convert fromSeconds o readPosInt
            
            fun add read (time, s) =
               case read s of
                  SOME (readTime, s) => SOME (time + readTime, s)
                | NONE => NONE
                  
            fun parseChar c (time, s) =
               case readChar s of
                  NONE => NONE
                | SOME (x, s) =>
                    if x = c then SOME (time, s) else NONE
            fun sep c = Option.mapPartial (parseChar c)
            
            fun parseNanoOpt (time, s) =
               case readChar s of
                  NONE => SOME (time, s)
                | SOME (c, s') =>
                     if c <> #"." then SOME (time, s) else
                     readNano (time, 100000000, s')
            
            val parseSecond = Option.mapPartial parseNanoOpt o add readSecond
            val parseMinute = Option.mapPartial parseSecond o sep #":" o add readMinute
            val parseHour   = Option.mapPartial parseMinute o sep #":" o add readHour
                                      
            fun parseTime (time, s) =
               case parseHour (time, s) of
                  SOME (time, s) => SOME (time, s) (* HH:MM:SS[.XXXX] *)
                | NONE => 
                  case parseMinute (time, s) of
                     SOME (time, s) => SOME (time, s) (* MM:SS[.XXXX] *)
                   | NONE =>
                     case parseSecond (time, s) of
                        SOME (time, s) => SOME (time, s) (* SS[.XXXX] *)
                      | NONE => NONE (* unparseable *)

            fun parseUnsignedRelative (s as s') =
               case readPosInt s of
                   NONE => parseTime (zero, s')
                 | SOME (days, s) =>
                      case readChar s of
                         SOME (#" ", s) =>
                           (case parseHour (fromDays days, s) of
                               NONE => parseTime (zero, s')
                             | z => z)
                       | _ => parseTime (zero, s')
            
            fun parseRelative s =
               case readChar s of
                  SOME (#"~", s) => convert ~ (parseUnsignedRelative s)
                | _ => parseUnsignedRelative s
            
         in
            case parseDate s of
               NONE => parseRelative s
             | SOME (date, s as s') => 
                  (case readChar s of
                     SOME (#" ", s) =>
                        (case parseTime (date, s) of
                           NONE => SOME (date, s')
                         | SOME (time, s) => SOME (time, s)) 
                   | _ => SOME (date, s'))
         end
            
      fun fromString s = StringCvt.scanString scan s
      
      val realTime = Int64.fromLarge o Time.toNanoseconds o Time.now
      
      fun multReal32 (x, r) = fromSecondsReal32 (toSecondsReal32 x * r)
      fun x * i = Int64.* (x, Int64.fromInt i)
      fun x div y = Int64.toInt (Int64.div (x, y))
      val div64 = Int64.div
      fun divInt (x, i) = Int64.div (x, Int64.fromInt i)      
      fun divInt64 (x, i) = Int64.div (x, i)      
      
      val hash = Hash.int64
   end

(*
val [timeStr] = CommandLine.arguments ()
val fmt = 
   case Time.fromString timeStr of
      NONE => ["bogus"]
    | SOME x => [Time.toAbsoluteString x, " ", Time.toRelativeString x]
val () = print (concat fmt ^ "\n")
*)
