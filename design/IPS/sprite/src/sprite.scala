package IPS.sprite

import spinal.core._
import spinal.lib.{Counter, Delay, LatencyAnalysis, master}
import spinal.lib.fsm._
import utils.PathUtils


case class SpriteConfig (
  //val SPR_NAME   = "hourglass"
  SPR_NAME : String = "hedgehog",
  SPR_BITS_W : Int  = 4,
  SPR_SCALE : Int   = 2,
  X_OFFSET : Int    = 3,
  xBitsWidth : Int,
  yBitsWidth : Int
) {

  // Parameters preparation

  val spritePattern = Map(
    "hourglass" ->
      """| 0 0 0 0 0 0 0 0
         | F 1 1 1 1 1 1 F
         | F F 2 2 2 2 F F
         | F F F 3 3 F F F
         | F F F 4 4 F F F
         | F F 5 5 5 5 F F
         | F 6 6 6 6 6 6 F
         | 7 7 7 7 7 7 7 7""",
    "hedgehog" ->
      """|9 9 9 9 9 9 9 9 9 9 9 9 8 9 9 9 8 9 9 9 8 9 9 9 9 9 9 9 9 9 9 9
         |9 9 9 9 9 9 9 9 9 9 9 8 6 8 9 8 6 8 9 9 8 9 9 9 8 9 9 9 9 9 9 9
         |9 9 9 9 9 9 9 9 8 8 9 8 6 8 9 8 6 8 9 8 6 8 9 8 6 8 9 9 9 9 9 9
         |9 9 9 9 9 9 9 9 8 6 8 9 8 6 8 8 3 8 9 8 3 8 9 5 6 8 9 9 8 8 9 9
         |9 9 9 9 9 9 9 9 8 6 8 8 8 4 6 8 3 8 8 8 3 8 7 4 8 9 9 8 6 8 9 9
         |9 9 9 9 9 8 8 8 9 8 6 8 8 4 4 8 8 8 8 8 8 8 4 5 8 9 8 6 4 8 9 9
         |9 9 9 9 9 9 8 8 8 8 3 6 8 8 4 8 8 6 6 8 6 6 6 8 8 8 6 4 8 9 9 9
         |9 9 9 9 8 8 8 8 8 8 6 3 8 8 6 6 8 6 3 8 6 3 6 8 6 8 4 8 9 9 9 9
         |9 9 9 8 0 8 0 0 2 8 8 8 8 8 7 7 7 7 7 7 7 8 8 6 4 6 8 8 9 8 9 9
         |9 9 9 8 8 8 8 2 0 2 8 8 7 8 7 7 6 6 7 7 7 7 7 8 8 8 8 8 8 5 8 9
         |9 9 9 8 8 8 8 8 0 0 8 7 7 8 7 7 3 6 7 7 3 7 7 7 6 6 5 5 4 8 9 9
         |9 9 8 8 8 8 8 8 0 0 7 7 7 7 8 7 7 7 6 6 6 6 6 4 4 6 6 7 7 8 9 9
         |9 8 8 5 8 2 8 2 0 2 7 6 6 7 7 8 8 8 8 7 7 7 7 7 7 7 7 7 7 8 9 9
         |8 1 8 8 7 8 0 0 2 8 7 5 5 5 6 6 7 7 7 8 8 8 8 7 7 6 6 6 6 8 9 9
         |8 8 8 8 4 7 8 8 8 7 7 5 5 5 4 4 4 4 5 5 5 6 7 8 8 6 6 6 7 8 9 9
         |8 5 4 4 4 4 4 5 5 5 6 5 5 5 4 4 4 4 4 5 5 6 6 7 8 7 7 7 7 8 9 9
         |9 8 5 4 4 4 4 4 6 6 6 6 5 5 5 5 4 5 5 5 6 7 6 6 6 8 7 7 8 9 9 9
         |9 9 8 8 8 8 8 8 5 5 5 6 6 8 7 6 5 5 6 7 8 5 5 5 5 8 8 8 9 9 9 9
         |9 9 9 9 9 9 9 8 8 5 3 5 5 8 8 8 8 8 8 8 8 5 5 3 7 8 8 9 9 9 9 9
         |9 9 9 9 9 9 9 8 8 8 3 3 5 8 9 9 9 9 9 9 8 5 3 3 8 8 8 9 9 9 9 9"""
  ).get(SPR_NAME).map { patternString =>
    val lines = patternString
      .stripMargin // This removes the leading | and any whitespace before it from each line of the multi-line string.
      .lines // splits the string into an iterator of lines based on newline characters */
      .filter(_.trim.nonEmpty) // Filters out any empty lines (after trimming leading/trailing whitespace)
      .toList
    val height = lines.length

    if (height > 0) {
      val content = lines.map(v => v.replaceAll("[\\s]+", " ").trim.split(" ").map(BigInt(_, 16)).toSeq) //
      (content.flatten, content(0).length, height ) // Merge all lines and retrieve the width of the 1st line
    } else {
      ( Seq[BigInt](), 0, 0 )
    }

  }

  val ( romInitContent, spr_width, spr_height) = spritePattern match {
    case Some( ( data, width, height )  ) if ( width > 0 )   => ( data, width, height )
    case _   => throw new IllegalArgumentException(f"The sprite '$SPR_NAME' does not have correct content structure.")
  }

  val spr_rom_depth = spr_width * spr_height

}

