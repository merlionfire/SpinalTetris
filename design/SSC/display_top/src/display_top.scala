package SSC.display_top


import config._

import spinal.core._
import spinal.lib._
import spinal.lib.graphic.vga._
import spinal.lib.graphic._
import spinal.lib.{BufferCC, Counter, Delay, Flow, LatencyAnalysis, master}
import spinal.lib.fsm.{State, StateFsm, StateMachine}
import utils.PathUtils


//------------ IPs --------------//
import IPS.vga_sync_gen._
import IPS.racing_beam._
import IPS.sprite._
import IPS.color_palettes._
import IPS.char_tile._
import IPS.draw_char_engine._
import IPS.linebuffer._
import IPS.bram_2p._
import IPS.fb_addr_gen._
import IPS.draw_block_engine._
import IPS.string_draw_engine._
import IPS.piece_draw_engine._

case class DisplayTopConfig(
                             xWidth : Int = 640,
                             yWidth : Int = 480
                           ) {

  val xBitsWidth: Int = log2Up(xWidth)
  val yBitsWidth: Int = log2Up(yWidth)
  val timingsWidth = xBitsWidth max yBitsWidth

  val COLOR_NUM = 16
  val COLOR_WIDTH = 4
  val IDX_W= log2Up(COLOR_NUM)
  val FB_SCALE = 1 << 1

  val FB_WIDTH = xWidth / FB_SCALE
  val FB_HEIGHT = yWidth / FB_SCALE
  val FB_PIXELS = FB_WIDTH * FB_HEIGHT
  val FB_ADDRWIDTH =  log2Up(FB_PIXELS)
  val FB_WORDWIDTH = log2Up(COLOR_NUM)
  val FB_X_ADDRWIDTH = log2Up(FB_WIDTH)
  val FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT)

  val BG_COLOR_IDX = 2

  val BACKGROUND_COLOR : Int = 0x137

  val pfConfig = TetrisPlayFeildConfig(
    block_len = 9,
    wall_width = 9,
    x_orig = 50,
    y_orig = 20,
    piece_ft_color = 9,
    piece_bg_color = 2
  )


  val rgbConfig = RgbConfig(4, 4, 4)

  val fbConfig = Bram2pConfig(
    wordWidth = FB_WORDWIDTH,
    depth = FB_PIXELS,
    //initFileName = "design/res/david.mem",
    initFileName = "",
    default_value = BG_COLOR_IDX
  )

  val drawCharEngConfig = DrawCharEngConfig(
    CHAR_PIXEL_WIDTH = 8,
    CHAR_PIXEL_HEIGHT = 16,
    IDX_W = IDX_W,
    FB_X_ADDRWIDTH = FB_X_ADDRWIDTH,
    FB_Y_ADDRWIDTH = FB_Y_ADDRWIDTH,
    bg_color_idx = BG_COLOR_IDX
  )

  val drawBlockEngConfig = DrawBlockEngConfig(
    IDX_W = IDX_W,
    FB_X_ADDRWIDTH = FB_X_ADDRWIDTH,
    FB_Y_ADDRWIDTH = FB_Y_ADDRWIDTH,
  )

  val cpConfig = ColorPalettesConfig(
    COLOR_NUM = COLOR_NUM,
    COLOR_W = 12,
    Palettes_name =  "Teleport",
    bg_color_idx = BG_COLOR_IDX
  )

  val charTileConfig = CharTileConfig(
    CHAR_NUM = 128,
    CHAR_PIXEL_WIDTH = 8,
    CHAR_PIXEL_HEIGHT = 16,
    xBitsWidth = xBitsWidth,
    yBitsWidth = yBitsWidth
  )

  val fbAddrGenConfig = FbAddrGenConfig(
    FB_WIDTH = FB_WIDTH,
    FB_X_ADDRWIDTH = FB_X_ADDRWIDTH,
    FB_Y_ADDRWIDTH = FB_Y_ADDRWIDTH,
    FB_ADDRWIDTH = FB_ADDRWIDTH
  )


  val stringDrawEngConfig = StringDrawEngConfig(
    FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
    FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
    IDX_W = 4,
    bg_color_idx = BG_COLOR_IDX,
    playFieldConfig = pfConfig
  )

  val pieceDrawEngConfig = PieceDrawEngConfig(
    FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
    FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
    IDX_W = 4,
    playFieldConfig = pfConfig
  )
}


