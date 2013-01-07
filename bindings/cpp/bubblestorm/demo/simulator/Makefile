BS_DIR= ../../../../../../BubbleStorm
CUSP_CPP_DIR=${BS_DIR}/bindings/cpp/cusp
BS_CPP_DIR=${BS_DIR}/bindings/cpp/bubblestorm

CPP_BASE_DIR = ../../..
C_BASE_DIR = $(CPP_BASE_DIR)/../c

MLTON=${BS_DIR}/csupport/mlton

all:	simulator simulator.db

clean:
	rm -f simulator simulator.db simulator.a simulator.h *.o .*.d

simulator.db:	\
		${BS_DIR}/simulator/sql/begin-transaction.sql \
		${BS_DIR}/simulator/sql/geo-hosts.sql \
		${BS_DIR}/simulator/sql/regions.sql \
		${BS_DIR}/simulator/sql/countries.sql \
		${BS_DIR}/simulator/sql/cities.sql \
		${BS_DIR}/simulator/sql/continents.sql \
		${BS_DIR}/simulator/sql/pinger_data.sql \
		${BS_DIR}/simulator/sql/experiments.sql \
		${BS_DIR}/simulator/sql/connection_type.sql \
		${BS_DIR}/simulator/sql/node_groups.sql \
		${BS_DIR}/simulator/sql/experiment2nodes.sql \
		${BS_DIR}/simulator/sql/experiment_node_group.sql \
		${BS_DIR}/simulator/sql/churn.sql \
		${BS_DIR}/simulator/sql/nodes.sql \
		${BS_DIR}/simulator/sql/log.sql \
		${BS_DIR}/simulator/sql/log_filters.sql \
		${BS_DIR}/simulator/sql/statistics.sql \
		${BS_DIR}/simulator/sql/dumps.sql \
		${BS_DIR}/simulator/sql/analytical-views.sql \
		${BS_DIR}/simulator/sql/analytical-views-kademlia.sql \
		${BS_DIR}/simulator/sql/host_cache.sql \
		${BS_DIR}/simulator/sql/commit.sql \
		bs-sim.sql
	rm -f $@
	cat $^ | sqlite3 $@

# debug
#MLFLAGS = -verbose 2 -const "Exn.keepHistory true"
# non-debug
MLFLAGS = -drop-pass 'deepFlatten' -verbose 2

simulator:	sim-start.o ../node.cpp simulator.a ${BS_CPP_DIR}/libbubblestorm-sim.a
	g++ -lstdc++ -lsqlite3 -lgmp -lm -I$(CPP_BASE_DIR) -I$(C_BASE_DIR) -L$(C_BASE_DIR)/bubblestorm sim-start.o ../node.cpp simulator.a ${BS_CPP_DIR}/libbubblestorm-sim.a -o $@

simulator.a:	simulator.mlb .simulator.d
	$(MLTON) -mlb-path-map bs-path -mlb-path-map ${BS_DIR}/simulator/virtual-runtime ${MLFLAGS} -format archive $<	

%.o:	%.cpp simulator.a
	g++ -c $< -o $@

.%.d:	%.mlb
	@echo Analyzing dependencies for $<
	@echo "$@ $*: " `$(MLTON) -mlb-path-map bs-path -mlb-path-map ${BS_DIR}/simulator/virtual-runtime -stop f $< | grep -v "[ :]\|^/"` > $@.tmp
	@mv $@.tmp $@

-include $(patsubst %.mlb,.%.d,$(wildcard *.mlb))
