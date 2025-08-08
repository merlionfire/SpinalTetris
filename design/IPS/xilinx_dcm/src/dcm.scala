package IPS.xilinx_dcm

import spinal.core._

class dcm extends BlackBox {
  val io = new Bundle {
    val CLKIN_IN = in Bool()
    val RST_IN = in Bool()
    val CLKDV_OUT = out Bool()
    val CLKIN_IBUFG_OUT = out Bool()
    val CLK0_OUT = out Bool()
    val LOCKED_OUT = out Bool()
  }

  noIoPrefix()

}