class display_top ( config :  DisplayTopConfig, test : Boolean = false ) extends Component {

  import config._
  import utils.RgbPrefs._

  val io = new Bundle{
    val vga       = master(Vga(rgbConfig, withColorEn = true ))
    val softRest  = in Bool() default(True)
    val core_clk = in Bool()
    val core_rst = in Bool()
    val vga_clk = in Bool()
    val vga_rst = in Bool()
    val row_val =  slave Flow( Bits(colBlocksNum bits) )
    /*
    val draw_char_word = in UInt(7 bit)
    val draw_char_scale = in UInt( 3 bits)
    val draw_char_color = in UInt (IDX_W bits)
    val start_block_draw = in Bool()
    val draw_x_orig = in UInt(FB_X_ADDRWIDTH bits )
    val draw_y_orig = in UInt(FB_Y_ADDRWIDTH bits )
    val draw_block_width = in UInt (8 bits)
    val draw_block_height = in UInt (8 bits)
    val draw_block_color = in UInt (IDX_W bits)
    val draw_block_pat_color = in UInt (IDX_W bits)
    val draw_block_fill_pattern = in UInt( 2 bits)
    */
    //val draw_openning_start   = if (test)  null else in Bool()
    val game_start            = if (test)  null else in Bool()
    val draw_char_start       = if (test)  in Bool()  else null
    val draw_char_word        = if (test)  in UInt(7 bit) else null
    val draw_char_scale       = if (test) in UInt(3 bits) else null
    val draw_char_color       = if (test) in UInt(IDX_W bits) else null
    val draw_block_start      = if (test) in Bool() else null
    val draw_x_orig           = if (test) in UInt(FB_X_ADDRWIDTH bits) else null
    val draw_y_orig           = if (test) in UInt(FB_Y_ADDRWIDTH bits) else null
    val draw_block_width      = if (test) in UInt(8 bits) else null
    val draw_block_height     = if (test) in UInt(8 bits) else null
    val draw_block_color      = if (test) in UInt(IDX_W bits) else null
    val draw_block_pat_color  = if (test) in UInt(IDX_W bits) else null
    val draw_block_fill_pattern = if (test) in UInt(2 bits) else null
    val draw_done = out Bool()
    val draw_field_done = out Bool()
    val screen_is_ready = out Bool()
    val sof = out Bool()
  }

  noIoPrefix()


  val vgaClockDomain = ClockDomain(
    clock = io.vga_clk,
    reset = io.vga_rst,
    frequency = FixedFrequency( 25 MHz)
  )

  val coreClockDomain = ClockDomain (
    clock = io.core_clk,
    reset = io.core_rst
  )


