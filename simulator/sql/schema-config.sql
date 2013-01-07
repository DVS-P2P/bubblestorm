-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Simulator/testbed schema definitions for experiment configuration
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Experiments --

CREATE TABLE [experiments]
(
	[id] INTEGER NOT NULL PRIMARY KEY,
	[name] VARCHAR(50) NOT NULL UNIQUE,
	[size] INTEGER NOT NULL,
	[start_date] DATETIME NOT NULL,
	[runtime] DATETIME NOT NULL,
	[last_run] DATETIME,
	[log_interval] DATETIME NOT NULL,
	[seed] INTEGER NOT NULL
);
-- Note: Experiment sizes are specified as average online node counts.
--   The total (online and offline) number of nodes are scaled depending
--   on the node group's lifetime distributions.


-- Node groups --

CREATE TABLE [connection_type]
(
	[name] STRING PRIMARY KEY NOT NULL,
	[description] TEXT,
	[downstream] INTEGER  NOT NULL,
	[upstream] INTEGER  NOT NULL,
	[receive_buffer] INTEGER  NOT NULL,
	[send_buffer] INTEGER  NOT NULL,
	[lasthop_delay] INTEGER DEFAULT '''''''0''''''' NOT NULL,
	[msg_loss] REAL DEFAULT '''''''0.0''''''' NOT NULL
);

CREATE TABLE [lifetimes]
(
	[name] STRING NOT NULL PRIMARY KEY,
	[lifetime_type] STRING NOT NULL,
	[online_time] DATETIME,
	[offline_time] DATETIME,
	[crash_ratio] REAL DEFAULT '''''''0.0''''''' NOT NULL,
	[static_address] STRING
);

CREATE TABLE [node_sets]
(
	[name]       STRING NOT NULL,
	[fixed_size] INTEGER,
	[remainder_weight] REAL,
	[connection] STRING NOT NULL REFERENCES [connection_type](name),
	[lifetime]   STRING NOT NULL REFERENCES [lifetimes](name),
	[location]   STRING NOT NULL,
	[workload]   STRING NOT NULL REFERENCES [workload](name)
);
CREATE INDEX [node_set_names] ON [node_sets] (name);

