package SOC.tetris_top

import spinal.core._
import spinal.lib.{IMasterSlave, master, slave}
import spinal.lib.graphic.vga.Vga
import SSC.tetris_core._
import IPS.keyboard._
import utils.PathUtils

object brd_btns {
  def apply( btns: Bool* ) : brd_btns = {
    val ret = new brd_btns
    ret.btn_north := btns(0)
    ret.btn_east  := btns(1)
    ret.btn_south := btns(2)
    ret.btn_west  := btns(3)
    ret.rot_push  := btns(4)
    ret.rot_pop   := btns(5)
    ret.rot_left  := btns(6)
    ret.rot_right := btns(7)
    btns(8) := ret.rot_clr
    ret
  }

}

class brd_btns( ) extends Bundle with IMasterSlave {
   val btn_north = Bool()
   val btn_east  = Bool()
   val btn_south = Bool()
   val btn_west = Bool()
   val rot_push = Bool()
   val rot_pop = Bool()
   val rot_left = Bool()
   val rot_right = Bool()
   val rot_clr   = Bool()

  override def asMaster(): Unit = {
    out(btn_north,btn_east, btn_south, btn_west, rot_push, rot_pop,rot_left,rot_right )
    in(rot_clr)
  }

  override def asSlave(): Unit = {
    in(btn_north,btn_east, btn_south, btn_west, rot_push, rot_pop,rot_left,rot_right )
    out(rot_clr)
  }
}

class tetris_top ( config : TetrisCoreConfig ) extends Component {

  import config._
  val io = new Bundle {

    val core_clk = in Bool()  // 50MHz
    val core_rst = in Bool()
    val vga_clk =  in Bool()  // 25MHz for 640x480
    val vga_rst =  in Bool()

    val btns =  slave( new brd_btns )
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


//  tetris_core_inst.io.game_start := kd_ps2_inst.io.keys_valid(0)
//  tetris_core_inst.io.move_down  := kd_ps2_inst.io.keys_valid(1)
//  tetris_core_inst.io.move_left  := kd_ps2_inst.io.keys_valid(2)
//  tetris_core_inst.io.move_right := kd_ps2_inst.io.keys_valid(3)
//  tetris_core_inst.io.rotate     := kd_ps2_inst.io.keys_valid(4)



  tetris_core_inst.io.game_start := io.btns.btn_west
  tetris_core_inst.io.move_down  := io.btns.rot_push
  tetris_core_inst.io.move_left  := io.btns.rot_left
  tetris_core_inst.io.move_right := io.btns.rot_right

  new ClockingArea(tetris_core_inst.coreClockDomain) {
    io.btns.rot_clr := tetris_core_inst.io.ctrl_allowed.rise(False)
    tetris_core_inst.io.rotate := RegInit(False) .setWhen(io.btns.btn_south.rise(False)) clearWhen (io.btns.rot_clr)
  }
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