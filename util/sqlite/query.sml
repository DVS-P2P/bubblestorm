(*
** 2007 February 18
**
** The author disclaims copyright to this source code.  In place of
** a legal notice, here is a blessing:
**
**    May you do good and not evil.
**    May you find forgiveness for yourself and forgive others.
**    May you share freely, never taking more than you give.
**
*************************************************************************
** $Id: query.sml 5303 2007-02-23 02:09:44Z wesley $
*)
structure Query =
   struct
      (* Cry ... *)
      type 'a oF = Prim.query -> 'a
      type ('b, 'c) oN = Prim.query * (unit -> 'b) -> 'c
      type 'd iF = Prim.query * 'd -> unit
      type ('e, 'f) iN = Prim.query * 'e -> 'f
      type ('i, 'o, 'w, 'x, 'y, 'z) acc = 
         string list * 'o oF * ('w, 'x) oN * int * 'i iF * ('y, 'z) iN * int
      
      type ('v, 'i, 'o, 'p, 'q, 'a, 'b, 'x, 'y, 'z) output = 
           (('i, 'o, 'v, 'p,            'a, 'b) acc, 
            ('i, 'p, 'q, ('p, 'q) pair, 'a, 'b) acc, 
            'x, 'y, 'z) Fold.step0
      type ('v, 'i, 'o, 'j, 'k, 'a, 'b, 'x, 'y, 'z) input = 
           (string, ('i, 'o, 'a, 'b, 'j, 'v) acc, 
                    ('j, 'o, 'a, 'b, ('j, 'k) pair, 'k) acc, 
                    'x, 'y, 'z) Fold.step1
      
      type ('i, 'o) t = { query: Prim.query Ring.element,
                          iF:    Prim.query * 'i -> unit,
                          oF:    Prim.query -> 'o }
      
      (* Close unused queries, one at a time *)
      fun finalize { query, iF=_, oF=_ } =
         if Ring.isSolo query then raise Prim.Error "Already closed" else
         let
            val q = Ring.unwrap query
            val () = Ring.remove query
         in
            Prim.finalize q
         end
      
      fun peek ({ query, iF=_, oF=_ }, f) =
         if Ring.isSolo query then raise Prim.Error "Query closed" else
         f (Ring.unwrap query)
      
      fun alloc ({ query, iF, oF}, i) =
         if Ring.isSolo query then raise Prim.Error "Query closed" else
         let
            val q = Ring.unwrap query
            val () = iF (q, i)
         in
            (q, oF)
         end
      
      fun release ({ query=_, iF=_, oF=_ }, pq) =
         (Prim.reset pq; Prim.clearbindings pq)
      
      fun oF0 _ = ()
      fun oN0 (_, n) = n ()
      val oI0 = 0
      fun iF0 (_, ()) = ()
      fun iN0 (_, x) = x
      val iI0 = 1
      
      fun prepare { db, queries, hooks=_, auth=_ } qt =
         if not (isSome (!db)) then raise Prim.Error "Database closed" else
         Fold.fold (([qt], oF0, oN0, oI0, iF0, iN0, iI0),
                    fn (ql, oF, _, oI, iF, _, iI) => 
                    let
                        val qs = concat (rev ql)
                        val q = Prim.prepare (valOf (!db), qs)
                        val r = Ring.wrap q
                        val () = Ring.add (queries, r)
                    in 
                        if Prim.cols q < oI
                        then (Prim.finalize q;
                              raise Prim.Error "Insufficient output columns\
                                               \ to satisfy prototype")
                        else
                        if Prim.bindings q + 1 <> iI
                        then (Prim.finalize q;
                              raise Prim.Error "Too many query parameters\
                                               \ for specified prototype")
                        else
                        { query = r, iF = iF, oF = oF }
                    end)
      
      (* terminate an expression with this: *)
      val $ = $
      
      (* the ignore is just to silence a warning. it really will be a unit *)
      fun iFx f (iN, iI) (q, a) = f (q, iI, iN (q, a))
      fun iNx f (iN, iI) (q, a & y) = (ignore (f (q, iI, iN (q, a))); y)
      fun iMap f = Fold.step1 (fn (qs, (ql, oF, oN, oI, _, iN, iI)) => 
                                  (qs :: "?" :: ql, oF, oN, oI, 
                                   iFx f (iN, iI), iNx f (iN, iI), iI + 1))
      fun iB z = iMap Prim.bindB z
      fun iR z = iMap Prim.bindR z
      fun iI z = iMap Prim.bindI z
      fun iZ z = iMap Prim.bindZ z
      fun iN z = iMap Prim.bindN z
      fun iS z = iMap Prim.bindS z
      fun iX z = iMap Prim.bindX z
      
      fun oFx f (oN, oI) q = oN (q, fn () => f (q, oI))
      fun oNx f (oN, oI) (q, n) = oN (q, fn () => f (q, oI)) & n ()
      fun oMap f = Fold.step0 (fn (ql, _, oN, oI, iF, iN, iI) => 
                                  (ql, oFx f (oN, oI), oNx f (oN, oI), oI+1, 
                                   iF, iN, iI))
      fun oB z = oMap Prim.fetchB z
      fun oR z = oMap Prim.fetchR z
      fun oI z = oMap Prim.fetchI z
      fun oZ z = oMap Prim.fetchZ z
      fun oN z = oMap Prim.fetchN z
      fun oS z = oMap Prim.fetchS z
      fun oX z = oMap Prim.fetchX z
      
      fun fetchA (q, m) = Vector.tabulate (Prim.cols q, fn i => m (q, i))
      fun oFAx f oN q = oN (q, fn () => fetchA (q, f))
      fun oNAx f oN (q, n) = oN (q, fn () => fetchA (q, f)) & n ()
      fun oMapA f = Fold.step0 (fn (ql, _, oN, oI, iF, iN, iI) => 
                                   (ql, oFAx f oN, oNAx f oN, oI, 
                                    iF, iN, iI))
      fun oAB z = oMapA Prim.fetchB z
      fun oAR z = oMapA Prim.fetchR z
      fun oAI z = oMapA Prim.fetchI z
      fun oAZ z = oMapA Prim.fetchZ z
      fun oAN z = oMapA Prim.fetchN z
      fun oAS z = oMapA Prim.fetchS z
      fun oAX z = oMapA Prim.fetchX z
   end      
