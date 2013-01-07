-- Views for simpifying log/statistics analysis

-- Warning messages
create view log_warn as
select * from log where level>=3;
create view log_error as
select * from log where level>=4;

-- Per-node logs
create view log_node0 as
select * from log where node=0;
create view log_node1 as
select * from log where node=1;
create view log_node2 as
select * from log where node=2;
create view log_node3 as
select * from log where node=3;

-- Simulatior statistics
-- create view memory_usage as
-- select * from statistics where name='memory usage';
-- create view simulator_events_executed as
-- select * from statistics where name='simulator events executed';