CREATE TABLE [node_groups]
(
	[id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	[experiment] STRING NOT NULL REFERENCES [experiments](name),
	[name] STRING NOT NULL REFERENCES [node_sets](name),
	[command] STRING NOT NULL
	-- proc -ip $ip --port $port --bootstrap $alias[master] -progarg1 v1 -progarg2 v2
);

CREATE VIEW [experiment_node_group] AS SELECT
	experiment,
	node_groups.id as id,
	node_groups.name as name,
	command,
	fixed_size,
	remainder_weight,
	connection,
	location,
	lifetime_type,
	online_time,
	offline_time,
	crash_ratio,
	static_address,
	workload
FROM
	node_groups
INNER JOIN
	node_sets ON node_groups.name = node_sets.name
INNER JOIN
	lifetimes ON node_sets.lifetime = lifetimes.name;


-- Testbed/host data --

CREATE TABLE [hosts]
(
	[id] INTEGER NOT NULL PRIMARY KEY,
	[name] TEXT,
	[address] TEXT NOT NULL,
	[port] INTEGER NOT NULL,
	[user_name] TEXT NOT NULL,
	[key_file] TEXT NOT NULL,
	[max_prototypes] INTEGER NOT NULL,
	[working_dir] TEXT NOT NULL,
	[ssh_args] TEXT,
	[public_interface] TEXT,
	[usable_ports_start] INTEGER NOT NULL,
	[usable_ports_end] INTEGER NOT NULL,
	[insp_free_disc] INTEGER,
	[insp_free_ram] INTEGER, 
	[insp_cpu_64bit] BOOLEAN, 
	[insp_max_nodes] INTEGER, 
	[insp_ping]  INTEGER,
	[insp_time_zone]  INTEGER,
	[insp_time_delta]  REAL,
	UNIQUE (address, working_dir)
);

CREATE TABLE [nodes]
(
	[experiment] INTEGER NOT NULL REFERENCES [experiments](id),
	[id] INTEGER NOT NULL,
	[node_group] INTEGER NOT NULL REFERENCES [node_groups](id),
	[location] INTEGER,
	[host] INTEGER REFERENCES [hosts](id),
	[address] VARCHAR(20),
	PRIMARY KEY (experiment, id)
);

CREATE VIEW [hosts_experiments_node_groups] AS 
	SELECT 
		hosts.*, 
		nodes.experiment as experiment, 
		nodes.node_group as node_group, 
		count(nodes.id) as nodes 
	FROM 
		hosts 
	JOIN 
		nodes ON (nodes.host = hosts.id) 
	GROUP BY 
		nodes.experiment, 
		nodes.host 	
	ORDER BY 
		hosts.id;

CREATE TABLE [prototypes]
(
	[id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	[experiment] STRING NOT NULL REFERENCES [experiments](name),
	[command] STRING NOT NULL,
	[x86_64] BOOLEAN NOT NULL,
	[bin_path] TEXT NOT NULL,
	[libs_path] TEXT,
	[data_path] TEXT,
	[req_ram] INTEGER NOT NULL,
	[req_disc] INTEGER NOT NULL,
	UNIQUE (experiment, command, x86_64)
);


-- Node events (join, crash, etc.) --

CREATE TABLE [node_events]
(
	[id] INTEGER NOT NULL PRIMARY KEY,
	[node] INTEGER NOT NULL REFERENCES [nodes](id) ON DELETE CASCADE,
	[experiment] INTEGER NOT NULL REFERENCES [experiments](id) ON DELETE CASCADE,
	[time] DATETIME NOT NULL,
	[signal] STRING NOT NULL,
	[seed] INTEGER,
	[args] TEXT,
	UNIQUE (node, experiment, time)
);

CREATE VIEW [node_events_by_host] AS 
	SELECT 
		nodes.host as host, 
		node_events.* 
 	FROM 
 		node_events 
 	INNER JOIN 
 		nodes ON (nodes.id = node_events.node) 
 	ORDER BY 
 		host;

 
-- Node workload configuration --

CREATE TABLE [workload_events]
(
	[name] STRING NOT NULL,
	[type] VARCHAR(20) NOT NULL,
	[time] DATETIME NOT NULL,
	[percentage] REAL NOT NULL,
	[optional_parameter] VARCHAR(50) NULL,
	[plot] VARCHAR(4) NULL
);
-- optional_parameter:
--   * LinearJoin: number of seconds between join events (i.e, join rate)

CREATE TABLE [workload_sets]
(
	[name] STRING NOT NULL,
	[event] STRING NOT NULL REFERENCES [workload_events](name)
);

CREATE VIEW [workload] AS SELECT
	workload_sets.name as name,
	workload_events.name as event_name,
	type,
	time,
	percentage,
	optional_parameter,
	plot
FROM
	workload_sets
INNER JOIN
	workload_events
ON
	workload_sets.event = workload_events.name;


-- Geographic network model --

CREATE TABLE [continents]
(
	[id] INTEGER PRIMARY KEY AUTOINCREMENT,
	[name] TEXT
);

CREATE TABLE [countries]
(
	[id] INTEGER PRIMARY KEY AUTOINCREMENT,
	[continent_id] INTEGER,
	[country_code] TEXT UNIQUE,
	[name] TEXT,
	FOREIGN KEY ([continent_id]) REFERENCES [continents]([id]) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE [regions]
(
	[id] INTEGER PRIMARY KEY AUTOINCREMENT,
	[country_id] INTEGER,
	[name] TEXT,
	FOREIGN KEY ([country_id]) REFERENCES [countries]([id]) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE [cities]
(
	[id] INTEGER PRIMARY KEY AUTOINCREMENT,
	[region_id] INTEGER,
	[name] TEXT,
	FOREIGN KEY ([region_id]) REFERENCES [regions]([id]) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE [geo_hosts]
(
	[id] INTEGER PRIMARY KEY AUTOINCREMENT,
	[city_id] INTEGER,
	[ip] INTEGER(12),
	[longitude] REAL,
	[latitude] REAL,
	[coordinate1] REAL,
	[coordinate2] REAL,
	[randVal] INTEGER,
	FOREIGN KEY ([city_id]) REFERENCES [cities]([id]) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE [pinger_data]
(
   [from] INTEGER,
   [to] INTEGER,
   [jitter_mu] REAL,
   [jitter_sigma] REAL,
   [loss] REAL,
   FOREIGN KEY ([from], [to]) REFERENCES [countries]([id], [id]) ON DELETE CASCADE ON UPDATE CASCADE,
   PRIMARY KEY ([from], [to])
);


-- Global configuration data --

CREATE TABLE [dns]
(
	-- [experiment] STRING REFERENCES [experiments](name),
	[hostname] TEXT NOT NULL,
	[ip] VARCHAR(15) NOT NULL
);
