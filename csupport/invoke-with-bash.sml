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

(* Get an absolute path to this executable *)
val cwd = OS.FileSys.getDir ()
val name = CommandLine.name ()
val self = OS.Path.mkRelative { path = name, relativeTo = cwd }

(* In case we end in '.exe' strip this *)
val { base, ext } = OS.Path.splitBaseExt self
val basename =
   case ext of
      SOME "exe" => base
    | _ => self

(* See if the script exists and is readable (perhaps add a .sh) *)
val shname = OS.Path.joinBaseExt { base=basename, ext = SOME "sh" }
val script =
   if OS.FileSys.access (basename, [OS.FileSys.A_READ]) then basename else
   if OS.FileSys.access (shname,   [OS.FileSys.A_READ]) then shname   else
   raise Fail "Script of same name does not exist!"

(* MSYS bash does not like backslashes... *)
val script = OS.Path.toUnixPath script

(* Launch it! *)
val pid =
   MLton.Process.spawnp {
      args = "bash" :: script :: CommandLine.arguments (),
      file = "bash"
   }

(* Reap the child process *)
val (done, status) = Posix.Process.waitpid (Posix.Process.W_CHILD pid, [])
val () = if done <> pid then raise Fail "Wrong child quit?!" else ()

datatype z = datatype Posix.Process.exit_status
val () =
   case status of 
      W_EXITED => () (* exit cleanly *)
    | W_STOPPED _ => raise Fail "Process stopped on windows?!"
    | W_SIGNALED _ => raise Fail "Process signalled on windows?!"
    | W_EXITSTATUS w => Posix.Process.exit w (* copy exit status *)
