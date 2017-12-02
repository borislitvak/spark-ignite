#!/usr/bin/env bash

docker stop $(docker ps -aq)
docker rm $(docker ps -aq)


docker network create --driver bridge spark-net
docker run -dP --net spark-net --hostname spark-master --name spark-master gszecsenyi/spark-docker master
docker run -dP --net spark-net --name spark-worker-01 gszecsenyi/spark-docker worker spark://spark-master:7077
docker run -dP --net spark-net --name spark-worker-02 gszecsenyi/spark-docker worker spark://spark-master:7077
