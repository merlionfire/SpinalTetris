package IPS.playfield

import config.TetrominoesConfig.binaryTypeOffsetTable
import spinal.core._
import spinal.core.sim.{SimCompiled, _}
import config._
import org.scalatest.funsuite.AnyFunSuite
import spinal.lib.sim.FlowMonitor
import utils.PathUtils
import utils.BitPatternGenerators
import utils.ImageGenerator.{GridItem, PlaceTetromino, TextLabel}
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


  def backdoorWritePlayfieldRow(dut: playfield, row: Int, data: Int) = {
    println(s"[INFO] @${simTime()} Backdoor write playfield row[${row}] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')}")
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= true
    dut.io.playfield_backdoor.row #= row
    dut.io.playfield_backdoor.data #= data
  }


  def backdoorWriteWholePlayfield(dut: playfield, content: Seq[Int]) = {
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
    content.zipWithIndex.foreach { case (value, i) =>
      backdoorWritePlayfieldRow(dut, i, value)
    }
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
  }

  def backdoorWriteFlowRegion(dut: playfield, content: Seq[Int], row: Int) = {

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
    for (i <- content.indices) {
      dut.io.flow_backdoor.data(i).randomize()
    }
  }

  def backdoorWriteCheckerRegion(dut: playfield, content: Seq[Int], row: Int) = {

    dut.clockDomain.waitSampling()
    dut.io.checker_backdoor.valid #= false
    dut.clockDomain.waitSampling()
    dut.io.checker_backdoor.valid #= true
    dut.io.checker_backdoor.row #= row
    content.zipWithIndex.foreach { case (data, i) =>
      dut.io.checker_backdoor.data(i) #= data
      println(s"[INFO] @${simTime()} Backdoor write checker regin[${i}] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')}")
    }
    dut.clockDomain.waitSampling()
    dut.io.checker_backdoor.valid #= false
    dut.io.checker_backdoor.row.randomize()
    for (i <- content.indices) {
      dut.io.checker_backdoor.data(i).randomize()
    }
  }


  def backdoorWritePlayfieldWithPattern(dut: playfield, length: Int, width: Int, pattern: BitPatternGenerators.Pattern) = {

    BitPatternGenerators.generateSequence(length, width, pattern).sample match {
      case Some(seq) =>
        backdoorWriteWholePlayfield(dut, seq)
        seq
      case None => simFailure("[ERROR] No seq is created !!!"); Nil
    }

  }

  def backdoorWriteFlowWithPattern(dut: playfield, row: Int, width: Int, pattern: BitPatternGenerators.Pattern) = {

    BitPatternGenerators.generateSequence(4, width, pattern).sample match {
      case Some(seq) =>
        backdoorWriteFlowRegion(dut, seq, row)
        seq
      case None => simFailure("[ERROR] No seq is created !!!"); Nil
    }

  }

  def backdoorWriteCheckerWithPattern(dut: playfield, row: Int, width: Int, pattern: BitPatternGenerators.Pattern, ref: Seq[Int]) = {

    // create Seq[Int] having 4 item which is "width" bit-width
    BitPatternGenerators.generateSequence(n = 4, width, pattern, ref).sample match {
      case Some(seq) =>
        backdoorWriteCheckerRegion(dut, seq, row)
        seq
      case None => simFailure("[ERROR] No seq is created !!!"); Nil
    }

  }





  def readWholePlayfield(dut: playfield) = {
    println(s"[INFO] @${simTime()} Start to front-door read whole playfield .......")
    dut.clockDomain.waitSampling()
    dut.io.read #= true
    dut.clockDomain.waitSampling()
    dut.io.read #= false

  }


  def startCollisonCheck(dut: playfield) = {
    println(s"[INFO] @${simTime()} initiate collision check .......")
    dut.clockDomain.waitSampling()
    dut.io.start_collision_check #= true
    dut.clockDomain.waitSampling()
    dut.io.start_collision_check #= false

  }

  def issuePlacePiece(dut : playfield, pieceType :  SpinalEnumElement[config.TYPE.type]  ) = {
    dut.clockDomain.waitSampling(1)
    dut.io.piece_in.valid #= true
    dut.io.piece_in.payload #= pieceType
    dut.clockDomain.waitSampling()
    dut.io.piece_in.valid #= false
    dut.io.piece_in.payload.randomize()
  }



  /**
   * Execute a sequence of test actions
   */
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
    for ((action, i) <- actions.zipWithIndex) {
      println(f"\t\t\t${i + 1}\t: ${action.p0}%12s\tx\t${action.p1}%12s\t\t\t${action.count}")
    }
    println(s"\n${"=" * 120}")

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
        val expectedData = orOverlay(playfieldData, flowData, row)

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

  /**
   * Execute a sequence of test actions
   */
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
    def orOverlay(a: Seq[Int], b: Seq[Int], row: Int): Int = {

      val region_overlap = a.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << colBlocksNum) - 1))

      val ret = region_overlap.zip(b).map { case (a, b) => (a & b).toInt > 0 }

      region_overlap.foreach { a => println(f"Compared Playield data : 0b${String.format("%10s", Integer.toBinaryString(a)).replace(' ', '0')} ") }
      ret.foldLeft(false)(_ | _) toInt

    }

    var actionIndex = 0

    // Print Test suits Summary
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tTest Group Summary\n")
    println(s"\tChecker Region based on Row : ${row}")
    println(f"\tTest Pattern :\t Playfield  x\t Flow region\t\tCount")
    for ((action, i) <- actions.zipWithIndex) {
      println(f"\t\t\t${i + 1}\t: ${action.p0}%12s\tx\t${action.p1}%12s\t\t\t${action.count}")
    }
    println(s"\n${"=" * 120}")

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

        val ref = playfieldData.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << colBlocksNum) - 1))
        val checkData = backdoorWriteCheckerWithPattern(
          dut,
          row,
          width,
          action.p1,
          ref = ref
        )

        // Modelling readout by OR flow.region and playfield.region
        val expectedData = orOverlay(playfieldData, checkData, row)

        scbd.addExpected(expectedData)

        // Stimulus DUT with test data
        startCollisonCheck(dut)
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


  /**
   * Execute a sequence of test actions
   */
  def executeTestPlaceActions(
                               dut: playfield,
                               scbd: PlayFieldScoreboard,
                               length: Int,
                               width: Int,
                               row: Int,
                               actions: Seq[TestPiecePatternPair],
                               verbose: Boolean
                             ): Unit = {

    assert(
      row >= 0 && row <= (length - 1),
      s"Row options $row is out of the expected range [0, ${length - 1}]."
    )

    val playfieldDrawTasks =  mutable.Queue[GridItem] ()

    /**
     * Overlays sequence `b` onto sequence `a` using a bitwise OR operation.
     *
     * @param a   The base sequence.
     * @param b   The sequence to overlay.
     * @param row The starting index in `a` where the operation begins.
     * @return A new sequence with the result of the OR operation.
     */
    def orOverlay(a: Seq[Int], b: Seq[Int], row: Int): Int = {



      val region_overlap = a.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << colBlocksNum) - 1))

      val ret = region_overlap.zip(b).map { case (a, b) => (a & b).toInt > 0 }

      region_overlap.foreach { a => println(f"Compared Playield data : 0b${String.format("%10s", Integer.toBinaryString(a)).replace(' ', '0')} ") }
      ret.foldLeft(false)(_ | _) toInt

    }

    def reverseLow10Bits(value: Int): Int = {
      var result = 0
      var temp = value & 0x3FF  // Mask to get only lower 10 bits

      for (i <- 0 until 10) {
        result = (result << 1) | (temp & 1)
        temp >>= 1
      }

      result
    }


    var actionIndex = 0

    // Print Test suits Summary
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tTest Group Summary\n")
    println(s"\tChecker Region based on Row : ${row}")
    println(f"\tTest Pattern :\t Playfield  x\t Place item\t\tCount")
    for ((action, i) <- actions.zipWithIndex) {
      println(f"\t\t\t${i + 1}\t: ${action.p0}%12s\tx\t${action.p1}%12s\t\t\t${action.count}")
    }
    println(s"\n${"=" * 120}")

    // transverse to execute test patterns

    val blocSize = 20

    var y_step  = 6 * blocSize

    for (action <- actions) {
      if (verbose) {
        println(s"\n${"=" * 100}\n")
        println(s"\t\tExecuting Test Action ${actionIndex + 1}/${actions.size}")
        println(s"\t\tPurpose\t: ${action.getDescription}")
        println(s"\t\tPattern\t: ${action.p0} x ${action.p1}, Count: ${action.count}")
        println(s"\n${"=" * 100}")
      }

      var x_start = 100
      var y_start = 100

      var pieceIsDraw = false

      for (iteration <- 0 until action.count) {
        if (verbose && action.count > 1) {
          println(s"\t\t Round ${iteration + 1}/${action.count}")
        }
        // Generate Place piece
        val (pieceType, rot  ) = PiecePatternGenerators.generatePiecePattern(action.p1).sample match {
          case Some ( (pieceType, rot  ) ) =>  (pieceType, rot  )
          case None => simFailure("[ERROR] No Piece is created !!!");
        }

        // Generate and write pattern
        val playfieldData = backdoorWritePlayfieldWithPattern(
          dut,
          length,
          width,
          action.p0
        )

        val ref = playfieldData.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << colBlocksNum) - 1))

        issuePlacePiece(dut,  pieceType )
        dut.clockDomain.waitSamplingWhere(dut.io.status.valid.toBoolean) // Wait collision result
        val placePieceData = binaryTypeOffsetTable(pieceType)(0) map ( _ << ( (colBlocksNum / 2 )  - 2 ) )
        placePieceData.zipWithIndex.foreach { case (data, i) =>
          println(s"[INFO] place row[$i] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')} ")
        }
        val expectedData = orOverlay(playfieldData, placePieceData, row)
        scbd.addExpected(expectedData)

        if ( ! pieceIsDraw ) {
          playfieldDrawTasks.enqueue (
            PlaceTetromino(
              x_start = x_start, y_start = y_start,
              sizeInPixel = blocSize,
              width = colBlocksNum,
              allBlocks = placePieceData
            ),
            TextLabel(
              x = x_start - 50 ,
              y = y_start + 50,
              text = pieceType.toString(),
              color = Color.BLACK
            )
          )
          pieceIsDraw = true
          y_start += y_step
        }

        playfieldDrawTasks.enqueue(
          PlaceTetromino(
            x_start =  x_start, y_start =  y_start,
            sizeInPixel = blocSize,
            width = colBlocksNum,
            allBlocks = playfieldData.map(reverseLow10Bits).take(4),
            blockColor = new Color(100,120, 120 )
          ),
          TextLabel(
            x = x_start - 50 ,
            y = y_start + 50,
            text = s"$iteration",
            color = Color.BLACK
          )
        )

        y_start += y_step

        dut.clockDomain.waitSampling(10)

        val allMatch = scbd.compare()

        println(scbd.report())

        if (!allMatch) {
          ImageGenerator.fromGridLayout(totalWidth = 400,  totalHeight = (action.count + 3 ) * ( y_step + 1 ) , playfieldDrawTasks )
            .buildAndSave( PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString + s"/PlaceImg_${action.p0}x${action.p1}.png" )
          simFailure("Scoreboard Reports Error ")
        }
        scbd.clear()
      }

      ImageGenerator.fromGridLayout(totalWidth = 400,  totalHeight = (action.count + 3 ) * ( y_step + 1 )  , playfieldDrawTasks )
        .buildAndSave( PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString + s"/PlaceImg_${action.p0}x${action.p1}.png" )

      playfieldDrawTasks.clear()

      actionIndex += 1
    }



  }

}


