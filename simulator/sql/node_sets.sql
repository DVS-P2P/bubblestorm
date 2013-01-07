-- login nodes
INSERT INTO "node_sets" VALUES ('coord',         1,0.0,'100MBit','always on','London','coordinator');
INSERT INTO "node_sets" VALUES ('master',        1,0.0,'16MBit','always on','London','master');
INSERT INTO "node_sets" VALUES ('login',         9,0.0,'16MBit','always on','global','login');
   
-- standard peers
INSERT INTO "node_sets" VALUES ('peers',     0,1.0,'16MBit','default',   'global','leave-join-crash');
INSERT INTO "node_sets" VALUES ('churn-only',0,1.0,'16MBit','default',   'global','churn');
INSERT INTO "node_sets" VALUES ('high-churn',0,1.0,'16MBit','high churn','global','leave-join-crash');
INSERT INTO "node_sets" VALUES ('always-on', 0,1.0,'16MBit','always on', 'global','leave-join-crash');

-- heterogeneous default
INSERT INTO "node_sets" VALUES('16mbit', 0, 0.05,'16MBit','default','global','leave-join-crash');
INSERT INTO "node_sets" VALUES( '6mbit', 0, 0.1,  '6MBit','default','global','leave-join-crash');
INSERT INTO "node_sets" VALUES( '3mbit', 0, 0.15, '3MBit','default','global','leave-join-crash');
INSERT INTO "node_sets" VALUES( '2mbit', 0, 0.2,  '2MBit','default','global','leave-join-crash');
INSERT INTO "node_sets" VALUES( '1mbit', 0, 0.5,  '1MBit','default','global','leave-join-crash');

-- heterogeneous churn
INSERT INTO "node_sets" VALUES('16mbit-churn', 0,0.05,'16Mbit','always on','global','churn');
INSERT INTO "node_sets" VALUES( '6mbit-churn', 0,0.1,  '6Mbit','always on','global','churn');
INSERT INTO "node_sets" VALUES( '3mbit-churn', 0,0.15, '3Mbit','always on','global','churn');
INSERT INTO "node_sets" VALUES( '2mbit-churn', 0,0.2,  '2Mbit','always on','global','churn');
INSERT INTO "node_sets" VALUES( '1mbit-churn', 0,0.5,  '1Mbit','always on','global','churn');
