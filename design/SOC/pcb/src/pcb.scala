package SOC.pcb

import spinal.core._
import SSC.tetris_core._
import utils.PathUtils

import SOC.tetris_top._
import IPS.xilinx_dcm._
import IPS.picouser._
import spinal.lib.blackbox.xilinx.s7._

class PcbIo() extends Bundle {
  val CLK_50M   = in Bool()
  val BTN_SOUTH = in Bool()
  val BTN_WEST  = in Bool()
  val BTN_NORTH = in Bool()
  val BTN_EAST  = in Bool()
  val SW        = in Bits(4 bits)
  val ROT_A     = in Bool()
  val ROT_B     = in Bool()
  val ROT_CENTER  = in Bool()

  val PS2_CLK = inout(Analog(Bool()))
  val PS2_DATA = inout(Analog(Bool()))
  // `ifdef UART` in Verilog can be handled with an optional bundle
  /*
  val UART = new Bundle {
    val RS232_DCE_RXD = in Bool()
    val RS232_DCE_TXD = out Bool()
  }.setName("UART").asOptional()
  */

  val VGA_B = out UInt(4 bits)
  val VGA_G = out UInt(4 bits)
  val VGA_R = out UInt(4 bits)
  val VGA_HSYNC = out Bool()
  val VGA_VSYNC = out Bool()
}

class pcb extends  Component {

  val io = new PcbIo
  noIoPrefix()


  // --------------------------------------------
  //          DCM
  // --------------------------------------------

  val dcm_inst = new dcm()

  dcm_inst.io.CLKIN_IN := io.CLK_50M
  dcm_inst.io.RST_IN := False


  // vga_clk = 50 / 2 = 25MHz
  // core_clk = 50 MHz

  //val core_clk = dcm_inst.io.CLK0_OUT
  val vga_clk = dcm_inst.io.CLKDV_OUT
  val core_fast_clk, dcm_clocked  = Bool()
  core_fast_clk := dcm_inst.io.CLK2X_OUT
  dcm_clocked := dcm_inst.io.LOCKED_OUT

  core_fast_clk.addAttribute("keep")
  dcm_clocked.addAttribute("keep")

  val core_clk =  BUFG.on( dcm_inst.io.CLK0_OUT )
  val cdc_clk = BUFG.on( dcm_inst.io.CLK180_OUT)

  cdc_clk.addAttribute("keep")

  // --------------------------------------------
  //          button
  // --------------------------------------------

  // Create output signals
  val btn_out = Bits(4 bits)
  val sws_out = Bits(4 bits)
  val rot_out = Bits(4 bits)
  val rot_clr = Bool()

  // Instantiate the module
  val picouser_inst = new picouser()


  // Connect button inputs
  picouser_inst.io.BTN_EAST   := io.BTN_EAST
  picouser_inst.io.BTN_NORTH  := io.BTN_NORTH
  picouser_inst.io.BTN_SOUTH  := io.BTN_SOUTH
  picouser_inst.io.BTN_WEST   := io.BTN_WEST
  picouser_inst.io.SW         := io.SW
  picouser_inst.io.ROT_A      := io.ROT_A
  picouser_inst.io.ROT_B      := io.ROT_B
  picouser_inst.io.ROT_CENTER := io.ROT_CENTER

  picouser_inst.io.rot_clr    := rot_clr
  picouser_inst.io.clk        := core_clk

  // Connect clean button outputs
  btn_out := picouser_inst.io.btn_out
  sws_out := picouser_inst.io.sws_out
  rot_out := picouser_inst.io.rot_out

  val btn_north = btn_out(3)
  val btn_east  = btn_out(2)
  val btn_south = btn_out(1)
  val btn_west  = btn_out(0)

  val rot_push  = rot_out(3)
  val rot_pop   = rot_out(2)
  val rot_left  = rot_out(1)
  val rot_right = rot_out(0)

  val btns : brd_btns = brd_btns(  btn_north, btn_east, btn_south, btn_west, rot_push, rot_pop, rot_left, rot_right, rot_clr  )


  val core_rst, vga_rst = btn_north

  // --------------------------------------------
  //          tetris_top
  // --------------------------------------------
  //val tetris_top_inst = new tetris_top(TetrisCoreConfig())
  val tetris_top_inst = new tetris_top(
    TetrisCoreConfig( offset_x = 32, levelFallInCycle = 473 * 50000,  lockDownInCycle =500 * 50000  ),
    rot_dir_swap = true
  ) // For Spartan 3A with limitd BRAM
  tetris_top_inst.addAttribute( "keep_hierarchy", "yes")
  tetris_top_inst.io.core_clk := core_clk
  tetris_top_inst.io.core_rst := core_rst

  tetris_top_inst.io.btns <> btns
  tetris_top_inst.io.vga_clk := vga_clk
  tetris_top_inst.io.vga_rst := vga_rst

  io.VGA_HSYNC := tetris_top_inst.io.vga.hSync
  io.VGA_VSYNC := tetris_top_inst.io.vga.vSync
  io.VGA_R := tetris_top_inst.io.vga.color.r
  io.VGA_G := tetris_top_inst.io.vga.color.g
  io.VGA_B := tetris_top_inst.io.vga.color.b

  io.PS2_CLK  := tetris_top_inst.io.ps2_clk
  io.PS2_DATA := tetris_top_inst.io.ps2_data

}

object PcbMain{

  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SOC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new pcb()
    ).mergeRTLSource()
  }

}
