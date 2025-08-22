package SOC.tetris_top

import spinal.core._
import spinal.core.sim._
import config.runSimConfig
import org.scalatest.funsuite.AnyFunSuite
import utils.PathUtils
import config._
import IPS.play_field._
import SOC.tetris_top._
import SSC.tetris_core.TetrisCoreConfig
import spinal.lib.sim.FlowMonitor

import SOC.tetris_top.model._

import scala.collection.mutable.ArrayBuffer
import scala.swing._
import scala.swing.event._
import java.awt.{BasicStroke, Color, Font, Graphics2D}
import java.awt.image.BufferedImage
import java.io.File
import java.util.concurrent.CountDownLatch
import javax.imageio.ImageIO
import javax.swing.WindowConstants
import scala.collection.mutable


class TetrisTopTest extends AnyFunSuite {
  // ***************************************
  //  CUSTOM CODE END
  // ***************************************
  //val compiler: String = "verilator"
  val compiler: String = "vcs"
  val runFolder: String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SOC", targetName = "sim").toString
  val verilogFile: String = PathUtils.getVerilogFilePath(
    middlePath = "design/SOC",
    ipFolderName = "tetris_top/rtl",
    fileName = "tetris_top_bb.v").toString

  val workFolder = runFolder + "/" + compiler

  val memory_model: String = compiler match {
    case "verilator" => "RAMB16_S9_VERILATOR.v"
    case "vcs" => "RAMB16_S9.v"
  }

  val xilinxPath = System.getenv("XILINX")
  println("[DEBUG] xilinxPath = " + xilinxPath)

  println(s"Max Heap: ${Runtime.getRuntime.maxMemory() / 1024 / 1024} MB")
  println(s"Available Processors: ${Runtime.getRuntime.availableProcessors()}")
  val threadMX = java.lang.management.ManagementFactory.getThreadMXBean
  println(s"Thread Count: ${threadMX.getThreadCount}")

  lazy val compiled: SimCompiled[tetris_top] = runSimConfig(runFolder, compiler)
    .addRtl(s"${xilinxPath}/glbl.v")
    .addRtl(s"${xilinxPath}/unisims/${memory_model}")
    //.addRtl(s"${verilogFile}")
    .withTimeScale(1 ns)
    .withTimePrecision(10 ps)
    .compile {
      val c = new tetris_top(TetrisCoreConfig(offset_x = 32))
      c.tetris_core_inst.game_display_inst.io.sof.simPublic()
      c
    }


  //
  //  def init(dut: tetris_top): Unit = {
  //    dut.coreClockDomain.waitSampling()
  //    dut.io.game_start #= false
  //    dut.io.move_left #= false
  //    dut.io.move_right #= false
  //    dut.io.move_down #= false
  //    dut.io.rotate #= false
  //    dut.coreClockDomain.waitSampling()
  //  }


  test("usecase - test internal keyboard interface works with external keyBoard via PS2 protocol ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>


      var id = 0

      var simulationRunning = true

      val coreClocking = ClockDomain(dut.io.core_clk, dut.io.core_rst)
      val vgaClocking = ClockDomain(dut.io.vga_clk, dut.io.vga_rst)


      coreClocking.forkStimulus(50 MHz)
      vgaClocking.forkStimulus(25 MHz)

      SimTimeout(100 ms) // adjust timeout as needed

      coreClocking.waitSampling(100)

      val ps2HostIf = PS2Interface(clk = dut.io.ps2_clk, data = dut.io.ps2_data)
      // In your SpinalHDL testbench
      val kdSlaveVip = new PS2KbTestEnvironment(ps2HostIf, dut.keyClockDomain)


      kdSlaveVip.run()

      kdSlaveVip.sendKeys("ws")


      println("simTime : " + simTime() + "[Main] Wait for some time")

      vgaClocking.waitSampling(10000)
      vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 2nd frame has been started and then stop sim now !")
      vgaClocking.waitSampling(10000)
      vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 3rd frame has been started and then stop sim now !")
      println("simTime : " + simTime())
      simSuccess()

    }


  }
}