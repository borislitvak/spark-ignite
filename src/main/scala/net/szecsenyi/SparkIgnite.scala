package net.szecsenyi

import org.apache.ignite.spark.{IgniteRDD, IgniteContext}
import org.apache.ignite.configuration._
import org.apache.spark.{SparkConf, SparkContext}

object RDDProducer extends App {
  val conf = new SparkConf().setAppName("SparkIgnitePro")
  val sc = new SparkContext(conf)
  val ic = new IgniteContext[Int, Int](sc, () => new IgniteConfiguration().setClientMode(true))
  val sharedRDD: IgniteRDD[Int, Int] = ic.fromCache("intpaircache")
  sharedRDD.savePairs(sc.parallelize(1 to 100, 10).map(i => (i, i)))
}

object RDDConsumer extends App {
  val conf = new SparkConf().setAppName("SparkIgniteCon")
  val sc = new SparkContext(conf)
  val ic = new IgniteContext[Int, Int](sc, () => new IgniteConfiguration().setClientMode(true))
  val sharedRDD = ic.fromCache("intpaircache")
  println("The count is:::::::::::: "+sharedRDD.count())
}
