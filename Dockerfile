# author mjaglan@umail.iu.edu
# Coding Style: Shell form

# Start from Ubuntu OS image
FROM ubuntu:14.04

# set root user
USER root

# install utilities on up-to-date node
RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y openssh-server default-jdk wget

# set java home
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

# setup ssh with no passphrase
RUN ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" \
    && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

# download & extract & move kafka & clean up
RUN wget -O /kafka.tar.gz -q https://iu.box.com/shared/static/jj9y2p5buaa875f2xejaq6zj94iqp6tn.tgz \
	&& tar xfz kafka.tar.gz \
	&& mv /kafka_2.11-0.11.0.1 /usr/local/kafka \
	&& rm /kafka.tar.gz

# kafka environment variables
ENV KAFKA_HOME=/usr/local/kafka

# download & extract & move zookeeper & clean up
RUN wget -O /zookeeper.tar.gz -q https://iu.box.com/shared/static/36magujkse2nc33r865vqitnvymwl0wx.gz \
	&& tar xfz zookeeper.tar.gz \
	&& mv /zookeeper-3.4.10 /usr/local/zookeeper \
	&& rm /zookeeper.tar.gz

# zookeeper environment variables
ENV ZK_HOME=/usr/local/zookeeper

# setup configs - [standalone, pseudo-distributed mode, fully distributed mode]
# NOTE: Directly using COPY/ ADD will NOT work if you are NOT using absolute paths inside the docker image.
# Temporary files: http://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s18.html
COPY config/ /tmp/
RUN mv /tmp/ssh_config $HOME/.ssh/config \
    && mv /tmp/server.properties $KAFKA_HOME/config/server.properties \
    && cp /tmp/zookeeper.properties $ZK_HOME/conf/zoo.cfg \
    && mv /tmp/zookeeper.properties $KAFKA_HOME/config/zookeeper.properties \
    && mkdir -p /tmp/zookeeper/ \
    && mv /tmp/myid /tmp/zookeeper/myid \
    && rm -rf /tmp/*.template

# Add startup script
COPY scripts/ /tmp/
RUN mv /tmp/kafka-services.sh $KAFKA_HOME/kafka-services.sh \
	&& mv /tmp/zk-services.sh $KAFKA_HOME/zk-services.sh \
	&& mv /tmp/kafka-health.sh $KAFKA_HOME/kafka-health.sh \
	&& mv /tmp/zk-health.sh $KAFKA_HOME/zk-health.sh \
	&& mv /tmp/kafka-benchmarks.sh $KAFKA_HOME/kafka-benchmarks.sh

# set permissions
RUN chmod 744 -R $KAFKA_HOME
RUN chmod 744 -R /tmp

# run ssh services
ENTRYPOINT service ssh start; bash

