package IPS.bcd

import IPS.playfield.executors._
import config.TetrominoesConfig.binaryTypeOffsetTable
import spinal.core._
import spinal.core.sim.{SimCompiled, _}
import config._
import org.scalatest.funsuite.AnyFunSuite
import spinal.lib.Reverse
import spinal.lib.sim.FlowMonitor
import utils.PathUtils

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer



class bcdTest extends AnyFunSuite {
  //val compiler: String = "verilator"
  val compiler: String = "vcs"

  val runFolder: String = PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString


//  test("usecase 1 - r") {
//    compiled.doSimUntilVoid(seed = 42) { dut =>
//
//      val obs_data =  mutable.Queue[BigInt]()
//
//      val total_num = 120
//      val exp_data = (0 until total_num ) .toList
//      dut.clockDomain.forkStimulus(10)
//      SimTimeout(900000)
//
//      println(s"@${simTime()} Start create data pattern ")
//
//      // Prepare Monitor
//      FlowMonitor(dut.io.data_out_dec, dut.clockDomain) { payload =>
//        obs_data.enqueue( payload.toBigInt )
//      }
//
//
//      dut.io.data_in_bin.valid #= false
//
//
//      dut.clockDomain.waitSampling(20)
//
//      for( data <- exp_data ) {
//
//        dut.io.data_in_bin.valid #= true
//        dut.io.data_in_bin.payload #= data
//
//        dut.clockDomain.waitSampling(1)
//
//        dut.io.data_in_bin.valid #= false
//
//        dut.clockDomain.waitSampling(30)
//
//      }
//
//      println(s"${"-" * 100}")
//      println(s"\t\t\t\t\t Result")
//      println(s"${"-" * 100}")
//      for ( ( send_data, i) <- exp_data.zipWithIndex ) {
//        val obs = obs_data.dequeue()
//        val hundreds =  obs >> ( 4 * 2 ) & 0xF
//        val tens = obs >> ( 4 * 1 ) & 0xF
//        val ones = obs & 0xF
//        val obs_value = hundreds * 100 + tens * 10 + ones
//        println(f"\t${i}\t: ${send_data}%3d\t\t$hundreds%2d$tens%2d$ones%2d\t\t" + { if (send_data==obs_value) "Pass" else "Fail" } )
//      }
//
//      dut.clockDomain.waitSampling(100)
//      println("[DEBUG] doSim is exited !!!")
//      println("simTime : " + simTime())
//      simSuccess()
//
//    }
//
//  }
  // Test parameters
  val BINARY_WIDTH = 10
  val CLOCK_PERIOD = 10
  val SIM_TIMEOUT = 900000
  val INTER_STIMULUS_CYCLES = 30

  lazy val compiled: SimCompiled[bcd] = runSimConfig(runFolder, compiler)
    .compile {
      val c = new bcd(binaryWidth = BINARY_WIDTH )
      c
    }


  test("DoubleDabble - Binary to BCD Conversion") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      // Test configuration
      val totalTestCases = 120
      val stimulusData = (0 until totalTestCases).toList
      val observedOutputQueue = mutable.Queue[BigInt]()

      // Initialize clock and timeout
      dut.clockDomain.forkStimulus(CLOCK_PERIOD)
      SimTimeout(SIM_TIMEOUT)

      println(s"@${simTime()} Initializing Double Dabble Binary to BCD Test")
      println("=" * 100)

      // Setup output monitor
      FlowMonitor(dut.io.data_out_dec, dut.clockDomain) { payload =>
        observedOutputQueue.enqueue(payload.toBigInt)
      }

      // Initialize input signals
      dut.io.data_in_bin.valid #= false
      dut.io.data_in_bin.payload #= 0
      dut.clockDomain.waitSampling(20)

      // Apply stimulus patterns
      println(s"@${simTime()} Applying ${stimulusData.length} test vectors...")
      for (inputValue <- stimulusData) {
        dut.io.data_in_bin.valid #= true
        dut.io.data_in_bin.payload #= inputValue
        dut.clockDomain.waitSampling(1)
        dut.io.data_in_bin.valid #= false
        dut.clockDomain.waitSampling(INTER_STIMULUS_CYCLES)
      }

      // Wait for all outputs to be captured
      dut.clockDomain.waitSampling(50)

      // Analyze and verify results
      var passCount = 0
      var failCount = 0
      val detailedResults = mutable.ArrayBuffer[String]()

      println("=" * 100)
      println(f"${"Index"}%8s | ${"Input"}%8s | ${"BCD Output"}%12s | ${"Decoded"}%8s | ${"Status"}%8s")
      println("-" * 100)

      for ((inputValue, testIndex) <- stimulusData.zipWithIndex) {
        // Collect all BCD digits for this test (MSB first)
        val origDigits = observedOutputQueue.dequeue()
        val bcdDigits = mutable.ArrayBuffer[BigInt]()

        // Use for-loop instead
//        bcdDigits += origDigits >> ( 4 * 3 ) & 0xF
//        bcdDigits += origDigits >> ( 4 * 2 ) & 0xF
//        bcdDigits += origDigits >> ( 4 * 1 ) & 0xF
//        bcdDigits += origDigits >> ( 4 * 0 ) & 0xF

          for ( i <- ( 0 until dut.bcdDigits  ).reverse) {
            bcdDigits += ( origDigits >> ( 4 * i ) )  & 0xF
          }

//        for (_ <- 0 until dut.bcdDigits) {
//          if (observedOutputQueue.nonEmpty) {
//            bcdDigits += observedOutputQueue.dequeue()
//          }
//        }

        // Convert BCD digits back to decimal value
        val decodedValue = bcdDigits.zipWithIndex.map { case (digit, idx) =>
          val position = dut.bcdDigits - 1 - idx
          digit.toInt * Math.pow(10, position).toInt
        }.sum

        // Verify correctness
        val testPassed = decodedValue == inputValue
        val status = if (testPassed) "✓ PASS" else "✗ FAIL"

        if (testPassed) passCount += 1 else failCount += 1

        // Format BCD output string
        val bcdString = bcdDigits.map(d => f"$d%1d").mkString("")

        // Store detailed result
        val resultLine = f"$testIndex%8d | $inputValue%8d | $bcdString%12s | $decodedValue%8d | $status%8s"
        detailedResults += resultLine

        // Print result
        println(resultLine)
      }

      // Print comprehensive summary at end
      println("=" * 100)
      println("Test Execution Summary:")
      println("-" * 100)
      println(f"Total Test Cases:     $totalTestCases%5d")
      println(f"Passed:               $passCount%5d  (${passCount * 100.0 / totalTestCases}%6.2f%%)")
      println(f"Failed:               $failCount%5d  (${failCount * 100.0 / totalTestCases}%6.2f%%)")
      println(f"Binary Width:         $BINARY_WIDTH%5d bits")
      println(f"BCD Digits:           ${dut.bcdDigits}%5d")
      println(f"Simulation Time:      ${simTime()}%5d ns")
      println("=" * 100)

      if (failCount == 0) {
        println("✓ All tests passed successfully!")
      } else {
        println(s"✗ Warning: $failCount test(s) failed. Please review detailed results above.")
      }
      println("=" * 100)

      // Complete simulation
      dut.clockDomain.waitSampling(100)
      println(s"[INFO] Simulation completed at ${simTime()} ns")
      simSuccess()
    }
  }
}