package SSC.vga_display


import spinal.core._
import spinal.lib.graphic._
import spinal.lib.graphic.vga._
import spinal.lib.{BufferCC, Counter, Delay, Flow, LatencyAnalysis, master}
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


case class VgaDisplayConfig(
                             xWidth : Int = 640,
                             yWidth : Int = 480
                           ) {

  val xBitsWidth: Int = log2Up(xWidth)
  val yBitsWidth: Int = log2Up(yWidth)
  val timingsWidth = xBitsWidth max yBitsWidth

  val COLOR_NUM = 16
  val COLOR_WIDTH = 4
  val IDX_W= log2Up(COLOR_NUM)
  //val FB_SCALE = 1 << 1
  val FB_SCALE = 1 << 2

  val FB_WIDTH = xWidth / FB_SCALE
  val FB_HEIGHT = yWidth / FB_SCALE
  val FB_PIXELS = FB_WIDTH * FB_HEIGHT
  val FB_ADDRWIDTH =  log2Up(FB_PIXELS)
  val FB_WORDWIDTH = log2Up(COLOR_NUM)
  val FB_X_ADDRWIDTH = log2Up(FB_WIDTH)
  val FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT)

  val rgbConfig = RgbConfig(4, 4, 4)

  val fbConfig = Bram2pConfig(
    wordWidth = FB_WORDWIDTH,
    depth = FB_PIXELS,
    initFileName = "design/res/david.mem",
    //initFileName = "",
    default_value = 15
  )

  val racingBeamConfig = RacingBeamConfig(
    pattern = 0,
    V_WIDTH = yWidth,
    H_WIDTH = xWidth,
    COLOR_NUM = COLOR_NUM,
    LINE_NUM = 2,
    BAR_COLOR_INIT = 0x126
  )

  val drawCharEngConfig = DrawCharEngConfig(
    CHAR_PIXEL_WIDTH = 8,
    CHAR_PIXEL_HEIGHT = 16,
    IDX_W = IDX_W,
    FB_X_ADDRWIDTH = FB_X_ADDRWIDTH,
    FB_Y_ADDRWIDTH = FB_Y_ADDRWIDTH,
    bg_color_idx = 2
  )


  val spriteConfig = SpriteConfig(
    SPR_NAME = "hedgehog",
    SPR_BITS_W = 4,
    SPR_SCALE = 2,
    X_OFFSET = 3,
    xBitsWidth = xBitsWidth,
    yBitsWidth = yBitsWidth
  )


  val lbcpConfig = ColorPalettesConfig(
    COLOR_NUM = COLOR_NUM,
    COLOR_W = 12,
    Palettes_name = "Sepia",
    bg_color_idx = 2
  )

  val cpConfig = ColorPalettesConfig(
    COLOR_NUM = COLOR_NUM,
    COLOR_W = 12,
    Palettes_name = "Teleport",
    bg_color_idx = 2
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

}

class vga_display( config :  VgaDisplayConfig  ) extends Component {

  import config._
  import utils.RgbPrefs._

  val io = new Bundle{
    val vga       = master(Vga(rgbConfig, withColorEn = true ))
    val softRest  = in Bool() default(True)
    val core_clk = in Bool()
    val core_rst = in Bool()
    val vga_clk = in Bool()
    val vga_rst = in Bool()
    val draw_char_start = in Bool()
    val draw_char_word  = in UInt(7 bit)
    val draw_char_scale = in UInt(3 bits)
    val draw_char_color = in UInt(IDX_W bits)
    val draw_x_orig  = in UInt(FB_X_ADDRWIDTH bits)
    val draw_y_orig  = in UInt(FB_Y_ADDRWIDTH bits)
    val draw_done = out Bool()
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

    //-------------------------------------------------------
    //    Installation
    //-------------------------------------------------------


    val fb = new bram_2p( fbConfig )
    val draw_char_engine = new draw_char_engine(drawCharEngConfig)
    val fb_addr_gen_inst = new fb_addr_gen(fbAddrGenConfig)

    //-------------------------------------------------------
    //    Connectivity
    //-------------------------------------------------------
    draw_char_engine.io.start := io.draw_char_start
    //draw_char_engine.io.word := U"7'h41"
    draw_char_engine.io.word := io.draw_char_word
    draw_char_engine.io.scale := io.draw_char_scale
    draw_char_engine.io.color := io.draw_char_color

    fb_addr_gen_inst.io.x := io.draw_x_orig
    fb_addr_gen_inst.io.y := io.draw_y_orig
    fb_addr_gen_inst.io.start :=  io.draw_char_start
    fb_addr_gen_inst.io.h_cnt := draw_char_engine.io.h_cnt
    fb_addr_gen_inst.io.v_cnt := draw_char_engine.io.v_cnt


    fb.io.wr.en := draw_char_engine.io.out_valid
    fb.io.wr.addr := fb_addr_gen_inst.io.out_addr
    fb.io.wr.data := draw_char_engine.io.out_color.asBits

    io.draw_done := RegNext( draw_char_engine.io.done , init=False )

  }



