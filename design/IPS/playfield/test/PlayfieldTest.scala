package IPS.playfield

import IPS.playfield.executors._
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

import scala.util.control.Breaks._
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

class PlayFieldTest extends AnyFunSuite
  with PlayfieldTestBase
  with PlayfieldBackdoorAPI
  with ReadoutTestExecutor
  with CollisionTestExecutor
  with PlaceTestExecutor
  with MotionTestExecutor {

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

  /** Helper method for common DUT setup and initialization logic. */
  private def commonSetup(dut: playfield): Unit = {
    // Global Clocking settings
    dut.clockDomain.forkStimulus(10)
    SimTimeout(10 us ) // adjust timeout as needed
    dut.clockDomain.waitSampling(20)
    initDUT(dut)
  }

  private def runSimTest( testPattern :   List[(Int, TestMotionPatternGroup)]  ): Unit = {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      val scbd = new PlayFieldScoreboard(
        name = "Scbd - playfield readout",
        verbose = true
      )

      commonSetup(dut)

      val PlaceTestPatternList = testPattern  /* Pattern group selection */
        .collect{ case (1, pattern) => pattern }

      FlowMonitor(dut.io.row_val, dut.clockDomain) { payload =>
        scbd.addActual( payload.toInt, s"@${simTime()}" )
      }

      executeTestMotionActions(dut, scbd,
        actions = PlaceTestPatternList,
        length = config.rowBlocksNum,
        width = config.colBlocksNum,
        verbose = true
      )

      dut.clockDomain.waitSampling(100)
      println("[DEBUG] doSim is exited !!!")
      println("simTime : " + simTime())
      simSuccess()
    }
  }


  test("usecase 1 - random fill all pixel and flow region via backdoor") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      /*****************************************
            Custom settings begin
      ******************************************/

      /* 1 is for pattern selection */
      val predefReadTestPattern = List(
        0 -> ReadoutScenarios.basic,
        1 -> ReadoutScenarios.playfieldPatternOnly,
        1 -> ReadoutScenarios.flowPatternOnly,
        1 -> ReadoutScenarios.usecase,
        1 -> ReadoutScenarios.random
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
      val rowLow = ( 0 to 8)
      val rowMed = ( 9 to 15)
      val rowHigh = ( 16 to 19 )

      for ( flowRegionRow <- rowLow ++ rowHigh ) {
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

  test("usecase 2 - Check collision checker functionality with playfield region and checker region via backdoor") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      /*****************************************
       Custom settings begin
       ******************************************/

      /* 1 is for pattern selection */
      val predefReadTestPattern = List(
        1 -> CollisionCheckScenarios.basic,
        1 -> CollisionCheckScenarios.playfieldPatternOnly,
        1 -> CollisionCheckScenarios.CheckerPatternOnly,
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
      val rowLow = ( 0 to 8)
      val rowMed = ( 9 to 15)
      val rowHigh = ( 16 to 19 )

      for ( checkerRegionRow <- rowLow ++ rowHigh ) {
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

  test("usecase 3 - Check place pieces via interface ( front-door ) . Images are created . ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      val predefPlaceTestPattern = List(
        1 -> PlaceScenarios.basic( BitPatternGenerators.AllZeros),
        1 -> PlaceScenarios.basic( BitPatternGenerators.AllOnes),
        0 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(1),  count = 100 ),
        1 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(2),  count = 50 ),
        0 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(3),  count = 50 ),
        0 -> PlaceScenarios.basic( BitPatternGenerators.FixedOnes(4),  count = 50 ),
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

  test("usecase 4 - Check Place -> Collision Check -> left/right/down -> bottom  via interface and Game over") {

      val predefMotionsTestPattern = List(
        1 -> MotionScenarios.uc1( PiecePatternGenerators.I(0) ) ,  /* New Game */
        1 -> MotionScenarios.uc1( PiecePatternGenerators.J(0), playfieldHold = true  ) ,
        1 -> MotionScenarios.uc2( PiecePatternGenerators.L(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc3( PiecePatternGenerators.O(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc4( PiecePatternGenerators.S(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc5( PiecePatternGenerators.T(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc6( PiecePatternGenerators.Z(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc5( PiecePatternGenerators.L(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc5( PiecePatternGenerators.T(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc5( PiecePatternGenerators.J(0), playfieldHold = true ) ,
        1 -> MotionScenarios.uc5( PiecePatternGenerators.S(0), playfieldHold = true ) ,
        1 -> MotionScenarios.ucs1( PiecePatternGenerators.I(0) ) ,
        1 -> MotionScenarios.ucs2( PiecePatternGenerators.J(0), playfieldHold = true  ),
        1 -> MotionScenarios.ucs3( PiecePatternGenerators.L(0), playfieldHold = true  ),
        1 -> MotionScenarios.ucs3( PiecePatternGenerators.O(0), playfieldHold = true  )
      )

      runSimTest(predefMotionsTestPattern)

  }

  test("usecase 5 - Test single row clean ") {

    val predefMotionsTestPattern = List(
      1 -> MotionScenarios.ucs4( PiecePatternGenerators.I(0) ) ,  /* New Game */
      1 -> MotionScenarios.ucs5( PiecePatternGenerators.J(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs6( PiecePatternGenerators.L(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs7( PiecePatternGenerators.O(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs8( PiecePatternGenerators.S(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs9( PiecePatternGenerators.T(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs10( PiecePatternGenerators.J(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs10( PiecePatternGenerators.S(0), playfieldHold = true  )
    )

    runSimTest(predefMotionsTestPattern)

  }

  test("usecase 6 - Test 2 rows clean ") {

    val predefMotionsTestPattern = List(
      1 -> MotionScenarios.ucs20( PiecePatternGenerators.O(0), left_step=5 ) ,  /* New Game */
      1 -> MotionScenarios.ucs20( PiecePatternGenerators.O(0), left_step=2, playfieldHold = true  ),
      1 -> MotionScenarios.ucs20( PiecePatternGenerators.O(0), left_step=0, playfieldHold = true  ),
      1 -> MotionScenarios.ucs20( PiecePatternGenerators.O(0), left_step= -2, playfieldHold = true  ),
      1 -> MotionScenarios.ucs20( PiecePatternGenerators.O(0), left_step= -4, playfieldHold = true  ),
      1 -> MotionScenarios.ucs20( PiecePatternGenerators.O(0), left_step= 0, playfieldHold = true  ),
    )

    runSimTest(predefMotionsTestPattern)

  }

  test("usecase 7 - Test 3 rows clean ") {

    val predefMotionsTestPattern = List(
      1 -> MotionScenarios.ucs31( PiecePatternGenerators.I(0)  ),
      1 -> MotionScenarios.ucs32( PiecePatternGenerators.I(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs32( PiecePatternGenerators.I(0), playfieldHold = true  ),
    )

    runSimTest(predefMotionsTestPattern)

  }


  test("usecase 8 - Test 4 rows clean ") {

    val predefMotionsTestPattern = List(
      1 -> MotionScenarios.ucs41( PiecePatternGenerators.I(0)  ),
      1 -> MotionScenarios.ucs42( PiecePatternGenerators.I(0), playfieldHold = true  ),
      1 -> MotionScenarios.ucs42( PiecePatternGenerators.I(0), playfieldHold = true  ),
    )

    runSimTest(predefMotionsTestPattern)

  }

}




