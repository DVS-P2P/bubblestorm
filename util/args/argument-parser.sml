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

structure ArgumentParser :> ARGUMENT_PARSER =
   struct
      structure StringKey : HASH_KEY = struct
         type t = string
         val hash = Hash.string
         val op == = op =
      end
      structure Map = HashTable(StringKey)

      type t = { used : bool ref, values : string list } Map.t
      
      exception ParameterMissing of string
      exception ValueMissing of string
      exception UnparseableValue of string * string
      exception ParseException of string * exn
      exception IllegalArgSequence
      
      local
         open General
         fun fmt (ParameterMissing x) = SOME ("Required argument \"" ^ x  ^ "\" is missing")
           | fmt (ValueMissing x) = SOME ("Required value for argument \"" ^ x  ^ "\" is missing")
           | fmt (UnparseableValue (x, y)) = SOME ("\"" ^ y ^ "\" is not a valid value for argument \"" ^ x  ^ "\"")
           | fmt (ParseException (x, y)) = SOME ("Parsing argument \"" ^ x ^ "\" raised the exception \"" ^ (General.exnMessage y)  ^ "\"")
           | fmt IllegalArgSequence = SOME ("Illegal sequence of command line arguments")
           | fmt _ = NONE
      in
         val () = MLton.Exn.addExnMessager fmt
      end

      val empty = Map.new
      
      fun new (args, stopMark) =
         let
            fun check args =
               case stopMark of
                  SOME stop =>
                     (case args of
                        nil => raise IllegalArgSequence
                      | arg :: tail => (Option.filter (fn x => not (x = stop)) arg, tail)
                     )
                | NONE =>
                  case args of
                     nil => (NONE, [])
                   | arg :: tail => (SOME arg, tail)

            fun add (this, key, vals) =
               case Map.get (this, key) of
                  SOME { used, values } =>
                     Map.set (this, key, { used = used, values = values @ vals })
                | NONE => 
                     Map.set (this, key, { used = ref false, values = vals })
               
            fun readVals (this, key, vals, args) =
               case check args of
                  (NONE, _) => ( add (this, key, vals) ; args )
                | (SOME arg, tail) =>
                     if String.sub (arg, 0) = #"-" 
                        then ( add (this, key, vals) ; args )
                        else readVals (this, key, arg :: vals, tail)
            
            fun read (this, args) =
               case check args of
                  (NONE, tail) => (this, tail)
                | (SOME arg, tail) =>
                     if String.sub (arg, 0) = #"-"
                        then read (this, readVals (this, arg, [], tail))
                        else raise IllegalArgSequence
         in
            read (empty (), args)
         end

      fun get (this, name, letter) =
         let
            fun retrieve key =
               case Map.get (this, key) of
                  SOME { used, values } => ( used := true ; SOME values )
                | NONE => NONE
            val name = "--" ^ name
            val letter = CharVector.fromList [#"-", letter]
         in
            case (retrieve name, retrieve letter) of
               (SOME x, SOME y) => SOME (x @ y)
             | (SOME x, NONE)   => SOME x
             | (NONE,   SOME y) => SOME y
             | (NONE,   NONE)   => NONE
         end

      fun parseVal (parse, name) value =
         (case parse value of
            SOME x => x
          | NONE => raise UnparseableValue (name, value))
          handle exn => raise ParseException (name, exn)
          
      fun flag this (name, letter) =
         case get (this, name, letter) of
            NONE => false
          | SOME [] => true
          | SOME _ => raise IllegalArgSequence
          
      fun exactlyOnce this (name, letter, parse) =
         case get (this, name, letter) of
            NONE => raise ParameterMissing name
          | SOME [] => raise ValueMissing name
          | SOME (arg :: nil) => parseVal (parse, name) arg
          | SOME _ => raise IllegalArgSequence
         
      fun optional this (name, letter, parse) =
         case get (this, name, letter) of
            NONE => NONE
          | SOME [] => raise ValueMissing name
          | SOME (arg :: nil) => SOME (parseVal (parse, name) arg)
          | SOME _ => raise IllegalArgSequence
         
      fun atLeastOnce this (name, letter, parse) =
         case get (this, name, letter) of
            NONE => raise ParameterMissing name
          | SOME [] => raise ValueMissing name
          | SOME args => List.map (parseVal (parse, name)) args
         
      fun any this (name, letter, parse) =
         case get (this, name, letter) of
            NONE => []
          | SOME [] => raise ValueMissing name
          | SOME args => List.map (parseVal (parse, name)) args
      
      fun isUnused (key, { used, values=_ }) =
         if !used then NONE else SOME key
      
      fun complainUnused this =
         Iterator.toList (Iterator.mapPartial isUnused (Map.iterator this))
   end
