package SSC.display_top

import config._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core._
import spinal.core.sim._
import utils.PathUtils

import java.awt.Graphics2D
import java.awt.image.BufferedImage
import java.io.File
import java.util.concurrent.CountDownLatch
import javax.imageio.ImageIO
import javax.swing.WindowConstants
import scala.collection.mutable
import scala.language.postfixOps
import scala.swing._
import scala.swing.event.WindowClosing
import scala.util.Random

class DisplayTopTest extends AnyFunSuite {

  private val compiler: String = "vcs"
  private val runFolder: String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SSC", targetName = "sim").toString
  private val workFolder: String = s"$runFolder/$compiler"
  private val debugRunFolder: String = s"$runFolder/debug"
  private val normalRunFolder: String = s"$runFolder/normal"
  private val displayConfig: DisplayTopConfig = DisplayTopConfig(offset_x = 32)
  private val frameWidth: Int = displayConfig.xWidth
  private val frameHeight: Int = displayConfig.yWidth
  private val framePixels: Int = frameWidth * frameHeight
  private val enableInteractiveGui: Boolean = false

  private val memoryModel: String = compiler match {
    case "verilator" => "RAMB16_S9_VERILATOR.v"
    case "vcs" => "RAMB16_S9.v"
  }

  private val xilinxPath: String = System.getenv("XILINX")
  println(s"[INFO] @[elab] xilinxPath=$xilinxPath")

  private var drawFrameInstance: Option[MainFrame] = None
  private val obsMem: mutable.Queue[(Int, Int, Int)] = mutable.Queue[(Int, Int, Int)]()

  private lazy val debugCompiled: SimCompiled[display_top] = compileDut(testMode = true, outputFolder = debugRunFolder)
  private lazy val normalCompiled: SimCompiled[display_top] = compileDut(testMode = false, outputFolder = normalRunFolder)

  import displayConfig.pfConfig._

  private case class TestInfo(name: String, purpose: String, strategy: String, imageName: String, interactiveGui: Boolean = false)

  private object ControllerState {
    val WAIT_GAME_START: Int = 4
  }

  private def compileDut(testMode: Boolean, outputFolder: String): SimCompiled[display_top] = {
    runSimConfig(outputFolder, compiler)
      .addRtl(s"$xilinxPath/glbl.v")
      .addRtl(s"$xilinxPath/unisims/$memoryModel")
      .withTimeScale(1 ns)
      .withTimePrecision(10 ps)
      .compile {
        val dut = new display_top(displayConfig, testMode)
        dut.vgaArea.pixel_debug.simPublic()
        dut.vgaArea.vgaSync.io.sof.simPublic()
        dut.coreArea.drawController.setupRenderer.fsmDebug.simPublic()
        dut
      }
  }

  private def logInfo(message: String): Unit = println(s"[INFO] @[${simTime()}] $message")
  private def logDebug(message: String): Unit = println(s"[DEBUG] @[${simTime()}] $message")
  private def logError(message: String): Unit = println(s"[ERROR] @[${simTime()}] $message")
  private def logInteractiveGuiDisabled(): Unit = {
    println(s"[WARN] @[${simTime()}] Interactive GUI helper is kept for this test but disabled by enableInteractiveGui=false")
  }

  private def logTestStart(info: TestInfo): Unit = {
    logInfo(s"[TEST][START] name='${info.name}'")
    logInfo(s"[TEST][PURPOSE] ${info.purpose}")
    logInfo(s"[TEST][STRATEGY] ${info.strategy}")
  }

  private def logTestPass(info: TestInfo, imageFile: File, detail: String): Unit = {
    logInfo(s"[TEST][PASS] name='${info.name}' image='${imageFile.getAbsolutePath}' detail='$detail'")
  }

  private def startClocksAndInit(dut: display_top, testMode: Boolean): Unit = {
    dut.coreClockDomain.forkStimulus(4 ns)
    dut.vgaClockDomain.forkStimulus(10 ns)
    init(dut, testMode)
    dut.vgaClockDomain.waitSampling(20)
    dut.io.softRest #= false
  }

