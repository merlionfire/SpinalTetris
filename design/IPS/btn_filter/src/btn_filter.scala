package IPS.btn_filter


import spinal.core._
import utils.PathUtils.getVerilogFilePath

class btn_filter ( number : Int ) extends BlackBox {

  addGeneric("PIN_NUM", number )

  val io = new Bundle {
    val clk = in Bool()
    val pin_in = in Bits( number bits)
    val pin_out = out Bits( number bits)
  }
  noIoPrefix()

  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "btn_filter.v" ).toString)
  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "debounce.v" ).toString)
}



