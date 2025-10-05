package IPS.playfield



import IPS.collision_checker.blockSim
import spinal.core._
import spinal.core.sim.{SimCompiled, _}
import config._
import org.scalatest.funsuite.AnyFunSuite
import spinal.lib.sim.FlowMonitor
import utils.PathUtils
import utils.BitPatternGenerators
import utils.TestPatterns._
import utils._

import scala.collection.mutable
import scala.util.Random
import scala.collection.mutable.ArrayBuffer
import java.awt.{BasicStroke, Color, Font, Graphics2D}
import java.awt.image.BufferedImage
import java.io.File
import java.util.concurrent.CountDownLatch
import javax.imageio.ImageIO
import javax.swing.WindowConstants
import scala.swing._
import scala.swing.event._

trait PlayFieldTestHelper {



  def backdoorWritePlayfieldRow( dut : playfield, row : Int, data : Int  ) = {
    println(s"[INFO] @${simTime()} Backdoor write playfield row[${row}] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')}")
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= true
    dut.io.playfield_backdoor.row #= row
    dut.io.playfield_backdoor.data #= data
  }


  def backdoorWriteWholePlayfield(dut : playfield, content : Seq[Int]  ) = {
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
    content.zipWithIndex.foreach { case ( value, i )    =>
      backdoorWritePlayfieldRow( dut, i, value )
    }
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
  }

  def backdoorWriteFlowRegion(dut : playfield, content : Seq[Int], row : Int ) = {

    dut.clockDomain.waitSampling()
    dut.io.flow_backdoor.valid #= false
    dut.clockDomain.waitSampling()
    dut.io.flow_backdoor.valid #= true
    dut.io.flow_backdoor.row #= row
    content.zipWithIndex.foreach { case (data, i) =>
      dut.io.flow_backdoor.data(i) #= data
      println(s"[INFO] @${simTime()} Backdoor write flow regin[${i}] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')}")
    }
    dut.clockDomain.waitSampling()
    dut.io.flow_backdoor.valid #= false
    dut.io.flow_backdoor.row.randomize()
    for ( i <- content.indices) {  dut.io.flow_backdoor.data(i).randomize()  }
  }


  def backdoorWritePlayfieldWithPattern( dut : playfield, length : Int, width : Int,  pattern: BitPatternGenerators.Pattern ) = {

    BitPatternGenerators.generateSequence( length, width, pattern).sample match {
      case Some(seq) =>
        backdoorWriteWholePlayfield(dut, seq)
        seq
      case None =>  simFailure("[ERROR] No seq is created !!!") ;  Nil
    }

  }

  def backdoorWriteFlowWithPattern( dut : playfield, row : Int, width : Int,  pattern: BitPatternGenerators.Pattern ) = {

    BitPatternGenerators.generateSequence(4, width, pattern).sample match {
      case Some(seq) =>
        backdoorWriteFlowRegion(dut, seq, row)
        seq
      case None =>  simFailure("[ERROR] No seq is created !!!") ;  Nil
    }

  }


  def readWholePlayfield(dut : playfield ) ={
    println(s"[INFO] @${simTime()} Start to front-door read whole playfield .......")
    dut.clockDomain.waitSampling()
    dut.io.read #= true
    dut.clockDomain.waitSampling()
    dut.io.read #= false

  }

