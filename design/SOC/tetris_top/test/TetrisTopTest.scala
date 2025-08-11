package SOC.tetris_top.test

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
  val compiler : String = "verilator"
  //val compiler : String = "vcs"
  val runFolder : String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SOC", targetName = "sim").toString

  val workFolder = runFolder+"/"+compiler

  val memory_model : String  = compiler match  {
    case "verilator" => "RAMB16_S9_VERILATOR.v"
    case "vcs" => "RAMB16_S9.v"
  }

  val xilinxPath = System.getenv("XILINX")
  println("[DEBUG] xilinxPath = " + xilinxPath)

  lazy val compiled : SimCompiled[tetris_top] = runSimConfig(runFolder, compiler)
    .addRtl(s"${xilinxPath}/glbl.v")
    .addRtl(s"${xilinxPath}/unisims/${memory_model}")
    .withTimeScale( 1 ns )
    .withTimePrecision( 10 ps)
    .compile {
      val c = new tetris_top( TetrisCoreConfig(offset_x = 32 ) )
      c
    }
}
