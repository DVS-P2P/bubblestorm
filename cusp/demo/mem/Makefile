TARGETS=mem-usage-sim simulator.db
MLTON=../../../csupport/mlton

all:	$(TARGETS)
clean:
	rm -f $(TARGETS) .*.d

simulator.db:	\
		../../../simulator/sql/begin-transaction.sql \
		../../../simulator/sql/geo-hosts.sql \
		../../../simulator/sql/regions.sql \
		../../../simulator/sql/countries.sql \
		../../../simulator/sql/cities.sql \
		../../../simulator/sql/continents.sql \
		../../../simulator/sql/pinger_data.sql \
		../../../simulator/sql/experiments.sql \
		../../../simulator/sql/connection_type.sql \
		../../../simulator/sql/node_groups.sql \
		../../../simulator/sql/experiment2nodes.sql \
		../../../simulator/sql/experiment_node_group.sql \
		../../../simulator/sql/churn.sql \
		../../../simulator/sql/nodes.sql \
		../../../simulator/sql/log.sql \
		../../../simulator/sql/statistics.sql \
		../../../simulator/sql/dumps.sql \
		../../../simulator/sql/analytical-views.sql \
		../../../simulator/sql/analytical-views-kademlia.sql \
		../../../simulator/sql/host_cache.sql \
		mem-usage.sql \
		../../../simulator/sql/commit.sql
	rm -f $@
	cat $^ | sqlite3 $@

%:	%.mlb .%.d
#	$(MLTON) -const 'Exn.keepHistory true' $<
#	$(MLTON) -inline-nonrec-small 100 -inline-leafa-size 30 -inline-nonrec-product 640 -max-function-size 40000 $<
	$(MLTON) -mlb-path-map ../../../simulator/virtual-runtime $<
.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
