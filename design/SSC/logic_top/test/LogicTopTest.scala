package SSC.logic_top

import spinal.core._
import config.runSimConfig
import spinal.core.sim._
import org.scalatest.funsuite.AnyFunSuite
import utils._
import utils.TestPatterns._
import utils.BitPatternGenerators
import IPS.play_field._
import IPS.playfield.playfield
import spinal.lib.sim.FlowMonitor

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import java.awt.{BasicStroke, Color, Font, Graphics2D}
import java.awt.image.BufferedImage
import java.io.File
import java.util.concurrent.CountDownLatch
import javax.imageio.ImageIO
import javax.swing.WindowConstants
import scala.swing._
import scala.swing.event._

trait LogicTopTestBase {

  def initDUT(dut: logic_top): Unit = {
    dut.clockDomain.waitSampling()
    dut.io.game_start #= false
    dut.io.move_left #= false
    dut.io.move_right #= false
    dut.io.move_down #= false
    dut.io.rotate #= false
    dut.io.drop #= false
    dut.io.screen_is_ready #= true
    dut.io.vga_sof #= true  // start refresh immediately
    dut.io.draw_field_done #= true // Simulate refresh done
    dut.clockDomain.waitSampling()
  }

  def startGame(dut: logic_top ) : Unit = {
    dut.io.game_start #= true
    dut.clockDomain.waitSampling()
    dut.io.game_start #= false
  }


  /** Helper method for common DUT setup and initialization logic. */
  def commonSetup(dut: logic_top, timeoutByUs : Int = 10 ): Unit = {
    // Global Clocking settings
    dut.clockDomain.forkStimulus(10)
    SimTimeout( timeoutByUs us ) // adjust timeout as needed
    dut.clockDomain.waitSampling(20)
    initDUT(dut)
  }


//  def waitForMainState(dut: logic_top, state : String ) = {
//    println(f"@${simTime()} [DEBUG] Wait FSM state  : <$state> ...... ")
//    dut.clockDomain.waitSamplingWhere(dut.main_fsm_debug.toInt == stateMap(state)  )
//    println(f"@${simTime()} [DEBUG] State <$state> is active now ! ")
//    dut.clockDomain.waitSampling(1)
//  }
//
//  def waitForSubState( dut: logic_top, state : String ) = {
//    println(f"@${simTime()} [DEBUG] Wait FSM state  : <$state> ...... ")
//    dut.clockDomain.waitSamplingWhere(dut.playfield_fsm_debug.toInt == stateMap(state)  )
//    println(f"@${simTime()} [DEBUG] State <$state> is active now ! ")
//    dut.clockDomain.waitSampling(1)
//  }

}



class LogicTopTest extends AnyFunSuite
  with LogicTopTestBase
  with MotionTestExecutor {

  val rowNum : Int = 23   // include bottom wall
  val colNum :Int = 12    // include left and right wall
  val rowBlocksNum = rowNum - 1   // working field for Tetromino
  val colBlocksNum = colNum - 2   // working field for Tetromino
  val lastCol = colNum - 1   /* 0 and 11 are col index of left and right wall */
  val bottomRow = rowNum - 1

  val config = LogicTopConfig( rowNum, colNum , 1 )

  // ***************************************
  //  CUSTOM CODE END
  // ***************************************

  //val compiler : String = "verilator"
  val compiler : String = "vcs"

  val runFolder : String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SSC", targetName = "sim").toString
  lazy val compiled : SimCompiled[logic_top] = runSimConfig(runFolder, compiler)
    .compile {
      val c = new logic_top(config, sim= true)  /* Test = true is ONLY for standalone DUT test */
      c
    }


  private def runSimTest( testPattern :   List[(Int, Seq[MotionPatternGenerators.Pattern])]  ): Unit = {
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

      startGame(dut)

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


  test ("usecase <0> - transverse all states of FSM ") {

    val predefMotionsTestPattern = List(
      1 -> MotionScenarios.m1(),
      1 -> MotionScenarios.m2(),
      1 -> MotionScenarios.m3()

    )

    runSimTest(predefMotionsTestPattern)
  }

}
