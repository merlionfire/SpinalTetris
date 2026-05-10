package IPS.bram_2p

import config.runSimConfig
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.sim._
import spinal.lib.sim.FlowMonitor
import utils.PathUtils

import scala.annotation.tailrec
import scala.collection.mutable.ArrayBuffer
import scala.util.Random

class bram2pTest extends AnyFunSuite {

  private final case class ReadRequest(address: Int, expected: BigInt, issuedAtNs: Long)

  private final case class ReadCapture(timeNs: Long, data: BigInt)

  private final class ScenarioScoreboard(val name: String, val description: String) {
    private val passedChecks = ArrayBuffer.empty[String]
    private val failedChecks = ArrayBuffer.empty[(String, Seq[String])]

    def pass(message: String): Unit = passedChecks += message

    def fail(message: String, details: Seq[String]): Unit = {
      failedChecks.append((message, details))
    }

    def fail(message: String, detail: String): Unit = fail(message, Seq(detail))

    def print(): Unit = {
      val summary = render
      println(summary)
      assert(failedChecks.isEmpty, summary)
    }

    private def render: String = {
      val builder = new StringBuilder
      val result = if (failedChecks.isEmpty) "PASS" else "FAIL"

      builder.append("\n")
      builder.append("=" * 120).append("\n")
      builder.append("\t\t\tBRAM2P TEST SUMMARY\n")
      builder.append("-" * 120).append("\n")
      builder.append(s"Name     : $name\n")
      builder.append(s"Scenario : $description\n")
      builder.append(s"Result   : $result\n")

      if (passedChecks.nonEmpty) {
        builder.append("\nChecks:\n")
        passedChecks.foreach(message => builder.append(s"  [PASS] $message\n"))
      }

      if (failedChecks.nonEmpty) {
        builder.append("\nFailed Items:\n")
        failedChecks.foreach { case (message, details) =>
          builder.append(s"  [FAIL] $message\n")
          details.foreach(detail => builder.append(s"         - $detail\n"))
        }
      }

      builder.append("=" * 120)
      builder.toString()
    }
  }

  //********** CUSTOMIZE TEST CONFIGURATION BELOW **********//
  private val compiler: String = "vcs"
//  private val compiler: String = "verilator"
  private val memoryDepth: Int = 1024
  private val memoryWordWidth: Int = 4
  private val defaultValue: BigInt = BigInt(2)
  private val verbosity : Boolean = false
  //********** END OF CUSTOM CONFIGURATION **********//

  private val bramConfig = Bram2pConfig(
    wordWidth = memoryWordWidth,
    depth = memoryDepth,
    default_value = defaultValue
  )

  private lazy val compiled: SimCompiled[Bram2p] =
    runSimConfig(PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString, compiler)
      .compile {
        new Bram2p(bramConfig)
      }

  private def init(dut: Bram2p): Unit = {
    dut.io.clear_start #= false
    dut.io.wr.en #= false
    dut.io.wr.addr #= 0
    dut.io.wr.data #= 0
    dut.io.rd.en #= false
    dut.io.rd.addr #= 0
    dut.clockDomain.waitSampling(2)
  }

  private def clearRam(dut: Bram2p): Int = {
    dut.io.clear_start #= true
    dut.clockDomain.waitSampling()
    dut.io.clear_start #= false

    var cycles = 0
    while (!dut.io.clear_done.toBoolean && cycles <= memoryDepth + 2) {
      dut.clockDomain.waitSampling()
      cycles += 1
    }

    if (!dut.io.clear_done.toBoolean) {
      simFailure(s"clear_done did not assert within ${memoryDepth + 2} cycles")
    }

    cycles
  }

  private def writeWord(dut: Bram2p, address: Int, data: BigInt, burst: Boolean = false): Unit = {
    dut.io.wr.addr #= address
    dut.io.wr.data #= data
    dut.io.wr.en #= true
    dut.clockDomain.waitSampling()
    if (!burst) {
      dut.io.wr.en #= false
      dut.io.wr.addr #= 0
      dut.io.wr.data #= 0
      dut.clockDomain.waitSampling()
    }
  }

