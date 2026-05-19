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
//import IPS.string_draw_engine._
//import IPS.piece_draw_engine._
import IPS.display_controller._

case class ScreenCropConfig(x: Int, y: Int, width: Int, height: Int)

case class DisplayTopConfig(
                             xWidth : Int = 640,
                             yWidth : Int = 480,
                             offset_x : Int = 0,
                             offset_y : Int = 0
                           ) {

  val xBitsWidth: Int = log2Up(xWidth)
  val yBitsWidth: Int = log2Up(yWidth)
  val timingsWidth = xBitsWidth max yBitsWidth

  val colorSystem = ColorSystemConfig(
    paletteName = "Teleport",
    colorNum = 16,
    colorW = 12
  )

  val COLOR_NUM = colorSystem.colorNum
  val COLOR_WIDTH = 4
  val IDX_W = colorSystem.idxW
  val FB_SCALE = 1 << 1

  val screenCrop = ScreenCropConfig(
    offset_x,
    offset_y,
    xWidth - 2 * offset_x, yWidth - 2 * offset_y
  )

  /*
  val FB_WIDTH = xWidth / FB_SCALE
  val FB_HEIGHT = yWidth / FB_SCALE
  */
  val FB_WIDTH = screenCrop.width / FB_SCALE
  val FB_HEIGHT = screenCrop.height / FB_SCALE

  val FB_PIXELS = FB_WIDTH * FB_HEIGHT
  val FB_ADDRWIDTH =  log2Up(FB_PIXELS)
  val FB_WORDWIDTH = IDX_W
  val FB_X_ADDRWIDTH = log2Up(FB_WIDTH)
  val FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT)

  val BG_COLOR_IDX = 2

  val BACKGROUND_COLOR : Int = 0x137

  val pfConfig = TetrisPlayFeildConfig(
    block_len = 9,
    wall_width = 9,
    x_orig = 50 - offset_x / FB_SCALE ,
    y_orig = 20 - offset_y / FB_SCALE,
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

  val cpConfig = ColorPalettesConfig(colorSystem)

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

  val displayControllerConfig = DisplayControllerConfig(
    FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
    FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
    IDX_W = IDX_W,
    bg_color_idx = BG_COLOR_IDX,
    playFieldConfig = pfConfig
  )

}


