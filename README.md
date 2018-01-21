# spark-ignite with Docker
A Docker environment and a sample application to demonstrate sharing state of RDDs across multiple spark applications using Apache Spark and Apache Ignite.  

The Docker Image contains Spark and Ignite installations. A new container is startable as Spark master node or Spark worker node. On every Spark worker container a preconfigured Standalone Ignite server is also started. 

### How to prepare the Docker environment
Build the image with the following command:
```{r, engine='bash', count_lines}
docker build -t gszecsenyi/spark-ignite . 
```
Or the image is downloadable from DockerHub with the following command:
```{r, engine='bash', count_lines}
docker pull gszecsenyi/spark-ignite
```
### Start the environment with 2 Worker nodes
```{r, engine='bash', count_lines}
docker network create --driver bridge spark-net
docker run -dP --net spark-net --hostname spark-master --name spark-master gszecsenyi/spark-ignite master
docker run -dP --net spark-net --name spark-worker-01 gszecsenyi/spark-ignite worker spark://spark-master:7077
docker run -dP --net spark-net --name spark-worker-02 gszecsenyi/spark-ignite worker spark://spark-master:7077
```
### How to Test Ignite Shared Spark RDD Cache with Spark Shell
#### Login into Docker container, and start Spark Shell with the following command:
```{r, engine='bash', count_lines}
docker exec -it spark-master /bin/bash
cd /opt/spark
./bin/spark-shell --packages org.apache.ignite:ignite-spark:2.3.0,org.apache.ignite:ignite-spring:2.3.0 --master spark://spark-master:7077
```

#### Execute the following scala code to save cache data into Ignite, and exit.
```scala
import org.apache.ignite.spark._
import org.apache.ignite.configuration._
val ic = new IgniteContext(sc, () => new IgniteConfiguration().setClientMode(true))
val sharedRDD: IgniteRDD[Integer, Integer] = ic.fromCache[Integer, Integer]("intpaircache")
sharedRDD.savePairs(sc.parallelize(1 to 100, 10).map(i => (i, i)))
sharedRDD.count
sys.exit
```
#### Login into a different Docker Container and open there a new Spark Shell and execute the following code to read the cache from a different Spark Application (Spark Shell works as a Spark Application)
```{r, engine='bash', count_lines}
docker exec -it spark-worker-01 /bin/bash
cd /opt/spark
./bin/spark-shell --packages org.apache.ignite:ignite-spark:2.3.0,org.apache.ignite:ignite-spring:2.3.0 --master spark://spark-master:7077
```

```scala
import org.apache.ignite.spark._
import org.apache.ignite.configuration._
val ic = new IgniteContext(sc, () => new IgniteConfiguration().setClientMode(true))
val sharedRDD: IgniteRDD[Integer, Integer] = ic.fromCache[Integer, Integer]("intpaircache")
sharedRDD.count
sys.exit
```


### How to Package and submit Applications
**IMPORTANT:
Because there is a bug in the Ignite Spark library (wrong version in pom files), the ignite SharedRDD doesnt work with sbt. These will be fixed in Ignite Version 2.4, than I update this text too.**

There are two application in the source namely: RDDProducer and RDDConsumer. Run the following command in the project root direcotory to package the application: 
```{r, engine='bash', count_lines}
$ sbt assmebly
```
When jar is produced. Submit both the applications by changing only the --class argument as: 

```{r, engine='bash', count_lines}
$ spark-submit --class "net.szecsenyi.RDDProducer"  --master spark://spark-master:7077 path_to_jar
$ spark-submit --class "net.szecsenyi.RDDConsumer"  --master spark://spark-master:7077 path_to_jar
```

### Filtering data
If we use an Ignite RDD, and execute a filter, then the filter will be pushed down to Ignite server. 

```Java
JavaIgniteContext<Integer, Integer> igniteContext = new JavaIgniteContext<Integer, Integer>(
            sparkContext,"examples/config/spark/example-shared-rdd.xml", false);
JavaIgniteRDD<Integer, Integer> sharedRDD = igniteContext.<Integer, Integer>fromCache("sharedRDD");
JavaPairRDD<Integer, Integer> transformedValues =
            sharedRDD.filter(new Function<Tuple2<Integer, Integer>, Boolean>() {
                @Override public Boolean call(Tuple2<Integer, Integer> tuple) throws Exception {
                    return tuple._2() % 2 == 0;
                }
            });
```