  private def idleWriteInterface(dut: Bram2p, cycles: Int): Unit = {
    dut.io.wr.en #= false
    dut.io.wr.addr #= 0
    dut.io.wr.data #= 0
    if (cycles > 0) {
      dut.clockDomain.waitSampling(cycles)
    }
  }

  private def writePatternWithRandomPhases(
    dut: Bram2p,
    pattern: Seq[BigInt],
    random: Random,
    minGapCycles: Int = 1,
    maxGapCycles: Int = 4,
    maxBurstLength: Int = 4
  ): Seq[String] = {
    val activityLog = ArrayBuffer.empty[String]
    @tailrec
    def writeNext(address: Int): Unit =
      if (address >= pattern.length) {
        ()
      } else {
        val remaining = pattern.length - address
        val useBurst = remaining > 1 && random.nextBoolean() // Last word must be single write, otherwise randomly choose burst or single
        val burstLength = if (useBurst) math.min(random.nextInt(maxBurstLength) + 1, remaining) else 1
        val mode = if (burstLength == 1) "single" else s"burst($burstLength)"

        // Perform single or burst write for the current segment
        // burtLength
        //  1 : Single write, isBurstCycle = false
        // >1 : Burst write, isBurstCycle = true for all but the last word

        (0 until burstLength).foreach { offset =>
          val isBurstCycle = offset != burstLength - 1
          writeWord(
            dut,
            address = address + offset,
            data = pattern(address + offset),
            burst = isBurstCycle
          )
        }

        idleWriteInterface(dut, cycles = 0)
        activityLog += s"@${simTime()}ps $mode write covered addresses ${address}..${address + burstLength - 1}"

        val nextAddress = address + burstLength
        if (nextAddress < pattern.length) {
          val gapCycles = minGapCycles + random.nextInt(maxGapCycles - minGapCycles + 1)
          idleWriteInterface(dut, cycles = gapCycles)
          activityLog += s"@${simTime()}ns inserted $gapCycles idle write cycles before next write-active phase"
        }

        writeNext(nextAddress)
      }

    writeNext(0)

    activityLog
  }

  private def readWord(dut: Bram2p, address: Int, burst: Boolean = false): Long = {
    val issuedAtNs = simTime()
    dut.io.rd.addr #= address
    dut.io.rd.en #= true
    dut.clockDomain.waitSampling()

    if (!burst) {
      dut.io.rd.en #= false
      dut.io.rd.addr #= 0
      dut.clockDomain.waitSampling()
    }

    issuedAtNs
  }

  private def startReadMonitor(dut: Bram2p, captures: ArrayBuffer[ReadCapture]): Unit = {
    FlowMonitor(dut.io.rd.data, dut.clockDomain) { payload =>
      captures += ReadCapture(
        timeNs = simTime(),
        data = payload.toBigInt
      )
    }
  }

  private def formatHex(value: BigInt): String = s"0x${value.toString(16)}"

  private def formatReadIssue(timeNs: Long, address: String, expected: String, actual: String): String = {
    s"@${timeNs}ns addr=$address, expected=$expected actual=$actual"
  }

  private def compareReadResults(
    report: ScenarioScoreboard,
    failureMessage: String,
    successMessage: String,
    requests: Seq[ReadRequest],
    captures: Seq[ReadCapture]
  ): Unit = {
    val mismatches = ArrayBuffer.empty[String]

    requests.zip(captures).foreach { case (request, capture) =>
      if (capture.data != request.expected) {
        mismatches += formatReadIssue(
          timeNs = capture.timeNs,
          address = request.address.toString,
          expected = formatHex(request.expected),
          actual = formatHex(capture.data)
        )
      }
    }

    requests.drop(captures.size).foreach { request =>
      mismatches += formatReadIssue(
        timeNs = request.issuedAtNs,
        address = request.address.toString,
        expected = formatHex(request.expected),
        actual = "<no-capture>"
      )
    }

    captures.drop(requests.size).foreach { capture =>
      mismatches += formatReadIssue(
        timeNs = capture.timeNs,
        address = "?",
        expected = "<no-request>",
        actual = formatHex(capture.data)
      )
    }

    if (mismatches.isEmpty) {
      report.pass(successMessage)
    } else {
      report.fail(failureMessage, mismatches)
    }
  }

