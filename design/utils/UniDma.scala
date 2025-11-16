package utils


import spinal.core._
import spinal.lib._


case class DmaChannel[ T <: Data ]  (  payloadType: HardType[T], id : Int, latency : Int  = 0 ) extends ImplicitArea[T]  {

  val valid = Bool()
  val payload : T = payloadType()

  val enable  = RegInit(False )

  val data_in, data_out, data_inter  = Flow( payload )

  data_in.valid := valid
  data_in.payload := payload

  data_inter.valid := data_in.valid & enable
  data_inter.payload := data_in.payload
  data_out := data_inter.delay(latency)

  override def implicitValue : T = this.data_out.payload

  def <<(that: Flow[T]): Flow[T] = this connectFrom that

  def >>(into: Flow[T]): Flow[T] = {
    into << this.data_out
    into
  }

  def connectFrom(that: Flow[T]): Flow[T] = {
    valid := that.valid
    payload := that.payload
    that
  }

  def enableOut() = enable := True
  def disableOut() = enable := False

}

case class DataPort(id: Int, mode: String) {
  require(mode == "read" || mode == "write", s"Invalid mode: $mode")
}

case class PortMapping(ports: Seq[Int]) {
  require(ports.nonEmpty, "Port mapping must have at least one port")
}

object UniDmaConfig {
  // Implicit conversion for clean syntax
  implicit class ChannelDataBuilder(tuple: (Int, String)) {
    def ->(ports: Int*): (DataPort, PortMapping) = {
      (DataPort(tuple._1, tuple._2), PortMapping(ports.toSeq))
    }
  }

}

case class UniDmaConfig(
                         dataWidth: Int,
                         count: Int,
                         mappings: Seq[ ( DataPort, PortMapping ) ]
                       ) {
  require(dataWidth > 0, "dataWidth must be positive")
  require(count > 0, "count must be positive")

  def data_in_port_num = mappings.size

  def data_out_port_num = mappings.flatMap(_._2.ports).size


}

class UniDma[T <: Data ](addr_port : Flow[UInt],config : UniDmaConfig ) extends ImplicitArea[Int] {
  import config._

  val addrType = HardType( addr_port.payload )
  // Register

  val base_addr  = Reg( addrType() ) init U(0)
  val word_count = Reg( addrType() ) init U(count-1)

  base_addr.allowUnsetRegToAvoidLatch
  word_count.allowUnsetRegToAvoidLatch

  val start = False allowOverride()

  val delay = 1

  def setWordCount( n : Int ) = word_count := U(n-1)
  def setBaseAddr( addr : UInt ) = base_addr := addr
  def startTrans() = start := True
  def stopTrans() = start := False



  // Address bus as output stream

  // Logic for address bus

  val req_counter = Reg( addrType() ) init U(0)

  val counter_is_last = req_counter ===  word_count

  val trig = start.rise(False)

  val req_valid = RegInit(False ) clearWhen( counter_is_last ) setWhen ( trig )

  when ( req_valid ) {
    req_counter := req_counter + 1
  } elsewhen( req_valid.fall(False) ) {
    req_counter := U(0)
  }

  val addr = cloneOf(base_addr ) setAsReg()


  addr_port.valid := req_valid
  addr_port.payload := req_counter + base_addr

  val source  = Vec.fill(data_in_port_num)(Bits(dataWidth bits ))
  val sink = Vec.fill(data_out_port_num)( Flow( Bits(dataWidth bits )) )

  val dir = List.fill((data_in_port_num))("read")

   val req_valid_1d = Delay(req_valid, cycleCount= delay, init=False )


  val channel = List.fill(data_out_port_num)( DmaChannel( payloadType = Bits(dataWidth bits), id = 0, latency = 0 ) )


  for (  ( in_port, out_ports ) <- mappings ){
    val dir = in_port.mode
    val i = in_port.id

    for ( j <- out_ports.ports ) {
      val data_in = Flow(channel(j).payloadType)
      data_in.valid := {
        dir.toLowerCase match {
          case "write" => req_valid
          case "read" => req_valid_1d
          case _ => False
        }
      }
      data_in.payload := source(i)
      channel(j) << data_in
      channel(j) >> sink(j)
    }
  }

  def <<( index : Int, data : Bits ) = source(index) := data
  def apply( index : Int )  : Flow[Bits] = sink(index)

  def enableChannel( n : Int ) = channel(n).enableOut()
  def disableChannel( n : Int ) = channel(n).disableOut()
  def enableAllChannel() = for ( i <- 0 until data_out_port_num  ) { channel(i).enableOut()  }
  def disableAllChannel() = for ( i <- 0 until data_out_port_num  ) { channel(i).disableOut()  }

  override def implicitValue : Int = data_out_port_num

}


import UniDmaConfig._
class halfDmaWrapper ( addrWidth : Int , dataWidth : Int ) extends Component {
  val start = RegInit(False)
  val addr_port = Flow( UInt( addrWidth bit )  )


  val data_in_0 = Bits( dataWidth bit  )
  val data_in_1 = Bits( dataWidth bit  )

  val config = UniDmaConfig(
    dataWidth,
    4,
    mappings = Seq (
      (0,"read" )  -> (0, 1, 2 ),
      (1, "read" ) ->  (3)
    )
  )
  val dma = new UniDma( addr_port, config )

  dma.setWordCount(8)
  dma.setBaseAddr(U(4, 3 bit ))
  dma.start := start
  val a = dma(0)
  val b = dma(1)
  val c = dma(2)
  val d = dma(3)

  dma << (0, data_in_0 )
  dma << (1, data_in_1 )

}

object HalfDmaMain{

  def main(args: Array[String]) {

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog( gen = new halfDmaWrapper(3,10)  )

  }
}
