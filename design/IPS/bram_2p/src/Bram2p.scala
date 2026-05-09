package IPS.bram_2p

import spinal.core._
import spinal.lib._
import spinal.core.internals._
import scala.io.Source
import scala.util.Try
import utils.{MemInitUtils, PathUtils}

case class Bram2pConfig (
                    wordWidth:Int,
                    depth: Int,
                    initFileName : String  = "",
                    default_value : BigInt = BigInt(15) )  {
//  val initContent = if ( initFileName.nonEmpty) {
//    Source.fromFile(initFileName)
//      .getLines() // Get an iterator of lines
//      .filterNot(_.trim.startsWith("//")) // Filter out lines starting with "//" after trimming whitespace
//      .flatMap(line => Try(BigInt(Integer.parseInt(line.trim, 16))).toOption) // Attempt to convert the trimmed line to an Int, discard if not a valid integer
//      .toSeq // Collect the valid integers into a Seq
//  } else {
//    Seq.fill(depth)(BigInt(default_value))
//  }

  val initContent: Vector[BigInt] = MemInitUtils.loadHexInitFile(
    initFileName = initFileName,
    depth = depth,
    wordWidth = wordWidth,
    defaultValue = default_value
  )


}

case class Bram2pWritePort(addressWidth: Int, wordWidth: Int) extends Bundle {
  val en = in Bool()
  val addr = in UInt(addressWidth bits)
  val data = in Bits(wordWidth bits)
}

case class Bram2pReadPort(addressWidth: Int, wordWidth: Int) extends Bundle {
  val en = in Bool()
  val addr = in UInt(addressWidth bits)
  val data = master Flow(Bits(wordWidth bits))
}

case class Bram2pIo(addressWidth: Int, wordWidth: Int) extends Bundle {
  val wr = Bram2pWritePort(addressWidth = addressWidth, wordWidth = wordWidth)
  val rd = Bram2pReadPort(addressWidth = addressWidth, wordWidth = wordWidth)
  val clear_start = in Bool()
  val clear_done = out Bool()
}

class Bram2p(config :Bram2pConfig ) extends Component {

  import config._

  definitionName = s"Bram2p_${wordWidth}x${depth}"

  val addressWidth  = log2Up(depth)
  val io = Bram2pIo(addressWidth = addressWidth, wordWidth = wordWidth)

  noIoPrefix()

  // concise version.
  val clear_start_rise = io.clear_start.rise(False)
  val clear_busy = RegInit(False) setWhen(clear_start_rise)
  val clear_addr = Counter( depth, clear_busy )
  clear_busy.clearWhen(clear_addr.willOverflow)
  io.clear_done := clear_addr.willOverflow

// verbose version : clear logic with more explicit state management.
//  val clear_busy = RegInit(False)
//
//  val clear_addr = Counter( depth )
//
//  when ( clear_start_rise && !clear_busy ) {
//    clear_busy := True
//    clear_addr.clear()
//  } elsewhen ( clear_busy ) {
//    clear_addr.increment()
//    when ( clear_addr.willOverflow ) {
//      clear_busy := False
//    }
//  }
//  io.clear_done := clear_addr.willOverflow

  // Instantiate the memory
  val memory = Mem(Bits(wordWidth bits), depth)
  memory.addAttribute("ram_style", "block")
  memory.initBigInt(initContent)

  // Create the write port and associate it with the writeClockDomain
  val wr_addr = Mux(clear_busy ,clear_addr.value  , io.wr.addr)
  val wr_data = Mux(clear_busy , B(default_value, wordWidth bits) , io.wr.data )
  val wr_en   =  clear_busy || io.wr.en

  memory.write(
      address = wr_addr ,
      data    = wr_data,
      enable  = wr_en
      // mask is optional for byte/bit enables
  )

  io.rd.data.valid := RegNext(io.rd.en, init = False)
  io.rd.data.payload := memory.readSync(
    address = io.rd.addr,
    enable = io.rd.en
  )


  val external_write_during_clear = clear_busy && io.wr.en
  external_write_during_clear.setName("external_write_during_clear")

  assert(
    !external_write_during_clear,
    "Bram2p: external write requested while clear is active",
    severity = FAILURE
  )

  // ── Pattern 1: private nested BlackBox class ──────────────────────────────
  private class WriteWhileClearAssert extends BlackBox {
    val io = new Bundle {
      val clk      = in Bool()
      val rst      = in Bool()
      val vld      = in Bool()   // external_write_during_clear
    }
    noIoPrefix()
    mapCurrentClockDomain(clock = io.clk, reset = io.rst)

    setInlineVerilog(
      s"""module WriteWhileClearAssert
         |(
         |  input wire clk,
         |  input wire rst,
         |  input wire vld
         |);
         |`ifdef SIM
         |  // SVA: vld must never be high
         |  chk_no_write_during_clear : assert property (
         |    @(posedge clk) disable iff (rst)
         |    !vld
         |  ) else $$error("Bram2p: external write requested while clear is active");
         |`endif
         |endmodule
         |""".stripMargin
    )
  }

  // ── Pattern 2: companion object holds factory, keeps it out of public API ──
  object WriteWhileClearAssert {
    def apply(vld: Bool): Unit = {
      val bb = new WriteWhileClearAssert
      bb.io.vld := vld
    }
  }

  // Instantiate — single call, no leakage outside Bram2p
  WriteWhileClearAssert(external_write_during_clear)

}

object Bram2pMain{
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
      gen = new Bram2p( fbConfig )
    )
  }
}