class PlayFieldTest extends AnyFunSuite with PlayFieldTestHelper {

  //val compiler: String = "verilator"
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
    dut.io.start_collision_check #= false

  }

  test("usecase 1 - random fill all pixel and flow region ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      /*****************************************
            Custom settings begin
      ******************************************/

      /* 1 is for pattern selection */
      val predefReadTestPattern = List(
        1 -> ReadoutScenarios.basic,
        0 -> ReadoutScenarios.playfieldPatternOnly,
        0 -> ReadoutScenarios.flowPatternOnly,
        0 -> ReadoutScenarios.usecase,
        0 -> ReadoutScenarios.random
      )

      val readTestPatternList = predefReadTestPattern  /* Pattern group selection */
        .collect{ case (1, pattern) => pattern }
        .flatten


      /*****************************************
       Custom settings end
       ******************************************/

      val scbd = new PlayFieldScoreboard(
        name = "Scbd - playfield readout",
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
      for ( flowRegionRow <- 0 until 20 ) {
        println(s"[INFO] flow region row at ${flowRegionRow} !!!")
        executeTestReadoutActions(dut, scbd,
          actions = readTestPatternList,
          length = config.rowBlocksNum, width = config.colBlocksNum,
          row = flowRegionRow,
          verbose = true
        )
        dut.clockDomain.waitSampling(100)

      }

      println("[DEBUG] doSim is exited !!!")

      println("simTime : " + simTime())
      simSuccess()
    }
  }


  test("usecase 2 - Check collision checker functionality with playfield region and checker region ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      /*****************************************
       Custom settings begin
       ******************************************/

      /* 1 is for pattern selection */
      val predefReadTestPattern = List(
        0 -> CollisionCheckScenarios.basic,
        0 -> CollisionCheckScenarios.playfieldPatternOnly,
        0 -> CollisionCheckScenarios.CheckerPatternOnly,
        1 -> CollisionCheckScenarios.noCollison,
        1 -> CollisionCheckScenarios.fixedCollison(1), // 1 bit are overlaps for affected rows.
        1 -> CollisionCheckScenarios.fixedCollison(2), // 2 bits are overlaps for affected rows.
        1 -> CollisionCheckScenarios.usecase,
        1 -> CollisionCheckScenarios.random
      )

      /*****************************************
       Custom settings end
       ******************************************/

      val readTestPatternList = predefReadTestPattern  /* Pattern group selection */
        .collect{ case (1, pattern) => pattern }
        .flatten

      val scbd = new PlayFieldScoreboard(
        name = "Scbd - Collision Checker",
        verbose = true
      )

      // Global Clocking settings
      dut.clockDomain.forkStimulus(10)
      SimTimeout(1 ms ) // adjust timeout as needed
      dut.clockDomain.waitSampling(20)

      // Initialize DUT
      initDUT(dut)

      // Prepare Monitor
      FlowMonitor(dut.io.status, dut.clockDomain) { payload =>
        scbd.addActual( payload.toBoolean.toInt, s"@${simTime()}" )
      }

      // Body
      //for ( flowRegionRow <- 0 until config.rowBlocksNum ) {
      for ( checkerRegionRow <- 16 until 20 ) {
        println(s"[INFO] checker region row at ${checkerRegionRow} !!!")
        executeTestCollisionCheckerActions(dut, scbd,
          actions = readTestPatternList,
          length = config.rowBlocksNum,
          width = config.colBlocksNum,
          row = checkerRegionRow,
          verbose = true
        )
        dut.clockDomain.waitSampling(100)

      }

      println("[DEBUG] doSim is exited !!!")

      println("simTime : " + simTime())
      simSuccess()
    }
  }

  test("usecase 3 - Check place pieces ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      val predefPlaceTestPattern = List(
        0 -> PlaceScenarios.basic( BitPatternGenerators.AllZeros),
        0 -> PlaceScenarios.basic( BitPatternGenerators.AllOnes),
        1 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(1),  count = 100 ),
        1 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(2),  count = 50 ),
        1 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(3),  count = 50 ),
        1 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(4),  count = 50 ),
      )

      val PlaceTestPatternList = predefPlaceTestPattern  /* Pattern group selection */
        .collect{ case (1, pattern) => pattern }
        .flatten

      val scbd = new PlayFieldScoreboard(
        name = "Scbd - Place Checker",
        verbose = true
      )


      // Global Clocking settings
      dut.clockDomain.forkStimulus(10)
      SimTimeout(1 ms ) // adjust timeout as needed
      dut.clockDomain.waitSampling(2)

      // Initialize DUT
      initDUT(dut)

      // Prepare Monitor
      FlowMonitor(dut.io.status, dut.clockDomain) { payload =>
        scbd.addActual( payload.toBoolean.toInt, s"@${simTime()}" )
      }


      val checkerRegionRow = 0
      executeTestPlaceActions(dut, scbd,
        actions = PlaceTestPatternList,
        length = config.rowBlocksNum,
        width = config.colBlocksNum,
        row = checkerRegionRow,
        verbose = true
      )

      println("[DEBUG] doSim is exited !!!")
      println("simTime : " + simTime())
      simSuccess()

    }
  }
}




