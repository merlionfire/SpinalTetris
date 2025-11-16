package utils

import spinal.core._
import spinal.lib._


case class DmaGeneric(  dataBitWidth : Int ,
                        srcAddrWidth : Int,
                        dstAddrWidth : Int = -1
                     ) {
    def isDualPort = dstAddrWidth > 0
}
//
//
//case class DmaAddr( g : DmaGeneric ) extends Bundle  {
//  val src = UInt( g.srcAddrWidth bit  )
//  val dst = if ( g.isDualPort ) UInt(g.dstAddrWidth bit ) else null
//}
//
//object dma {
//
//  //----------------------------------------------------------------------
//  //      Single Port access - Read address request + Data passthrough
//  //----------------------------------------------------------------------
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : UInt, wordCount : UInt ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := srcAddrBase
//    ret.io.word_count := wordCount
//    ret
//  }
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : UInt, wordCount : Int ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := srcAddrBase
//    ret.io.word_count := wordCount-1
//    ret
//  }
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : Int,  wordCount : UInt ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := U(srcAddrBase)
//    ret.io.word_count := wordCount
//    ret
//  }
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : Int,  wordCount : Int ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := U(srcAddrBase)
//    ret.io.word_count := wordCount-1
//    ret
//  }
//
//
//  //----------------------------------------------------------------------
//  //      Double Port access - Read address request + Write address request + Data passthrough
//  //----------------------------------------------------------------------
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : UInt, dstAddrBase : UInt, wordCount : UInt ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := srcAddrBase
//    ret.io.start.dst := dstAddrBase
//    ret.io.word_count := wordCount
//    ret
//  }
//
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : UInt, dstAddrBase : UInt, wordCount : Int ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := srcAddrBase
//    ret.io.start.dst := dstAddrBase
//    ret.io.word_count := wordCount-1
//    ret
//  }
//
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : Int, dstAddrBase : Int,  wordCount : UInt ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := U(srcAddrBase)
//    ret.io.start.dst := U(dstAddrBase)
//    ret.io.word_count := wordCount
//    ret
//  }
//
//  def apply(g: DmaGeneric, start: Bool, srcAddrBase : Int, dstAddrBase : Int,  wordCount : Int ): Dma = {
//    val ret = new Dma(g)
//    ret.io.start.valid := start
//    ret.io.start.src := U(srcAddrBase)
//    ret.io.start.dst := U(dstAddrBase)
//    ret.io.word_count := wordCount-1
//    ret
//  }
//
//
//}
//
//class Dma  ( g : DmaGeneric ) extends Component  {
//  import g._
//
//  val io = new Bundle {
//    val start = slave Flow  DmaAddr(g)
//    val word_count = in UInt(srcAddrWidth bit)
//    val busy  = out Bool()
//
//    val data_in = in Bits( dataBitWidth bit )
//    val src_req = master Flow UInt( srcAddrWidth bit)
//    val dst_req = if ( isDualPort ) master Flow UInt( dstAddrWidth bit) else null
//    val data_out = master Flow  Bits( dataBitWidth bit )
//
//  }
//
//  noIoPrefix()
//
//
//
//  val req_valid = RegInit ( False )
//
//  val src_addr = Reg( UInt( g.srcAddrWidth bit  ) )
//  val dst_addr = if ( isDualPort ) Reg( UInt( g.dstAddrWidth bit  ) ) else null
//
//  val req_counter = cloneOf( io.word_count)  setAsReg()
//  val req_a_is_last = req_counter ===  io.word_count
//
//  when ( io.start.valid ) {
//    req_counter := 0
//  } elsewhen ( req_valid ) {
//    req_counter := req_counter + 1
//  }
//
//  req_valid setWhen( io.start.valid )  clearWhen( req_a_is_last )
//
//  when ( io.start.valid ) {
//    src_addr := io.start.src
//    if ( isDualPort ) {
//      dst_addr := io.start.dst
//    }
//  } elsewhen ( req_valid ) {
//    src_addr := src_addr + 1
//    if ( isDualPort ) {
//      dst_addr := dst_addr + 1
//    }
//  }
//
//  io.src_req.valid := req_valid
//  io.src_req.payload := src_addr
//
//  if ( isDualPort ) {
//    io.dst_req.valid := req_valid
//    io.dst_req.payload := dst_addr
//  }
//
//  val data_valid = RegNext( req_valid, init = False )
//  io.data_out.valid := data_valid
//  io.data_out.payload := io.data_in
//
//  io.busy := req_valid | data_valid
//
//
//  def apply() ={
//    io.data_out
//  }
//}
//
//
//class dmaWrapper ( g1 : DmaGeneric, g2 : DmaGeneric) extends Component {
//  val start = RegInit(False)
//  val srcAddrBase = U(0, 2 bit  )
//  val dstAddrBase = U(3, 5 bit  )
//  val dma_1 = dma ( g1, start, srcAddrBase, dstAddrBase, 4 )
//  val dma_2 = dma ( g1, start, 0, 3, 4 )
//  val dma_3= dma ( g2, start, srcAddrBase, 4 )
//  val dma_4 = dma ( g2, start, 0, 4 )
//
//}
//
//

