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

structure SigPoll :> SIGPOLL =
   struct
      val sigpoll   = _import "bs_sigpoll"   public : Word32.word -> unit;
      val sigunpoll = _import "bs_sigunpoll" public : Word32.word -> unit;
      val sigready  = _import "bs_sigready"  public : Word32.word -> Word32.word;
      
      val toWord = Word32.fromLarge o SysWord.toLarge o Posix.Signal.toWord
      
      val poll = fn
         (s, true)  => sigpoll (toWord s)
       | (s, false) => sigunpoll (toWord s)
      
      fun ready s = sigready (toWord s) <> 0w0
   end
