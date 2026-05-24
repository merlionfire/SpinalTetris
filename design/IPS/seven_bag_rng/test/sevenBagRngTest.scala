package IPS.seven_bag_rng

import config._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.sim._
import utils.PathUtils

import scala.collection.mutable

class sevenBagRngTest extends AnyFunSuite {

  val compiler: String = "vcs"
  val runFolder: String = PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString

  lazy val compiled: SimCompiled[seven_bag_rng] = runSimConfig(runFolder, compiler)
    .compile {
      new seven_bag_rng()
    }

  private case class ShapeResult(index: Int, value: Int, latencyCycles: Int) {
    def inRange: Boolean = value >= 0 && value <= 6
  }

  private def initialize(dut: seven_bag_rng): Unit = {
    dut.clockDomain.forkStimulus(10)
    SimTimeout(20000)
    dut.io.enable #= false
    dut.clockDomain.waitSampling(5)
    println(s"[INFO] @[${simTime()}] seven_bag_rng initialized")
  }

  private def checkOrFail(condition: Boolean, message: String): Unit = {
    if (!condition) {
      simFailure(s"[ERROR] @[${simTime()}] $message")
    }
  }

  private def requestShape(dut: seven_bag_rng, index: Int, maxLatencyCycles: Int = 32): ShapeResult = {
    checkOrFail(!dut.io.shape.valid.toBoolean, s"shape.valid must be low before request index=$index")

    dut.io.enable #= true
    dut.clockDomain.waitSampling()
    dut.io.enable #= false

    var latencyCycles = 0
    while (!dut.io.shape.valid.toBoolean && latencyCycles < maxLatencyCycles) {
      dut.clockDomain.waitSampling()
      latencyCycles += 1
    }

    checkOrFail(dut.io.shape.valid.toBoolean, s"request index=$index did not produce shape within $maxLatencyCycles cycles")
    val value = dut.io.shape.payload.toInt
    checkOrFail(value >= 0 && value <= 6, s"request index=$index produced out-of-range shape=$value")

    dut.clockDomain.waitSampling()
    checkOrFail(!dut.io.shape.valid.toBoolean, s"shape.valid stayed high for more than one cycle after request index=$index")

    val result = ShapeResult(index = index, value = value, latencyCycles = latencyCycles)
    println(s"[INFO] @[${simTime()}] request=${result.index} shape=${result.value} latency_cycles=${result.latencyCycles} status=PASS")
    result
  }

  private def requestShapes(dut: seven_bag_rng, count: Int): Seq[ShapeResult] = {
    (0 until count).map { index =>
      requestShape(dut, index)
    }
  }

  private def printSummary(name: String, results: Seq[ShapeResult]): Unit = {
    val values = results.map(_.value)
    val allInRange = results.forall(_.inRange)
    println("=" * 80)
    println(s"[INFO] @[${simTime()}] $name summary")
    println(s"[INFO] @[${simTime()}] values=${values.mkString(",")}")
    println(s"[INFO] @[${simTime()}] total=${results.size} unique=${values.distinct.size} all_in_range=$allInRange")
    println("=" * 80)
  }

  test("disabled rng keeps shape flow invalid") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      initialize(dut)

      val observedValidCycles = mutable.ArrayBuffer[Long]()
      for (_ <- 0 until 40) {
        dut.clockDomain.waitSampling()
        if (dut.io.shape.valid.toBoolean) {
          observedValidCycles += simTime()
        }
      }

      println("=" * 80)
      println(s"[INFO] @[${simTime()}] disabled summary observed_valid_cycles=${observedValidCycles.mkString(",")}")
      println("=" * 80)
      checkOrFail(observedValidCycles.isEmpty, s"shape.valid asserted while enable stayed low at ${observedValidCycles.mkString(",")}")
      simSuccess()
    }
  }

  test("single enable pulse produces one valid shape in range") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      initialize(dut)

      val result = requestShape(dut, index = 0)
      printSummary("single enable pulse", Seq(result))
      checkOrFail(result.inRange, s"shape=${result.value} is outside valid tetromino id range")
      simSuccess()
    }
  }

  test("first bag contains all seven unique tetromino ids") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      initialize(dut)

      val results = requestShapes(dut, count = 7)
      val values = results.map(_.value)
      printSummary("first bag", results)

      checkOrFail(values.toSet == (0 to 6).toSet, s"first bag must contain exactly ids 0..6, observed=${values.mkString(",")}")
      checkOrFail(values.distinct.size == 7, s"first bag contains duplicates, observed=${values.mkString(",")}")
      simSuccess()
    }
  }

  test("consecutive bags each contain one of every tetromino id") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      initialize(dut)

      val bagCount = 28
      val results = requestShapes(dut, count = bagCount * 7)
      printSummary(s"$bagCount consecutive bags", results)

      val expectedSet = (0 to 6).toSet
      val failedBags = results.grouped(7).zipWithIndex.flatMap { case (bagResults, bagIndex) =>
        val values = bagResults.map(_.value)
        val passed = values.toSet == expectedSet && values.distinct.size == 7
        println(s"[INFO] @[${simTime()}] bag=$bagIndex values=${values.mkString(",")} unique=${values.distinct.size} status=${if (passed) "PASS" else "FAIL"}")
        if (passed) None else Some(s"bag=$bagIndex observed=${values.mkString(",")}")
      }.toSeq

      checkOrFail(failedBags.isEmpty, s"one or more bags were invalid: ${failedBags.mkString("; ")}")
      simSuccess()
    }
  }
}