  private def runPassingScenario(
    report: ScenarioScoreboard,
    seed: Int,
    timeoutCycles: Int
  )(
    scenario: Bram2p => Unit
  ): Unit = {
    val thrown = try {
      compiled.doSimUntilVoid(seed = seed) { dut =>
        dut.clockDomain.forkStimulus(10)  // 10 ps
        SimTimeout(timeoutCycles)
        init(dut)
        scenario(dut)
        dut.clockDomain.waitSampling(10)
        println( f"@${simTime()}ps Simulation is done." )
        simSuccess()
      }

      None
    } catch {
      case throwable: Throwable => Some(throwable)
    }

    thrown.foreach { throwable =>
      report.fail(
        s"Simulation terminated unexpectedly.",
        Seq(Option(throwable.getMessage).getOrElse(throwable.getClass.getName))
      )
    }

    report.print()

  }

  test("normal read-after-write") {
    val scbd = new ScenarioScoreboard(
      name = "normal read-after-write",
      description = "Write deterministic random data across the full RAM, then read every location back and printverify exact matches."
    )

    runPassingScenario(scbd, seed = 11, timeoutCycles = 600000 ) { dut =>
      val readCaptures = ArrayBuffer.empty[ReadCapture]
      startReadMonitor(dut, readCaptures)

      val clearCycles = clearRam(dut)
      scbd.pass(s"@${simTime()}ps clear_done asserted after $clearCycles cycles.")

      val random = new Random(0x5eedL)
      val pattern = Vector.tabulate(memoryDepth) { _ =>
        BigInt(random.nextInt(1 << memoryWordWidth))
      }

      val writeRandom = new Random(0x51a7L)
      val writeActivity = writePatternWithRandomPhases(dut, pattern, writeRandom)
      scbd.pass(s"@${simTime()}ps Writing deterministic random data into all $memoryDepth RAM addresses using randomized single/burst write phases is done.")
      if ( verbosity ) {
        writeActivity.foreach(scbd.pass)
      }

      val readRequests = ArrayBuffer.empty[ReadRequest]
      pattern.zipWithIndex.foreach { case (expected, address) =>
        val issuedAtNs = readWord(dut, address, burst = address != memoryDepth - 1)
        readRequests += ReadRequest(address = address, expected = expected, issuedAtNs = issuedAtNs)
      }
      scbd.pass(s"@${simTime()}ps Issuing read requests for all $memoryDepth addresses with expected data from the random pattern is Done.")

      compareReadResults(
        report = scbd,
        failureMessage = "Read-after-write mismatches were detected.",
        successMessage = s"@${simTime()}ps All $memoryDepth read-after-write checks matched the written random pattern.",
        requests = readRequests,
        captures = readCaptures
      )
    }


  }

  test("ram clearing operation") {
    val report = new ScenarioScoreboard(
      name = "ram clearing operation",
      description = "RAM clear must overwrite preloaded content with the configured default value."
    )

    runPassingScenario(report, seed = 22, timeoutCycles = 600000) { dut =>
      val readCaptures = ArrayBuffer.empty[ReadCapture]
      startReadMonitor(dut, readCaptures)

      val preloadPattern = Vector.tabulate(memoryDepth) { address =>
        val value = BigInt((address * 3 + 1) & ((1 << memoryWordWidth) - 1))
        if (value == defaultValue) value + 1 else value
      }

      val writeRandom = new Random(0x6c34L)
      val writeActivity = writePatternWithRandomPhases(dut, preloadPattern, writeRandom)
      report.pass(s"@${simTime()}ns Preloaded $memoryDepth addresses with non-default data before clear using randomized single/burst write phases.")
      if (verbosity) {
        writeActivity.foreach(report.pass)
      }

      val clearCycles = clearRam(dut)
      report.pass(s"clear_done asserted after $clearCycles cycles.")

      val readRequests = ArrayBuffer.empty[ReadRequest]
      for (address <- 0 until memoryDepth) {
        val issuedAtNs = readWord(dut, address, burst = address != memoryDepth - 1)
        readRequests += ReadRequest(address = address, expected = defaultValue, issuedAtNs = issuedAtNs)
      }

      compareReadResults(
        report = report,
        failureMessage = "RAM clearing left unexpected contents in memory.",
        successMessage = s"All $memoryDepth addresses returned the default value ${formatHex(defaultValue)} after clear.",
        requests = readRequests,
        captures = readCaptures
      )
    }
  }

