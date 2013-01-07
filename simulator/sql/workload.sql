INSERT INTO "workload_events" VALUES('coordinator-join','SimultaneousJoin','2010-01-01 00:00:00',1.0,NULL,NULL);
INSERT INTO "workload_events" VALUES('master-join','SimultaneousJoin','2010-01-01 00:00:01',1.0,NULL,NULL);
INSERT INTO "workload_events" VALUES('login-join','LinearJoin','2010-01-01 00:00:05',1.0,'15.0',NULL);

INSERT INTO "workload_events" VALUES('peer-join-linear','LinearJoin','2010-01-01 00:05:00',0.05,'5',NULL);
INSERT INTO "workload_events" VALUES('peer-join-exp','ExponentialJoin','2010-01-01 00:10:00',0.95,'0.000075','plot');

INSERT INTO "workload_events" VALUES('leave50','SimultaneousLeave','2010-01-01 03:00:00',0.5,NULL,'plot');
INSERT INTO "workload_events" VALUES('join50','SimultaneousJoin','2010-01-01 04:00:00',0.5,NULL,'plot');
INSERT INTO "workload_events" VALUES('crash50','SimultaneousCrash','2010-01-01 05:00:00',0.5,NULL,'plot');

INSERT INTO "workload_events" VALUES('start-work','SigUsr1','2010-01-01 01:00:00',1.0,NULL,'plot');
INSERT INTO "workload_events" VALUES('stop-work','SigUsr2','2010-01-01 04:00:00',1.0,NULL,'plot');

-- Workload sets --

INSERT INTO "workload_sets" VALUES('coordinator','coordinator-join');

INSERT INTO "workload_sets" VALUES('master','master-join');

INSERT INTO "workload_sets" VALUES('master-signal','master-join');
INSERT INTO "workload_sets" VALUES('master-signal','start-work');

INSERT INTO "workload_sets" VALUES('login','login-join');

INSERT INTO "workload_sets" VALUES('churn','peer-join-linear');
INSERT INTO "workload_sets" VALUES('churn','peer-join-exp');

INSERT INTO "workload_sets" VALUES('leave-join-crash','peer-join-linear');
INSERT INTO "workload_sets" VALUES('leave-join-crash','peer-join-exp');
INSERT INTO "workload_sets" VALUES('leave-join-crash','leave50');
INSERT INTO "workload_sets" VALUES('leave-join-crash','join50');
INSERT INTO "workload_sets" VALUES('leave-join-crash','crash50');
