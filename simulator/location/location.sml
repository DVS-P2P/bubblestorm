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

      structure Area =
         struct
            type t = int

            (* read jitter & loss statistics from database *)
            local
               open SQL.Query
               
               val pingerQuery = prepare database
                  "SELECT jitter_mu, jitter_sigma, loss\
                  \ FROM pinger_data\
                  \ ORDER BY \"from\" ASC, \"to\" ASC;" oR oR oR $
                  handle SQL.Error x =>
                     raise At ("simulator/location/pingerQuery", SQL.Error x)

               fun convertPingER (mu & sigma & loss) =
                  { mu = mu, sigma = sigma, loss = loss / 100.0 }
            in
               val pingER = Vector.map convertPingER (SQL.table pingerQuery ())
               val areaCount =
                  (Real.round o Math.sqrt o Real.fromInt o Vector.length) pingER
            end

            fun byID id = id

            fun jitter (rand, src, dest) =
               let
                  val model = Vector.sub (pingER, (src - 1) * areaCount + (dest - 1))
                  val (mu, sigma) = (#mu model, #sigma model)
                  val jit = Real.Math.exp ((Random.normal rand) * sigma + mu)
                  val jit = (Real32.fromLarge IEEEReal.TO_NEAREST o Real.toLarge) jit
               in
                  Time.fromSecondsReal32 (jit / 1000.0)
               end

            fun loss (rand, src, dest) =
               let
                  val p = #loss (Vector.sub (pingER, (src - 1) * areaCount + (dest - 1)))
               in
                  (Random.real rand) < p
               end
         end

      datatype t = T of {
         id        : int,
         virtualX  : Real32.real,
         virtualY  : Real32.real,
         longitude : Real32.real,
         latitude  : Real32.real,
         area      : Area.t
      }

      fun id (T fields) = #id fields
      fun virtualX (T fields) = #virtualX fields
      fun virtualY (T fields) = #virtualY fields
      fun geoPosition (T fields) = (#longitude fields, #latitude fields)
      fun area (T fields) = #area fields

      fun new (id, virtualX, virtualY, long, lat, areaID) =
         T {
            id = id,
            virtualX = virtualX,
            virtualY = virtualY,
            longitude = long,
            latitude = lat,
            area = Area.byID areaID
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
            "SELECT h.id, h.longitude, h.latitude, h.coordinate1,\
            \ h.coordinate2, cn.id\
            \ FROM geo_hosts h\
            \ INNER JOIN cities ci ON h.city_id = ci.id\
            \ INNER JOIN regions r ON ci.region_id = r.id\
            \ INNER JOIN countries cn ON r.country_id = cn.id\
            \ INNER JOIN continents co ON cn.continent_id = co.id\
            \ ORDER BY h.randVal * "iZ"\
            \ LIMIT "iI";" oI oR oR oR oR oI $
            handle SQL.Error x => raise At ("simulator/location/hostQueryGlobal", SQL.Error x)

         val hostQueryFromString = prepare database
            "SELECT h.id, h.longitude, h.latitude, h.coordinate1,\
            \ h.coordinate2, cn.id\
            \ FROM geo_hosts h\
            \ INNER JOIN cities ci ON h.city_id = ci.id\
            \ INNER JOIN regions r ON ci.region_id = r.id\
            \ INNER JOIN countries cn ON r.country_id = cn.id\
            \ INNER JOIN continents co ON cn.continent_id = co.id\
            \ WHERE co.name = "iS" OR cn.name = "iS" OR\
            \ r.name = "iS" OR ci.name = "iS" ORDER BY h.randVal * "iZ"\
            \ LIMIT "iI";" oI oR oR oR oR oI $
            handle SQL.Error x => raise At ("simulator/location/hostQueryString", SQL.Error x)

         val hostQueryFromId = prepare database
            "SELECT h.id, h.longitude, h.latitude, h.coordinate1,\
            \ h.coordinate2, cn.id\
            \ FROM geo_hosts h\
            \ INNER JOIN cities ci ON h.city_id = ci.id\
            \ INNER JOIN regions r ON ci.region_id = r.id\
            \ INNER JOIN countries cn ON r.country_id = cn.id\
            \ WHERE h.id = "iI";" oI oR oR oR oR oI $
            handle SQL.Error x => raise Fail ("Could not prepare hostQuery-SQL statement.\n " ^ x)
      end

      fun sqlResultToHost (id & longitude & latitude & virtualX & virtualY & countryId) =
         let
            val convert = Real32.fromLarge IEEEReal.TO_NEAREST o Real.toLarge
         in
            new (
               id,
               convert virtualX,
               convert virtualY,
               convert longitude,
               convert latitude,
               countryId
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
