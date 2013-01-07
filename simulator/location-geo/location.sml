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

structure Location :> LOCATION =
   struct

      val database = Experiment.database ()
      val random = Experiment.random ()

      datatype t = T of {
         id        : int,
         longitude : Real32.real,
         latitude  : Real32.real
      }

      fun id (T fields) = #id fields
      fun geoPosition (T fields) = (#longitude fields, #latitude fields)

      fun new (id, long, lat) =
         T {
            id = id,
            longitude = long,
            latitude = lat
         }

      (* read locations from database *)
      local
         open SQL.Query
      in
         val dupes = SQL.simpleTable (database, 
            "select count(id), max(id) from geo_hosts group by randval having count(id)>1;")
         val () = if (Vector.length dupes) = 0 then () else
            raise At ("simulator/location", 
               Fail "geo_hosts table must not have duplicate random values!")
         
         val evenVals = SQL.simpleTable (database, 
            "select id from geo_hosts where randval % 2 = 0;")
         val () = if (Vector.length evenVals) = 0 then () else
            raise At ("simulator/location", 
               Fail "geo_hosts table must not have even random values (must be odd 64 bit integers)!")

         val hostQueryGlobal = prepare database
            "SELECT h.id, h.longitude, h.latitude\
            \ FROM geo_hosts h\
            \ INNER JOIN cities ci ON h.city_id = ci.id\
            \ INNER JOIN regions r ON ci.region_id = r.id\
            \ INNER JOIN countries cn ON r.country_id = cn.id\
            \ INNER JOIN continents co ON cn.continent_id = co.id\
            \ ORDER BY h.randVal * "iZ"\
            \ LIMIT "iI";" oI oR oR $
            handle SQL.Error x => raise At ("simulator/location/hostQueryGlobal", SQL.Error x)

         val hostQueryFromString = prepare database
            "SELECT h.id, h.longitude, h.latitude\
            \ FROM geo_hosts h\
            \ INNER JOIN cities ci ON h.city_id = ci.id\
            \ INNER JOIN regions r ON ci.region_id = r.id\
            \ INNER JOIN countries cn ON r.country_id = cn.id\
            \ INNER JOIN continents co ON cn.continent_id = co.id\
            \ WHERE co.name = "iS" OR cn.name = "iS" OR\
            \ r.name = "iS" OR ci.name = "iS" ORDER BY h.randVal * "iZ"\
            \ LIMIT "iI";" oI oR oR $
            handle SQL.Error x => raise At ("simulator/location/hostQueryString", SQL.Error x)

         val hostQueryFromId = prepare database
            "SELECT h.id, h.longitude, h.latitude\
            \ FROM geo_hosts h\
            \ INNER JOIN cities ci ON h.city_id = ci.id\
            \ INNER JOIN regions r ON ci.region_id = r.id\
            \ INNER JOIN countries cn ON r.country_id = cn.id\
            \ WHERE h.id = "iI";" oI oR oR $
            handle SQL.Error x => raise Fail ("Could not prepare hostQuery-SQL statement.\n " ^ x)
      end

      fun sqlResultToHost (id & longitude & latitude) =
         let
            val convert = Real32.fromLarge IEEEReal.TO_NEAREST o Real.toLarge
         in
            new (
               id,
               convert longitude,
               convert latitude
            )
         end

      fun generate (name, count) =
         let
         val result = case (Int.fromString name) of
            NONE =>
               (case (CharVector.map Char.toLower name) = "global" of
                  true =>
                        SQL.map sqlResultToHost hostQueryGlobal (
                           (Random.int64 (random, valOf Int64.maxInt)) & count
                        )
                  | false =>
                        SQL.map sqlResultToHost hostQueryFromString (
                           name & name & name & name &
                           (Random.int64 (random, valOf Int64.maxInt)) & count
                        ))
            | SOME number => SQL.map sqlResultToHost hostQueryFromId number

         val resultSize = Vector.length result

         val () = if (resultSize = 0)
                     then raise Fail ("No hosts for '" ^ name ^ "' found!")
                  else ()

         val result = if (resultSize >= count) then result
                        else Vector.tabulate (count, fn i => Vector.sub (result, i mod resultSize))
      in
         result
      end
   end
