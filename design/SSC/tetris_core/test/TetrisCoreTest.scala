package SSC.tetris_core

import spinal.core._
import config.runSimConfig
import spinal.core.sim._
import org.scalatest.funsuite.AnyFunSuite
import utils._
import utils.TestPatterns._
import spinal.lib.sim.FlowMonitor

trait TetrisCoreTestBase {

  def initDUT(dut: tetris_core): Unit = {
    dut.coreClockDomain.waitSampling()
    dut.io.game_start #= false
    dut.io.move_left #= false
    dut.io.move_right #= false
    dut.io.move_down #= false
    dut.io.rotate #= false
    dut.io.drop #= false
    dut.coreClockDomain.waitSampling()
  }


  /** Helper method for common DUT setup and initialization logic. */
  def commonSetup(dut: tetris_core, timeoutByUs: Int = 10): Unit = {
    // Global Clocking settings
    dut.coreClockDomain.forkStimulus(4 ns)
    dut.vgaClockDomain.forkStimulus(10 ns)

    SimTimeout(timeoutByUs us) // adjust timeout as needed
    dut.coreClockDomain.waitSampling(20)
    initDUT(dut)

  }


  def generateFrameImages(
                           width: Int,
                           height: Int,
                           obsFrames: VgaFrame,
                           testClass: Class[_],
                           middlePath: String = "design/SSC",
                         ) {


    for ((index, pixels) <- obsFrames.getAllFrames) {
      ImageGenerator.fromPixelData(width, height, pixels)
        .buildAndSave(
          PathUtils.getRtlOutputPath(
            testClass,
            middlePath = middlePath,
            targetName = s"sim/img").toString
            +
            s"/frame_${index}.png"
        )
    }

  }
}

class TetrisCoreTest extends AnyFunSuite
  with TetrisCoreTestBase
  with MotionTestExecutor {

  val rowNum : Int = 23   // include bottom wall
  val colNum :Int = 12    // include left and right wall
  val rowBlocksNum = rowNum - 1   // working field for Tetromino
  val colBlocksNum = colNum - 2   // working field for Tetromino
  val lastCol = colNum - 1   /* 0 and 11 are col index of left and right wall */
  val bottomRow = rowNum - 1

  val config = TetrisCoreConfig()




  val xilinxPath = System.getenv("XILINX")
  println("[DEBUG] xilinxPath = " + xilinxPath)

  // ***************************************
  //  CUSTOM CODE END
  // ***************************************

//  val compiler : String = "verilator"
  val compiler : String = "vcs"


  val memory_model : String  = compiler match  {
    case "verilator" => "RAMB16_S9_VERILATOR.v"
    case "vcs" => "RAMB16_S9.v"
  }

  val runFolder : String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SSC", targetName = "sim").toString
  lazy val compiled : SimCompiled[tetris_core] = runSimConfig(runFolder, compiler)
    .addRtl(s"${xilinxPath}/glbl.v")
    .addRtl(s"${xilinxPath}/unisims/${memory_model}")
    .compile {
      val c = new tetris_core(config, sim = true )  /* Test = true is ONLY for standalone DUT test */
      c.game_display_inst.vga.pixel_debug.simPublic()
      c.game_logic_inst.controller_inst.io.gen_piece_en.simPublic()
      c
    }

  protected def runSimTest( testPattern :   List[(Int, Seq[MotionPatternGenerators.Pattern])]  ): Unit = {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      val obsFrames = new VgaFrame( width = config.xWidth, height = config.yWidth )

      commonSetup(dut, timeoutByUs = 120000)

      val PlaceTestPatternList = testPattern  /* Pattern group selection */
        .collect{ case (1, pattern) => pattern }

      FlowMonitor(dut.game_display_inst.vga.pixel_debug, dut.vgaClockDomain) { payload =>
        obsFrames.addPixel(payload.r.toInt,  payload.g.toInt,  payload.b.toInt )
      }

      executeTestMotionActions(
        dut,
        obsFrames,
        actions = PlaceTestPatternList,
        verbose = true
      )

      generateFrameImages( width = config.xWidth, height = config.yWidth, obsFrames,   testClass = getClass  )

      dut.clockDomain.waitSampling(100)
      println("[DEBUG] doSim is exited !!!")
      println("simTime : " + simTime())
      simSuccess()
    }
  }


  test ("usecase <1>  " +
    " - Test fsm from game start to game stop " +
    " - Test all external inputs including left/right/rotate/down/drop" +
    " - Test game restart after one game failed. ") {

    val predefMotionsTestPattern = List(
      1 -> MotionScenarios.m0(),
      0 -> MotionScenarios.m1(),
      0 -> MotionScenarios.m2(),
      0 -> MotionScenarios.m3(),
      0 -> MotionScenarios.m4(),
      0 -> MotionScenarios.m5(),
      0 -> MotionScenarios.m6(),
      0 -> MotionScenarios.ms1(),
      0 -> MotionScenarios.ms2(),
      0 -> MotionScenarios.m6(),
      0 -> MotionScenarios.m5(),
      0 -> MotionScenarios.m4(),
      0 -> MotionScenarios.m3(),
      0 -> MotionScenarios.m2(),
      0 -> MotionScenarios.m1(),
      0 -> MotionScenarios.m6(),
      0 -> MotionScenarios.m5(),
      0 -> MotionScenarios.m4(),
    )

    runSimTest(predefMotionsTestPattern)
  }

  test ("usecase <2>  " +
    " - Test row removal with score updated " ) {

    val predefMotionsTestPattern = List(
      1 -> MotionScenarios.rowRemovePt1(),
      1 -> MotionScenarios.rowRemovePt2(),
      1 -> MotionScenarios.rowRemovePt3(),
      1 -> MotionScenarios.rowRemovePt4(),
      1 -> MotionScenarios.rowRemovePt5(),
      1 -> MotionScenarios.rowRemovePt6(),
      1 -> MotionScenarios.rowRemovePt7(),
      1 -> MotionScenarios.rowRemovePt8(),
      1 -> MotionScenarios.rowRemovePt9(),
      1 -> MotionScenarios.rowRemovePt10(),
      1 -> MotionScenarios.rowRemovePt11(),
      1 -> MotionScenarios.rowRemovePt12(),
      1 -> MotionScenarios.m5(),
    )

    runSimTest(predefMotionsTestPattern)
  }

}

class TetrisCoreTest2 extends TetrisCoreTest {
//    override val compiler : String = "verilator"
////  override val compiler : String = "vcs"

  override val config = TetrisCoreConfig( offset_x = 32  )

  test ("usecase <3>  " +
    " - Test fsm from game start to game stop " +
    " - Test all external inputs including left/right/rotate/down/drop" +
    " - Test game restart after one game failed. ") {

    val DoublePieceMotionsTestPattern = List(
      1 -> MotionScenarios.m5(),
      1 -> MotionScenarios.rowRemovePt12(),
      0 -> MotionScenarios.rowRemovePt12()
    )

    runSimTest(DoublePieceMotionsTestPattern)
  }

}


