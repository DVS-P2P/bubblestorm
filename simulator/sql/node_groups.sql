-- INSERT INTO "node_groups" VALUES(10,'kv-kademlia','coord', 'kv-coordinator --port $port --size 1200');
INSERT INTO "node_groups" VALUES(10,'kv-kademlia','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(11,'kv-kademlia','master','kv-kademlia @workload --coordinator $[coord] -- --port $port');
INSERT INTO "node_groups" VALUES(12,'kv-kademlia','login', 'kv-kademlia @workload --coordinator $[coord] -- --port $port --login $[master]');
INSERT INTO "node_groups" VALUES(13,'kv-kademlia','peers', 'kv-kademlia @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(20,'kv-fading','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(21,'kv-fading','master','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(22,'kv-fading','login', 'kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(23,'kv-fading','peers', 'kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(30,'kv-managed','coord', 'kv-coordinator --port $port --managed');
INSERT INTO "node_groups" VALUES(31,'kv-managed','master','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(32,'kv-managed','login', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(33,'kv-managed','peers', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(40,'kv-durable','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(41,'kv-durable','master','kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(42,'kv-durable','login', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(43,'kv-durable','peers', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(50,'kv-lookup','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(51,'kv-lookup','master','kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(52,'kv-lookup','login', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(53,'kv-lookup','peers', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(60,'kv-fading-hetero','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(61,'kv-fading-hetero','master','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 1.0 --min-bandwidth 0.125 --create $ip:$port');
INSERT INTO "node_groups" VALUES(62,'kv-fading-hetero', 'login','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 1.0 --min-bandwidth 0.125 --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(63,'kv-fading-hetero','16mbit','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 1.0  --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(64,'kv-fading-hetero', '6mbit','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.5  --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(65,'kv-fading-hetero', '3mbit','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.25 --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(66,'kv-fading-hetero', '2mbit','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.1875 --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(67,'kv-fading-hetero', '1mbit','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.125  --min-bandwidth 0.125');

INSERT INTO "node_groups" VALUES(70,'kv-managed-hetero','coord', 'kv-coordinator --port $port --managed');
INSERT INTO "node_groups" VALUES(71,'kv-managed-hetero','master','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 1.0 --min-bandwidth 0.125 --create $ip:$port');
INSERT INTO "node_groups" VALUES(72,'kv-managed-hetero', 'login','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 1.0 --min-bandwidth 0.125 --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(73,'kv-managed-hetero','16mbit','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 1.0  --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(74,'kv-managed-hetero', '6mbit','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.5  --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(75,'kv-managed-hetero', '3mbit','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.25 --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(76,'kv-managed-hetero', '2mbit','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.1875 --min-bandwidth 0.125');
INSERT INTO "node_groups" VALUES(77,'kv-managed-hetero', '1mbit','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bandwidth 0.125  --min-bandwidth 0.125');

-- INSERT INTO "node_groups" VALUES(110,'update-kademlia','coord', 'kv-coordinator --port $port --phases 10 --size 1200');
INSERT INTO "node_groups" VALUES(110,'update-kademlia','coord', 'kv-coordinator --port $port --phases 10');
INSERT INTO "node_groups" VALUES(111,'update-kademlia','master','kv-kademlia @workload --coordinator $[coord] -- --port $port');
INSERT INTO "node_groups" VALUES(112,'update-kademlia','login', 'kv-kademlia @workload --coordinator $[coord] -- --port $port --login $[master]');
INSERT INTO "node_groups" VALUES(113,'update-kademlia','churn-only', 'kv-kademlia @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(120,'update-managed','coord', 'kv-coordinator --port $port --phases 10 --managed');
INSERT INTO "node_groups" VALUES(121,'update-managed','master','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(122,'update-managed','login', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(123,'update-managed','churn-only', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(130,'update-durable','coord', 'kv-coordinator --port $port --phases 10');
INSERT INTO "node_groups" VALUES(131,'update-durable','master','kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(132,'update-durable','login', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(133,'update-durable','churn-only', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(140,'update-lookup','coord', 'kv-coordinator --port $port --phases 10');
INSERT INTO "node_groups" VALUES(141,'update-lookup','master','kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(142,'update-lookup','login', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(143,'update-lookup','churn-only', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(210,'delete-managed','coord', 'kv-coordinator --port $port --del-phases 1 --managed');
INSERT INTO "node_groups" VALUES(211,'delete-managed','master','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(212,'delete-managed','login', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(213,'delete-managed','churn-only', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(220,'delete-durable','coord', 'kv-coordinator --port $port --del-phases 1');
INSERT INTO "node_groups" VALUES(221,'delete-durable','master','kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(222,'delete-durable','login', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(223,'delete-durable','churn-only', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(230,'delete-lookup','coord', 'kv-coordinator --port $port --del-phases 1');
INSERT INTO "node_groups" VALUES(231,'delete-lookup','master','kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(232,'delete-lookup','login', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(233,'delete-lookup','churn-only', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

-- INSERT INTO "node_groups" VALUES(310,'short-kademlia','coord', 'kv-coordinator --port $port --size 1200');
INSERT INTO "node_groups" VALUES(310,'short-kademlia','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(311,'short-kademlia','master','kv-kademlia @workload --coordinator $[coord] -- --port $port');
INSERT INTO "node_groups" VALUES(312,'short-kademlia','login', 'kv-kademlia @workload --coordinator $[coord] -- --port $port --login $[master]');
INSERT INTO "node_groups" VALUES(313,'short-kademlia','churn-only', 'kv-kademlia @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(320,'short-fading','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(321,'short-fading','master','kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(322,'short-fading','login', 'kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(323,'short-fading','churn-only', 'kv-fading @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(330,'short-managed','coord', 'kv-coordinator --port $port --managed');
INSERT INTO "node_groups" VALUES(331,'short-managed','master','kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(332,'short-managed','login', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(333,'short-managed','churn-only', 'kv-managed @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(340,'short-durable','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(341,'short-durable','master','kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(342,'short-durable','login', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(343,'short-durable','churn-only', 'kv-durable @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

INSERT INTO "node_groups" VALUES(350,'short-lookup','coord', 'kv-coordinator --port $port');
INSERT INTO "node_groups" VALUES(351,'short-lookup','master','kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --create $ip:$port');
INSERT INTO "node_groups" VALUES(352,'short-lookup','login', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login] --bootstrap $[master]');
INSERT INTO "node_groups" VALUES(353,'short-lookup','churn-only', 'kv-lookup @workload --coordinator $[coord] -- --port $port --login $[master],$[login]');

