package IPS.bram_2p

import spinal.core._
import spinal.lib.Counter

import scala.io.Source
import scala.util.Try
import utils.PathUtils

case class Bram2pConfig (
                    wordWidth:Int,
                    depth: Int,
                    initFileName : String  = "",
                    default_value : Int = 15 )  {
  val initContent = if ( initFileName.nonEmpty) {
    Source.fromFile(initFileName)
      .getLines() // Get an iterator of lines
      .filterNot(_.trim.startsWith("//")) // Filter out lines starting with "//" after trimming whitespace
      .flatMap(line => Try(BigInt(Integer.parseInt(line.trim, 16))).toOption) // Attempt to convert the trimmed line to an Int, discard if not a valid integer
      .toSeq // Collect the valid integers into a Seq
  } else {
    Seq.fill(depth)(BigInt(default_value))
  }
}

class bram_2p  ( config :Bram2pConfig ) extends Component {

  import config._

  val addressWidth  = log2Up(depth)
  val io = new Bundle {
    val wr = new Bundle {
      val en   = in Bool()
      val addr = in UInt(addressWidth bits)
      val data = in Bits(wordWidth bits)
    }
    val rd = new Bundle {
      val en   = in Bool()
      val addr = in UInt(addressWidth bits)
      val data = out Bits(wordWidth bits)
    }
    val clear_start = in Bool()
    val clear_done = out Bool()
  }

  noIoPrefix()

  val addr_inc = RegInit(False) setWhen(io.clear_start)
  val full_addr = Counter( depth,  addr_inc )
  addr_inc.clearWhen(full_addr.willOverflow)
  io.clear_done := addr_inc.fall(False)

  // Instantiate the memory
  val memory = Mem(Bits(wordWidth bits), depth)
  memory.addAttribute("ram_style", "block")
  memory.initBigInt(initContent)

  // Create the write port and associate it with the writeClockDomain
  val wr_addr = Mux(addr_inc ,full_addr.value  , io.wr.addr)
  val wr_data = Mux(addr_inc , B(default_value) , io.wr.data )
  val wr_en   =  addr_inc | io.wr.en
  memory.write(
      address = wr_addr ,
      data    = wr_data,
      enable  = wr_en
      // mask is optional for byte/bit enables
  )

  io.rd.data :=  memory.readSync(
      address = io.rd.addr,
      enable = io.rd.en
  )

}

object bran2pMain{
  def main(args: Array[String]) {
    val fbConfig = Bram2pConfig(
      4,
      19200,
      "design/res/david.mem"
    )

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new bram_2p( fbConfig )
    )
  }
}