  private def init(dut: display_top, testMode: Boolean): Unit = {
    dut.io.softRest #= false
    dut.io.game_restart #= false
    dut.io.game_start #= false
    dut.io.row_val.valid #= false
    dut.io.row_val.payload #= 0
    dut.io.score_val.valid #= false
    dut.io.score_val.payload #= 0

    if (testMode) {
      dut.io.debug.draw_char_start #= false
      dut.io.debug.draw_block_start #= false
      dut.io.debug.draw_x_orig #= 0
      dut.io.debug.draw_y_orig #= 0
      dut.io.debug.draw_char_word #= 0
      dut.io.debug.draw_char_scale #= 0
      dut.io.debug.draw_char_color #= 0
      dut.io.debug.draw_block_width #= 0
      dut.io.debug.draw_block_height #= 0
      dut.io.debug.draw_block_in_color #= 0
      dut.io.debug.draw_block_pat_color #= 0
      dut.io.debug.draw_block_fill_pattern #= 0
    }
  }

  private def waitCoreUntil(dut: display_top, maxCycles: Int, message: String)(condition: => Boolean): Unit = {
    var cycles = 0
    while (cycles < maxCycles && !condition) {
      dut.coreClockDomain.waitSampling()
      cycles += 1
    }
    if (!condition) {
      logError(s"$message after waiting $cycles core cycles")
    }
    assert(condition, s"$message after waiting $cycles core cycles")
  }

  private def waitForOpeningWaitState(dut: display_top): Unit = {
    val message = "opening screen did not reach WAIT_GAME_START"
    waitCoreUntil(dut, maxCycles = 250000, message = message) {
      dut.coreArea.drawController.setupRenderer.fsmDebug.toInt == ControllerState.WAIT_GAME_START
    }
    logInfo(s"Controller reached state=${ControllerState.WAIT_GAME_START} for '$message'")
  }

  private def waitForScreenReady(dut: display_top): Unit = {
    val message = "controller did not finish static game layout after game_start"
    waitCoreUntil(dut, maxCycles = 250000, message = message) {
      dut.io.screen_is_ready.toBoolean
    }
    logInfo(s"screen_is_ready observed for '$message'")
  }

  private def waitForDrawDoneLow(dut: display_top): Unit = {
    var cycles = 0
    while (cycles < 20 && dut.io.draw_done.toBoolean) {
      dut.coreClockDomain.waitSampling()
      cycles += 1
    }
    assert(!dut.io.draw_done.toBoolean, s"draw_done stayed high for $cycles cycles")
  }

  private def configChar(dut: display_top, x: Int, y: Int, value: Int, color: Int = 6, scale: Int = 1): Unit = {
    logDebug(s"Start debug char draw x=$x y=$y word=$value color=$color scale=$scale")
    dut.coreClockDomain.waitSampling(2)
    dut.io.debug.draw_x_orig #= x
    dut.io.debug.draw_y_orig #= y
    dut.io.debug.draw_char_word #= value
    dut.io.debug.draw_char_scale #= scale - 1
    dut.io.debug.draw_char_color #= color
    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_char_start #= true
    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_char_start #= false
    dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
    dut.io.debug.draw_x_orig #= 0
    dut.io.debug.draw_y_orig #= 0
    dut.coreClockDomain.waitSampling(2)
    waitForDrawDoneLow(dut)
  }

  private def configBlock(
      dut: display_top,
      x: Int,
      y: Int,
      width: Int,
      height: Int,
      color: Int,
      patColor: Int,
      fillPattern: Int = 0
  ): Unit = {
    logDebug(s"Start debug block draw x=$x y=$y width=$width height=$height color=$color patColor=$patColor fillPattern=$fillPattern")
    dut.coreClockDomain.waitSampling(2)
    dut.io.debug.draw_x_orig #= x
    dut.io.debug.draw_y_orig #= y
    dut.io.debug.draw_block_width #= width - 1
    dut.io.debug.draw_block_height #= height - 1
    dut.io.debug.draw_block_in_color #= color
    dut.io.debug.draw_block_pat_color #= patColor
    dut.io.debug.draw_block_fill_pattern #= fillPattern
    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_block_start #= true
    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_block_start #= false
    dut.coreClockDomain.waitSampling(2)
    dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
    dut.io.debug.draw_x_orig #= 0
    dut.io.debug.draw_y_orig #= 0
    dut.coreClockDomain.waitSampling(2)
    waitForDrawDoneLow(dut)
  }

