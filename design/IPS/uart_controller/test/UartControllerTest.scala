package IPS.uart_controller

import spinal.core._
import spinal.core.sim.{SimCompiled, _}
import config._
import org.scalatest.funsuite.AnyFunSuite
import utils._
import scala.collection.mutable


class PlayFieldTest extends AnyFunSuite {
  //val compiler: String = "verilator"
  val compiler: String = "vcs"
  val runFolder: String = PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString

  lazy val compiled: SimCompiled[uart_controller] = runSimConfig(runFolder, compiler)
    .compile {
      val c = new uart_controller(systemClockFrequency = 50 MHz)
      c.uartCtrl.io.read.valid.simPublic()
      c
    }

  // UART VIP to send bytes following UART protocol
  def uartTx(baudRate: Int, txPin: Bool, data: Int, clockPeriod: Long): Unit = {
    val baudPeriod = (1e9 / baudRate).toLong // nanoseconds per bit

    // Start bit
    txPin #= false
    sleep(baudPeriod)

    // Data bits (LSB first)
    for (i <- 0 until 8) {
      txPin #= ((data >> i) & 1) == 1
      sleep(baudPeriod)
    }

    // Stop bit
    txPin #= true
    sleep(baudPeriod)
  }

  // Initialize DUT inputs
  def initDut(dut: uart_controller): Unit = {
    dut.io.uart.rxd #= true  // Idle high
    dut.io.controlReset #= false
  }

  def hardReset( dut: uart_controller, numInNs : Int ) : Unit = {

    println(s"@${simTime()} Reset DUT now ... " )
    dut.clockDomain.assertReset()
    sleep(numInNs)
    println(s"@${simTime()} Release DUT now ... " )
    dut.clockDomain.deassertReset()
    dut.clockDomain.waitSampling(5)

  }
  // Test key mapping
  case class KeyTest(key: Char, ascii: Int, signalName: String, getSignal: uart_controller => Bool)

  val keyTests = List(
    KeyTest('w', 0x77, "game_start", _.io.game_start),
    KeyTest('a', 0x61, "move_left", _.io.move_left),
    KeyTest('d', 0x64, "move_right", _.io.move_right),
    KeyTest('s', 0x73, "move_down", _.io.move_down),
    KeyTest(' ', 0x20, "rotate", _.io.rotate),
    KeyTest('\r', 0x0D, "drop", _.io.drop)
  )

  // Scoreboard for tracking results
  case class TestResult(key: Char, signalName: String, expected: Boolean, actual: Boolean) {
    def passed: Boolean = expected == actual
  }

  test("usecase 1 - Check all keys inputs") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      // Global Clocking settings
      dut.clockDomain.forkStimulus(20) // 50MHz clock (20ns period)
      SimTimeout(20 us)

      val results = mutable.ListBuffer[TestResult]()
      val baudRate = 19200
      val clockPeriod = 20 // ns

      /*  Main test body */

      // Initialize DUT
      initDut(dut)
      println("=" * 80)
      println("UART Controller Test - Baud Rate: 19200")
      println("=" * 80)

      dut.clockDomain.waitSampling(10)

      // ********************************************************
      // Test each key
      // ********************************************************

      println(s"\n[Test Phase 1] Testing all key mappings...")
      keyTests.foreach { test =>
        println(s"\n@${simTime()} Testing key '${test.key}' (0x${test.ascii.toHexString}) -> ${test.signalName}")

        // Wait for idle state
        dut.clockDomain.waitSampling(5)

        // Record signal state before transmission
        val signalBefore = test.getSignal(dut).toBoolean

        // Send UART byte
        uartTx(baudRate, dut.io.uart.rxd, test.ascii, clockPeriod)

        dut.clockDomain.waitSampling(10)  // Capture it at the next cycle
        val signalPulsed = test.getSignal(dut).toBoolean

        val result = TestResult(test.key, test.signalName, expected = true, actual = signalPulsed)
        results += result

        if (result.passed) {
          println(s"@${simTime()}  ✓ PASS: ${test.signalName} pulsed correctly")
        } else {
          println(s"@${simTime()}  ✗ FAIL: ${test.signalName} did not pulse (expected: true, actual: $signalPulsed)")
        }

        // Wait for signal to return to low
        dut.clockDomain.waitSampling(5)
      }


