#!/bin/bash

# debug flag on
#set -x
printf "\n"


echo "$HOSTNAME - KAFKA HEALTH STATUS"
OUTPUT=$(echo dump | nc $HOSTNAME 2181 | grep -i "brokers")
if [[ ! -z $OUTPUT ]]; then
	echo dump | nc $HOSTNAME 2181 | grep -i "brokers"
else
	echo dump | nc $HOSTNAME 2181
fi