  private def pulseGameStart(dut: display_top): Unit = {
    logInfo("Pulse game_start")
    dut.io.game_start #= true
    dut.coreClockDomain.waitSampling()
    dut.io.game_start #= false
    dut.coreClockDomain.waitSampling(4)
  }

  private def pulseGameRestart(dut: display_top): Unit = {
    logInfo("Pulse game_restart")
    dut.io.game_restart #= true
    dut.coreClockDomain.waitSampling()
    dut.io.game_restart #= false
    dut.coreClockDomain.waitSampling(4)
  }

  private def sendScore(dut: display_top, value: Int): Unit = {
    logInfo(s"Send score value=$value")
    dut.io.score_val.payload #= value
    dut.io.score_val.valid #= true
    dut.coreClockDomain.waitSampling()
    dut.io.score_val.valid #= false
    dut.io.score_val.payload #= 0
    dut.coreClockDomain.waitSampling(8)
  }

  private def sendPlayfieldRows(dut: display_top, rows: Seq[Int]): Unit = {
    assertResult(rowBlocksNum)(rows.length)
    logInfo(s"Send playfield row burst rows=${rows.length}")
    rows.zipWithIndex.foreach { case (rowValue, index) =>
      logDebug(s"Drive row_val index=$index value=$rowValue")
      dut.io.row_val.payload #= rowValue
      dut.io.row_val.valid #= true
      dut.coreClockDomain.waitSampling()
    }
    dut.io.row_val.valid #= false
    dut.io.row_val.payload #= 0
    dut.coreClockDomain.waitSampling(4)
  }

  private def waitForRuntimeRenderDone(dut: display_top, message: String): Unit = {
    dut.vgaClockDomain.waitSamplingWhere(dut.vgaArea.vgaSync.io.sof.toBoolean)
    logInfo(s"Frame boundary observed before waiting for runtime render: $message")
    waitCoreUntil(dut, maxCycles = 500000, message = message) {
      dut.io.draw_field_done.toBoolean
    }
    dut.coreClockDomain.waitSampling(8)
  }

  private def expectNoDrawFieldDoneAcrossNextFrame(dut: display_top): Unit = {
    val message = "Stale playfield render was observed after game_restart"
    var monitorActive = true
    var drawFieldDoneSeen = false
    fork {
      while (monitorActive) {
        dut.coreClockDomain.waitSampling()
        if (dut.io.draw_field_done.toBoolean) {
          drawFieldDoneSeen = true
        }
      }
    }

    dut.vgaClockDomain.waitSamplingWhere(dut.vgaArea.vgaSync.io.sof.toBoolean)
    dut.vgaClockDomain.waitSamplingWhere(dut.vgaArea.vgaSync.io.sof.toBoolean)
    monitorActive = false
    dut.coreClockDomain.waitSampling(2)
    if (drawFieldDoneSeen) {
      logError(message)
    }
    assert(!drawFieldDoneSeen, message)
  }

  private def makePlayfieldRows(seed: Int, density: Double = 0.2): Seq[Int] = {
    val random = new Random(seed)
    (0 until rowBlocksNum).map { row =>
      (0 until colBlocksNum).foldLeft(0) { case (acc, col) =>
        val isBorder = row == 0 || row == bottomRow - 1 || col == 0 || col == colBlocksNum - 1
        val drawOn = isBorder || random.nextDouble() < density
        if (drawOn) acc | (1 << col) else acc
      }
    }
  }

  private object ImageHelper {
    private def vga4BitTo8Bit(color: (Int, Int, Int)): Int = {
      val color8bit = Seq(color._1, color._2, color._3).map(value => (value & 0xF) | ((value & 0xF) << 4))
      color8bit.head << 16 | color8bit(1) << 8 | color8bit(2)
    }

    private def imageFile(info: TestInfo): File = {
      val safeName = info.imageName.stripSuffix(".png").replaceAll("[^A-Za-z0-9_.-]", "_")
      new File(workFolder, s"$safeName.png")
    }

