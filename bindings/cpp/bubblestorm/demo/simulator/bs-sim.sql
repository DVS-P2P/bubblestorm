
--                   [id], [name], [size], [startDate], [runtime], [logInterval], [seed]
INSERT INTO "experiments" VALUES(20,'BS',25,'2010-01-01','10:00',1,42);

--   [id], [name], [fixed_size], [remainder_weight], [connection], [location], [static_address], [well_known], [crash_ratio], [lifetime_type], [online_time], [offline_time], [command]
INSERT INTO "node_groups" VALUES(2000,'BS-Bootstrap',1,0.0,1,'Frankfurt Am Main','Y','Y',0.0,'always on',NULL,NULL,'bs-sim bootstrap');
INSERT INTO "node_groups" VALUES(2001,'BS-Peer',0,1.0,5,'Global','N','N',0.0,'always on',NULL,NULL,'bs-sim join 0.0.0.1');

--                          [experiment], [node_group]
INSERT INTO "experiments2nodes" VALUES(20,2000);
INSERT INTO "experiments2nodes" VALUES(20,2001);

--                      [experiment], [node_group], [type], [time], [percentage], [optionalParameter]
INSERT INTO "churn" VALUES(20,2000,'SimultaneousJoin','2010-01-01 00:00:00',1.0,NULL);
INSERT INTO "churn" VALUES(20,2001,'LinearJoin','2010-01-01 00:00:01',1.0,'0.1');
