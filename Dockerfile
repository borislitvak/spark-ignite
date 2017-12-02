FROM trivadisbds/base:ubuntu

MAINTAINER Gergely Szecsenyi <gergely@szecsenyi.net>


RUN apt-get -y update
RUN apt-get -y install apt-transport-https
RUN apt-get update && apt-get install -y unzip wget docker 
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-get -y update
RUN apt-get -y install sbt scala  --allow-unauthenticated
RUN apt-get install bc

# SPARK installation

RUN wget -c http://tux.rainside.sk/apache/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz && tar -xzvf spark-2.2.0-bin-hadoop2.7.tgz && mv spark-2.2.0-bin-hadoop2.7 /opt && ln -s /opt/spark-2.2.0-bin-hadoop2.7/ /opt/spark
ENV SPARK_HOME /opt/spark

# Ignite installation
ENV IGNITE_VERSION 2.3.0

# Ignite home
ENV IGNITE_HOME /opt/ignite/apache-ignite-fabric-${IGNITE_VERSION}-bin

# Do not rely on anything provided by base image(s), but be explicit, if they are installed already it is noop then
RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ignite

RUN curl https://dist.apache.org/repos/dist/release/ignite/${IGNITE_VERSION}/apache-ignite-fabric-${IGNITE_VERSION}-bin.zip -o ignite.zip \
    && unzip ignite.zip \
    && rm ignite.zip

EXPOSE 11211 47100 47500 49112

ADD docker_res/entrypoint.sh /root
ADD docker_res/start-spark-master.sh /root
ADD docker_res/start-spark-worker.sh /root
ADD docker_res/start-ignite.sh /root

ENTRYPOINT ["/root/entrypoint.sh"]
