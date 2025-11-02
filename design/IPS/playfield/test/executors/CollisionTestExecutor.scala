package IPS.playfield.executors

import IPS.playfield.{PlayfieldBackdoorAPI, PlayfieldTestBase, playfield}


import spinal.core._
import spinal.core.sim._
import utils.TestPatterns._
import utils._

trait CollisionTestExecutor {

  this: PlayfieldTestBase with PlayfieldBackdoorAPI =>

  def executeTestCollisionCheckerActions(
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
    def model(a: Seq[Int], b: Seq[Int], row: Int): Int = {

      val region_overlap = a.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << dut.config.colBlocksNum) - 1))

      val ret = region_overlap.zip(b).map { case (a, b) => (a & b).toInt > 0 }

      region_overlap.foreach { a => println(f"Compared Playield data : 0b${String.format("%10s", Integer.toBinaryString(a)).replace(' ', '0')} ") }
      ret.foldLeft(false)(_ | _) toInt

    }

    var actionIndex = 0

    printCollisionTestSummary(actions, row)

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

        val ref = playfieldData.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << dut.config.colBlocksNum) - 1))
        val checkData = backdoorWriteCheckerWithPattern(
          dut,
          row,
          width,
          action.p1,
          ref = ref
        )

        // Modelling readout by OR flow.region and playfield.region
        val expectedData = model(playfieldData, checkData, row)

        scbd.addExpected(expectedData)

        // Stimulus DUT with test data
        startCollisonCheck(dut)
        dut.clockDomain.waitSampling(60)

        forceFsmToIdle(dut)

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


  private def printCollisionTestSummary(
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
