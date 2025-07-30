package IPS.fb_addr_gen

import spinal.core._
import utils._

case class FbAddrGenConfig (
                               FB_WIDTH : Int,
                               FB_X_ADDRWIDTH : Int,
                               FB_Y_ADDRWIDTH : Int,
                               FB_ADDRWIDTH : Int
                             )

class fb_addr_gen ( config : FbAddrGenConfig )  extends Component {

  import config._

  val ( v_shift_a, v_shift_b ) = if ( FB_WIDTH == 320 ) (2,6) else (0,0)

  val io = new Bundle {
    val x = in UInt (FB_X_ADDRWIDTH bits)
    val y = in UInt (FB_Y_ADDRWIDTH bits)
    val start = in Bool()
    val h_cnt = in UInt (FB_X_ADDRWIDTH bits)
    val v_cnt = in UInt (FB_Y_ADDRWIDTH bits)
    val out_addr = out UInt (FB_ADDRWIDTH bits)

  }

  noIoPrefix()

  // Stage 1
  val x_reg   = RegNextWhen(io.x,   io.start) init (0)
  val y_reg   = RegNextWhen(io.y,   io.start) init (0)

  val v_next = y_reg + io.v_cnt

  val v_next_in_fb = ( v_next << v_shift_a )  + v_next.resize((FB_ADDRWIDTH-v_shift_b))

  // Stage 2
  val h_reg = RegNext(  ( x_reg + io.h_cnt )  ) init 0

  val v_reg = RegNext( v_next_in_fb ) init 0

  // Stage 3
  val addr = RegNext( ( h_reg + ( v_reg << v_shift_b ) )  ) init 0

  // Interface
  io.out_addr  := addr

}

object fbAddrGenMain{
  def main(args: Array[String]) {

    val FB_WIDTH = 320
    val FB_HEIGHT  = 240
    val FB_PIXELS = FB_WIDTH * FB_HEIGHT

    val fbAddrGenConfig = FbAddrGenConfig(
      FB_WIDTH = FB_WIDTH,
      FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
      FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
      FB_ADDRWIDTH = log2Up(FB_PIXELS)
    )

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new fb_addr_gen( fbAddrGenConfig )
    )
  }
}