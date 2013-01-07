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

structure LogLevels =
   struct
      datatype severity = DEBUG | INFO | STDOUT | WARNING | ERROR | BUG
      
      fun fromString level =
         case String.map Char.toUpper level of
            "DEBUG"   => SOME DEBUG
          | "INFO"    => SOME INFO
          | "STDOUT"  => SOME STDOUT
          | "WARNING" => SOME WARNING
          | "ERROR"   => SOME ERROR
          | "BUG"     => SOME BUG
          | _         => NONE
          
      fun toString level =
         case level of
            DEBUG   => "DEBUG"
          | INFO    => "INFO"
          | STDOUT  => "STDOUT"
          | WARNING => "WARNING"
          | ERROR   => "ERROR"
          | BUG     => "BUG"
          
      fun toInt level =
         case level of
            DEBUG   => 0
          | INFO    => 1
          | STDOUT  => 2
          | WARNING => 3
          | ERROR   => 4
          | BUG     => 5
          
      fun fromInt level =
         case level of
            0 => SOME DEBUG
          | 1 => SOME INFO
          | 2 => SOME STDOUT
          | 3 => SOME WARNING
          | 4 => SOME ERROR
          | 5 => SOME BUG
          | _ => NONE
   end
