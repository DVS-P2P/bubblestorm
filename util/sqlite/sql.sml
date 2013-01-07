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
** $Id: sql.sml 5302 2007-02-23 02:07:14Z wesley $
*)
structure SQL :> SQL =
   struct
      type column = Prim.column
      type db = { db      : Prim.db option ref,
                  queries : Prim.query Ring.t,
                  hooks   : Prim.hook list ref,
                  auth    : Prim.hook option ref }
      datatype storage = datatype Prim.storage
      
      exception Retry = Prim.Retry
      exception Abort = Prim.Abort
      exception Error = Prim.Error
      
      local
         fun messager (Retry x) = SOME ("SQL.Retry: " ^ x)
           | messager (Abort x) = SOME ("SQL.Abort: " ^ x)
           | messager (Error x) = SOME ("SQL.Error: " ^ x)
           | messager _ = NONE
      in
         val () = MLton.Exn.addExnMessager messager
      end

      structure Query = Query
      structure Function = Function
      
      val version = Prim.version
      
      fun getDB { db, queries=_, hooks=_, auth=_ } = 
         if not (isSome (!db)) then raise Error "Database already closed" else
         valOf (!db)
      
      fun openDB file = {
         db = ref (SOME (Prim.openDB file)),
         queries = Ring.new (),
         hooks = ref [],
         auth = ref NONE }
      
      fun closeDB { db, queries, hooks, auth } = 
         if not (isSome (!db)) then raise Error "Database already closed" else
         let
            fun kill r = (Prim.finalize (Ring.unwrap r); Ring.remove r)
            val () = Ring.app kill queries
            val () = Prim.closeDB (valOf (!db))
            val () = List.app Prim.unhook (!hooks before hooks := [])
            val () = Option.app Prim.unhook (!auth before auth := NONE)
         in
            db := NONE
         end
      
      fun columns q = Query.peek (q, Prim.columns)
      fun columnsMeta q = Query.peek (q, Prim.meta)
      
      datatype 'v stop = STOP | CONTINUE of 'v
      
      fun iterStop q i =
         let
            val ok = ref true
            val (pq, oF) = Query.alloc (q, i)
            fun stop () = (
               Query.release (q, pq);
               ok := false;
               NONE)
         in
            fn STOP => 
                  if not (!ok) then NONE else stop ()
             | (CONTINUE ()) =>
                  if not (!ok) then NONE else
                  if Prim.step pq then SOME (oF pq) else stop ()
         end
      
      fun mapStop f q i =
         let
            val (pq, oF) = Query.alloc (q, i)
            fun stop l = (
               Query.release (q, pq);
               Vector.fromList (List.rev l))
            
            fun helper l =
               if Prim.step pq
               then case f (oF pq) of
                       STOP => stop l
                     | CONTINUE r => helper (r :: l)
               else stop l
         in
            helper []
         end
      
      fun appStop f q i =
         let
            val (pq, oF) = Query.alloc (q, i)
            fun stop () = Query.release (q, pq)
            
            fun helper () =
               if Prim.step pq
               then case f (oF pq) of
                       STOP => stop ()
                     | CONTINUE () => helper ()
               else stop ()
         in
            helper ()
         end
      
      fun map f = mapStop (CONTINUE o f)
      fun app f = appStop (CONTINUE o f)
      fun iter q i =
         let
            val step = iterStop q i
         in
            fn () => step (CONTINUE ())
         end
      
      fun table q = map (fn x  => x)  q
      fun exec  q = app (fn () => ()) q
      
      local
         open Query
      in
         fun simpleTable (db, qs) =
            let
               val Q = prepare db qs oAS $
            in
               table Q ()
            end
         
         fun simpleExec (db, qs) =
            let
               val Q = prepare db qs $
            in
               exec Q ()
            end
      end
      
      fun registerFunction (db as { hooks, ... }, s, (f, i)) = 
         hooks := Prim.createFunction (getDB db, s, f, i) :: !hooks
         
      fun registerAggregate (db as { hooks, ... }, s, (a, i)) = 
         hooks := Prim.createAggregate (getDB db, s, a, i) :: !hooks
      
      fun registerCollation (db as { hooks, ... }, s, c) = 
         hooks := Prim.createCollation (getDB db, s, c) :: !hooks
      
      structure SQLite = 
         struct
            val lastInsertRowId = Prim.lastInsertRowid o getDB
            val changes = Prim.changes o getDB
            val totalChanges = Prim.totalChanges o getDB
            val transactionActive = not o Prim.getAutocommit o getDB
            
            fun preparedQueries { db=_, queries, hooks=_, auth=_ } =
               Iterator.length (Ring.iterator queries)
            fun registeredFunctions { db=_, queries=_, hooks, auth=_ } =
               List.length (!hooks)
            
            datatype access = datatype Prim.access
            datatype request = datatype Prim.request
            
            fun setAuthorizer (dbh as { auth, ... }, f) = 
               let
                  val db = getDB dbh
                  fun unset h = (Prim.unsetAuthorizer db; Prim.unhook h; auth := NONE)
                  fun set f = auth := SOME (Prim.setAuthorizer (db, f))
               in
                  Option.app unset (!auth);
                  Option.app set f
               end
         end
   end
