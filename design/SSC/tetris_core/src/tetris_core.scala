package SSC.tetris_core

import spinal.core._
import spinal.lib._
import spinal.lib.graphic.vga.Vga
import SSC.display_top._
import SSC.logic_top._
import utils.PathUtils
import utils.Implicits._

case class TetrisCoreConfig (
                              xWidth : Int = 640,
                              yWidth : Int = 480,
                              pixelFreqInMHz : Int = 25,
                              offset_x : Int = 0,
                              offset_y : Int = 0,
                              rowNum : Int = 23,   // include bottom wall
                              colNum :Int = 12    // include left and right wall
                            ){


  val logicTopConfig = LogicTopConfig( rowNum, colNum )

  val displayTopConfig = DisplayTopConfig(xWidth, yWidth, offset_x, offset_y )
}

class tetris_core ( config : TetrisCoreConfig ) extends Component {

  import config._

  val io = new Bundle {

    val core_clk = in Bool()
    val core_rst = in Bool()


    val vga_clk =  in Bool()
    val vga_rst =  in Bool()
    val game_start = in Bool()
    val move_left = in Bool()
    val move_right = in Bool()
    val move_down = in Bool()
    val rotate = in Bool()
    val ctrl_allowed = out Bool()
    val vga      = master(Vga(displayTopConfig.rgbConfig, withColorEn = true ))

  }

  noIoPrefix()

  val coreClockDomain = ClockDomain (
    clock = io.core_clk,
    reset = io.core_rst
  )

  val vgaClockDomain = ClockDomain(
    clock = io.vga_clk,
    reset = io.vga_rst,
    frequency = FixedFrequency( pixelFreqInMHz MHz)
  )

  //***********************************************************
  //              Instantiation
  //***********************************************************

  val game_logic_inst = coreClockDomain( new logic_top(logicTopConfig) )

  val game_display_inst = new display_top(displayTopConfig)



  //***********************************************************
  //    Connection
  //***********************************************************
  io -> game_display_inst.io connectByName List("vga_clk", "vga_rst", "core_clk", "core_rst", "game_start")
  io -> game_logic_inst.io connectByName List ( "game_start", "move_left", "move_right", "move_down", "rotate")
  io.ctrl_allowed := game_logic_inst.io.ctrl_allowed
  io.vga := game_display_inst.io.vga


  game_display_inst.io.row_val <> game_logic_inst.io.row_val
  game_logic_inst.io.vga_sof := game_display_inst.io.sof
  game_logic_inst.io.draw_field_done := game_display_inst.io.draw_field_done
  game_logic_inst.io.screen_is_ready := game_display_inst.io.screen_is_ready
  game_display_inst.io.softRest := game_logic_inst.io.softReset
  game_display_inst.io.game_restart := game_logic_inst.io.game_restart
}

object TetrisCoreMain{

  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SSC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new tetris_core(TetrisCoreConfig())
    )
  }

}