  test("write with read overlap") {
    val report = new ScenarioScoreboard(
      name = "write with read overlap",
      description = "A write and a read in the same cycle must both complete correctly on different addresses."
    )

    runPassingScenario(report, seed = 33, timeoutCycles = 50000) { dut =>
      val readCaptures = ArrayBuffer.empty[ReadCapture]
      val readRequests = ArrayBuffer.empty[ReadRequest]

      startReadMonitor(dut, readCaptures)

      clearRam(dut)
      writeWord(dut, address = 3, data = 5)

      val overlapIssuedAtNs = simTime()
      dut.io.wr.addr #= 7
      dut.io.wr.data #= 10
      dut.io.wr.en #= true
      dut.io.rd.addr #= 3
      dut.io.rd.en #= true
      dut.clockDomain.waitSampling()

      dut.io.wr.en #= false
      dut.io.rd.en #= false
      dut.io.wr.addr #= 0
      dut.io.wr.data #= 0
      dut.io.rd.addr #= 0
      dut.clockDomain.waitSampling()

      readRequests += ReadRequest(address = 3, expected = 5, issuedAtNs = overlapIssuedAtNs)
      readRequests += ReadRequest(address = 7, expected = 10, issuedAtNs = readWord(dut, 7))
      readRequests += ReadRequest(address = 3, expected = 5, issuedAtNs = readWord(dut, 3))

      compareReadResults(
        report = report,
        failureMessage = "Overlapped and follow-up reads mismatched expected data.",
        successMessage = "Overlapped read plus follow-up single reads matched expected data.",
        requests = readRequests,
        captures = readCaptures
      )
    }
  }

  test("write during clear asserts") {
    val report = new ScenarioScoreboard(
      name = "write during clear asserts",
      description = "Driving an external write while clear is active must raise the protection assertion."
    )

    val thrown = try {
      compiled.doSimUntilVoid(seed = 44) { dut =>
        dut.clockDomain.forkStimulus(10)
        SimTimeout(50000)

        init(dut)
        dut.io.clear_start #= true
        dut.clockDomain.waitSampling()
        dut.io.clear_start #= false

        dut.io.wr.addr #= 6
        dut.io.wr.data #= 13
        dut.io.wr.en #= true
        dut.clockDomain.waitSampling(2)

        simFailure("Expected write-during-clear assertion did not fire.")
      }
      None
    } catch {
      case throwable: Throwable => Some(throwable)
    }

    thrown match {
      case Some(throwable) =>
        val message = Option(throwable.getMessage).getOrElse(throwable.getClass.getName)
        if (message.contains("Expected write-during-clear assertion did not fire.")) {
          report.fail(
            "Simulation finished without triggering the expected assertion.",
            Seq(
              "Stimulus drove wr.en high while clear was active.",
              s"Observed message: $message"
            )
          )
        } else {
          report.pass("Simulation aborted immediately after the illegal write was driven.")
          if (
            message.toLowerCase.contains("clear") ||
            message.toLowerCase.contains("write") ||
            message.toLowerCase.contains("assert")
          ) {
            report.pass(s"Failure message captured for debug: $message")
          } else {
            report.fail(
              "A failure was observed, but the message did not clearly identify the assertion.",
              Seq(s"Observed message: $message")
            )
          }
        }
      case None =>
        report.fail(
          "Simulation completed without any failure.",
          "The write-during-clear assertion was expected to stop the test."
        )
    }

    report.print()
  }
}




