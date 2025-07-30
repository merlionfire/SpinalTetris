package IPS.char_tile

import spinal.core._
import spinal.lib.graphic.{Rgb, RgbConfig}
import spinal.lib.{Counter, Delay, LatencyAnalysis, master}
import spinal.lib.fsm._
import IPS.ascii_font16x8._
import utils.PathUtils

case class CharTileConfig(
                           CHAR_NUM : Int = 128,
                           CHAR_PIXEL_WIDTH : Int = 8,
                           CHAR_PIXEL_HEIGHT : Int = 16,
                           xBitsWidth : Int = log2Up(640),
                           yBitsWidth : Int = log2Up(480)
                          ) {
  val CHAR_PIXEL_W_BITS = log2Up( CHAR_PIXEL_WIDTH  )
  val CHAR_PIXEL_H_BITS = log2Up( CHAR_PIXEL_HEIGHT  )
  val CHAR_TILES_DEPTH = CHAR_NUM * CHAR_PIXEL_HEIGHT
  val CHAR_TILES_ADDR_W = log2Up(CHAR_TILES_DEPTH)

}


class char_tile ( rgbConfig: RgbConfig, config : CharTileConfig ) extends Component {

  import utils.RgbPrefs._
  import config._

  val CHAR_NUM = 128
  val CHAR_PIXEL_WIDTH = 8
  val CHAR_PIXEL_HEIGHT = 16
  val CHAR_PIXEL_W_BITS = log2Up( CHAR_PIXEL_WIDTH  )
  val CHAR_PIXEL_H_BITS = log2Up( CHAR_PIXEL_HEIGHT  )
  val CHAR_TILES_DEPTH = CHAR_NUM * CHAR_PIXEL_HEIGHT
  val CHAR_TILES_ADDR_W = log2Up(CHAR_TILES_DEPTH)
  val COLOR_W = 12
  val CHAR_SCALE = 1
  val TABLE_WIDTH = 16
  val TABLE_HEIGHT = 8
  val TABLE_X_W = log2Up(TABLE_WIDTH + 1)
  val TABLE_y_W = log2Up(TABLE_HEIGHT + 1)

  val io = new Bundle {
    val x = in UInt (xBitsWidth bits)
    val y = in UInt (yBitsWidth bits)
    val sol = in Bool()
    val sx_orig = in UInt (xBitsWidth bits)
    val sy_orig = in UInt (yBitsWidth bits)
    val color_en = in Bool()
    val color = master Flow Rgb(rgbConfig)

  }

  noIoPrefix()


  val char_pix_rom = new ascii_font16x8().setName("ascii_font16X8_inst")


  // Control Logic

  val y_diff = (io.y.intoSInt - io.sy_orig.intoSInt)
  val y_diff_scale = y_diff >> CHAR_SCALE
  val y_valid = (~y_diff.sign) && (y_diff_scale < CHAR_PIXEL_HEIGHT * TABLE_HEIGHT)


  val sx_early_r = RegInit(U(0, xBitsWidth bits))
  val sop = io.x === sx_early_r


  val rom_addr_block = RegInit(U(0, 11 bits))
  val rom_addr = RegInit(U(0, 11 bits))

  val draw_running = Bool()

  val scale_cnt = Counter(stateCount = (1 << CHAR_SCALE), draw_running)

  val x_cnt = Counter(stateCount = CHAR_PIXEL_WIDTH * TABLE_WIDTH, scale_cnt.willOverflowIfInc)

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
        val y_offset = y_diff_scale.asUInt
        rom_addr_block := ( (y_offset >> CHAR_PIXEL_H_BITS ) * (CHAR_PIXEL_HEIGHT * TABLE_WIDTH) + y_offset( (CHAR_PIXEL_H_BITS-1) downto 0 ) ) .resized
        when(sop) {
          x_cnt.clear()
          scale_cnt.clear()
          goto(FETCG_PIXEL)
        }
      }

    }

    val FETCG_PIXEL = new State {
      whenIsActive {
        rom_addr := rom_addr_block + (x_cnt >> CHAR_PIXEL_W_BITS  ) * CHAR_PIXEL_HEIGHT
        draw_running := True
        when(x_cnt.willOverflowIfInc && scale_cnt.willOverflowIfInc) {
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


  val x_pixel_offset = Delay(x_cnt(2 downto 0), 2)

  char_pix_rom.io.font_bitmap_addr := rom_addr

  val color = Rgb(rgbConfig).setAsReg()

  when { char_pix_rom.io.font_bitmap_byte.reversed(x_pixel_offset) } {
    color <= 0xCCC
  }.otherwise {
    color <= 0x0CA
  }

  io.color.payload := color
  io.color.valid := Delay(draw_running, 3)

  val delay_num = LatencyAnalysis(draw_running, io.color.valid)
  println( "[INFO] draw_running -> io.color.valid  = " + delay_num  )


}


object charTileMain{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new char_tile(RgbConfig(4, 4, 4), CharTileConfig())
    )
  }
}