#!/bin/bash

# variables
IMG_NAME="mjaglan/ubuntukafka2017"
HOST_PREFIX="testbed"
NETWORK_NAME=$HOST_PREFIX

# if desired, clean up containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)


# if desired, clean up images
if [[ "$2" == "rmi" ]] ; then
	docker rmi $(docker images -q)
fi


# total number of broker nodes
/bin/cp -rf config/server.properties.template      config/server.properties
/bin/cp -rf config/zookeeper.properties.template   config/zookeeper.properties
ZOOKEEPER_CONNECT=""
KAFKA_CONNECT=""
N=${1:-3}
INIT=1
i=$INIT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i
	KAFKA_CONNECT="$KAFKA_CONNECT$KAFKA_NODE:9092"
	ZOOKEEPER_CONNECT="$ZOOKEEPER_CONNECT$KAFKA_NODE:2181"

	if [ $i -lt $N ]
	then
		KAFKA_CONNECT="$KAFKA_CONNECT,"
		ZOOKEEPER_CONNECT="$ZOOKEEPER_CONNECT,"
	fi

	ZOOKEEPER_SERVER="server.$i=$KAFKA_NODE:2888:3888"
	echo $ZOOKEEPER_SERVER >> config/zookeeper.properties

	i=$(( $i + 1 ))
done
sed -i -e "s/zookeeper.connect=localhost:2181/zookeeper.connect=$ZOOKEEPER_CONNECT/g" config/server.properties

# build the Dockerfile
docker build  -t "$IMG_NAME" "$(pwd)"

# Default docker network name is 'bridge', driver is 'bridge', scope is 'local'
# Create a new network with any name, and keep 'bridge' driver for 'local' scope.
NET_QUERY=$(docker network ls | grep -i $NETWORK_NAME)
if [ -z "$NET_QUERY" ]; then
	docker network create --driver=bridge $NETWORK_NAME
fi

# start kafka container(s)
i=$INIT
ZK_CONTAINER_PORT=2181
ZK_HOST_PORT=$ZK_CONTAINER_PORT
KAFKA_CONTAINER_PORT=9092
KAFKA_HOST_PORT=$KAFKA_CONTAINER_PORT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i

	# Start container but don't run anything
	docker run --name $KAFKA_NODE -h $KAFKA_NODE \
				-p $ZK_HOST_PORT:$ZK_CONTAINER_PORT \
				-p $KAFKA_HOST_PORT:$KAFKA_CONTAINER_PORT \
				--net=$NETWORK_NAME \
				-itd "$IMG_NAME"

	# setup broker id for each kafka node
	BROKER_ID=$(( $i - 1 ))
	FILE_PATH='/usr/local/kafka/config/server.properties'
	CMD_SED="sed  -i -e s/broker.id=0/broker.id=$BROKER_ID/g $FILE_PATH"
	docker exec -it $KAFKA_NODE $CMD_SED

	# setup zookeeper id for each zookeeper node
	CMD_MYID="sed -i -e s/1-255/$i/ /tmp/zookeeper/myid"
	docker exec -it $KAFKA_NODE $CMD_MYID

	echo "ZK-$i Accepting Requests at 0.0.0.0:$ZK_HOST_PORT"
	echo "Broker-$i Accepting Requests at 0.0.0.0:$KAFKA_HOST_PORT"

	# increment further
	ZK_HOST_PORT=$(( $ZK_HOST_PORT + 1 ))
	KAFKA_HOST_PORT=$(( $KAFKA_HOST_PORT + 1 ))
	i=$(( $i + 1 ))
done

# start zk service(s)
i=$INIT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i

	# start zookeeper service(s)
	KAFKA_HOME="/usr/local/kafka"
	IS_NATIVE=true # prefer running naitive zookeeper
	CMD_KAFKA="$KAFKA_HOME/zk-services.sh $IS_NATIVE"
	docker exec -it $KAFKA_NODE $CMD_KAFKA

	i=$(( $i + 1 ))
done

# start zk health check(s)
i=$INIT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i

	# start zookeeper health check(s)
	KAFKA_HOME="/usr/local/kafka"
	CMD_KAFKA="$KAFKA_HOME/zk-health.sh"
	docker exec -it $KAFKA_NODE $CMD_KAFKA

	i=$(( $i + 1 ))
done

# start kafka service(s)
i=$INIT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i

	# start kafka service(s)
	KAFKA_HOME="/usr/local/kafka"
	CMD_KAFKA="$KAFKA_HOME/kafka-services.sh"
	docker exec -it $KAFKA_NODE $CMD_KAFKA

	i=$(( $i + 1 ))
done

# start kafka health check(s)
i=$INIT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i

	# start kafka health check(s)
	KAFKA_HOME="/usr/local/kafka"
	CMD_KAFKA="$KAFKA_HOME/kafka-health.sh"
	docker exec -it $KAFKA_NODE $CMD_KAFKA

	i=$(( $i + 1 ))
done


printf "\n"
echo "LIST OF RUNNING DOCKER CONTAINERS -"
docker ps


# Get All Kafka, Zookeeper logs from all container
rm -rf ./logs-$HOST_PREFIX*
i=$INIT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i
	LOGS_DIR="./logs-$KAFKA_NODE"
	mkdir -p $LOGS_DIR
	docker cp $KAFKA_NODE:/usr/local/kafka/logs/ $LOGS_DIR/
	i=$(( $i + 1 ))
done


# start kafka benchmark(s)
i=$INIT
while [ $i -le $N ]
do
	KAFKA_NODE="$HOST_PREFIX"-$i

	# start kafka benchmark(s)
	KAFKA_HOME="/usr/local/kafka"
	CMD_KAFKA="$KAFKA_HOME/kafka-benchmarks.sh $KAFKA_CONNECT $N"
	docker exec -it $KAFKA_NODE $CMD_KAFKA

	i=$(( $i + 1 ))
done


printf "\n"
LEADER_NODE=$(( $N / 2 + 1))
echo "Attaching to testbed-$LEADER_NODE"
docker attach testbed-$LEADER_NODE