    def writeFrame(info: TestInfo, pixels: Seq[(Int, Int, Int)]): File = {
      assertResult(framePixels, s"Captured pixel count for ${info.name}")(pixels.length)
      val outputFile = imageFile(info)
      val outputDir = outputFile.getParentFile
      if (!outputDir.exists() && !outputDir.mkdirs()) {
        logError(s"Failed to create image output directory: ${outputDir.getAbsolutePath}")
      }

      val image = new BufferedImage(frameWidth, frameHeight, BufferedImage.TYPE_INT_RGB)
      pixels.zipWithIndex.foreach { case (rgb, index) =>
        val x = index % frameWidth
        val y = index / frameWidth
        image.setRGB(x, y, vga4BitTo8Bit(rgb))
      }
      ImageIO.write(image, "png", outputFile)
      logInfo(s"Image saved to ${outputFile.getAbsolutePath}")
      outputFile
    }
  }

  private object GuiHelper {
    def launchGui(imageTitle: String, imageFile: File): Unit = {
      val guiClosedLatch = new CountDownLatch(1)
      val gui = fork {
        Swing.onEDT {
          object DrawFrame extends MainFrame {
            private val image = ImageIO.read(imageFile)
            title = imageTitle
            peer.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE)
            preferredSize = new Dimension(frameWidth, frameHeight)
            contents = new Panel {
              preferredSize = new Dimension(frameWidth, frameHeight)
              override def paintComponent(g: Graphics2D): Unit = {
                super.paintComponent(g)
                logDebug("[GUI] paintComponent() called")
                g.drawImage(image, 0, 0, size.width, size.height, null)
              }
            }
            reactions += {
              case _: WindowClosing =>
                logInfo("GUI window closing event received")
                dispose()
                guiClosedLatch.countDown()
            }
          }
          DrawFrame.visible = true
          drawFrameInstance = Some(DrawFrame)
        }

        try {
          logInfo("GUI thread waiting for window close")
          guiClosedLatch.await()
        } catch {
          case _: InterruptedException => Thread.currentThread().interrupt()
        }
        logInfo("GUI thread finished")
      }

