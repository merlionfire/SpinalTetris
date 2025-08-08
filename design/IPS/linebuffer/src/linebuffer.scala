package IPS.linebuffer

import spinal.core._
import spinal.lib._
import utils.PathUtils

class linebuffer[T<: Data]  ( val dataType: HardType[T],
                              val depth: Int,
                              val rd_scale : Int  = 1 ,
                              val wrClock: ClockDomain = null ,
                              val rdClock: ClockDomain = null ) extends Component {

  //assert(isPow2(depth) & depth >=2,  "The depth of the linebuffer must be a power of 2 and equal or bigger than 2")
  assert( isPow2(rd_scale), "rd_scae must be a power of 2" )

  // One clock dealy
  //   rd_stat  _| |__________
  //            _ _|          |_____
  //            _ _ xxxxxxxxxx _____
  val io = new Bundle  {
    val wr_in = slave Flow(dataType)
    val rd_start = in Bool()
    val rd_out = master Flow(dataType)
  }

  noIoPrefix()

  val addrWidth = log2Up(depth)

  val ram =Mem(dataType, depth)

  ram.addAttribute("ram_style", "distributed")

  val wr = new ClockingArea ( wrClock ) {

    val addr = RegInit(U(0, addrWidth bits))
    when(io.wr_in.valid) {
      when ( addr === U(depth-1)) {
        addr := U(0)
      }. otherwise {
        addr := addr + 1
      }
    }

    ram.write(
      enable = io.wr_in.valid,
      address = addr,
      data = io.wr_in.payload
    )

  }


  val rd = new ClockingArea( rdClock ) {

    val addr = RegInit(U(0, addrWidth bits))
    val enable = RegInit( False )



    val scale_cnt = Counter(stateCount = rd_scale, enable )
    when ( io.rd_start ) {
      scale_cnt.clear()
    }

    when (io.rd_start) {
      enable := True
    }.elsewhen { addr === (U( depth-1)) & scale_cnt.willOverflowIfInc } {
      enable := False
    }

    val valid = (scale_cnt === U(0) ) & enable
    val inc_enable = scale_cnt.willOverflowIfInc & enable

    val data = Flow(dataType)

    when ( io.rd_start ) {
      addr := U(0)
    } .elsewhen ( inc_enable ) {
      addr := addr + 1
    }

    val rd_data = ram.readSync(
      enable = valid,
      address = addr,
      clockCrossing = true
    )

    data.valid := RegNext(enable) init False
    data.payload := rd_data
  }

  io.rd_out := rd.data

  val delay_num = 1
  println( "[INFO] sync read delay  = " + delay_num )
}

object lineBufferMain{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new linebuffer(
        Bits(4 bit),
        32,
        1,
        ClockDomain.external("wr"),
        ClockDomain.external("rd")
      )
    )
  }
}
