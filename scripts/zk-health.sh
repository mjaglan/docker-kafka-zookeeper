#!/bin/bash

# debug flag on
#set -x
printf "\n"


OUTPUT=""
SERVER_OK=$(echo ruok | nc $HOSTNAME 2181)
echo "$HOSTNAME - ZOOKEEPER HEALTH STATUS: $SERVER_OK"
while [[ -z $OUTPUT ]]; do
	OUTPUT=$(echo srvr | nc $HOSTNAME 2181 | grep -i "Mode:")
done
echo srvr | nc $HOSTNAME 2181
