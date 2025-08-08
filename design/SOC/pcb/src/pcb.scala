package SOC.pcb

import spinal.core._
import SSC.tetris_core._
import utils.PathUtils

import SOC.tetris_top._
import IPS.xilinx_dcm._
import IPS.btn_filter._

class PcbIo() extends Bundle {
  val CLK_50M = in Bool()
  val BTN_SOUTH = in Bool()
  val BTN_WEST = in Bool()
  val BTN_NORTH = in Bool()
  val PS2_CLK = inout(Analog(Bool()))
  val PS2_DATA = inout(Analog(Bool()))
  val SW = in Bits(4 bits)
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


  val core_clk = dcm_inst.io.CLK0_OUT
  val vga_clk = dcm_inst.io.CLKDV_OUT

  // --------------------------------------------
  //          button
  // --------------------------------------------


  val btn_clean = new btn_filter(4)
  btn_clean.io.clk := core_clk
  btn_clean.io.pin_in := Cat(io.BTN_SOUTH, io.BTN_WEST, io.BTN_NORTH, io.SW(0))

  val btn_south_clean = btn_clean.io.pin_out(3)
  val btn_west_clean =  btn_clean.io.pin_out(2)
  val btn_north_clean = btn_clean.io.pin_out(1)
  val sw_0_clean      = btn_clean.io.pin_out(0)


  val core_rst, vga_rst = btn_north_clean

  // --------------------------------------------
  //          tetris_top
  // --------------------------------------------
  val tetris_top_inst = new tetris_top(TetrisCoreConfig())
  tetris_top_inst.addAttribute( "keep_hierarchy", "yes")
  tetris_top_inst.io.core_clk := core_clk
  tetris_top_inst.io.core_rst := core_rst

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
