
INSERT INTO "experiments" VALUES(122,'CUSP-flow',2,'2010-01-01','1:00',1,42);

INSERT INTO "node_groups" VALUES(1220,'flow-reader',1,0.0,1,'Frankfurt Am Main','Y','Y',0.0,'always on',NULL,NULL,'flow-reader');
INSERT INTO "node_groups" VALUES(1221,'flow-writer',0,1.0,1,'New York','N','N',0.0,'always on',NULL,NULL,'flow-writer 0.0.0.1');

INSERT INTO "experiments2nodes" VALUES(122,1220);
INSERT INTO "experiments2nodes" VALUES(122,1221);

INSERT INTO "churn" VALUES(122,1220,'SimultaneousJoin','2010-01-01 00:00:00',1.0,NULL);
INSERT INTO "churn" VALUES(122,1221,'SimultaneousJoin','2010-01-01 00:00:00',1.0,NULL);
