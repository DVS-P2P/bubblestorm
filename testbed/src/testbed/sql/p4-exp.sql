-- churn events (join & leave)
INSERT INTO "workload_events" VALUES('Workload-PlayerMaster-Join','LinearJoin','2010-01-01 00:00:00',1.0,'1.0',NULL);
INSERT INTO "workload_sets" VALUES('Workload-PlayerMaster','Workload-PlayerMaster-Join');
INSERT INTO "workload_events" VALUES('Workload-Player-Join','LinearJoin','2010-01-01 00:00:10',1.0,'5.0',NULL);
INSERT INTO "workload_sets" VALUES('Workload-Player','Workload-Player-Join');

INSERT INTO "node_sets" VALUES ('playerMaster',1,0.0,'16MBit','always on','London','Workload-PlayerMaster');
INSERT INTO "node_sets" VALUES ('player',0,1.0,'16MBit','always on','global','Workload-Player');
INSERT INTO "node_sets" VALUES ('player1',1,0.0,'16MBit','always on','global','Workload-Player');
INSERT INTO "node_sets" VALUES ('playerT0',0,0.5,'16MBit','always on','global','Workload-Player');
INSERT INTO "node_sets" VALUES ('playerT1',0,0.5,'16MBit','always on','global','Workload-Player');


-- prototype app
INSERT INTO "prototypes" VALUES(NULL, 'P4-PS', 'p4-sim', 1, 'p4-f8-64/planetp4', 'p4-f8-64/libs/', 'p4-f8-64/data/', 0, 200);
INSERT INTO "prototypes" VALUES(NULL, 'P4-PS3D', 'p4-sim', 1, 'p4-f8-64/planetp4', 'p4-f8-64/libs/', 'p4-f8-64/data/', 0, 200);
INSERT INTO "prototypes" VALUES(NULL, 'P4-BS', 'p4-sim', 1, 'p4-f8-64/planetp4', 'p4-f8-64/libs/', 'p4-f8-64/data/', 0, 200);
INSERT INTO "prototypes" VALUES(NULL, 'P4-CS', 'p4-sim', 1, 'p4-f8-64/planetp4', 'p4-f8-64/libs/', 'p4-f8-64/data/', 0, 200);
INSERT INTO "prototypes" VALUES(NULL, 'MM-PS', 'p4-sim', 1, 'p4-f8-64/planetp4', 'p4-f8-64/libs/', 'p4-f8-64/data/', 0, 200);


-- P4 PSense simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('P4-PS',50,'2010-01-01','30:00',1,42);
INSERT INTO "log_filters" VALUES('P4-PS','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-PS','playerMaster','p4-sim -b $port -m psense -c -a7');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-PS','player','p4-sim -b $port -m psense -s $[playerMaster] -c -a7');
-- INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-PS','playerT1','p4-sim -b $port -m psense -s $[playerMaster] -t1 -c');


-- P4 PSense-3D simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('P4-PS3D',10,'2010-01-01','5:00',1,42);
INSERT INTO "log_filters" VALUES('P4-PS3D','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-PS3D','master','p4-sim -b $port -m npsense3d -t1');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-PS3D','playerT0','p4-sim -b $port -m npsense3d -s $[master] -t0 -c -a7');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-PS3D','playerT1','p4-sim -b $port -m npsense3d -s $[master] -t1 -c -a7');


-- P4 BubbleStorm simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('P4-BS',50,'2010-01-01','30:00',1,42);
INSERT INTO "log_filters" VALUES('P4-BS','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-BS','playerMaster','p4-sim -b $port -m bs -s $[playerMaster] -n -c -a7');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-BS','player','p4-sim -b $port -m bs -s $[playerMaster] -c -a7');
-- INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-BS','playerT1','p4-sim -b $port -m bs -s $[playerMaster] -t1 -c');
--   --settings-file=sim.settings


-- P4 C/S simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('P4-CS',50,'2010-01-01','5:00',1,42);
INSERT INTO "log_filters" VALUES('P4-CS','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS','master','p4-sim -b $port -m cuspserver');
-- INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS','player1','p4-sim -b $port -m cuspclient -s $[master] -t1');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS','playerT0','p4-sim -b $port -m cuspclient -s $[master] -t0 -c -a7');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS','playerT1','p4-sim -b $port -m cuspclient -s $[master] -t1 -c -a7');


-- P4 C/S with new bots simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('P4-CS-2',8,'2010-01-01','60:00',1,42);
INSERT INTO "log_filters" VALUES('P4-CS-2','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS-2','master','p4-sim -b $port -m cuspserver');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS-2','player1','p4-sim -b $port -m cuspclient -s $[master] -t1');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS-2','playerT0','p4-sim -b $port -m cuspclient -s $[master] -t0 -c -a10');
INSERT INTO "node_groups" (experiment,name,command) VALUES('P4-CS-2','playerT1','p4-sim -b $port -m cuspclient -s $[master] -t1 -c -a10');


-- -- -- -- -- -- -- -- --

-- MM pSense simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('MM-PS',8,'2010-01-01','1:00',1,42);
INSERT INTO "log_filters" VALUES('MM-PS','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-PS','master','p4-sim -b $port -g1 -m psense');
INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-PS','player','p4-sim -b $port -g1 -m psense -s $[master]');


-- MM pSense 3D simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('MM-PS3D',128,'2010-01-01','60:00',1,42);
INSERT INTO "log_filters" VALUES('MM-PS3D','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-PS3D','master','p4-sim -b $port -g1 -m npsense3d');
INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-PS3D','player','p4-sim -b $port -g1 -m npsense3d -s $[master]');


-- MM BubbleStorm simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('MM-BS',128,'2010-01-01','60:00',1,42);
INSERT INTO "log_filters" VALUES('MM-BS','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-BS','master','p4-sim -b $port -g1 -m bs -n $ip');
INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-BS','player','p4-sim -b $port -g1 -m bs -s $[master]');


-- MM C/S simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('MM-CS',128,'2010-01-01','60:00',1,42);
INSERT INTO "log_filters" VALUES('MM-CS','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-CS','master','p4-sim -b $port -g1 -m cuspserver');
INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-CS','player','p4-sim -b $port -g1 -m cuspclient -s $[master]');


-- MM Breeze simulation
INSERT INTO "experiments" (name,size,start_date,runtime,log_interval,seed) VALUES('MM-BR',128,'2010-01-01','60:00',1,42);
INSERT INTO "log_filters" VALUES('MM-BR','p4',0);

INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-BR','master','p4-sim -b $port -g1 -m breeze');
INSERT INTO "node_groups" (experiment,name,command) VALUES('MM-BR','player','p4-sim -b $port -g1 -m breeze -s $[master]');
