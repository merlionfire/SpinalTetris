package IPS.ps2

import spinal.core._
import utils.PathUtils.getVerilogFilePath

class ps2_host_rxtx ( ) extends BlackBox {

  val io = new Bundle {

    val clk = in Bool()
    val rst = in Bool()
    val ps2 = new Bundle {
      val clk = inout(Analog(Bool()))
      val data = inout(Analog(Bool()))
      val wr_stb = in Bool()
      val wr_data = in UInt (8 bit)
      val tx_done = out Bool()
      val tx_ready = out Bool()
      val rddata_valid = out Bool()
      val rd_data = out UInt (8 bit)
      val rx_ready = out UInt (8 bit)
    }
  }
  noIoPrefix()

  mapClockDomain(clock = io.clk, reset = io.rst)


  val verilogFilesList = List (
    "ps2_host_rxtx.v",
    "ps2_host_tx.v",
    "ps2_host_rx.v",
  )

  verilogFilesList.foreach { fileName =>
    addRTLPath(getVerilogFilePath(ipFolderName = "ps2/rtl", fileName = fileName ).toString)
  }

  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "io_filter.v" ).toString)
  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "glitch_free.v" ).toString)
  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "synchro.v" ).toString)


}