      hardReset(dut, 200 )

      // ********************************************************
      // Test invalid key (should not trigger any signal)
      // ********************************************************

      println("\n[Test Phase 2] Testing invalid key (should not trigger signals)...")
      val invalidKey = 0x58 // 'X'
      println(s"@${simTime()} Sending invalid key 'X' (0x${invalidKey.toHexString})")

      uartTx(baudRate, dut.io.uart.rxd, invalidKey, clockPeriod)
      dut.clockDomain.waitSampling(10)

      val anySignalActive = keyTests.exists(t => t.getSignal(dut).toBoolean)
      val invalidResult = TestResult('X', "no_signal", expected = false, actual = anySignalActive)
      results += invalidResult

      if (invalidResult.passed) {
        println(s"@${simTime()}  ✓ PASS: No signals triggered for invalid key")
      } else {
        println(s"@${simTime()}  ✗ FAIL: Unexpected signal triggered for invalid key")
      }

      // ********************************************************
      // Test controlReset functionality
      // ********************************************************

      println("\n[Test Phase 3] Testing controlReset functionality...")
      dut.clockDomain.waitSampling(5)

      // Send a key to activate a signal
      println("Sending key 'a' to activate move_left...")
      uartTx(baudRate, dut.io.uart.rxd, 0x61, clockPeriod)
      dut.clockDomain.waitSampling(5)

      // Assert controlReset
      println("Asserting controlReset...")
      dut.io.controlReset #= true
      dut.clockDomain.waitSampling(3)

      // Check all signals are low
      val allSignalsLow = keyTests.forall(t => !t.getSignal(dut).toBoolean)
      val resetResult = TestResult('R', "controlReset", expected = true, actual = allSignalsLow)
      results += resetResult

      if (resetResult.passed) {
        println(s"  ✓ PASS: All signals reset to low")
      } else {
        println(s"  ✗ FAIL: Some signals not reset properly")
      }

      // Deassert controlReset
      dut.io.controlReset #= false
      dut.clockDomain.waitSampling(5)

      // Verify signals remain low after reset deasserted
      val signalsStillLow = keyTests.forall(t => !t.getSignal(dut).toBoolean)
      val postResetResult = TestResult('P', "post_reset", expected = true, actual = signalsStillLow)
      results += postResetResult

      if (postResetResult.passed) {
        println(s"  ✓ PASS: Signals remain low after reset deassertion")
      } else {
        println(s"  ✗ FAIL: Signals changed after reset deassertion")
      }

      // Summary Report
      println("\n" + "=" * 80)
      println("TEST SUMMARY REPORT")
      println("=" * 80)

      val totalTests = results.size
      val passedTests = results.count(_.passed)
      val failedTests = totalTests - passedTests

      println(f"\nTotal Tests: $totalTests")
      println(f"Passed:      $passedTests (${passedTests * 100.0 / totalTests}%.1f%%)")
      println(f"Failed:      $failedTests (${failedTests * 100.0 / totalTests}%.1f%%)")

      if (failedTests > 0) {
        println("\nFailed Tests:")
        results.filter(!_.passed).foreach { r =>
          println(f"  - ${r.signalName}%-15s (Key: '${r.key}', Expected: ${r.expected}, Actual: ${r.actual})")
        }
      }

      println("\n" + "=" * 80)
      if (passedTests == totalTests) {
        println("✓ ALL TESTS PASSED")
        println("=" * 80 + "\n")
        simSuccess()
      } else {
        println("✗ SOME TESTS FAILED")
        println("=" * 80 + "\n")
        simFailure("Test failures detected")
      }
    }
  }
}


