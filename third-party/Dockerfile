# author mjaglan@umail.iu.edu
# Coding Style: Shell form

# Start from Ubuntu OS image
FROM ubuntu:14.04

# set root user
USER root

# set work dir
WORKDIR /usr/local

# Install Ubuntu Utilities: https://github.com/dockerfile/ubuntu/blob/master/Dockerfile
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y dist-upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip openssh-server wget && \
  rm -rf /var/lib/apt/lists/*

# Install Java: https://github.com/dockerfile/java/blob/master/oracle-java8/Dockerfile
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# set java home
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH=$PATH:$JAVA_HOME/bin

# setup ssh with no passphrase
RUN ssh-keygen -t rsa -f $HOME/.ssh/id_rsa -P "" \
    && cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys

# download & extract & move kafka-manager & clean up
RUN git clone https://github.com/yahoo/kafka-manager.git \
	&& cd kafka-manager \
	&& ./sbt clean dist

# set kafka-manager
ENV KAFKA_MANAGER /usr/local/kafka-manager

# set work dir
WORKDIR $KAFKA_MANAGER

# Start service
RUN cd $KAFKA_MANAGER/target/universal \
	&& unzip kafka-manager-*.zip \
	&& rm -rf kafka-manager-*.zip \
	&& mv kafka-manager-* kafka-manager-service \
	&& cd "kafka-manager-service"

# set kafka-manager
ENV KAFKA_MANAGER_SERVICE /usr/local/kafka-manager/target/universal/kafka-manager-service

# Add startup script
ADD scripts/yahoo-kafka-manager.sh $KAFKA_MANAGER/yahoo-kafka-manager.sh

# run ssh service
ENTRYPOINT service ssh start; bash
