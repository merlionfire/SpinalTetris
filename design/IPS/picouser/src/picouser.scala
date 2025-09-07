package IPS.picouser
import spinal.core._
import utils.PathUtils.getVerilogFilePath

class picouser ( ) extends BlackBox {

  val io = new Bundle {
    val BTN_EAST    = in  Bool()
    val BTN_NORTH   = in  Bool()
    val BTN_SOUTH   = in  Bool()
    val BTN_WEST    = in  Bool()
    val SW          = in  Bits(4 bits)

    val ROT_A       = in  Bool()
    val ROT_B       = in  Bool()
    val ROT_CENTER  = in  Bool()

    val rot_clr     = in  Bool()
    val clk         = in  Bool()

    val btn_out     = out Bits(4 bits)
    val sws_out     = out Bits(4 bits)
    val rot_out     = out Bits(4 bits)
  }

  noIoPrefix()
  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "debounce.v" ).toString)
  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "debnce.v" ).toString)
  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "spinner.v" ).toString)
  addRTLPath(getVerilogFilePath(ipFolderName = "misc", fileName = "picouser.v" ).toString)

}

