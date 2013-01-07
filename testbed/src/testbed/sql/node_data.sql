CREATE TABLE [node_data]
(
	[id] INTEGER NOT NULL PRIMARY KEY,
	[node_group] INTEGER NOT NULL REFERENCES [node_groups](id),
	[path] TEXT NOT NULL,
	[target_sub_dir] TEXT,
	[target_file_name] TEXT,
	[recursive] BOOLEAN NOT NULL
);

CREATE VIEW [node_data_view] AS SELECT 
node_groups.experiment, 
node_data.id, 
node_data.node_group, 
node_data.path, 
node_data.target_sub_dir, 
node_data.target_file_name, 
node_data.recursive 
FROM node_data 
INNER JOIN node_groups 
ON node_groups.id = node_data.node_group;
