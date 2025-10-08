package utils

import spinal.core._
import spinal.lib._


case class DmaGeneric(  dataBitWidth : Int ,
                        srcAddrWidth : Int,
                        dstAddrWidth : Int = -1
                     ) {
    def isDualPort = dstAddrWidth > 0
    var wordCount : Int = 4
}


case class DmaAddr( g : DmaGeneric ) extends Bundle  {
  val src = UInt( g.srcAddrWidth bit  )
  val dst = if ( g.isDualPort ) UInt(g.dstAddrWidth bit ) else null
}

object dma {

  def apply(g: DmaGeneric, start: Bool, srcAddrBase : UInt, dstAddrBase : UInt, wordCount : Int ): Dma = {
      if ( wordCount > 0 ) g.wordCount = wordCount
      val ret = new Dma(g)
      ret.io.start.valid := start
      ret.io.start.src := srcAddrBase
      ret.io.start.dst := dstAddrBase
      ret
  }

  def apply(g: DmaGeneric, start: Bool, srcAddrBase : UInt, wordCount : Int ): Dma = {
    if ( wordCount > 0 ) g.wordCount = wordCount
    val ret = new Dma(g)
    ret.io.start.valid := start
    ret.io.start.src := srcAddrBase
    ret
  }

  def apply(g: DmaGeneric, start: Bool, srcAddrBase : Int, dstAddrBase : Int,  wordCount : Int ): Dma = {
    if ( wordCount > 0 ) g.wordCount = wordCount
    val ret = new Dma(g)
    ret.io.start.valid := start
    ret.io.start.src := U(srcAddrBase)
    ret.io.start.dst := U(dstAddrBase)
    ret
  }

  def apply(g: DmaGeneric, start: Bool, srcAddrBase : Int,  wordCount : Int ): Dma = {
    if ( wordCount > 0 ) g.wordCount = wordCount
    val ret = new Dma(g)
    ret.io.start.valid := start
    ret.io.start.src := U(srcAddrBase)
    ret
  }

}

class Dma  ( g : DmaGeneric ) extends Component  {
  import g._

  val io = new Bundle {
    val start = slave Flow  DmaAddr(g)
    val busy  = out Bool()

    val data_in = in Bits( dataBitWidth bit )
    val src_req = master Flow UInt( srcAddrWidth bit)
    val dst_req = if ( isDualPort ) master Flow UInt( dstAddrWidth bit) else null
    val data_out = master Flow  Bits( dataBitWidth bit )

  }

  noIoPrefix()



  val req_valid = RegInit ( False )

  val src_addr = Reg( UInt( g.srcAddrWidth bit  ) )
  val dst_addr = if ( isDualPort ) Reg( UInt( g.dstAddrWidth bit  ) ) else null

  val req_counter = Reg( UInt( log2Up( wordCount ) bit ))
  val req_a_is_last = req_counter ===  ( wordCount - 1 )

  when ( io.start.valid ) {
    req_counter := 0
  } elsewhen ( req_valid ) {
    req_counter := req_counter + 1
  }

  req_valid setWhen( io.start.valid )  clearWhen( req_a_is_last )

  when ( io.start.valid ) {
    src_addr := io.start.src
    if ( isDualPort ) {
      dst_addr := io.start.dst
    }
  } elsewhen ( req_valid ) {
    src_addr := src_addr + 1
    if ( isDualPort ) {
      dst_addr := dst_addr + 1
    }
  }

  io.src_req.valid := req_valid
  io.src_req.payload := src_addr

  if ( isDualPort ) {
    io.dst_req.valid := req_valid
    io.dst_req.payload := dst_addr
  }

  val data_valid = RegNext( req_valid, init = False )
  io.data_out.valid := data_valid
  io.data_out.payload := io.data_in

  io.busy := req_valid | data_valid


  def apply() ={
    io.data_out
  }
}


class dmaWrapper ( g1 : DmaGeneric, g2 : DmaGeneric) extends Component {
  val start = RegInit(False)
  val srcAddrBase = U(0, 2 bit  )
  val dstAddrBase = U(3, 5 bit  )
  val dma_1 = dma ( g1, start, srcAddrBase, dstAddrBase, 8 )
  val dma_2 = dma ( g1, start, 0, 3, 4 )
  val dma_3= dma ( g2, start, srcAddrBase, 8 )
  val dma_4 = dma ( g2, start, 0, 4 )

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


//    val g = DmaGeneric(
//      dataBitWidth      = 10,
//      wordCount         = 4,
//      srcAddrWidth      = 2,
//      dstAddrWidth      = 5,
//    )


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




