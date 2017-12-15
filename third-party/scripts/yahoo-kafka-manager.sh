#!/bin/bash

# check $ZK_HOSTS variable
echo "ZK_HOSTS=$ZK_HOSTS"

# got to git repository
cd $KAFKA_MANAGER_SERVICE

# run the service
nohup ./bin/kafka-manager -Dapplication.home=$(pwd) -Dconfig.file=conf/application.conf -Dhttp.port=9000 > kafka-manager-service.log  2>&1 &
echo "PID: $!"

# wait for few seconds until "logs/application.log" is generated
sleep 5s

# List all JAVA PID - helps you cross-check if kafka-manager is still running.
jps -lm

# List PID of all running processes - helps you cross-check if kafka-manager is still running.
ps -ef
