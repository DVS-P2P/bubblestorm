TARGETS=kv-kademlia kv-fading kv-managed kv-durable kv-lookup simulator.db
MLTON=../csupport/mlton

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

simulator.db:	\
		sql/begin-transaction.sql \
		sql/schema-config.sql \
		sql/schema-output.sql \
		sql/geo-hosts.sql \
		sql/regions.sql \
		sql/countries.sql \
		sql/cities.sql \
		sql/continents.sql \
		sql/pinger_data.sql \
		sql/experiments.sql \
		sql/connection_type.sql \
		sql/lifetimes.sql \
		sql/node_sets.sql \
		sql/node_groups.sql \
		sql/workload.sql \
		sql/dns.sql \
		sql/log_filters.sql \
		sql/commit.sql
	rm -f $@
	cat $^ | sqlite3 $@

%:	%.mlb .%.d
   # default compile options
	$(MLTON) -mlb-path-map virtual-runtime -link-opt "-lsqlite3" -drop-pass 'deepFlatten' $<
   # for useful stack traces
#	$(MLTON) @MLton gc-summary -- -mlb-path-map virtual-runtime -link-opt "-lsqlite3" -profile-val true -profile-branch true -verbose 1 -drop-pass 'deepFlatten' -const 'Exn.keepHistory true' $<
   # for profiling
   # use mlprof -show-lines true simulator mlmon.out after running the simulator
   # the database name doesn't get parsed correctly with profiling, 
   # use the default database instead of a command line parameter
#	$(MLTON) -profile time -profile-stack true -mlb-path-map virtual-runtime -link-opt "-lsqlite3" $<
.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -mlb-path-map virtual-runtime -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@files=$$(cat $@.tmp); for i in $${files##*:}; do if [ ! -f $$i ]; then echo Missing: $$i; fi; done
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