// Keep the legacy class name to avoid changing the generated top-level RTL module name.
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
    val score_val = slave Flow (UInt( config.displayControllerConfig.scoreBitsWidth bits))
    val game_start            = in Bool()
    val game_restart          = in Bool()

    val debug = if (test) new Bundle {
      val draw_char_start = in Bool()
      val draw_char_word =  in UInt (7 bit)
      val draw_char_scale = in UInt (3 bits)
      val draw_char_color = in UInt (IDX_W bits)
      val draw_block_start = in Bool()
      val draw_x_orig = in UInt (FB_X_ADDRWIDTH bits)
      val draw_y_orig = in UInt (FB_Y_ADDRWIDTH bits)
      val draw_block_width = in UInt (8 bits)
      val draw_block_height = in UInt (8 bits)
      val draw_block_in_color =  in UInt (IDX_W bits)
      val draw_block_pat_color = in UInt (IDX_W bits)
      val draw_block_fill_pattern = in UInt (2 bits)
    }  else null

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


  val coreArea = new ClockingArea(coreClockDomain) {

    // Shared storage and draw engines in the game/core clock domain.
    val frameBuffer = new Bram2p(fbConfig) setName("frame_buffer")
    val drawCharEngine = new draw_char_engine(drawCharEngConfig) setName("draw_char_engine")
    val drawBlockEngine = new draw_block_engine(drawBlockEngConfig ) setName("draw_block_engine")
    val frameBufferAddrGen = new fb_addr_gen(fbAddrGenConfig) setName("frame_buffer_addr_gen")
    val drawController = new display_controller(displayControllerConfig) setName("draw_controller")

    // In debug mode the testbench drives the primitive engines directly, so the normal
    // game-start handshake is intentionally held low.
    drawController.io.game_start := { if (test) False else io.game_start }
    drawController.io.game_restart := io.game_restart
    drawController.io.row_val := io.row_val
    drawController.io.score_val := io.score_val

    io.draw_field_done := drawController.io.draw_field_done

    // Select either controller-generated requests or debug overrides once, then wire the
    // engines explicitly. This avoids fragile string-based lookup logic and makes the
    // command ownership obvious at each connection point.
    private val drawCharStart = if (test) io.debug.draw_char_start else drawController.io.draw_char.start
    private val drawCharWord = if (test) io.debug.draw_char_word else drawController.io.draw_char.word
    private val drawCharScale = if (test) io.debug.draw_char_scale else drawController.io.draw_char.scale
    private val drawCharColor = if (test) io.debug.draw_char_color else drawController.io.draw_char.color

    private val drawBlockStart = if (test) io.debug.draw_block_start else drawController.io.draw_block.start
    private val drawBlockWidth = if (test) io.debug.draw_block_width else drawController.io.draw_block.width
    private val drawBlockHeight = if (test) io.debug.draw_block_height else drawController.io.draw_block.height
    private val drawBlockInColor = if (test) io.debug.draw_block_in_color else drawController.io.draw_block.in_color
    private val drawBlockPatternColor = if (test) io.debug.draw_block_pat_color else drawController.io.draw_block.pat_color
    private val drawBlockFillPattern = if (test) io.debug.draw_block_fill_pattern else drawController.io.draw_block.fill_pattern

    private val drawOriginX = if (test) io.debug.draw_x_orig else drawController.io.draw_x_orig
    private val drawOriginY = if (test) io.debug.draw_y_orig else drawController.io.draw_y_orig

    drawCharEngine.io.start := drawCharStart
    drawCharEngine.io.word := drawCharWord
    drawCharEngine.io.scale := drawCharScale
    drawCharEngine.io.color := drawCharColor

    drawBlockEngine.io.start := drawBlockStart
    drawBlockEngine.io.width := drawBlockWidth
    drawBlockEngine.io.height := drawBlockHeight
    drawBlockEngine.io.in_color := drawBlockInColor
    drawBlockEngine.io.pat_color := drawBlockPatternColor
    drawBlockEngine.io.fill_pattern := drawBlockFillPattern

    drawController.io.draw_char.done := drawCharEngine.io.done
    drawController.io.draw_block.done := drawBlockEngine.io.done

    // Only one draw engine is expected to own the framebuffer write address at a time.
    // The running mask selects which engine's local pixel counters feed the address generator.
    private val activeDrawEngineMask = drawCharEngine.io.is_running ## drawBlockEngine.io.is_running
    private val drawEnginesOverlap = drawCharEngine.io.is_running && drawBlockEngine.io.is_running

    assert(
      !drawEnginesOverlap,
      "display_top.core: char and block draw engines must not run simultaneously",
      severity = FAILURE
    )

    frameBufferAddrGen.io.x := drawOriginX
    frameBufferAddrGen.io.y := drawOriginY
    frameBufferAddrGen.io.start := drawCharStart || drawBlockStart

    frameBufferAddrGen.io.h_cnt := activeDrawEngineMask.mux(
      B"01" -> drawBlockEngine.io.h_cnt,
      B"10" -> drawCharEngine.io.h_cnt,
      default -> U(0,FB_X_ADDRWIDTH bits)
    )

    frameBufferAddrGen.io.v_cnt  := activeDrawEngineMask.mux(
      B"01" -> drawBlockEngine.io.v_cnt,
      B"10" -> drawCharEngine.io.v_cnt,
      default -> U(0,FB_Y_ADDRWIDTH bits)
    )

    // Character writes get priority if both valid signals rise together. The overlap assert
    // above makes that case a design error, while the priority keeps the hardware assignment
    // deterministic for debug/simulation.
    frameBuffer.io.wr.en := drawCharEngine.io.out_valid || drawBlockEngine.io.out_valid
    frameBuffer.io.wr.addr := frameBufferAddrGen.io.out_addr
    frameBuffer.io.wr.data := drawBlockEngine.io.out_color.asBits
    when ( drawCharEngine.io.out_valid ) {
      frameBuffer.io.wr.data := drawCharEngine.io.out_color.asBits
    }

    frameBuffer.io.clear_start := drawController.io.bf_clear_start
    drawController.io.bf_clear_done := frameBuffer.io.clear_done

    io.draw_done := RegNext(drawCharEngine.io.done || drawBlockEngine.io.done, init=False)
    io.screen_is_ready := drawController.io.screen_is_ready


  }.setName("")

  val vgaArea = new ClockingArea(vgaClockDomain) {

    val vgaSync = vga_sync_gen(rgbConfig, timingsWidth = timingsWidth + 1) setName("vga_sync")

    val lineBufferPalette = new ColorPalette(cpConfig) setName("line_buffer_palette")

    val lineBuffer = new LineBuffer(
      Bits(FB_WORDWIDTH bit),
      FB_WIDTH,
      FB_SCALE,
      coreClockDomain,
      ClockDomain.current
    ) setName("line_buffer")

    private val fbScaleCounter = Counter(stateCount = (FB_SCALE), vgaSync.io.colorEn.fall(False) )

    // The VGA domain emits line/frame events as toggles. Crossing a toggle through BufferCC
    // is safer than crossing a one-cycle pulse because the core clock can recover the event by
    // edge detection even when the two domains are asynchronous.
    private val lineFetchAllowed = ( fbScaleCounter === U(0) )  && vgaSync.io.vColorEn
    private val lineFetchPulse = vgaSync.io.sos && lineFetchAllowed
    val line_fetch_toggle = RegInit(False)
    val frame_start_toggle = RegInit(False)

    when(lineFetchPulse) {
      line_fetch_toggle := !line_fetch_toggle
    }

    when(vgaSync.io.sof) {
      frame_start_toggle := !frame_start_toggle
    }


    // Start shifting pixels from the line buffer when the visible line begins. If the display
    // is cropped horizontally, wait until the left margin is skipped before enabling readout.
    if ( screenCrop.x == 0) {
      lineBuffer.io.rd_start := vgaSync.io.sol
    } else {
      val cropOffsetCounterEnable = RegInit(False)
      val cropOffsetCounter = Counter( screenCrop.x, cropOffsetCounterEnable )
      cropOffsetCounterEnable.setWhen(vgaSync.io.sol).clearWhen(cropOffsetCounter.willOverflowIfInc)
      lineBuffer.io.rd_start := cropOffsetCounter.willOverflow
    }

    lineBufferPalette.io.rd_en := lineBuffer.io.rd_out.valid
    lineBufferPalette.io.addr := lineBuffer.io.rd_out.payload.asUInt


    private val paletteColor = lineBufferPalette.io.color

    private val videoPipelineDelay = lineBuffer.delay_num + lineBufferPalette.delay_num


    io.vga.hSync := Delay(vgaSync.io.hSync, videoPipelineDelay)
    io.vga.vSync := Delay(vgaSync.io.vSync, videoPipelineDelay)
    io.vga.colorEn := Delay(vgaSync.io.colorEn, videoPipelineDelay)


    // The palette returns RGB a few cycles after the line-buffer index. Delay the background
    // comparison by one cycle so the background substitution stays aligned with the palette data.
    private val isBackgroundIndex = RegNext(lineBuffer.io.rd_out.payload.asUInt === U(BG_COLOR_IDX), init=False)

    when (  paletteColor.valid  )   {
      when ( isBackgroundIndex ) {
        io.vga.color <= BACKGROUND_COLOR
      } otherwise  {
        io.vga.color <= paletteColor.payload
      }
    }.otherwise {
      io.vga.color <= 0
    }

    val pixel_debug = Flow(Rgb(rgbConfig))
    pixel_debug.valid := io.vga.colorEn
    pixel_debug.payload := io.vga.color


    vgaSync.io.softReset := BufferCC( io.softRest, False )


    private val expectedPipelineDelay = LatencyAnalysis(vgaSync.io.colorEn, io.vga.colorEn)
    println(f"[INFO] @[elab] vgaSync.io.colorEn -> io.vga.colorEn = ${expectedPipelineDelay} (Expected) / ${videoPipelineDelay} (Calc)")


  }.setName("")


  private val dmaArea = new ClockingArea(coreClockDomain ) {


    // Recover the toggle-based events from the VGA clock domain. A change on the synchronized
    // toggle means exactly one request pulse in the core clock domain.
    private val lineFetchToggleCore = BufferCC(vgaArea.line_fetch_toggle, False)
    private val frameStartToggleCore = BufferCC(vgaArea.frame_start_toggle, False)
    private val lineFetchStart = lineFetchToggleCore =/= RegNext(lineFetchToggleCore, init = False)
    val frameStart = frameStartToggleCore =/= RegNext(frameStartToggleCore, init = False)

    // Stream one framebuffer row into the line buffer after each recovered line-fetch event.
    private val frameBufferFetchActive = Reg(Bool()) init(False)

    private val lineFetchPixelCounter = Counter(stateCount = FB_WIDTH, frameBufferFetchActive)
    private val frameBufferReadAddr = Counter(stateCount = FB_PIXELS, frameBufferFetchActive)
    private val lineFetchWhileBusy = lineFetchStart && frameBufferFetchActive

    // This should never happen in a healthy pipeline: each line-fetch request must wait until
    // the previous row burst has fully drained into the line buffer.
    assert(
      !lineFetchWhileBusy,
      "display_top.dma: new line fetch started before the previous framebuffer burst completed",
      severity = FAILURE
    )


    when(lineFetchStart) {
      frameBufferFetchActive := True
    }

    when(lineFetchPixelCounter.willOverflowIfInc) {
      frameBufferFetchActive := False
      lineFetchPixelCounter.clear()
    }

    when ( frameStart ) {
      frameBufferReadAddr.clear()
    }

    coreArea.frameBuffer.io.rd.en := frameBufferFetchActive
    coreArea.frameBuffer.io.rd.addr := frameBufferReadAddr

    vgaArea.lineBuffer.io.wr_in << coreArea.frameBuffer.io.rd.data

    // The same recovered frame-start pulse resets the framebuffer reader and kicks the
    // controller draw sequence so setup and runtime updates both start on a frame boundary.
    if ( test ) {
      coreArea.drawController.io.frame_start := False // Freeze FSM when testing each draw engine in isolation.
    } else {
      coreArea.drawController.io.frame_start := frameStart
    }
  }

  io.sof := dmaArea.frameStart


}



object displayTopMain{
  def main(args: Array[String]): Unit = {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SSC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new display_top( DisplayTopConfig(),test = true )
    )
  }
}

