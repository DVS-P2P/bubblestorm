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


(* current polling request on hold from client *)
val pollRequest = ref NONE

(* shorthand -.- *)
val sockToFdStr = SysWord.toString o Posix.FileSys.fdToWord o valOf o Posix.FileSys.iodToFD o Socket.ioDesc

fun log (severity, msg) = Log.logExt (severity, fn () => "http", msg)


fun updatePollRequest (sock, request) =
   let
      val old = !pollRequest
      val () = pollRequest := SOME(sock, request)
   in
      old
   end


fun shutdownSocket sock =
   let
      val () = RegisteredSocket.shutdown sock
   in
      case !pollRequest of
         SOME(psock, _) =>
            if Socket.sameDesc (RegisteredSocket.desc sock, RegisteredSocket.desc psock)
               then pollRequest := NONE
               else ()
       | NONE => ()
   end


fun send (sock, data, close) =
   let
      val () = log (LogLevels.DEBUG, fn () => "TCP: will send " ^ Int.toString (VectorSlice.length data) ^ " bytes fd=" ^ RegisteredSocket.fdStr sock)
      fun write () =
         case Socket.sendVecNB (RegisteredSocket.sock sock, data) of
            SOME x => if (x = VectorSlice.length data)
               then (
                  log (LogLevels.DEBUG, fn () => "TCP: sent " ^ Int.toString x ^ " bytes (complete)");
                  if close
                     then (
                        log (LogLevels.DEBUG, fn () => "send: closing socket fd=" ^ RegisteredSocket.fdStr sock);
                        shutdownSocket sock)
                     else ();
                  Main.UNHOOK) (* sent all data *)
               else (
                  log (LogLevels.DEBUG, fn () => "TCP: sent " ^ Int.toString x ^ " bytes (partial)");
                  send (sock, VectorSlice.subslice (data, x, NONE), close);
                  Main.UNHOOK) (* partial send -> retry the remainder *)
            | NONE => (
                  log (LogLevels.DEBUG, fn () => "TCP: send failed (would have blocked)");
                  Main.REHOOK)
   in
      (* try to send now, if it doesn't work, register the socket for a later retry *)
      case write () of
         Main.REHOOK => RegisteredSocket.registerForWrite (sock, write)
       | Main.UNHOOK => ()
   end


fun makeTextWriter sock =
   let
      val name = RegisteredSocket.fdStr sock
      fun write data =
         let
            val () = log (LogLevels.DEBUG,
                  fn () => "outstream fd=" ^ RegisteredSocket.fdStr sock ^
                     ": " ^ Util.escapeSpecialCharsSub data)
            val bytes = Byte.stringToBytes (Substring.string data)
            val () = send (sock, Word8VectorSlice.full bytes, false)
         in
            Substring.size data
         end
   in
      TextPrimIO.WR {
         name = name,
         chunkSize = 4096,
         writeVec = SOME write,
         writeArr = NONE,
         writeVecNB = SOME (fn vec => SOME (write vec)),
         writeArrNB = NONE,
         block = SOME (fn () => ()),
         canOutput = SOME (fn () => true),
         getPos = NONE,
         setPos = NONE,
         endPos = NONE,
         verifyPos = NONE,
         close = fn () => log (LogLevels.BUG, fn () => "BUG: writer " ^ name ^ " closed!"),
         ioDesc = NONE (* provide this? *)
      }
   end


fun makeTextOutstream sock = TextIO.mkOutstream (TextIO.StreamIO.mkOutstream (makeTextWriter sock, IO.BLOCK_BUF))


fun sendString (sock, data, close) = (
   log (LogLevels.DEBUG, fn () => "sendString: " ^ Util.escapeSpecialChars data);
   send (sock, Word8VectorSlice.full (Byte.stringToBytes data), close))


fun receive (sock, readCallback) =
   let
      val maxBuf = 65536
      val buffer = ref (Word8Vector.tabulate (0, fn _ => 0w0))
      val regSock = RegisteredSocket.fromSock sock

      fun tcpRead () =
         case Socket.recvVecNB (sock, maxBuf) of
            SOME vect =>
               if (Vector.length vect = 0)
                  then (  (* other side disconnected 'orderly' *)
                     log (LogLevels.INFO, fn () => "TCP: other side diconnected (zero length read) fd=" ^ sockToFdStr sock);
                     shutdownSocket regSock;
                     Main.UNHOOK)
                  else (
                     log (LogLevels.DEBUG, fn () => "TCP: read " ^ (Int.toString o Vector.length) vect ^ " bytes fd=" ^ sockToFdStr sock);
                     buffer := Word8Vector.concat [!buffer, vect];
                     readCallback (regSock, buffer))
          | NONE => (
               log (LogLevels.BUG, fn () => "TCP: read fail: this shouldn't happen");
               Main.REHOOK)
   in
      RegisteredSocket.registerForRead (regSock, tcpRead)
   end


(* init TCP server socket *)
fun tcpListen (port, readCallback) =
   let
      val listenSock = INetSock.TCP.socket ()
      val () = Socket.Ctl.setREUSEADDR(listenSock, true);
      val bindAddr = INetSock.any (getOpt (port, 0))
      val () = Socket.bind (listenSock, bindAddr)
      val () = Socket.listen (listenSock, 5)

      fun addrToString addr =
         case INetSock.fromAddr addr of (ip, port) =>
            NetHostDB.toString ip ^ ":" ^ Int.toString port

      fun accept () =
         case Socket.acceptNB listenSock of
            SOME (sock, addr) =>
               let
                  val () = log (LogLevels.DEBUG, fn () => "incoming TCP connection from " ^ addrToString addr ^ " fd=" ^ sockToFdStr sock)
                  val () = receive (sock, readCallback)
               in
                  Main.REHOOK
               end
            | NONE => Main.REHOOK

      val unhook = Main.registerSocketForRead (Socket.sockDesc listenSock, accept)

      fun shutdown () =
         let
            val _ = unhook ()
         in
            Socket.close listenSock
         end
   in
      shutdown
   end


fun addHeader (resp, k, v) = StringMap.set ((#headers resp), k, v)


fun makeResponseHead (proto, status, reason) =
   let
      val response = {proto=proto, status=status, reason=reason, headers=StringMap.new ()}
      val () = addHeader (response, "Connection", "close")
      val () = addHeader (response, "Server", "bubblestorm webserver")
   in
      response
   end


fun sendResponseHead (sock, resp, close) =
   let
      val () = sendString (sock, (#proto resp) ^ " " ^ (#status resp) ^ " " ^ (#reason resp) ^ "\r\n", false)
      val () = Iterator.app (fn (k, v) => sendString (sock, k ^ ": " ^ v ^ "\r\n", false)) (StringMap.iterator (#headers resp))
      val () = sendString (sock, "\r\n", close)
   in () end


fun sendJsonResponse (sock, jsonstr) =
   let
      val resp = makeResponseHead ("HTTP/1.0", "200", "OK")
      val () = addHeader (resp, "Content-Type", "application/json;charset=utf-8")
      val () = sendResponseHead (sock, resp, false)
      val () = sendString (sock, jsonstr, true)
   in () end


fun sendJsonResponse2 (sock, jsonobj) =
   let
      val resp = makeResponseHead ("HTTP/1.0", "200", "OK")
      val () = addHeader (resp, "Content-Type", "application/json;charset=utf-8")
      val () = sendResponseHead (sock, resp, false)

      val outstream = makeTextOutstream sock
      val () = JSONPrinter.print (outstream, jsonobj)
      val () = TextIO.flushOut outstream
      val () = RegisteredSocket.shutdown sock
   in () end


fun sendPollResponse () =
   case !pollRequest of
      SOME (sock, response) => (
         case PushQueue.pop () of
            SOME (json) => (sendJsonResponse2 (sock, json); pollRequest := NONE)
          | NONE => ())
    | NONE => ()

val () = PushQueue.notify := sendPollResponse


fun sendDummyJson (sock) =
   let
      val resp = makeResponseHead ("HTTP/1.0", "200", "OK")
      val () = addHeader (resp, "Content-Type", "application/json;charset=utf-8")
      val () = sendResponseHead (sock, resp, false)

      val outstream = makeTextOutstream sock
      val foo3 = JSON.OBJECT([ ("a", JSON.BOOL(true)), ("b", JSON.BOOL(false)) ])
      val () = JSONPrinter.print (outstream, foo3)
      val () = TextIO.flushOut outstream
      val () = RegisteredSocket.shutdown sock
   in
      ()
   end


fun sendErrorResponse (sock, code, reason, msg, extraHeaders) =
   let
      val resp = makeResponseHead ("HTTP/1.0", code, reason)
      val () = addHeader (resp, "Content-Type", "text/plain")
      val () = case extraHeaders of
         SOME(headers) => List.app (fn (h, v) => addHeader (resp, h, v)) headers
       | NONE => ()
      val () = sendResponseHead (sock, resp, false)
      val () = sendString (sock, getOpt(msg, code ^ " " ^ reason) ^ "\n", true)
   in () end


fun logRequest (sock, req) =
   let
      fun stringifyHeaders (headers) = Iterator.fold (fn ((k, v), s) => s ^ "  " ^ k ^ ": " ^ v ^ "\n") "" (StringMap.iterator headers)
      fun logReq (Http.INVALID_REQUEST(msg)) =
            log (LogLevels.WARNING, fn () => "invalid request: " ^ msg)
        | logReq (Http.REQUEST({ body=_, method=method, uri=uri, version=version, headers=headers })) = (
            log (LogLevels.INFO, fn () =>
               ("incoming request: " ^ method ^ " " ^ uri ^ " (fd=" ^ RegisteredSocket.fdStr sock ^ ")"));
            log (LogLevels.DEBUG, fn () =>
               ("incoming request (long version):\n  " ^ method ^ " " ^ uri ^ " " ^ version ^ "\n" ^ stringifyHeaders headers))
          )
   in logReq req end


fun getMimeType (uri) =
   if String.isSuffix ".html" uri
      then "text/html"
   else if String.isSuffix ".js" uri
      then "text/javascript"
   else "application/octet-stream"


fun sendFileHeaders (sock, uri, close) =
   let
      val resp = makeResponseHead ("HTTP/1.0", "200", "OK")
      val () = addHeader (resp, "Content-Type", getMimeType (uri))
      val () = addHeader (resp, "Date", Http.timeToHttpDate (OS.FileSys.modTime (uri)))
      val () = sendResponseHead (sock, resp, close)
   in () end


(* FIXME: blocks on disk IO, reads everything into memory *)
fun sendFile (sock, uri) =
   let
      val instream = BinIO.openIn uri
      val data = Word8VectorSlice.full (BinIO.inputAll instream)
      val () = BinIO.closeIn instream
      val () = log (LogLevels.DEBUG, fn () => "transmitting file: " ^ uri ^ " (" ^ Int.toString (Word8VectorSlice.length data) ^ " bytes)")
      val () = send (sock, data, true)
   in () end


fun handlePollRequest (sock, request) =
   case (*ImperativeQueue.pop pushQueue*) PushQueue.pop () of
      SOME (data) => sendJsonResponse2 (sock, data)
    | NONE => (
         case updatePollRequest (sock, request) of
            SOME (oldsock, _) =>
               sendErrorResponse (oldsock, "409", "Conflict", SOME("there can be only one polling request at any time"), NONE)
          | NONE => ())


fun handleFileRequest (sock, uri, headers, isHead) =
   if String.isSubstring "/../" uri
      then sendErrorResponse (sock, "403", "Forbidden", NONE, NONE)
   else if not (OS.FileSys.access ("." ^ uri, []))
      then sendErrorResponse (sock, "404", "Not Found", NONE, NONE)
   else if not (OS.FileSys.access ("." ^ uri, [OS.FileSys.A_READ]))
      then sendErrorResponse (sock, "403", "Forbidden", NONE, NONE)
   else case StringMap.get (headers, "If-Modified-Since") of
      SOME (dateStr) =>
         let
            val date = Http.parseHttpDate dateStr
         in
            if isHead
               then sendErrorResponse (sock, "400", "Bad Request", NONE, NONE)
               else
                  case date of
                     SOME(d) => (case Date.compare (d, Date.fromTimeUniv (OS.FileSys.modTime ("." ^ uri))) of
                        LESS => (sendFileHeaders (sock, "." ^ uri, false); sendFile (sock, "." ^ uri))
                      | EQUAL => sendErrorResponse (sock, "304", "Not Modified", SOME(""), NONE)
                      | GREATER => sendErrorResponse (sock, "400", "Bad Request", NONE, NONE))
                   | NONE => sendErrorResponse (sock, "400", "Bad Request", NONE, NONE)
         end
    | NONE =>
         if isHead
            then sendFileHeaders (sock, "." ^ uri, true)
            else (sendFileHeaders (sock, "." ^ uri, false); sendFile (sock, "." ^ uri))


fun handleCallRequest (sock, body) =
   let
      val () = log (LogLevels.DEBUG, fn () => "body: " ^ body ^ "\n")
      (* FIXME handle parsing errors *)
      val json = JSONParser.parse (TextIO.openString body)
   in
      (case json of
         JSON.OBJECT(pairs) =>
            (case List.find (fn (k, _) => k = "fun") pairs of
               SOME (_, JSON.STRING(funname)) =>
                  (case List.find (fn (k, _) => k = "args") pairs of
                     SOME (_, args) =>
                        (case JavascriptApi.call (funname, args) of
                           SOME result => sendJsonResponse2 (sock, result)
                           | NONE => sendErrorResponse (sock, "500", "Internal Server Error", NONE, NONE)
                        )
                     | NONE => sendErrorResponse (sock, "400", "Bad Request", NONE, NONE)
                  )
               | _ => sendErrorResponse (sock, "400", "Bad Request", NONE, NONE)
            )
         | _ => sendErrorResponse (sock, "400", "Bad Request", NONE, NONE)
      )
   end


fun handleHttpRequest (sock, req) =
   let
      val () = logRequest (sock, req)
   in
      case req of
         Http.REQUEST({ body=_, method="GET", uri, version=_, headers }) =>
            if String.isPrefix "/static/" uri
               then handleFileRequest (sock, uri, headers, false)
            else if uri = "/poll"
               then handlePollRequest (sock, req)
            else if uri = "/call"
               then sendErrorResponse (sock, "405", "Method Not Allowed", NONE, SOME [("Allow", "POST")])
            else if uri = "/dummy"
               then sendDummyJson sock
            else sendErrorResponse (sock, "404", "Not Found", NONE, NONE)
       | Http.REQUEST({ body, method="HEAD", uri, version=_, headers }) =>
            if String.isPrefix "/static/" uri
               then handleFileRequest (sock, uri, headers, true)
            else if uri = "/poll"
               then sendErrorResponse (sock, "405", "Method Not Allowed", NONE, SOME [("Allow", "GET")])
            else if uri = "/call"
               then sendErrorResponse (sock, "405", "Method Not Allowed", NONE, SOME [("Allow", "POST")])
            else if uri = "/dummy"
               then sendErrorResponse (sock, "405", "Method Not Allowed", NONE, SOME [("Allow", "GET")])
            else sendErrorResponse (sock, "404", "Not Found", NONE, NONE)
       | Http.REQUEST({ body=SOME(body), method="POST", uri, version=_, headers=_ }) =>
            if String.isPrefix "/static/" uri
               then sendErrorResponse (sock, "405", "Method Not Allowed", NONE, SOME [("Allow", "GET, HEAD")])
            else if uri = "/poll"
               then sendErrorResponse (sock, "405", "Method Not Allowed", NONE, SOME [("Allow", "GET")])
            else if uri = "/call"
               then handleCallRequest (sock, body)
            else if uri = "/dummy"
               then sendErrorResponse (sock, "405", "Method Not Allowed", NONE, SOME [("Allow", "GET")])
            else sendErrorResponse (sock, "404", "Not Found", NONE, NONE)
       | Http.REQUEST(_) =>
            sendErrorResponse (sock, "501", "Not Implemented", NONE, NONE)
       | Http.INVALID_REQUEST(msg) =>
            sendErrorResponse (sock, "400", "Bad Request", SOME msg, NONE)
   end


fun handleTcpRead (sock, buffer) =
   case Http.parseHttpRequest (buffer) of
      (* complete request received *)
      SOME(req) => (
         handleHttpRequest(sock, req);
         (* although we don't want to read anything else now, we still need to REHOOK,
          * otherwise we wouldn't be able to detect disconnects *)
         Main.REHOOK)
      (* partial request, continue buffering *)
    | NONE => Main.REHOOK


fun webserver () = ignore (tcpListen (SOME(8080), handleTcpRead))

val () = Main.run ("webserver", webserver)
