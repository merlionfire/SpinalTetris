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
  val compiler: String = "verilator"
  //val compiler: String = "vcs"
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

  val config = TetrisCoreConfig(offset_x = 32)
  lazy val compiled: SimCompiled[tetris_top] = runSimConfig(runFolder, compiler)
    .addRtl(s"${xilinxPath}/glbl.v")
    .addRtl(s"${xilinxPath}/unisims/${memory_model}")
    .withTimeScale(1 ns)
    .withTimePrecision(100 ps)
    .compile {
      val c = new tetris_top(config)
      c.tetris_core_inst.game_display_inst.io.sof.simPublic()
      c.tetris_core_inst.game_display_inst.vga.pixel_debug.simPublic()
      c
    }

  var obs_vga = mutable.Queue[(Int, Int, Int)]()

  def createScreenImg() = {
    def vga4BitTo8Bit(color: (Int, Int, Int)): Int = {
      // Scale the 4-bit value (0-15) to the 8-bit range (0-255)
      // Multiplying by 17 (255 / 15 is approximately 17) often works well for this.
      // (value & 0xF) * 17
      // Alternatively, you can also try bit shifting and replication:
      // (value & 0xF) | ((value & 0xF) << 4)
      val r = color._1 | color._1 << 4
      val g = color._2 | color._2 << 4
      val color8bit = List(color._1, color._2, color._3).map(x => x | (x << 4))
      color8bit(0) << 16 | color8bit(1) << 8 | color8bit(2)

    }

    val width = config.xWidth
    val height = config.yWidth

    // Define the output directory
    val outputDirName = "screenShotsnap"
    val outputDir = new File(s"${workFolder}/${outputDirName}")

    // Create the directory if it doesn't exist
    if (!outputDir.exists()) {
      if (outputDir.mkdir()) {
        println(s"Created directory: ${outputDir.getAbsolutePath}")
      } else {
        // Handle the case where directory creation fails (e.g., permissions)
        println(s"[Error] Failed to create directory: ${outputDir.getAbsolutePath}. Images might not be saved.")
      }
    }

    var idx = 0
    while (obs_vga.length >= (640 * 480)) {
      println(s"Start to generate screen image : ${idx}")
      val img = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)

      for (y <- 0 until height) {
        for (x <- 0 until width) {
          val rgb = obs_vga.dequeue()
          img.setRGB(x, y, vga4BitTo8Bit(rgb))
        }
      }

      val g = img.createGraphics()
      val image_file_name: String = s"screen_640x480_${idx}.png"
      g.dispose()
      val outputFile = new File(outputDir, image_file_name)
      ImageIO.write(img, "png", outputFile)
      println(s"Image saved to ${outputFile.getAbsolutePath}")
      idx = idx + 1

    }

    if (obs_vga.nonEmpty) {
      println(f"[Error] obs_mem is NOT empty and number of the remaining items : ${obs_vga.size}")
    }

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

      SimTimeout(500 ms) // adjust timeout as needed

      coreClocking.waitSampling(50)

      /** *******************************************************
       * - It is for increasing id once a new block is created.
       * ********************************************************* */

      FlowMonitor(dut.tetris_core_inst.game_display_inst.vga.pixel_debug, vgaClocking) { payload =>

        obs_vga.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      val ps2HostIf = PS2Interface(clk = dut.io.ps2_clk, data = dut.io.ps2_data)
      // In your SpinalHDL testbench

      val kdSlaveVip = new PS2KbTestEnvironment(ps2HostIf, dut.keyClockDomain)

      kdSlaveVip.run()

      vgaClocking.waitSampling(50)

      kdSlaveVip.sendKeys("w")


      println("simTime : " + simTime() + "[Main] Wait for some time")


      //List("s","a", "d", "d", "d", "a", "s", "a", " ", "a").zipWithIndex.foreach { case ( action, i ) =>
      List("s", "a", "d", " ", "d", "a", "a", " ").zipWithIndex.foreach { case (action, i) =>
        //vgaClocking.waitSampling(6000)

        vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)
        println(f"[DEBUG] @${simTime()} The ${i + 2} frame has been started and then stop sim now !")

        println("simTime : " + simTime() + s"[Main] Send ${action} to DUT ...  ")
        kdSlaveVip.sendKeys(action, 8000) // key is hold 10ms
        println("simTime : " + simTime() + s"[Main] ${action} has been sent !!!  ")
        sleep(7000 us)
      }


      println("[DEBUG] Simulation logic finished. Shutting down monitor threads...")
      simulationRunning = false
      vgaClocking.waitSampling(50) // Give threads time to exit.
      println("[DEBUG] doSim is exited !!!")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      createScreenImg()

      println("simTime : " + simTime())
      simSuccess()

    }


  }

  test("usecase - Test on-board keys as input controller ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      var id = 0

      var simulationRunning = true

      val coreClocking = ClockDomain(dut.io.core_clk, dut.io.core_rst)
      val vgaClocking = ClockDomain(dut.io.vga_clk, dut.io.vga_rst)


      coreClocking.forkStimulus(50 MHz)
      vgaClocking.forkStimulus(25 MHz)

      SimTimeout(500 ms) // adjust timeout as needed

      dut.io.btns.btn_north #= false
      dut.io.btns.btn_east #= false
      dut.io.btns.btn_south #= false
      dut.io.btns.btn_west #= false
      dut.io.btns.rot_push #= false
      dut.io.btns.rot_pop #= false
      dut.io.btns.rot_left #= false
      dut.io.btns.rot_right #= false

      coreClocking.waitSampling(50)

      /** *******************************************************
       * - It is for increasing id once a new block is created.
       * ********************************************************* */

      FlowMonitor(dut.tetris_core_inst.game_display_inst.vga.pixel_debug, vgaClocking) { payload =>

        obs_vga.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)
      coreClocking.waitSampling()
      dut.io.btns.btn_west #= true
      coreClocking.waitSampling(10)

      vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)
      dut.io.btns.rot_left #= true
      vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)
      for (_ <- 0 to 5) {
        dut.io.btns.btn_south #= true
        vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)
        dut.io.btns.btn_south #= false
        coreClocking.waitSampling(10)
      }

      vgaClocking.waitSamplingWhere(dut.tetris_core_inst.game_display_inst.io.sof.toBoolean)

      println("[DEBUG] Simulation logic finished. Shutting down monitor threads...")
      simulationRunning = false
      vgaClocking.waitSampling(50) // Give threads time to exit.
      println("[DEBUG] doSim is exited !!!")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      createScreenImg()

      println("simTime : " + simTime())
      simSuccess()
    }

  }
}