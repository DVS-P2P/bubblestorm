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

structure Entropy :> ENTROPY =
   struct
      (* Get the Unix version *)
      open Entropy
      
      (* Windows version using FFI: *)
      local
         type pointer = MLton.Pointer.t
         val null = MLton.Pointer.null
         val module = "system/entropy-mlton"
         
         val CryptAcquireContext = _import "CryptAcquireContextA" stdcall external : 
            pointer ref * pointer * pointer * Word32.word * Word32.word -> int;
         val CryptGenRandom = _import "CryptGenRandom" stdcall external : 
            pointer * Word32.word * Word8Array.array -> int;
         val GetLastError = _import "GetLastError" stdcall external : 
            unit -> Word32.word;
         val CryptReleaseContext = _import "CryptReleaseContext" stdcall external : 
            pointer * Word32.word -> int;
         val context = ref null
         
         fun release () =
            case CryptReleaseContext (!context, 0w0) of
               0 => raise At (module ^ "CryptReleaseContext", 
                       Fail ("failed with error code " ^ 
                       Word32.toString (GetLastError ())))
             | _ => ()
         fun init () = 
            case CryptAcquireContext (context, null, null, 0w1, 0wxF0000000) of
              0 => raise At (module ^ "CryptAcquireContext", 
                     Fail ("failed with error code " ^ 
                     Word32.toString (GetLastError ())))
            | _ => OS.Process.atExit release
      in
         fun windows length = 
            let
               val () = if !context = null then init () else ()
               val entropy = Word8Array.tabulate (length, fn _ => 0w0)
               val () = 
                  case CryptGenRandom (!context, Word32.fromInt length, entropy) of
                     0 => raise At (module ^ "CryptGenRandom", 
                        Fail ("failed with error code " ^ 
                        Word32.toString (GetLastError ())))
                   | _ => ()
            in
               Word8Array.vector entropy
            end
      end
      
      (* Pick either the UNIX or Windows code path *)
      val get =
         case MLton.Platform.OS.host of
            MLton.Platform.OS.MinGW => windows
          | _ => get
   end