  val core = new ClockingArea(coreClockDomain) {

    // Sync-write and Sync-read
    val fb = new bram_2p(fbConfig)

    val draw_char_engine = new draw_char_engine(drawCharEngConfig)

    val draw_block_engine = new draw_block_engine(drawBlockEngConfig )

    val piece_draw_gen = new piece_draw_engine(pieceDrawEngConfig)

    val fb_addr_gen_inst = new fb_addr_gen(fbAddrGenConfig)

    val draw_fsm_inst = new string_draw_engine( stringDrawEngConfig )


    val _draw_char_start  = Option(io.draw_char_start) getOrElse draw_fsm_inst.io.draw_char_start
    val _draw_char_word   = Option(io.draw_char_word) getOrElse  draw_fsm_inst.io.draw_char_word
    val _draw_char_scale  = Option(io.draw_char_scale) getOrElse  draw_fsm_inst.io.draw_char_scale
    val _draw_char_color  = Option(io.draw_char_color) getOrElse  draw_fsm_inst.io.draw_char_color
    val _draw_block_start = Option(io.draw_block_start) getOrElse draw_fsm_inst.io.draw_block_start
    val _draw_x_orig      = Option(io.draw_x_orig) getOrElse draw_fsm_inst.io.draw_x_orig
    val _draw_y_orig      = Option(io.draw_y_orig) getOrElse draw_fsm_inst.io.draw_y_orig
    val _draw_block_width = Option(io.draw_block_width) getOrElse draw_fsm_inst.io.draw_block_width
    val _draw_block_height = Option(io.draw_block_height) getOrElse draw_fsm_inst.io.draw_block_height
    val _draw_block_color = Option(io.draw_block_color) getOrElse draw_fsm_inst.io.draw_block_color
    val _draw_block_pat_color = Option(io.draw_block_pat_color) getOrElse draw_fsm_inst.io.draw_block_pat_color
    val _draw_block_fill_pattern = Option(io.draw_block_fill_pattern) getOrElse draw_fsm_inst.io.draw_block_fill_pattern
    //draw_fsm_inst.io.draw_openning_start := io.draw_openning_start
    draw_fsm_inst.io.game_start := Option(io.game_start) getOrElse False
    draw_fsm_inst.io.draw_done  := io.draw_done


    draw_char_engine.io.start := _draw_char_start
    draw_char_engine.io.word  := _draw_char_word
    draw_char_engine.io.scale := _draw_char_scale
    draw_char_engine.io.color := _draw_char_color


    draw_block_engine.io.start    := _draw_block_start || piece_draw_gen.io.start_draw
    draw_block_engine.io.width    := piece_draw_gen.io.start_draw ? piece_draw_gen.io.length | _draw_block_width
    draw_block_engine.io.height   := piece_draw_gen.io.start_draw ? piece_draw_gen.io.length | _draw_block_height
    draw_block_engine.io.in_color := piece_draw_gen.io.start_draw ? piece_draw_gen.io.ft_color | _draw_block_color
    draw_block_engine.io.pat_color := _draw_block_pat_color
    draw_block_engine.io.fill_pattern := piece_draw_gen.io.start_draw ? piece_draw_gen.io.fill_pattern | _draw_block_fill_pattern

    // piece_draw_engine interface
    piece_draw_gen.io.row_val := io.row_val
    piece_draw_gen.io.draw_done := draw_block_engine.io.done
    io.draw_field_done := piece_draw_gen.io.gen_done


    val mux_sel =  draw_char_engine.io.is_running ## draw_block_engine.io.is_running
    fb_addr_gen_inst.io.x := _draw_x_orig | piece_draw_gen.io.draw_x_orig
    fb_addr_gen_inst.io.y := _draw_y_orig | piece_draw_gen.io.draw_y_orig
    fb_addr_gen_inst.io.start :=  _draw_char_start || _draw_block_start || piece_draw_gen.io.start_draw



    fb_addr_gen_inst.io.h_cnt := mux_sel.mux(
      B"01" -> draw_block_engine.io.h_cnt,
      B"10" -> draw_char_engine.io.h_cnt,
      default -> U(0,FB_X_ADDRWIDTH bits)
    )

    fb_addr_gen_inst.io.v_cnt  := mux_sel.mux(
      1 -> draw_block_engine.io.v_cnt,
      2 -> draw_char_engine.io.v_cnt,
      default -> U(0,FB_Y_ADDRWIDTH bits)
    )



    fb.io.wr.en := draw_char_engine.io.out_valid || draw_block_engine.io.out_valid
    fb.io.wr.addr := fb_addr_gen_inst.io.out_addr

    when ( draw_char_engine.io.out_valid ) {
      fb.io.wr.data := draw_char_engine.io.out_color.asBits
    } .otherwise {
      fb.io.wr.data := draw_block_engine.io.out_color.asBits
    }

    io.draw_done := RegNext( (draw_char_engine.io.done ||  draw_block_engine.io.done), init=False )
    io.screen_is_ready := draw_fsm_inst.io.screen_is_ready
  }

