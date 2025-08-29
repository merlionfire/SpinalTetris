package SOC.tetris_top

import spinal.core._
import spinal.lib.master
import spinal.lib.graphic.vga.Vga
import SSC.tetris_core._
import IPS.keyboard._
import utils.PathUtils

class tetris_top ( config : TetrisCoreConfig ) extends Component {

  import config._
  val io = new Bundle {

    val core_clk = in Bool()  // 50MHz
    val core_rst = in Bool()
    val vga_clk =  in Bool()  // 25MHz for 640x480
    val vga_rst =  in Bool()

    val ps2_clk = inout(Analog(Bool()))
    val ps2_data = inout(Analog(Bool()))


    val vga      = master(Vga(displayTopConfig.rgbConfig, withColorEn = true ))
  }

  noIoPrefix()


  val key_clk = io.core_clk
  val key_rst = io.core_rst

  val keyClockDomain = ClockDomain (
    clock = key_clk,
    reset = key_rst
  )

  val tetris_core_inst = new tetris_core(config)
  val kd_ps2_inst = keyClockDomain( new kd_ps2(KdPs2Config()) )

  io.ps2_clk  <> kd_ps2_inst.io.ps2_clk
  io.ps2_data <> kd_ps2_inst.io.ps2_data

  io.vga <> tetris_core_inst.io.vga

  tetris_core_inst.io.core_clk := io.core_clk
  tetris_core_inst.io.core_rst := io.core_rst
  tetris_core_inst.io.vga_clk := io.vga_clk
  tetris_core_inst.io.vga_rst := io.vga_rst

  tetris_core_inst.io.game_start := kd_ps2_inst.io.keys_valid(0)
  tetris_core_inst.io.move_down  := kd_ps2_inst.io.keys_valid(1)
  tetris_core_inst.io.move_left  := kd_ps2_inst.io.keys_valid(2)
  tetris_core_inst.io.move_right := kd_ps2_inst.io.keys_valid(3)
  tetris_core_inst.io.rotate     := kd_ps2_inst.io.keys_valid(4)


}

object TetrisTopMain{

  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SOC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new tetris_top(TetrisCoreConfig())
    ).mergeRTLSource()
  }

}