#!/usr/bin/env bash

# Starts Spark worker on the machine this script is executed on.

#usage="Usage: $(basename $0) <spark-master-URL> where <spark-master-URL> is like spark://master-hostname:7077"

# if [ $# -lt 1 ]; then
#   echo $usage
#   exit 1
# fi

# MASTER=$1
# shift

exec "$IGNITE_HOME/bin/ignite.sh"
