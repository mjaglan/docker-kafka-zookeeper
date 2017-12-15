#!/bin/bash

# debug flag on
#set -x
printf "\n"


echo "$HOSTNAME - Start Kafka Server"
nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /dev/null 2>&1 &
echo "PID: $!"

# BUG: Kafka Process quits when started in background using "docker exec" method.
# Workaround: Start Kafka Process in background and wait for few seconds before detaching from container.
sleep 5s

# List PID of all running processes - helps you cross-check if kafka is still running.
ps -ef