      logInfo("Waiting for GUI exit")
      gui.join()
      logInfo("GUI exited cleanly")
    }
  }

  private def captureReferenceImage(dut: display_top, info: TestInfo): File = {
    logInfo(s"Waiting for next SOF before reference capture for '${info.name}'")
    obsMem.clear()
    dut.vgaClockDomain.waitSamplingWhere(dut.vgaArea.vgaSync.io.sof.toBoolean)
    logInfo(s"Capture started for '${info.name}'")
    obsMem.clear()

    while (obsMem.length < framePixels) {
      dut.vgaClockDomain.waitSampling()
      if (dut.vgaArea.pixel_debug.valid.toBoolean) {
        val payload = dut.vgaArea.pixel_debug.payload
        obsMem.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }
    }

    val pixels = obsMem.toVector
    val distinctColors = pixels.distinct.length
    val nonBlackPixels = pixels.count(_ != (0, 0, 0))
    logInfo(s"Captured frame summary: pixels=${pixels.length} distinct_colors=$distinctColors non_black_pixels=$nonBlackPixels")
    assert(distinctColors > 1, s"${info.name}: expected more than one color in reference image")

    val outputFile = ImageHelper.writeFrame(info, pixels)
    obsMem.clear()

    if (info.interactiveGui && enableInteractiveGui) {
      GuiHelper.launchGui(info.name, outputFile)
    } else if (info.interactiveGui) {
      logInteractiveGuiDisabled()
    }

    outputFile
  }

  test("debug primitives draw char and block reference image") {
    val info = TestInfo(
      name = "debug primitives draw char and block reference image",
      purpose = "Verify the debug-exposed draw_char_engine and draw_block_engine can draw sequential commands without overlapping engine execution.",
      strategy = "Use test-mode display_top, serialize every char/block start until draw_done is observed low again, then capture one full VGA frame as PNG.",
      imageName = "display_top_debug_char_and_block_reference",
      interactiveGui = true
    )

    debugCompiled.doSimUntilVoid(seed = 42) { dut =>
      logTestStart(info)
      startClocksAndInit(dut, testMode = true)
      SimTimeout(20 ms)

      dut.vgaClockDomain.waitSamplingWhere(dut.vgaArea.vgaSync.io.sof.toBoolean)
      logInfo("The first frame has started")

      configChar(dut, x = 0, y = 0, value = 0x41, scale = 2)
      for (i <- 1 to 16) {
        configBlock(dut, 10 + i * 16, 20, i, i, i % 16, (i + 1) % 16, fillPattern = 1)
      }
      for (i <- 1 to 16) {
        configBlock(dut, 10 + i * 16, 80, i, i * 2, i % 16, (i + 1) % 16, fillPattern = 2)
      }
      for (i <- 1 to 16) {
        configBlock(dut, 10 + i * 16, 160, i, i * 3, i % 16, i % 16, fillPattern = 3)
      }

      val imageFile = captureReferenceImage(dut, info)
      logTestPass(info, imageFile, "Serialized one char draw and 48 block draws; PNG contains multiple visible colors.")
      simSuccess()
    }
  }

  test("debug primitives draw tetris opening string reference image") {
    val info = TestInfo(
      name = "debug primitives draw tetris opening string reference image",
      purpose = "Verify direct character rendering for the opening Tetris banner independent of the display controller FSM.",
      strategy = "Use debug mode, draw the banner characters one by one with a fixed scale/color, and capture exactly one VGA frame.",
      imageName = "display_top_debug_tetris_opening_string_reference"
    )

    debugCompiled.doSimUntilVoid(seed = 42) { dut =>
      logTestStart(info)
      startClocksAndInit(dut, testMode = true)
      SimTimeout(20 ms)

      dut.vgaClockDomain.waitSamplingWhere(dut.vgaArea.vgaSync.io.sof.toBoolean)
      logInfo("The first frame has started")

      val (x, y, width, margin) = (15, 60, 50, 18)
      "Tetris".map(_.toInt).zipWithIndex.foreach { case (charCode, index) =>
        configChar(dut, x + index * width + margin, y, charCode, scale = 3)
      }

      val imageFile = captureReferenceImage(dut, info)
      logTestPass(info, imageFile, "Drew six opening banner characters and captured the resulting frame.")
      simSuccess()
    }
  }

  test("debug primitives draw tetris layout wall and score reference image") {
    val info = TestInfo(
      name = "debug primitives draw tetris layout wall and score reference image",
      purpose = "Verify the composed in-game layout can be drawn using serialized primitive debug commands.",
      strategy = "Draw static walls, a deterministic playfield sample, separator, and score text without starting a new command until the previous draw is idle.",
      imageName = "display_top_debug_tetris_layout_reference"
    )

    debugCompiled.doSimUntilVoid(seed = 42) { dut =>
      logTestStart(info)
      startClocksAndInit(dut, testMode = true)
      SimTimeout(50 ms)

      dut.vgaClockDomain.waitSamplingWhere(dut.vgaArea.vgaSync.io.sof.toBoolean)
      logInfo("The first frame has started")

      configBlock(dut, x_orig, y_orig, wall_width, wall_height, 0, 15, fillPattern = 3)
      val rightWallOrig = getRightWallOrig
      configBlock(dut, rightWallOrig._1, rightWallOrig._2, wall_width, wall_height, 0, 15, fillPattern = 3)
      val baseOrig = getBaseOrig
      configBlock(dut, baseOrig._1, baseOrig._2, base_width, base_height, 0, 15, fillPattern = 3)

      makePlayfieldRows(seed = 42).zipWithIndex.foreach { case (rowValue, row) =>
        (0 until colBlocksNum).filter(col => ((rowValue >> col) & 1) == 1).foreach { col =>
          configBlock(dut, col * block_len + x_orig + wall_width, row * block_len + y_orig, block_len, block_len, 10, 11)
        }
      }

      val splitX = 200
      val splitY = 10
      configBlock(dut, splitX, splitY, 2, 222, 15, 14)

      val scoreStringX = splitX + 14
      val scoreStringY = splitY + 12
      val scoreX = scoreStringX + 8
      val scoreY = scoreStringY + 22
      "Score".map(_.toInt).zipWithIndex.foreach { case (charCode, index) =>
        configChar(dut, scoreStringX + index * 12, scoreStringY, charCode)
      }
      "234".map(_.toInt).zipWithIndex.foreach { case (charCode, index) =>
        configChar(dut, scoreX + index * 12, scoreY, charCode, color = 3, scale = 2)
      }

      val imageFile = captureReferenceImage(dut, info)
      logTestPass(info, imageFile, "Drew deterministic walls, playfield blocks, separator, and score text into the reference frame.")
      simSuccess()
    }
  }

  test("controller opening screen produces reference image") {
    val info = TestInfo(
      name = "controller opening screen produces reference image",
      purpose = "Verify the normal display_controller setup path draws the opening screen and then waits for game_start.",
      strategy = "Use non-debug display_top, wait for the controller WAIT_GAME_START state, assert the screen is not ready yet, and capture one VGA frame.",
      imageName = "display_top_controller_opening_screen_reference"
    )

    normalCompiled.doSimUntilVoid(seed = 42) { dut =>
      logTestStart(info)
      startClocksAndInit(dut, testMode = false)
      SimTimeout(30 ms)

      waitForOpeningWaitState(dut)
      assert(!dut.io.screen_is_ready.toBoolean, "Opening screen should wait for game_start before reporting ready")

      val imageFile = captureReferenceImage(dut, info)
      logTestPass(info, imageFile, "Controller reached WAIT_GAME_START and produced a non-empty opening reference frame.")
      simSuccess()
    }
  }

  test("controller running screen accepts score and playfield safely") {
    val info = TestInfo(
      name = "controller running screen accepts score and playfield safely",
      purpose = "Verify score/playfield traffic is driven only after setup rendering is complete, avoiding display_controller start-collision assertions.",
      strategy = "Wait for opening idle, pulse game_start, wait for screen_is_ready, send a complete no-gap playfield burst plus score, wait for frame-gated rendering, and capture one PNG.",
      imageName = "display_top_controller_running_score_playfield_reference"
    )

    normalCompiled.doSimUntilVoid(seed = 42) { dut =>
      logTestStart(info)
      startClocksAndInit(dut, testMode = false)
      SimTimeout(80 ms)

      waitForOpeningWaitState(dut)
      pulseGameStart(dut)
      waitForScreenReady(dut)

      sendScore(dut, value = 987)
      sendPlayfieldRows(dut, makePlayfieldRows(seed = 987, density = 0.25))
      waitForRuntimeRenderDone(dut, "runtime score/playfield render did not finish")

      val imageFile = captureReferenceImage(dut, info)
      logTestPass(info, imageFile, "Screen became ready before runtime inputs; complete row burst rendered with score value 987.")
      simSuccess()
    }
  }

  test("controller restart clears stale runtime image and redraws reference screen") {
    val info = TestInfo(
      name = "controller restart clears stale runtime image and redraws reference screen",
      purpose = "Verify game_restart after a runtime update does not replay stale playfield data and still produces a valid reference image.",
      strategy = "Reach running state, render one score/playfield frame, pulse game_restart only after render completion, wait for a later frame, and capture the restarted screen.",
      imageName = "display_top_controller_restart_reference"
    )

    normalCompiled.doSimUntilVoid(seed = 42) { dut =>
      logTestStart(info)
      startClocksAndInit(dut, testMode = false)
      SimTimeout(100 ms)

      waitForOpeningWaitState(dut)
      pulseGameStart(dut)
      waitForScreenReady(dut)

      sendScore(dut, value = 321)
      sendPlayfieldRows(dut, makePlayfieldRows(seed = 321, density = 0.3))
      waitForRuntimeRenderDone(dut, "initial runtime render before restart did not finish")

      sendScore(dut, value = 654)
      sendPlayfieldRows(dut, makePlayfieldRows(seed = 654, density = 0.35))
      logInfo("Pending runtime update prepared; restart will be asserted before the next frame consumes it")

      pulseGameRestart(dut)
      expectNoDrawFieldDoneAcrossNextFrame(dut)

      val imageFile = captureReferenceImage(dut, info)
      logTestPass(info, imageFile, "Restart cleared a pending runtime update; no stale draw_field_done was seen before the captured reference frame.")
      simSuccess()

    }
  }


}