//object dmaMain{
//
//  def main(args: Array[String]) {
//
//    val g1 = DmaGeneric(
//      dataBitWidth      = 10,
//      srcAddrWidth      = 2,
//      dstAddrWidth      = 5,
//    )
//
//    val g2 = DmaGeneric(
//      dataBitWidth      = 10,
//      srcAddrWidth      = 2,
//    )


//    val g = DmaGeneric(
//      dataBitWidth      = 10,
//      wordCount         = 4,
//      srcAddrWidth      = 2,
//      dstAddrWidth      = 5,
//    )

//
//    SpinalConfig(
//      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
//      verbose = true,
//      nameWhenByFile = false,
//      enumPrefixEnable = false,
//      anonymSignalPrefix = "temp",
//      mergeAsyncProcess = true
//    ).generateVerilog( gen = new dmaWrapper(g1,g2)  )
//
//  }
//}




object dma {


  def apply ( start : Bool, data_in : Bits, word_count : UInt, address_reqs : (  UInt, Flow[UInt] )* ) = {
    new dma(  start, data_in, word_count, address_reqs )
  }

  def apply ( start : Bool, data_in : Bits, word_count : Int, address_reqs : (  UInt, Flow[UInt] )* ) = {
    new dma(  start, data_in, U(word_count-1), address_reqs )
  }

  def apply ( start : Flow[UInt], data_in : Bits,  address_reqs : (  UInt, Flow[UInt] )* ) = {
    new dma(  start.valid, data_in, start.payload, address_reqs )
  }

}




class dma ( start : Bool, data_in : Bits, word_count : UInt, address_reqs : Seq[ ( UInt, Flow[UInt] ) ] ) extends ImplicitArea[Bits] {

  val req_valid = RegInit ( False )

  val word_count_reg = RegNextWhen(word_count, start )

  //val req_counter = Reg( UInt( log2Up(word_count)  bit )  )
  val req_counter = cloneOf(word_count) setAsReg()
  val counter_is_last = req_counter ===  word_count_reg

  when ( start ) {
    req_counter := 0
  } elsewhen ( req_valid ) {
    req_counter := req_counter + 1
  }

  req_valid   clearWhen( counter_is_last  ) setWhen( start )

  for ( ( addrBase, addrReq ) <- address_reqs ) {
    val addr = cloneOf(addrReq.payload ) setAsReg()

    when(start) {
      addr := addrBase
    } .elsewhen ( req_valid ) {
      addr := addr + 1
    }

    addrReq.valid := req_valid
    addrReq.payload := addr

  }


  val flow_sync  = Flow(data_in)
  flow_sync.valid := RegNext(req_valid, init = False)
  flow_sync.payload := data_in

  val flow_async = Flow(data_in)
  flow_async.valid  := req_valid
  flow_async.payload := data_in



  def is_busy : Bool = flow_sync.valid | flow_async.valid

  def read_sync()  = this.flow_sync
  def read_async() = this.flow_async

  override def implicitValue: Bits = this.data_in

}




class dmaWrapper ( g1 : DmaGeneric, g2 : DmaGeneric) extends Component {
  val start = RegInit(False)
  val srcAddrBase = U(0, 2 bit  )
  val dstAddrBase = U(3, 5 bit  )

  val data_in = Bits( g1.dataBitWidth  bit )

  val src_req= Flow( UInt( g1.srcAddrWidth bit ))
  val dst_req= Flow( UInt( g1.dstAddrWidth bit ))

  val dma_sync = dma ( start, data_in, U(3,2 bits ),
     srcAddrBase -> src_req,
     dstAddrBase -> dst_req )


}

object dmaMain{

  def main(args: Array[String]) {

    val g1 = DmaGeneric(
      dataBitWidth      = 10,
      srcAddrWidth      = 2,
      dstAddrWidth      = 5,
    )

    val g2 = DmaGeneric(
      dataBitWidth      = 10,
      srcAddrWidth      = 2,
    )

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog( gen = new dmaWrapper(g1,g2)  )

  }
}