  val vga = new ClockingArea(vgaClockDomain) {

    val vga_sync = vga_sync_gen(rgbConfig, timingsWidth = timingsWidth + 1)

    val lbcp = new color_palettes(cpConfig)

    val lb = new linebuffer(
      Bits(FB_WORDWIDTH bit),
      FB_WIDTH,
      FB_SCALE,
      coreClockDomain,
      ClockDomain.current
    )


    val lb_orig_x = 0
    val lb_orig_y = 0

    val fb_scale_cnt = Counter(stateCount = (FB_SCALE), vga_sync.io.colorEn.fall(False) )

    val lb_load_valid = ( fb_scale_cnt === U(0) )  && vga_sync.io.vColorEn

    // Initiate line buffer readout
    lb.io.rd_start :=  vga_sync.io.sol

    // write to linebuffer colorP interface
    lbcp.io.rd_en := lb.io.rd_out.valid
    lbcp.io.addr := lb.io.rd_out.payload.asUInt


    // linebuffer ColorP readout
    val lb_color = lbcp.io.color

    val delayNum = lb.delay_num + lbcp.delay_num


    io.vga.hSync := Delay(vga_sync.io.hSync, delayNum)
    io.vga.vSync := Delay(vga_sync.io.vSync, delayNum)
    io.vga.colorEn := Delay(vga_sync.io.colorEn, delayNum)


    /*
        when (  lb.io.rd_out.valid )   {
          io.vga.color <= lb_color.payload
        }.otherwise {
          io.vga.color <= 0
        }
    */
    val is_bg_color = RegNext(lb.io.rd_out.payload.asUInt === U(BG_COLOR_IDX), init=False)

    when (  lb_color.valid  )   {
      when ( is_bg_color ) {
        io.vga.color <= BACKGROUND_COLOR
      } otherwise  {
        io.vga.color <= lb_color.payload
      }
    }.otherwise {
      io.vga.color <= 0
    }

    val pixel_debug = Flow(Rgb(rgbConfig))
    pixel_debug.valid := io.vga.colorEn
    pixel_debug.payload := io.vga.color


    vga_sync.io.softReset := io.softRest

    val delayNumExpected = LatencyAnalysis(vga_sync.io.colorEn, io.vga.colorEn)
    println(f"[INFO] vga_sync.io.colorEn -> io.vga.colorEn  = ${delayNumExpected} ( Expected ) / ${delayNum} ( Calc ) ")


  }.setName("")


  val dma = new ClockingArea(coreClockDomain ) {


    val sos = BufferCC(vga.vga_sync.io.sos, False).rise(False)
    val sof = BufferCC(vga.vga_sync.io.sof, False)
    val row_valid = BufferCC(vga.lb_load_valid, False )

    // Frame buffer <-> Line buffer

    // 1. Read from frameBuffer interface
    val fb_fetch_en = Reg(Bool()) init(False)

    val fb_fetch_en_cnt = Counter(stateCount = FB_WIDTH,fb_fetch_en)
    val fb_fetch_addr = Counter(stateCount = FB_PIXELS, fb_fetch_en )


    when ( row_valid ) {
      when(sos) {
        fb_fetch_en := True
      }

      when(fb_fetch_en_cnt.willOverflowIfInc) {
        fb_fetch_en := False
        fb_fetch_en_cnt.clear()
      }
    }

    when ( sof ) {
      fb_fetch_addr.clear()
    }

    core.fb.io.rd.en := fb_fetch_en
    core.fb.io.rd.addr := fb_fetch_addr

    // 2. Write to Line buffer interface
    val lb_wr = Flow(Bits(FB_WORDWIDTH bit))
    lb_wr.valid := RegNext(fb_fetch_en, False)
    lb_wr.payload := core.fb.io.rd.data
    vga.lb.io.wr_in << lb_wr

    // 3. Start to draw opening figure
    core.draw_fsm_inst.io.draw_openning_start := sof
  }

  io.sof := dma.sof


}



object displayTopMain{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SSC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new display_top( DisplayTopConfig(),false)
    )
  }
}

