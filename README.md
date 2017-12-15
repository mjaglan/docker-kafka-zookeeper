# Run Kafka inside docker container in Multi-Node Cluster mode

## Install Docker CE on Ubuntu

Follow the instructions from [Get Docker CE for Ubuntu](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/) page.


## Manage Docker as a non-root user

Follow the instructions from [Post-installation steps for Linux](https://docs.docker.com/engine/installation/linux/linux-postinstall/#manage-docker-as-a-non-root-user) page.


## How to Run
- Go to your terminal.
- Clone this repository and go inside it
	```
	git clone https://github.com/mjaglan/docker-kafka-zookeeper.git
	cd docker-kafka-zookeeper
	```
- Run the following script
	```
	# Here, N = number of kafka & zookeeper nodes to create (default value is 3).
	. ./restart-all.sh   N

	```
- Zookeeper Nodes are available at
	```
	ZK-1 Accepting Requests at 0.0.0.0:2181
	ZK-2 Accepting Requests at 0.0.0.0:2182
	ZK-3 Accepting Requests at 0.0.0.0:2183
	...
	```
- Broker Nodes are available at
	```
	Broker-1 Accepting Requests at 0.0.0.0:9092
	Broker-2 Accepting Requests at 0.0.0.0:9093
	Broker-3 Accepting Requests at 0.0.0.0:9094
	...
	```


## After Starting Containers

- The [zk-services.sh](scripts/zk-services.sh) starts zookeeper on `N` nodes.
	```
	testbed-1 - Start Native zkServer
	PID: 65
	```

- The [zk-health.sh](scripts/zk-services.sh) checks zookeeper status.
	```
	testbed-1 - ZOOKEEPER HEALTH STATUS: imok
	Zookeeper version: 3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT
	Latency min/avg/max: 0/0/0
	Received: 2
	Sent: 1
	Connections: 1
	Outstanding: 0
	Zxid: 0x100000000
	Mode: follower
	Node count: 4
	```

- The [kafka-services.sh](scripts/kafka-services.sh) starts kafka on the same `N` nodes.
	```
	testbed-1 - Start Kafka Server
	PID: 1488
	```

- The [kafka-health.sh](scripts/kafka-services.sh) checks for kafka broker ids in zookeeper.
	```
	testbed-1 - KAFKA HEALTH STATUS
		/brokers/ids/2
		/brokers/ids/1
		/brokers/ids/0
	```

- The [kafka-benchmarks.sh](scripts/kafka-benchmarks.sh) will create some topics and run a few benchmark tests.
	- Create and list all the topics -
		```
		testbed-1 - KAFKA TOPICS:
		test-topic-rep-3
		test-topic-rep-one
		topic-testbed-1
		```
	- Kafka producer performance test -

		`PRODUCER PROCESS @ testbed-1 -`
		```
		3-thread, async 3 times replication, no compression
		15000000 records sent, 63406.716039 records/sec (6.05 MB/sec), 8642.51 ms avg latency, 29022.00 ms max latency, 64 ms 50th, 9341 ms 95th, 12387 ms 99th, 13204 ms 99.9th.
		```
		```
		1-thread, no replication, no compression
		15000000 records sent, 130646.088456 records/sec (12.46 MB/sec), 3887.82 ms avg latency, 7980.00 ms max latency, 3749 ms 50th, 6582 ms 95th, 7583 ms 99th, 7913 ms 99.9th.
		```

	- Kafka consumer performance test -

		`CONSUMER PROCESS @ testbed-3 -`
		```
		1-thread, no replication, no compression
		start.time, end.time, data.consumed.in.MB, MB.sec, data.consumed.in.nMsg, nMsg.sec
		2017-12-12 22:45:02:571, 2017-12-12 22:45:29:852, 1430.5115, 52.4362, 15000000, 549833.2173
		```


## Tools
```
Docker version 17.06.0-ce
Ubuntu Trusty 14.04 Host OS
Eclipse IDE for Java EE Developers Oxygen (4.7.0)
Eclipse Docker Tooling 3.1.0
```


## Configuration References
- [ZooKeeper Administrator's Guide](https://zookeeper.apache.org/doc/r3.1.2/zookeeperAdmin.html)
- [Monitoring ZooKeeper 3.3](https://phunt1.wordpress.com/category/zookeeper/)
- [kafka-0.11.0.x documentation](https://kafka.apache.org/0110/documentation.html)
- [get-kafka-broker-list-from-zookeeper](https://stackoverflow.com/questions/40146921/command-to-get-kafka-broker-list-from-zookeeper)
- [Benchmarking Apache Kafka 0.8: 2 Million Writes Per Second](https://engineering.linkedin.com/kafka/benchmarking-apache-kafka-2-million-writes-second-three-cheap-machines)
- [Benchmarking Apache Kafka 0.11](https://gist.github.com/dongjinleekr/d24e3d0c7f92ac0f80c87218f1f5a02b)


<!--
## Fix Docker Networking DNS Config

See the article on [Fix Docker's networking DNS config](https://robinwinslow.uk/2016/06/23/fix-docker-networking-dns/)
-->

