-- Views for simpifying log/statistics analysis for Kademlia

-- -- Join success
-- create view join_success as
-- select * from statistics where name='join success';
-- 
-- create view join_success_total as
-- select sum(sum)/sum(count) as success, sum(sum) as successful, sum(count) as total from join_success;
-- 
-- -- Store success
-- create view store_success as
-- select * from statistics where name='store success';
-- 
-- create view store_success_total as
-- select sum(sum)/sum(count) as success, sum(sum) as successful, sum(count) as total from store_success;
-- 
-- -- Store replication
-- create view store_replication as
-- select * from statistics where name='store replication';
-- 
-- create view store_replication_total as
-- select sum(sum)/sum(count) as average, sum(count) as total from store_replication;
-- 
-- -- Store latency
-- create view store_latency as
-- select * from statistics where name='store latency';
-- 
-- create view store_latency_total as
-- select sum(sum)/sum(count) as average, sum(count) as total from store_latency;
-- 
-- -- Retrieve success
-- create view retrieve_success as
-- select * from statistics where name='retrieve success';
-- 
-- create view retrieve_success_total as
-- select sum(sum)/sum(count) as success, sum(sum) as successful, sum(count) as total from retrieve_success;
-- 
-- -- Retrieve latency
-- create view retrieve_latency as
-- select * from statistics where name='retrieve latency';
-- 
-- create view retrieve_latency_total as
-- select sum(sum)/sum(count) as average, sum(count) as total from retrieve_latency;
-- 
-- -- Stored values
-- create view stored_values as
-- select * from statistics where name='stored values';
-- 
-- -- Republish success
-- create view republish_success as
-- select * from statistics where name='republish success';
-- 
-- create view republish_success_total as
-- select sum(sum)/sum(count) as success, sum(sum) as successful, sum(count) as total from republish_success;
