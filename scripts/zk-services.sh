#!/bin/bash

# debug flag on
#set -x
printf "\n"


# Run naitve zk, or kafka's inbuilt zk - both works fine
IS_NATIVE=${1:-false}
if [[ $IS_NATIVE == true ]] ; then
	echo "$HOSTNAME - Start Native zkServer"
	nohup $ZK_HOME/bin/zkServer.sh start $ZK_HOME/conf/zoo.cfg > /tmp/zk.log 2>&1 &
else
	echo "$HOSTNAME - Start Kafka's zookeeper"
	nohup $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > /dev/null 2>&1 &
fi
echo "PID: $!"


# Wait until channel 2181 is up and running
OUTPUT=""
while [[ -z $OUTPUT ]]; do
	OUTPUT=$(echo stat | nc $HOSTNAME 2181)
done
