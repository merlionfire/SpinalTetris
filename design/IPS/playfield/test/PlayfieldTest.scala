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


  test("usecase 1 - random fill all pixel and flow region via backdoor") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      /*****************************************
            Custom settings begin
      ******************************************/

      /* 1 is for pattern selection */
      val predefReadTestPattern = List(
        0 -> ReadoutScenarios.basic,
        0 -> ReadoutScenarios.playfieldPatternOnly,
        0 -> ReadoutScenarios.flowPatternOnly,
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

  test("usecase 2 - Check collision checker functionality with playfield region and checker region via backdoor") {
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

  test("usecase 3 - Check place pieces via interface ( front-door ) ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      val predefPlaceTestPattern = List(
        0 -> PlaceScenarios.basic( BitPatternGenerators.AllZeros),
        0 -> PlaceScenarios.basic( BitPatternGenerators.AllOnes),
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
    compiled.doSimUntilVoid(seed = 42) { dut =>

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


      val PlaceTestPatternList = predefMotionsTestPattern  /* Pattern group selection */
        .collect{ case (1, pattern) => pattern }

      /*****************************************
       Custom settings end
       ******************************************/

      val scbd = new PlayFieldScoreboard(
        name = "Scbd - playfield readout",
        verbose = true
      )

      // Global Clocking settings
      dut.clockDomain.forkStimulus(10)
      SimTimeout(10 us ) // adjust timeout as needed
      dut.clockDomain.waitSampling(20)

      initDUT(dut)

      // Prepare Monitor
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
}