//****************************************************
// x,y -> -> pix  2 cycles delay
//    - ( x,y ) -> rom address
//    - rom address -> pixel
//****************************************************

class sprite  ( val config : SpriteConfig  )  extends Component {

  import config._

  val io = new Bundle {
    val x = in UInt (xBitsWidth bits)
    val y = in UInt (yBitsWidth bits)
    val sol = in Bool()
    val sx_orig = in UInt (xBitsWidth bits)
    val sy_orig = in UInt (yBitsWidth bits)
    val pix =  master Flow UInt( SPR_BITS_W bits )
  }

  noIoPrefix()

  // ROM
  val rom = Mem( Bits( SPR_BITS_W bits), spr_rom_depth  )
  rom.initBigInt( romInitContent )

  // Control Logic

  val y_diff = ( io.y.intoSInt - io.sy_orig.intoSInt )
  val y_diff_scale = y_diff >> SPR_SCALE
  val y_valid =  ( ~ y_diff.sign ) &&  (  y_diff_scale   < spr_height  )

  val sx_early_r = RegInit(U(0, xBitsWidth bits))

  val sop = io.x === sx_early_r

  val rom_addr_block = RegInit(U(0, log2Up(spr_rom_depth-1) bits) )
  val rom_addr = RegInit(U(0, log2Up(spr_rom_depth-1) bits) )

  val draw_running = Bool()


  val scale_cnt = Counter(stateCount = ( 1 << SPR_SCALE ) , draw_running )
  val x_cnt  = Counter(stateCount = spr_width, scale_cnt.willOverflowIfInc  )

  val fsm = new StateMachine {

    draw_running := False

    val IDLE = makeInstantEntry()
    IDLE.whenIsActive {
      when(io.sol) {
        goto(LINE_START)
      }
    }

    val LINE_START = new State {
      whenIsActive {
        when(y_valid) {
          sx_early_r := io.sx_orig - 1
          goto(WAIT_POS)
        }.otherwise {
          goto(IDLE)
        }
      }
    }

    val WAIT_POS = new State {
      whenIsActive {
        rom_addr_block := ( y_diff_scale.asUInt.resize( log2Up(spr_height)) * spr_width ).resized
        when(sop) {
          x_cnt.clear()
          scale_cnt.clear()
          goto(LINE_DRAW)
        }
      }
    }

    val LINE_DRAW = new State {
      whenIsActive {
        rom_addr := rom_addr_block + x_cnt
        draw_running := True
        when(x_cnt.willOverflowIfInc && scale_cnt.willOverflowIfInc ) {
          goto(LINE_END)
        }
      }
    }

    val LINE_END = new State {
      whenIsActive {
        goto(IDLE)
      }
    }
  }

  // Ouput Interface

  io.pix.valid := Delay(draw_running,2)
  io.pix.payload  := rom.readSync( rom_addr, True ).asUInt

  // Debug Information

  val delay_num = LatencyAnalysis(draw_running, io.pix.valid)
  println( "[INFO] draw_running -> io.pix.valid  = " + LatencyAnalysis(draw_running, io.pix.valid)  )

}


object spriteMain{
  def main(args: Array[String]) {

    val config =  SpriteConfig (
      SPR_NAME   = "hedgehog",
      SPR_BITS_W = 4,
      SPR_SCALE = 2,
      X_OFFSET = 3,
      xBitsWidth = log2Up(640),
      yBitsWidth = log2Up(480)
    )
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true,
      inlineRom = true
    ).generateVerilog(
      gen = new sprite(config)
    )
  }
}