package IPS.playfield.executors

import IPS.playfield.{PlayfieldBackdoorAPI, PlayfieldTestBase, playfield}
import spinal.core._
import spinal.core.sim._
import utils.TestPatterns._
import utils._

trait ReadoutTestExecutor {

  this: PlayfieldTestBase with PlayfieldBackdoorAPI =>

  def executeTestReadoutActions(
                                 dut: playfield,
                                 scbd: PlayFieldScoreboard,
                                 length: Int,
                                 width: Int,
                                 row: Int,
                                 actions: Seq[TestPatternPair],
                                 verbose: Boolean
                               ): Unit = {

    assert(
      row >= 0 && row <= (length - 1),
      s"Row options $row is out of the expected range [0, ${length - 1}]."
    )

    /**
     * Overlays sequence `b` onto sequence `a` using a bitwise OR operation.
     *
     * @param a   The base sequence.
     * @param b   The sequence to overlay.
     * @param row The starting index in `a` where the operation begins.
     * @return A new sequence with the result of the OR operation.
     */
    def model(a: Seq[Int], b: Seq[Int], row: Int): Seq[Int] = {
      a.zipWithIndex.map { case (aValue, index) =>
        // Check if the current index is within the overlay range
        if (index >= row && index < row + b.length) {
          // Calculate the corresponding index for sequence 'b'
          val bIndex = index - row
          // Perform the bitwise OR operation
          aValue | b(bIndex)
        } else {
          // If outside the range, keep the original value from 'a'
          aValue
        }
      }
    }

    var actionIndex = 0

    printReadoutTestSummary(actions, row)

    dut.clockDomain.waitSampling()
    dut.io.fsm_contrl #= true
    dut.clockDomain.waitSampling()
    dut.io.fsm_contrl #= false

    // transverse to execute test patterns
    for (action <- actions) {
      if (verbose) {
        println(s"\n${"=" * 100}\n")
        println(s"\t\tExecuting Test Action ${actionIndex + 1}/${actions.size}")
        println(s"\t\tPurpose\t: ${action.getDescription}")
        println(s"\t\tPattern\t: ${action.p0} x ${action.p1}, Count: ${action.count}")
        println(s"\n${"=" * 100}")
      }

      for (iteration <- 0 until action.count) {
        if (verbose && action.count > 1) {
          println(s"\t\t Round ${iteration + 1}/${action.count}")
        }

        // Generate and write pattern
        val playfieldData = backdoorWritePlayfieldWithPattern(
          dut,
          length,
          width,
          action.p0
        )

        val flowData = backdoorWriteFlowWithPattern(
          dut,
          row,
          width,
          action.p1
        )

        // Modelling readout by OR flow.region and playfield.region
        val expectedData = model(playfieldData, flowData, row)

        expectedData.foreach {
          scbd.addExpected
        }

        // Stimulus DUT with test data
        readWholePlayfield(dut)
        dut.clockDomain.waitSampling(60)

        val allMatch = scbd.compare()

        println(scbd.report())

        if (!allMatch) {
          simFailure("Scoreboard Reports Error ")
        }
        scbd.clear()
      }

      actionIndex += 1
    }
  }

  private def printReadoutTestSummary(
                                         actions: Seq[TestPatternPair],
                                         row: Int
                                       ): Unit = {
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tPlacement Test Group Summary\n")
    println(s"\tChecker Region based on Row : $row")
    println(f"\tTest Pattern :\t Playfield  x\t Place item\t\tCount")
    actions.zipWithIndex.foreach { case (action, i) =>
      println(f"\t\t\t${i + 1}\t: ${action.p0}%12s\tx\t${action.p1}%12s\t\t\t${action.count}")
    }
    println(s"\n${"=" * 120}")
  }


}
