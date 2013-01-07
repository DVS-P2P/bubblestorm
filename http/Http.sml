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

fun log (severity, msg) = Log.logExt (severity, fn () => "http", msg)

structure Http = struct

   (* Everything of an http request except for the body.
    * Only used during parsing the request to reduce pattern matching verbosity *)
   datatype http_request_head
      = REQUEST_HEAD of {
         method : string,
         uri : string,
         version : string,
         headers : string StringMap.t }
      | INVALID_HEAD of string (* string is a short error message *)

   (* A complete http request *)
   datatype http_request
      = REQUEST of {
         method : string,
         uri : string,
         version : string,
         headers : string StringMap.t,
         body : string option }
      | INVALID_REQUEST of string (* string is a short error message *)


   fun timeToHttpDate (time) =
      let
         (* it seems there is no locale independent version of %b *)
         fun monthToStr Date.Jan = "Jan"
           | monthToStr Date.Feb = "Feb"
           | monthToStr Date.Mar = "Mar"
           | monthToStr Date.Apr = "Apr"
           | monthToStr Date.May = "May"
           | monthToStr Date.Jun = "Jun"
           | monthToStr Date.Jul = "Jul"
           | monthToStr Date.Aug = "Aug"
           | monthToStr Date.Sep = "Sep"
           | monthToStr Date.Oct = "Oct"
           | monthToStr Date.Nov = "Nov"
           | monthToStr Date.Dec = "Dec"

         (* it seems there is no locale independent version of %a *)
         fun dayToStr Date.Mon = "Mon"
           | dayToStr Date.Tue = "Tue"
           | dayToStr Date.Wed = "Wed"
           | dayToStr Date.Thu = "Thu"
           | dayToStr Date.Fri = "Fri"
           | dayToStr Date.Sat = "Sat"
           | dayToStr Date.Sun = "Sun"

         val date = Date.fromTimeUniv (time)
      in
         dayToStr (Date.weekDay date) ^ ", "
         ^ (Date.fmt "%d" date) ^ " "
         ^ monthToStr (Date.month date) ^ " "
         ^ (Date.fmt "%Y %H:%M:%S GMT" date)
      end

   (* FIXME: this only implements the first of the three http date variants,
    *        which is hopefully the most common.
    *
    * Example: Sun, 26 Jun 2011 14:49:01 GMT *)
   fun parseHttpDate (str) =
      let
         fun strToMonth "Jan" = SOME(Date.Jan)
           | strToMonth "Feb" = SOME(Date.Feb)
           | strToMonth "Mar" = SOME(Date.Mar)
           | strToMonth "Apr" = SOME(Date.Apr)
           | strToMonth "May" = SOME(Date.May)
           | strToMonth "Jun" = SOME(Date.Jun)
           | strToMonth "Jul" = SOME(Date.Jul)
           | strToMonth "Aug" = SOME(Date.Aug)
           | strToMonth "Sep" = SOME(Date.Sep)
           | strToMonth "Oct" = SOME(Date.Oct)
           | strToMonth "Nov" = SOME(Date.Nov)
           | strToMonth "Dec" = SOME(Date.Dec)
           | strToMonth _ = NONE

         val parts = Util.splitString (" ", str, NONE)
         val day = getOpt (Int.fromString (List.nth (parts, 1)), ~1)
         val month = strToMonth (List.nth (parts, 2))
         val year = getOpt (Int.fromString (List.nth (parts, 3)), ~1)
         val timeParts = Util.splitString (":", List.nth (parts, 4), NONE)
         val hour = getOpt (Int.fromString (List.nth (timeParts, 0)), ~1)
         val min = getOpt (Int.fromString (List.nth (timeParts, 1)), ~1)
         val sec = getOpt (Int.fromString (List.nth (timeParts, 2)), ~1)
      in
         if day < 0 orelse year < 0 orelse hour < 0 orelse min < 0 orelse sec < 0
            then NONE
            else case month of
               SOME(m) => SOME(Date.date {year=year, month=m, day=day, hour=hour, minute=min, second=sec, offset=NONE})
             | NONE => NONE
      end
      handle _ => (
         log (LogLevels.BUG, fn () => "could not parse http date" ^ str);
         NONE
      )


   (* FIXME: handle possible exception *)
   fun parseHttpRequest (buffer) =
      let
         fun retrieveRequestHead (buffer) =
            let
               (* \r\n is defined in the RFCs but netcat just sends \n => support both for easier debugging
                * FIXME: this won't work if we don't get the first line at once *)
               val newline = case Word8Vector.find (fn x => Byte.byteToChar(x) = #"\r") (!buffer) of
                  SOME(_) => "\r\n"
                | NONE    => "\n"
               val two_newlines = newline ^ newline
               val str = Byte.bytesToString (!buffer)
               val request = (#1 (Substring.position (two_newlines) (Substring.full str)))
               val () = if request = Substring.full str
                  then ()
                  (* remove request head from buffer *)
                  else buffer := Word8VectorSlice.vector (Word8VectorSlice.slice (!buffer, (Substring.size request) + (String.size two_newlines), NONE))
            in
               if (request = Substring.full str)
                  then NONE
                  else SOME(Substring.string request, newline)
            end

         fun parseRequestHead (req, newline) : http_request_head =
            let
               val headers = StringMap.new ()
               val lastHeader = ref ""
               val headerValid = ref true

               fun parseHeader (line) =
                  if (String.isPrefix " " line orelse String.isPrefix "\t" line)
                     (* continued multiline header (RFC 1945 4.2) *)
                     then
                        let
                           val () = if (!lastHeader = "") then raise Fail("invalid request (leading space/tab)") else ()
                        in
                           case StringMap.get (headers, !lastHeader) of
                              SOME(x) => StringMap.set (headers, !lastHeader, String.concat [x, String.extract (line, 1, NONE)])
                            | NONE    => raise Fail("this shouldn't happen")
                        end
                     (* next header *)
                     else
                        let
                           val parts = Util.splitString (": ", line, SOME(2))
                           val key = List.nth (parts, 0)
                           val value = if List.length(parts) = 2 then List.nth (parts, 1) else ""
                           val () = lastHeader := key
                        in
                           if value <> ""
                              then case StringMap.get (headers, key) of
                                    (* merge headers with same keys (RFC 1945 4.2) *)
                                    SOME(x) => StringMap.set (headers, key, String.concat [x, ";", value])
                                  | NONE    => StringMap.add (headers, key, value)
                              else headerValid := false
                        end

               fun parseRequestLine (lines) =
                  let
                     val reqLineParts = Util.splitString (" ", hd lines, NONE)
                  in
                     if length(reqLineParts) = 3
                        then REQUEST_HEAD({
                           method=List.nth(reqLineParts, 0),
                           uri=List.nth(reqLineParts, 1),
                           version=List.nth(reqLineParts, 2),
                           headers=headers})
                        else INVALID_HEAD("request line #tokens != 3")
                  end

               fun validateRequest (INVALID_HEAD(err)) = INVALID_HEAD(err)
                 | validateRequest (REQUEST_HEAD({ method, uri, version, headers })) =
                  if (method <> "GET" andalso method <> "POST" andalso method <> "HEAD")
                     then INVALID_HEAD("invalid method")
                  else if (not (String.isPrefix "HTTP/" version))
                     then INVALID_HEAD("unknown protocol")
                  else if (not (!headerValid))
                     then INVALID_HEAD("invalid header")
                  else
                     REQUEST_HEAD({ method=method, uri=uri, version=version, headers=headers })

               val lines = Util.splitString (newline, req, NONE)
            in
               if length(lines) = 0
                  then INVALID_HEAD("empty request")
                  else
                     let
                        (* the ordering of the following is important because parseHeader modifies headerValid *)
                        val reqHead1 = parseRequestLine lines
                        val () = List.app parseHeader (List.drop (lines, 1))
                        val reqHead2 = validateRequest reqHead1
                     in
                        reqHead2
                     end
            end

         fun retrieveRequestBody (INVALID_HEAD(err)) = SOME(INVALID_REQUEST(err))
           | retrieveRequestBody (REQUEST_HEAD({method, uri, version, headers})) =
            let
               fun getContentLength (headers) =
                  case StringMap.get (headers, "Content-Length") of
                     SOME(s) => Int.fromString s
                   | NONE => NONE

               fun fetchNBytes (n) =
                  if (Word8Vector.length (!buffer) >= 0)
                     then
                        let
                           val data = Word8VectorSlice.vector (Word8VectorSlice.slice (!buffer, 0, SOME(n)))
                           val () = buffer := Word8VectorSlice.vector (Word8VectorSlice.slice (!buffer, n, NONE))
                        in
                           SOME(Byte.bytesToString data)
                        end
                     else NONE
            in
               if (method = "POST")
                  (* there should be a request body *)
                  then case getContentLength (headers) of
                     SOME(n) => (case fetchNBytes n of
                        (* we got the complete request body *)
                        SOME(data) => SOME(REQUEST({ method=method, uri=uri, version=version, headers=headers, body=SOME(data) }))
                        (* request body is still incomplete *)
                      | NONE => NONE)
                   | NONE => SOME(INVALID_REQUEST("missing Content-Length header"))
                  (* no request body *)
                  else SOME(REQUEST({ method=method, uri=uri, version=version, headers=headers, body=NONE }))
            end

      in
         case retrieveRequestHead (buffer) of
            SOME(reqStr, nl) => retrieveRequestBody (parseRequestHead (reqStr, nl))
          | NONE => NONE
      end


end
