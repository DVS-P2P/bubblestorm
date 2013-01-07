CREATE TABLE [node_host_placement]
(
	[id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	[experiment] STRING NOT NULL REFERENCES [experiments](name),
	[groupA] STRING NOT NULL REFERENCES [node_sets](name),
	[groupB] STRING NOT NULL REFERENCES [node_sets](name),
	[relation] STRING NOT NULL
);


--INSERT INTO "node_host_placement" VALUES (Null, 'kv-managed', 'login', 'login','exclusion');
--INSERT INTO "node_host_placement" VALUES (Null, 'kv-managed', 'login', 'master','exclusion');
--INSERT INTO "node_host_placement" VALUES (Null, 'kv-managed', 'login', 'coord','exclusion');
--
--INSERT INTO "node_host_placement" VALUES (Null, 'kv-managed', 'master', 'master','exclusion');
--INSERT INTO "node_host_placement" VALUES (Null, 'kv-managed', 'master', 'coord','exclusion');
--
--INSERT INTO "node_host_placement" VALUES (Null, 'kv-managed', 'coord', 'coord','exclusion');
