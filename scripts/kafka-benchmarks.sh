#!/bin/bash

# debug flag on
#set -x
printf "\n"


# Stay in KAFKA_HOME Directory
cd $KAFKA_HOME


# List kafka Brokers
KAFKA_CONNECT=${1:-null}
N=${2:-null}
echo "Total $N brokers=$KAFKA_CONNECT"


# Each Node Should be able to create a new topic
./bin/kafka-topics.sh --create --zookeeper $HOSTNAME:2181 --replication-factor 1 --partitions 1 --topic topic-$HOSTNAME


# Duplicate topics should not be created
TOPIC_REP_ONE="test-topic-rep-one"
RESULT=$(./bin/kafka-topics.sh --list --zookeeper $HOSTNAME:2181 | grep -i $TOPIC_REP_ONE)
if [[ -z $RESULT ]] ; then
	./bin/kafka-topics.sh --zookeeper $HOSTNAME:2181 --create --topic $TOPIC_REP_ONE --partitions 1 --replication-factor 1
fi
TOPIC_REP_N="test-topic-rep-$N"
RESULT=$(./bin/kafka-topics.sh --list --zookeeper $HOSTNAME:2181 | grep -i $TOPIC_REP_N)
if [[ -z $RESULT ]] ; then
	./bin/kafka-topics.sh --zookeeper $HOSTNAME:2181 --create --topic $TOPIC_REP_N   --partitions $N --replication-factor $N
fi


echo "$HOSTNAME - KAFKA TOPICS:"
./bin/kafka-topics.sh --list --zookeeper $HOSTNAME:2181


NUM_RECORDS=15000000
THROUGHPUT=$NUM_RECORDS
MESSAGES=$NUM_RECORDS
# Begin Benchmarking Apache Kafka
if [[ $HOSTNAME == "testbed-1" ]] ; then
	echo "PRODUCER PROCESS @ $HOSTNAME -"

	echo "$N-thread, async $N times replication, no compression"
	./bin/kafka-producer-perf-test.sh	--topic $TOPIC_REP_N \
										--num-records $NUM_RECORDS \
										--record-size 100 \
										--throughput $THROUGHPUT \
										--producer-props \
										acks=1 \
										bootstrap.servers=$KAFKA_CONNECT \
										buffer.memory=67108864 \
										compression.type=none \
										batch.size=8196

	printf "\n\n"

	 echo "1-thread, no replication, no compression"
	./bin/kafka-producer-perf-test.sh	--topic $TOPIC_REP_ONE \
										--num-records $NUM_RECORDS \
										--record-size 100 \
										--throughput $THROUGHPUT \
										--producer-props \
										acks=1 \
										bootstrap.servers=$KAFKA_CONNECT \
										buffer.memory=67108864 \
										compression.type=none \
										batch.size=8196

else
	echo "CONSUMER PROCESS @ $HOSTNAME -"

	echo "1-thread, no replication, no compression"
	./bin/kafka-consumer-perf-test.sh 	--topic $TOPIC_REP_ONE \
										--zookeeper $HOSTNAME:2181 \
										--messages $MESSAGES \
										--threads 1

fi