  val vga = new ClockingArea(vgaClockDomain) {

    val vga_sync = vga_sync_gen(rgbConfig, timingsWidth = timingsWidth + 1)
    val rb = new racing_beam(rgbConfig, racingBeamConfig)
    val sp = new sprite(spriteConfig)
    val cp = new color_palettes(cpConfig)
    val ascii = new char_tile(rgbConfig, charTileConfig)

    val lbcp = new color_palettes(lbcpConfig)

    val lb = new linebuffer(
      Bits(FB_WORDWIDTH bit),
      FB_WIDTH,
      FB_SCALE,
      coreClockDomain,
      ClockDomain.current
    )

    //vga_sync.io.timings.setAs_h640_v480_r60

    rb.io.x := vga_sync.io.x
    rb.io.y := vga_sync.io.y.resize(yBitsWidth)
    rb.io.color_en := vga_sync.io.colorEn
    rb.io.sof := vga_sync.io.sof


    sp.io.x := vga_sync.io.x
    sp.io.y := vga_sync.io.y.resize(yBitsWidth)
    sp.io.sx_orig := U(10)
    sp.io.sy_orig := U(20)
    sp.io.sol := vga_sync.io.sol

    cp.io.rd_en := sp.io.pix.valid
    cp.io.addr := sp.io.pix.payload


    ascii.io.x := vga_sync.io.x
    ascii.io.y := vga_sync.io.y.resize(yBitsWidth)
    ascii.io.sx_orig := U(336)
    ascii.io.sy_orig := U(128)
    ascii.io.sol := vga_sync.io.sol


    val lb_orig_x = 10
    val lb_orig_y = 200



    val lb_row_valid = Reg( Bool() ) init False

    val fb_scale_cnt = Counter(stateCount = (FB_SCALE), lb_row_valid && vga_sync.io.colorEn.fall(False) )

    val lb_load_valid = ( fb_scale_cnt === U(0)  ) && lb_row_valid

    when ( ( vga_sync.io.y >= U(lb_orig_y) ) &&
      vga_sync.io.y < U(lb_orig_y + FB_HEIGHT * FB_SCALE )  )  {
      lb_row_valid := True
    } .otherwise {
      lb_row_valid := False
    }


    val lb_rd_start = RegNext( vga_sync.io.colorEn && ( vga_sync.io.x === U(lb_orig_x) )  && lb_row_valid, False )

    lb.io.rd_start := lb_rd_start
    lbcp.io.rd_en := lb.io.rd_out.valid
    lbcp.io.addr := lb.io.rd_out.payload.asUInt


    val delayNumViaRb = rb.delay_num
    val delayNumViaSp = sp.delay_num + cp.delay_num
    val delayNumViaAscii = ascii.delay_num

    val delayNum = List[Int](delayNumViaRb, delayNumViaSp, delayNumViaAscii).max


    io.vga.hSync := Delay(vga_sync.io.hSync, delayNum)
    io.vga.vSync := Delay(vga_sync.io.vSync, delayNum)
    io.vga.colorEn := Delay(vga_sync.io.colorEn, delayNum)

    val sp_color = if ((delayNum - delayNumViaSp) > 0) Delay(cp.io.color, delayNum - delayNumViaSp) else cp.io.color
    val rb_color = if ((delayNum - delayNumViaRb) > 0) Delay(rb.io.color, delayNum - delayNumViaRb) else rb.io.color
    val ascii_color = if ((delayNum - delayNumViaAscii) > 0) Delay(ascii.io.color, delayNumViaAscii) else ascii.io.color
    val lb_color = lbcp.io.color

/*
    when { sp_color.valid } {
      io.vga.color <= sp_color.payload
    }.elsewhen { ascii_color.valid } {
      io.vga.color := ascii_color.payload
    }.elsewhen {  lb_color.valid  }  {
      io.vga.color <= lb_color.payload
    }.otherwise {
      io.vga.color := rb_color.payload
    }
*/
    when { lb_color.valid  }  {
      io.vga.color <= lb_color.payload
    }.elsewhen { ascii_color.valid } {
      io.vga.color := ascii_color.payload
    } .elsewhen { sp_color.valid } {
      io.vga.color <= sp_color.payload
    }.otherwise {
      io.vga.color := rb_color.payload
    }


    val pixel_debug = Flow(Rgb(rgbConfig))
    pixel_debug.valid := io.vga.colorEn
    pixel_debug.payload := io.vga.color


    vga_sync.io.softReset := io.softRest

    val delayNumExpected = LatencyAnalysis(vga_sync.io.colorEn, io.vga.colorEn)
    println(f"[INFO] vga_sync.io.colorEn -> io.vga.colorEn  = ${delayNumExpected} ( Expected ) / ${delayNum} ( Calc ) ")


    // Below is 1024x768@70 HZ
    // Pixel freq : 75 MHz
    // Screen refresh 70 Hz

    /*
  ctrl.io.timings.setAs(
    hPixels = 1024,
    hSync = 136,
    hFront = 24,
    hBack = 144,
    hPolarity = false,
    vPixels = 768,
    vSync = 6,
    vFront = 3,
    vBack = 29,
    vPolarity = false
  )

*/

  }.setName("")


  val dma = new ClockingArea(coreClockDomain ) {


    val sol = BufferCC(vga.vga_sync.io.sol)
    val sof = BufferCC(vga.vga_sync.io.sof)
    val row_valid = BufferCC(vga.lb_load_valid )

    val fb_fetch_en = Reg(Bool()) init(False)

    val fb_fetch_en_cnt = Counter(stateCount = FB_WIDTH,fb_fetch_en)
    val fb_fetch_addr = Counter(stateCount = FB_PIXELS, fb_fetch_en )


    when ( row_valid ) {
      when(sol) {
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

    val lb_wr = Flow(Bits(FB_WORDWIDTH bit))
    lb_wr.valid := RegNext(fb_fetch_en, False)
    lb_wr.payload := core.fb.io.rd.data

    core.fb.io.rd.en := fb_fetch_en
    core.fb.io.rd.addr := fb_fetch_addr

    lb_wr >> vga.lb.io.wr_in
  }


}


object vgaDisplayMain{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SSC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new vga_display(VgaDisplayConfig())
    )
  }
}