  /**
   * Execute a sequence of test actions
   */
  def executeTestReadoutActions(
                                 dut: playfield,
                                 scbd: PlayFieldScoreboard,
                                 length : Int,
                                 width : Int,
                                 row : Int,
                                 actions: Seq[TestPatternPair],
                                 verbose: Boolean
                                ): Unit = {

    assert(
      row >= 0 && row <= (length-1 ) ,
      s"Row options $row is out of the expected range [0, ${length-1}]."
    )

    /**
     * Overlays sequence `b` onto sequence `a` using a bitwise OR operation.
     *
     * @param a   The base sequence.
     * @param b   The sequence to overlay.
     * @param row The starting index in `a` where the operation begins.
     * @return A new sequence with the result of the OR operation.
     */
    def orOverlay(a: Seq[Int], b: Seq[Int], row: Int): Seq[Int] = {
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

    // Print Test suits Summary
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tTest Group Summary\n")
    println(s"\tFlow Region Row : ${row}")
    println(f"\tTest Pattern :\t Playfield  x\t Flow region\t\tCount")
    for ( (action,i) <- actions.zipWithIndex ) {
      println(f"\t\t\t${i+1}\t: ${action.p0}%12s\tx\t${action.p1}%12s\t\t\t${action.count}")
    }
    println(s"\n${"=" * 120}")

    // transverse to execute test patterns
    for (action <- actions) {
      if (verbose) {
        println(s"\n${"="*100}\n")
        println(s"\t\tExecuting Test Action ${actionIndex + 1}/${actions.size}")
        println(s"\t\tPurpose\t: ${action.getDescription}")
        println(s"\t\tPattern\t: ${action.p0} x ${action.p1}, Count: ${action.count}")
        println(s"\n${"="*100}")
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
        val expectedData = orOverlay(playfieldData,flowData, row )

        expectedData.foreach{ scbd.addExpected }

        // Stimulus DUT with test data
        readWholePlayfield(dut)
        dut.clockDomain.waitSampling(60)

        val allMatch = scbd.compare()

        println( scbd.report() )

        if ( ! allMatch) { simFailure( "Scoreboard Reports Error ")}
        scbd.clear()
      }

      actionIndex += 1
    }
  }

}



class PlayFieldTest extends AnyFunSuite with PlayFieldTestHelper {


  //var compiler: String = "verilator"
  val compiler : String = "vcs"

  val runFolder: String = PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString


  var drawFrameInstance: Option[MainFrame] = None
  val expectedData, receivedData = ArrayBuffer[Int]()
  val receivedHitStatus = mutable.Queue[Boolean]()
  val receivedRowValue = mutable.Queue[Int]()


  val rowNum: Int = 20 // include bottom wall
  val colNum: Int = 10 // include left and right wall

  val rowBitsWidth = log2Up(rowNum)
  val colBitsWidth = log2Up(colNum)
  val rowBlocksNum = rowNum // working field for Tetromino
  val colBlocksNum = colNum // working field for Tetromino

  val config = PlayfieldConfig(
    rowBlocksNum = rowBlocksNum,
    colBlocksNum = colBlocksNum,
    rowBitsWidth = rowBitsWidth,
    colBitsWidth = colBitsWidth
  )


  lazy val compiled : SimCompiled[playfield]  = runSimConfig(runFolder, compiler)
    .compile {
      val c = new playfield(config, sim= true)
      c
    }

  def initDUT( dut : playfield ) = {
    println(s"[INFO] @${simTime()} initDut is called .......")
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
    dut.io.read #= false
    dut.io.piece_in.valid #= false
    dut.io.piece_in.payload.randomize()

  }

  test("usecase 1 - random fill all pixel and flow region ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      /*****************************************
            Custom settings begin
      ******************************************/

      val predefReadTestPattern = List(
        ReadoutScenarios.basic,
        ReadoutScenarios.playfieldPatternOnly,
        ReadoutScenarios.flowPatternOnly,
        ReadoutScenarios.usecase,
        ReadoutScenarios.random
      )

      val readTestPatternList = List( 1 ,0 ,0 ,0 ,0 )  /* Pattern group selection */
        .zip( predefReadTestPattern )
        .collect{ case (1, pattern) => pattern }
        .flatten

      /*****************************************
       Custom settings end
       ******************************************/

      val scbd = new PlayFieldScoreboard(
        name = "Scoreboard",
        size = rowBlocksNum,
        verbose = true
      )

      // Global Clocking settings
      dut.clockDomain.forkStimulus(10)
      SimTimeout(1 ms ) // adjust timeout as needed
      dut.clockDomain.waitSampling(20)

      // Initialize DUT
      initDUT(dut)

      // Prepare Monitor
      FlowMonitor(dut.io.row_val, dut.clockDomain) { payload =>
        scbd.addActual( payload.toInt, s"@${simTime()}" )
      }

      // Body
      //for ( flowRegionRow <- 0 until config.rowBlocksNum ) {
      for ( flowRegionRow <- 0 until 2 ) {
        println(s"[INFO] flow region row at ${flowRegionRow} !!!")
        executeTestReadoutActions(dut, scbd,
          actions = readTestPatternList,
          length = config.rowBlocksNum, width = config.colBlocksNum,
          row = flowRegionRow,
          verbose = true
        )
        dut.clockDomain.waitSampling(500)

      }

      println("[DEBUG] doSim is exited !!!")

      println("simTime : " + simTime())
      simSuccess()
    }
  }



}




