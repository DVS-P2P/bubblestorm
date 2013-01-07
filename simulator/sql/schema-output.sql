-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Simulator/testbed schema definitions for experiment results
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Log --

CREATE TABLE [log]
(
	[experiment] INTEGER REFERENCES [experiments](id),
	[node] INTEGER REFERENCES [nodes](id),
	[ip] VARCHAR(15),
	[time] DATETIME,
	[level] INTEGER,
	[module] TEXT,
	[message] TEXT
);

CREATE TABLE [log_filters]
(
	[experiment] STRING REFERENCES [experiments](name),
	[module] TEXT,
	[level] INTEGER
);


-- Statistics --

CREATE TABLE [statistics]
(
	[id] INTEGER PRIMARY KEY,
	[experiment] INTEGER NOT NULL REFERENCES [experiments](id),
	[name] TEXT NOT NULL,
	[units] TEXT NOT NULL,
	[label] TEXT NOT NULL,
	[node] INTEGER NOT NULL,
	[type] TEXT
	-- type definitions:
	--   'normal': normal measurements
	--   'single': measurements_single
	--   + '-histogram': histogram enabled
);
CREATE UNIQUE INDEX [statistics_by_experiment] ON [statistics] (experiment, name, node);

CREATE TABLE [measurements]
(
	[statistic] INTEGER NOT NULL REFERENCES [statistics](id),
	[time] DATETIME NOT NULL,
	[count] INTEGER,
	[min] REAL,
	[max] REAL,
	[sum] REAL,
	[sum2] REAL,
	PRIMARY KEY (statistic, time)
);

-- CREATE TABLE [measurements_single]
-- (
-- 	[statistic] INTEGER NOT NULL REFERENCES [statistics](id),
-- 	[time] DATETIME NOT NULL,
-- 	[value] REAL,
-- 	PRIMARY KEY (statistic, time)
-- );

CREATE TABLE [histograms]
(
	[statistic] INTEGER NOT NULL REFERENCES [statistics](id),
	[time] DATETIME NOT NULL,
	[bucket] REAL,
	[width] REAL,
	[count] INTEGER,
	PRIMARY KEY (statistic, time, bucket)
);

-- -- 'no-aggregate' view
-- CREATE VIEW measurements0 AS
-- SELECT statistic, time, count, min, max, sum/count as avg, (count*sum2-sum*sum)/(count*count) as var FROM measurements;

-- Dumps --

CREATE TABLE [dumps]
(
	[id] INTEGER PRIMARY KEY,
	[experiment] INTEGER NOT NULL REFERENCES [experiments](id),
	[name] TEXT NOT NULL,
	[prefix] TEXT,
	[suffix] TEXT
);
CREATE UNIQUE INDEX [dumps_by_experiment] ON [dumps] (experiment, name);

CREATE TABLE [dump_data]
(
	[dump] INTEGER REFERENCES [dumps](id),
	[time] DATETIME NOT NULL,
	[node] INTEGER NOT NULL,
	[text] TEXT,
	PRIMARY KEY (dump, time, node)
);
