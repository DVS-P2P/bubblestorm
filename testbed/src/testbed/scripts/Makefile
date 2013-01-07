TARGETS=experiment.db experiment_node.db

all:	$(TARGETS)
	sh run.sh --downloadpython
	
clean:
	rm -f $(TARGETS)

experiment.db:	\
		sql/begin-transaction.sql \
		sql/schema-config.sql \
		sql/schema-output.sql \
		sql/experiments.sql \
		sql/connection_type.sql \
		sql/lifetimes.sql \
		sql/node_sets.sql \
		sql/node_groups.sql \
		sql/workload.sql \
		sql/log_filters.sql \
		sql/node_data.sql \
		sql/prototypes.sql \
		sql/node_host_placement.sql \
		sql/planetLabNodes.sql \
		sql/germanLabNodes.sql \
		sql/p4-exp.sql \
		sql/commit.sql
	rm -f $@
	cat $^ | sqlite3 $@

experiment_node.db:	\
		sql/begin-transaction.sql \
		sql/schema-output.sql \
		sql/log_filters.sql \
		sql/commit.sql
	rm -f $@
	cat $^ | sqlite3 $@
