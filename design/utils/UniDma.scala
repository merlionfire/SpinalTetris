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

/**
  * Uni-directional DMA helper that fans a sequential address request stream into one or more
  * data output channels.
  *
  * Functional description
  * ----------------------
  * `UniDma` generates a linear address sequence on `addr_port` starting from `base_addr` and
  * continuing for `word_count` words after a start pulse is detected. Each generated request can
  * drive one or more logical DMA channels described by `config.mappings`.
  *
  * - The address side uses a `Flow[UInt]` request port.
  * - Each input source slot in `source` is associated with a logical port id from `mappings`.
  * - Each mapping can replicate one input source into multiple output `sink` flows.
  * - Read mappings delay the valid signal by one cycle (`delay`) to model data returning after the
  *   address request.
  * - Write mappings emit valid in the same cycle as the request.
  * - Each output channel can be individually enabled/disabled through the channel control APIs.
  *
  * Parameters description
  * ----------------------
  * @param addr_port
  *   Address request `Flow`. `payload` defines the address width used by the internal registers and
  *   generated address counter. `valid` is asserted while a burst is active.
  * @param config
  *   DMA structural configuration.
  *   - `dataWidth`: bit width of each data word driven through `source` and `sink`.
  *   - `count`: default transfer length used to initialize `word_count`.
  *   - `mappings`: relationship between logical data input ports and DMA output channels. Each entry
  *     is `(DataPort(id, mode), PortMapping(out0, out1, ...))`, where `mode` is either `"read"` or
  *     `"write"`.
  *
  * Methods as API
  * --------------
  * Configuration / control:
  * - `setWordCount(n)`: program transfer length to `n` words.
  * - `setBaseAddr(addr)`: program the first request address.
  * - `startTrans()`: request a transfer start by asserting `start`.
  * - `stopTrans()`: deassert `start`.
  *
  * Data path:
  * - `<<(index, data)`: connect one producer data word into source slot `index`.
  * - `apply(index)`: access output `Flow[Bits]` channel `index`.
  *
  * Channel gating:
  * - `enableChannel(n)`: enable a specific output channel.
  * - `disableChannel(n)`: disable a specific output channel.
  * - `enableAllChannel()`: enable all output channels.
  * - `disableAllChannel()`: disable all output channels.
  *
  * Integration example in ASCII
  * ----------------------------
  * {{
  *   val addr_port = Flow(UInt(16 bits))
  *   val config = UniDmaConfig(
  *     dataWidth = 32,
  *     count = 128,
  *     mappings = Seq(
  *       (0, "read")  -> (0, 1),
  *       (1, "write") -> (2)
  *     )
  *   )
  *
  *   val dma = new UniDma(addr_port, config)
  *   dma.setBaseAddr(U(0x1000, 16 bits))
  *   dma.setWordCount(16)
  *   dma.enableAllChannel()
  *
  *   dma << (0, read_data_bits)
  *   dma << (1, write_data_bits)
  *
  *   val read_copy0 = dma(0)
  *   val read_copy1 = dma(1)
  *   val write_out  = dma(2)
  * }}
  *
  *   +--------------------+        +---------------------------+
  *   | address generator  |------->| addr_port : Flow[UInt]    |
  *   +--------------------+        +---------------------------+
  *              |                                   |
  *              | mappings                          |
  *              v                                   v
  *   +--------------------+        +----------------------------------+
  *   | source(0) read     |------->| sink(0), sink(1) delayed by 1cy |
  *   +--------------------+        +----------------------------------+
  *   +--------------------+        +---------------------------+
  *   | source(1) write    |------->| sink(2) same-cycle valid  |
  *   +--------------------+        +---------------------------+
  *
  * Timing example in ASCII
  * -----------------------
  * Example for one request burst with `base_addr = A0` and `word_count = 4`:
  *
  *   cycle        | 0 | 1 | 2 | 3 | 4 | 5 |
  *   -------------+---+---+---+---+---+---
  *   start        | 0 | 1 | 1 | 1 | 1 | 0 |
  *   req_valid    | 0 | 1 | 1 | 1 | 1 | 0 |
  *   addr_port    | - |A0 |A1 |A2 |A3 | - |
  *   write.valid  | 0 | 1 | 1 | 1 | 1 | 0 |
  *   read.valid   | 0 | 0 | 1 | 1 | 1 | 1 |
  *
  * This means write-mode outputs are aligned with the address request, while read-mode outputs are
  * delayed by `delay` cycles to match returning data.
 */
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
