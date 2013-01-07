
INSERT INTO "experiments" VALUES(123,'CUSP-Mem',11,'2010-01-01','1:00',1,42);

INSERT INTO "node_groups" VALUES(1230,'CUSP-Mem-1',1,0.0,1,'Frankfurt Am Main','Y','Y',0.0,'always on',NULL,NULL,'cusp-mem-usage-1 0.0.0.1');
INSERT INTO "node_groups" VALUES(1231,'CUSP-Mem-2',0,1.0,1,'Frankfurt Am Main','N','N',0.0,'always on',NULL,NULL,'cusp-mem-usage-2 0.0.0.1');

INSERT INTO "experiments2nodes" VALUES(123,1230);
INSERT INTO "experiments2nodes" VALUES(123,1231);

INSERT INTO "churn" VALUES(123,1230,'SimultaneousJoin','2010-01-01 00:00:00',1.0,NULL);
INSERT INTO "churn" VALUES(123,1231,'SimultaneousJoin','2010-01-01 00:00:00',1.0,NULL);
