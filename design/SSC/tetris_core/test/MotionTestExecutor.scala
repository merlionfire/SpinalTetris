package SSC.tetris_core

import IPS.playfield.visualizers.MotionVisualizer
import SSC.tetris_core.src.tetris_core
import spinal.core.sim._
import spinal.core._
import utils.MotionPatternGenerators
import utils.MotionPatternGenerators._
import utils.ImageGenerator
import utils.ImageGenerator._

import scala.collection.mutable

trait MotionTestExecutorBase {

  def printMotionActionHeader(
                               action: Seq[Pattern],
                               roundIndex: Int,
                             ): Unit = {
    println(s"\n${"=" * 100}\n")
    println(s"\t\tExecuting Round ${roundIndex + 1} : ${getMotionsDescription(action)}")
    println(s"\n${"=" * 100}")
  }

  def printMotionTestSummary(actionsByRound: Seq[Seq[Pattern]]): Unit = {
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tMotion Test Group Summary\n")
    println(f"\t\t\tMotions")

    for ( ( pat, i )  <- actionsByRound.zipWithIndex ) {
      println(f"\t${i + 1}:\t${getMotionsDescription(pat)} ")
    }
    println(s"\n${"=" * 120}")
  }
}


trait MotionTestExecutor extends MotionTestExecutorBase  {


  def executeTestMotionActions(
                                dut: tetris_core,
                                obs : VgaFrame,
                                actions: Seq[Seq[MotionPatternGenerators.Pattern]],
                                verbose: Boolean
                              ): Unit = {


    printMotionTestSummary(actions)

    dut.coreClockDomain.waitSampling(40)

    startGame(dut)
    dut.coreClockDomain.waitSamplingWhere( dut.io.screen_is_ready.toBoolean )


//    dut.coreClockDomain.waitSamplingWhere(condAnd = dut.io.ctrl_allowed.toBoolean)


    var round = 0

    for ((action, actionIndex) <- actions.zipWithIndex) {
      /* One round means one game round */

      if (verbose) {
        printMotionActionHeader(action, actionIndex)
      }

      val motionNames = mutable.Queue[String]()
      val motionSequence = expandMotionPatterns(action)

      dut.coreClockDomain.waitSamplingWhere(condAnd = dut.game_logic_inst.controller_inst.io.gen_piece_en.toBoolean)
      dut.coreClockDomain.waitSampling(20)

      motionSequence.foreach { motion =>
        issueMotion(dut, motion)
        motionNames.enqueue(motion)

        dut.coreClockDomain.waitSamplingWhere(condAnd = dut.io.ctrl_allowed.toBoolean)
      }

      dut.coreClockDomain.waitSamplingWhere(condAnd = dut.io.ctrl_allowed.toBoolean)
      dut.io.vga_rst #= false

      println(s"[DEBUG]${simTime()} Checking if dut.io.controller_in_end is asserted ...  ")

    }

  }



  def issueMotion(dut: tetris_core, motion: String): Unit  = {
    //    dut.clockDomain.waitSamplingWhere(dut.io.motion_is_allowed.toBoolean)
//    dut.coreClockDomain.waitSampling()
    dut.coreClockDomain.waitSamplingWhere( dut.io.vga_sof.toBoolean )
    println(s"[INFO] @${simTime()} Issue [${motion}] to DUT via interface")
    motion match {
      case "LF" => dut.io.move_left #= true
      case "RG" => dut.io.move_right #= true
      case "RT" => dut.io.rotate #= true
      case "DN" => dut.io.move_down #= true
      case "DP" => dut.io.drop #= true
    }

//    dut.coreClockDomain.waitSampling(2000)
    sleep(8 us)
    dut.coreClockDomain.waitSampling()
    dut.io.move_left #= false
    dut.io.move_right #= false
    dut.io.rotate #= false
    dut.io.move_down #= false
    dut.io.drop #= false

  }

  def startGame(dut: tetris_core ) : Unit = {
    dut.io.game_start #= true
    dut.coreClockDomain.waitSampling(10)
    //dut.io.game_start #= false
  }

}