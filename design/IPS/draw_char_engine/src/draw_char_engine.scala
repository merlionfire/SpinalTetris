package IPS.draw_char_engine


import spinal.core._
import spinal.lib.{Counter, Delay}
import IPS.ascii_font16x8._
import utils._

case class DrawCharEngConfig (
                               CHAR_PIXEL_WIDTH : Int = 8,
                               CHAR_PIXEL_HEIGHT : Int = 16,
                               IDX_W : Int = 4,
                               FB_X_ADDRWIDTH : Int,
                               FB_Y_ADDRWIDTH : Int,
                               bg_color_idx : Int = 2
                             )

class draw_char_engine ( config : DrawCharEngConfig ) extends Component {
  import config._

  val io = new Bundle {
    val start = in Bool()
    val word = in UInt (7 bits)
    val color = in UInt (IDX_W bits)
    val scale = in UInt( 3 bits)  // x1 : 0, x2 : 1, x3 : 2, x4:3, x5:4,
    val h_cnt = out UInt (FB_X_ADDRWIDTH bits)
    val v_cnt = out UInt (FB_Y_ADDRWIDTH bits)
    val is_running = out Bool()
    val out_valid = out Bool()
    val out_color = out UInt (IDX_W bits)
    val done = out Bool()
  }

  noIoPrefix()

  val char_pix_rom = new ascii_font16x8().setName("ascii_font16X8_inst")


  // Stage 1
  val word_reg = RegNextWhen(io.word, io.start) init (0)
  val scale_reg = RegNextWhen(io.scale, io.start) init (0)
  val color_reg = RegNextWhen(io.color, io.start) init (0)


  val rom_rd_en = RegInit(False)

  val x_scale_cnt = Counter2(  scale_reg, rom_rd_en)


  //val h_cnt = Counter(stateCount = CHAR_PIXEL_WIDTH, rom_rd_en)

  val x_cnt = Counter(stateCount = CHAR_PIXEL_WIDTH, x_scale_cnt.willOverflow)

  //val v_cnt = Counter(stateCount = CHAR_PIXEL_HEIGHT, h_cnt.willOverflowIfInc)

  val x_last_cycle = x_cnt.willOverflow & x_scale_cnt.willOverflow

  val y_scale_cnt = Counter2(  scale_reg, x_last_cycle  )

  val y_cnt = Counter(stateCount = CHAR_PIXEL_HEIGHT, y_scale_cnt.willOverflow && x_last_cycle )

  val y_last_cycle = y_cnt.willOverflowIfInc & y_scale_cnt.willOverflow

  val cnt_last = x_last_cycle && y_last_cycle

  when(io.start) {
    rom_rd_en := True
  }.elsewhen(cnt_last ) {
    rom_rd_en := False
  }

  char_pix_rom.io.font_bitmap_addr := ( word_reg ## y_cnt ) .asUInt


  val h_cnt = RegInit(U(0,FB_X_ADDRWIDTH bit) )
  when ( rom_rd_en )   {
    when (x_last_cycle ) {
      h_cnt := U(0)
    } otherwise {
      h_cnt := h_cnt + 1
    }
  }



  val v_cnt = RegInit(U(0,FB_Y_ADDRWIDTH bit) )
  when ( rom_rd_en )   {
    when (y_last_cycle ) {
      v_cnt := U(0)
    } elsewhen ( x_last_cycle ) {
      v_cnt := v_cnt + 1
    }
  }


  // Stage 2
  val char_color = Reg(UInt(IDX_W bits)) init (0)

  val pix_idx = RegNext(x_cnt.value) init (0)

  when(char_pix_rom.io.font_bitmap_byte.reversed(pix_idx)) {
    char_color := Delay(color_reg,1)
  } otherwise {
    char_color := bg_color_idx
  }

  // Stage 3

  io.out_color := char_color
  io.out_valid := Delay(rom_rd_en, 2, init = False)
  io.done := rom_rd_en.fall()

  io.h_cnt := h_cnt
  io.v_cnt := v_cnt
  io.is_running := rom_rd_en
}




object drawCharEngMain{

  def main(args: Array[String]) {
    val FB_WIDTH = 160
    val FB_HEIGHT  = 120
    val config = DrawCharEngConfig(
      FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
      FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT)
    )

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new draw_char_engine(config)
    )
  }
}


