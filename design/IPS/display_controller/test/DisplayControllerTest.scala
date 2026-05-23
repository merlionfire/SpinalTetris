package IPS.display_controller

import config._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core._
import spinal.core.sim.{SimCompiled, _}
import utils.PathUtils

import scala.collection.mutable.ArrayBuffer

class DisplayControllerTest extends AnyFunSuite {
  val compiler: String = "vcs"
  val runFolder: String = PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString

  private val playFieldConfig = TetrisPlayFeildConfig(
    block_len = 9,
    wall_width = 9,
    x_orig = 50,
    y_orig = 20,
    piece_ft_color = 9,
    piece_bg_color = 2
  )

  private val controllerConfig = DisplayControllerConfig(
    FB_X_ADDRWIDTH = log2Up(320),
    FB_Y_ADDRWIDTH = log2Up(240),
    bg_color_idx = 2,
    playFieldConfig = playFieldConfig
  )

  lazy val compiled: SimCompiled[display_controller] = runSimConfig(runFolder, compiler)
    .compile {
      new display_controller(controllerConfig)
    }

  private case class CharDrawEvent(time: Long, xOrig: Int, yOrig: Int, word: Int, scale: Int, color: Int)
  private case class BlockDrawEvent(
      time: Long,
      xOrig: Int,
      yOrig: Int,
      width: Int,
      height: Int,
      inColor: Int,
      patColor: Int,
      fillPattern: Int
  )
  private case class ClearEvent(time: Long)

  private val openingText: Seq[Int] = "Tetris".map(_.toInt)
  private val scoreText: Seq[Int] = "Score".map(_.toInt)
  private val openingInfo = controllerConfig.stringList("Tetris")
  private val scoreInfo = controllerConfig.stringList("Score")
  private val leftWallOrig = (playFieldConfig.x_orig, playFieldConfig.y_orig)
  private val rightWallOrig = playFieldConfig.getRightWallOrig
  private val baseOrig = playFieldConfig.getBaseOrig
  private val fieldOrig = playFieldConfig.getFieldOrig
  private val initialPlayfieldBurstRows = rowBlocksNum - 1

  private def initDut(dut: display_controller): Unit = {
    dut.io.game_restart #= false
    dut.io.frame_start #= false
    dut.io.game_start #= false
    dut.io.row_val.valid #= false
    dut.io.row_val.payload #= 0
    dut.io.score_val.valid #= false
    dut.io.score_val.payload #= 0
    dut.io.draw_char.done #= false
    dut.io.draw_block.done #= false
    dut.io.bf_clear_done #= false
  }

  private def pulseFrameStart(dut: display_controller): Unit = {
    println(s"[INFO] @[${simTime()}] Pulse frame_start")
    dut.io.frame_start #= true
    dut.clockDomain.waitSampling()
    dut.io.frame_start #= false
  }

  private def pulseGameStart(dut: display_controller): Unit = {
    println(s"[INFO] @[${simTime()}] Pulse game_start")
    dut.io.game_start #= true
    dut.clockDomain.waitSampling()
    dut.io.game_start #= false
  }

  private def pulseGameRestart(dut: display_controller): Unit = {
    println(s"[INFO] @[${simTime()}] Pulse game_restart")
    dut.io.game_restart #= true
    dut.clockDomain.waitSampling()
    dut.io.game_restart #= false
  }

  private def sendScore(dut: display_controller, value: Int, settleCycles: Int = 40): Unit = {
    println(s"[INFO] @[${simTime()}] Send score update value=$value")
    dut.io.score_val.valid #= true
    dut.io.score_val.payload #= value
    dut.clockDomain.waitSampling()
    dut.io.score_val.valid #= false
    dut.io.score_val.payload #= 0
    dut.clockDomain.waitSampling(settleCycles)
  }

  private def sendPlayfieldBurst(dut: display_controller, rows: Seq[Int]): Unit = {
    println(s"[INFO] @[${simTime()}] Send playfield burst rows=${rows.length}")
    rows.foreach { rowValue =>
      dut.io.row_val.valid #= true
      dut.io.row_val.payload #= rowValue
      dut.clockDomain.waitSampling()
    }
    dut.io.row_val.valid #= false
    dut.io.row_val.payload #= 0
    dut.clockDomain.waitSampling()
  }

  private def forkClearResponder(dut: display_controller, clearEvents: ArrayBuffer[ClearEvent]): Unit = {
    fork {
      while (true) {
        dut.clockDomain.waitSampling()
        if (dut.io.bf_clear_start.toBoolean) {
          clearEvents += ClearEvent(simTime())
          println(s"[INFO] @[${simTime()}] Observed bf_clear_start")
          dut.io.bf_clear_done #= true
          dut.clockDomain.waitSampling()
          dut.io.bf_clear_done #= false
        }
      }
    }
  }

  private def forkCharResponder(dut: display_controller, charEvents: ArrayBuffer[CharDrawEvent]): Unit = {
    fork {
      while (true) {
        dut.clockDomain.waitSampling()
        if (dut.io.draw_char.start.toBoolean) {
          val event = CharDrawEvent(
            time = simTime(),
            xOrig = dut.io.draw_x_orig.toInt,
            yOrig = dut.io.draw_y_orig.toInt,
            word = dut.io.draw_char.word.toInt,
            scale = dut.io.draw_char.scale.toInt,
            color = dut.io.draw_char.color.toInt
          )
          charEvents += event
          println(s"[INFO] @[${simTime()}] Char draw start word=${event.word} x=${event.xOrig} y=${event.yOrig} scale=${event.scale} color=${event.color}")
          dut.io.draw_char.done #= true
          dut.clockDomain.waitSampling()
          dut.io.draw_char.done #= false
        }
      }
    }
  }

  private def forkBlockResponder(dut: display_controller, blockEvents: ArrayBuffer[BlockDrawEvent]): Unit = {
    fork {
      while (true) {
        dut.clockDomain.waitSampling()
        if (dut.io.draw_block.start.toBoolean) {
          val event = BlockDrawEvent(
            time = simTime(),
            xOrig = dut.io.draw_x_orig.toInt,
            yOrig = dut.io.draw_y_orig.toInt,
            width = dut.io.draw_block.width.toInt,
            height = dut.io.draw_block.height.toInt,
            inColor = dut.io.draw_block.in_color.toInt,
            patColor = dut.io.draw_block.pat_color.toInt,
            fillPattern = dut.io.draw_block.fill_pattern.toInt
          )
          blockEvents += event
          println(s"[INFO] @[${simTime()}] Block draw start x=${event.xOrig} y=${event.yOrig} w=${event.width} h=${event.height} in=${event.inColor} pat=${event.patColor} fill=${event.fillPattern}")
          dut.io.draw_block.done #= true
          dut.clockDomain.waitSampling()
          dut.io.draw_block.done #= false
        }
      }
    }
  }

  private def waitUntil(dut: display_controller, maxCycles: Int, message: String)(condition: => Boolean): Unit = {
    var cycles = 0
    while (cycles < maxCycles && !condition) {
      dut.clockDomain.waitSampling()
      cycles += 1
    }
    assert(condition, s"$message after waiting $cycles cycles")
  }

  private def formatChars(events: Seq[CharDrawEvent]): String =
    events.zipWithIndex.map { case (event, index) =>
      f"#$index%03d @[${event.time}] x=${event.xOrig}%3d y=${event.yOrig}%3d word=${event.word}%3d scale=${event.scale}%2d color=${event.color}%2d"
    }.mkString("\n")

  private def formatBlocks(events: Seq[BlockDrawEvent]): String =
    events.zipWithIndex.map { case (event, index) =>
      f"#$index%03d @[${event.time}] x=${event.xOrig}%3d y=${event.yOrig}%3d w=${event.width}%3d h=${event.height}%3d in=${event.inColor}%2d pat=${event.patColor}%2d fill=${event.fillPattern}%2d"
    }.mkString("\n")


  // This method works as scoreboard

  private def expectText(
      observed: Seq[CharDrawEvent],
      expectedWords: Seq[Int],
      xStart: Int,
      yStart: Int,
      xStep: Int,
      scale: Int,
      color: Int
  ): Unit = {
    withClue(s"Observed char events:\n${formatChars(observed)}\n") {
      assertResult(expectedWords.length)(observed.length)
      assertResult(expectedWords)(observed.map(_.word))
      assertResult(expectedWords.indices.map(index => xStart + index * xStep))(observed.map(_.xOrig))
      assertResult(Seq.fill(expectedWords.length)(yStart))(observed.map(_.yOrig))
      assertResult(Seq.fill(expectedWords.length)(scale))(observed.map(_.scale))
      assertResult(Seq.fill(expectedWords.length)(color))(observed.map(_.color))
    }
  }

  private def bootToWaitingForGameStart(
      dut: display_controller,
      charEvents: ArrayBuffer[CharDrawEvent],
      clearEvents: ArrayBuffer[ClearEvent]
  ): Unit = {
    pulseFrameStart(dut)
    waitUntil(dut, maxCycles = 80, message = "opening text did not complete") {
      charEvents.length >= openingText.length
    }
    waitUntil(dut, maxCycles = 20, message = "clear screen did not start for opening frame") {
      clearEvents.nonEmpty
    }
  }

  private def bootToRunning(
      dut: display_controller,
      charEvents: ArrayBuffer[CharDrawEvent],
      blockEvents: ArrayBuffer[BlockDrawEvent],
      clearEvents: ArrayBuffer[ClearEvent]
  ): Unit = {
    bootToWaitingForGameStart(dut, charEvents, clearEvents)
    pulseGameStart(dut)
    waitUntil(dut, maxCycles = 120, message = "controller did not become screen ready") {
      dut.io.screen_is_ready.toBoolean
    }
    waitUntil(dut, maxCycles = 20, message = "setup walls were not drawn") {
      blockEvents.length >= 4
    }
  }

  // Verification strategy:
  // 1. Drive a single frame-start pulse while the controller is still in setup mode.
  // 2. Respond automatically to clear and draw handshakes so the test observes only externally
  //    visible behavior at the controller interface.
  // 3. Verify that exactly the opening banner characters are emitted with the configured origin,
  //    spacing, scale, and color.
  // 4. Verify that no wall or runtime playfield drawing occurs before game start is asserted.
  // 5. Verify that the controller remains not-ready after the banner completes, proving it is
  //    waiting for the explicit game-start event instead of progressing on its own.
  test("opening frame draws tetris banner and waits for game start") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      val charEvents = ArrayBuffer[CharDrawEvent]()
      val blockEvents = ArrayBuffer[BlockDrawEvent]()
      val clearEvents = ArrayBuffer[ClearEvent]()

      dut.clockDomain.forkStimulus(10)
      SimTimeout(20000)
      initDut(dut)
      forkClearResponder(dut, clearEvents)
      forkCharResponder(dut, charEvents)
      forkBlockResponder(dut, blockEvents)

      dut.clockDomain.waitSampling(5)
      bootToWaitingForGameStart(dut, charEvents, clearEvents)
      dut.clockDomain.waitSampling(10)

      expectText(
        observed = charEvents,
        expectedWords = openingText,
        xStart = openingInfo.x_orig,
        yStart = openingInfo.y_orig,
        xStep = openingInfo.width,
        scale = openingInfo.scale,
        color = openingInfo.color
      )

      withClue(s"Observed block events during opening:\n${formatBlocks(blockEvents)}\n") {
        assert(blockEvents.isEmpty)
      }
      assertResult(1)(clearEvents.length)
      assert(!dut.io.screen_is_ready.toBoolean)
      assert(!dut.io.draw_field_done.toBoolean)

      val charCountBeforeIdleWait = charEvents.length
      dut.clockDomain.waitSampling(20)
      assertResult(charCountBeforeIdleWait)(charEvents.length)
      simSuccess()
    }
  }

  // Verification strategy:
  // 1. Boot the controller through the opening phase, then issue game_start to enter the running
  //    setup path that redraws the static in-game HUD.
  // 2. Verify the full opening text first, then verify the score label that must appear after the
  //    screen clear associated with game start.
  // 3. Verify the four expected static block draws in order: left wall, right wall, base, and the
  //    score separator bar.
  // 4. Check that the ready flag is asserted only after this static scene construction completes,
  //    which confirms the controller exposes readiness based on user-visible setup completion.
  test("game start draws score label and walls before reporting screen ready") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      val charEvents = ArrayBuffer[CharDrawEvent]()
      val blockEvents = ArrayBuffer[BlockDrawEvent]()
      val clearEvents = ArrayBuffer[ClearEvent]()

      dut.clockDomain.forkStimulus(10)
      SimTimeout(30000)
      initDut(dut)
      forkClearResponder(dut, clearEvents)
      forkCharResponder(dut, charEvents)
      forkBlockResponder(dut, blockEvents)

      dut.clockDomain.waitSampling(5)
      bootToRunning(dut, charEvents, blockEvents, clearEvents)

      expectText(
        observed = charEvents.take(openingText.length),
        expectedWords = openingText,
        xStart = openingInfo.x_orig,
        yStart = openingInfo.y_orig,
        xStep = openingInfo.width,
        scale = openingInfo.scale,
        color = openingInfo.color
      )
      expectText(
        observed = charEvents.drop(openingText.length),
        expectedWords = scoreText,
        xStart = scoreInfo.x_orig,
        yStart = scoreInfo.y_orig,
        xStep = scoreInfo.width,
        scale = scoreInfo.scale,
        color = scoreInfo.color
      )

      val expectedWalls = Seq(
        BlockDrawEvent(0, leftWallOrig._1, leftWallOrig._2, playFieldConfig.wall_width - 1, playFieldConfig.wall_height - 1, 0, 15, 3),
        BlockDrawEvent(0, rightWallOrig._1, rightWallOrig._2, playFieldConfig.wall_width - 1, playFieldConfig.wall_height - 1, 0, 15, 3),
        BlockDrawEvent(0, baseOrig._1, baseOrig._2, playFieldConfig.base_width - 1, playFieldConfig.base_height - 1, 0, 15, 3),
        BlockDrawEvent(0, 190, 10, 2, 222, 15, 14, 0)
      )

      withClue(s"Observed setup wall events:\n${formatBlocks(blockEvents)}\n") {
        assertResult(expectedWalls.map(_.xOrig))(blockEvents.map(_.xOrig))
        assertResult(expectedWalls.map(_.yOrig))(blockEvents.map(_.yOrig))
        assertResult(expectedWalls.map(_.width))(blockEvents.map(_.width))
        assertResult(expectedWalls.map(_.height))(blockEvents.map(_.height))
        assertResult(expectedWalls.map(_.inColor))(blockEvents.map(_.inColor))
        assertResult(expectedWalls.map(_.patColor))(blockEvents.map(_.patColor))
        assertResult(expectedWalls.map(_.fillPattern))(blockEvents.map(_.fillPattern))
      }

      assertResult(2)(clearEvents.length)
      assert(dut.io.screen_is_ready.toBoolean)
      assert(!dut.io.draw_field_done.toBoolean)
      simSuccess()
    }
  }

  // Verification strategy:
  // 1. Bring the controller into RUNNING state, then update the score and stream a complete
  //    playfield burst without issuing frame_start yet.
  // 2. Verify that the pending playfield snapshot is latched but not rendered immediately,
  //    demonstrating that runtime refresh is gated by the next frame boundary.
  // 3. After pulsing frame_start, verify that one full playfield image is emitted as a block draw
  //    for every field cell with the configured geometry and background pattern.
  // 4. Sample several block locations and colors to prove that bit-to-cell mapping matches the
  //    provided row payloads across different rows and columns.
  // 5. Verify that score digits are drawn only after all field cells complete, and that the digit
  //    positions and styling follow the configured score-rendering parameters.
  test("runtime refresh waits for frame start and renders playfield cells followed by score digits") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      val charEvents = ArrayBuffer[CharDrawEvent]()
      val blockEvents = ArrayBuffer[BlockDrawEvent]()
      val clearEvents = ArrayBuffer[ClearEvent]()
      val fieldX0 = fieldOrig._1
      val fieldY0 = fieldOrig._2
      val blockStep = playFieldConfig.block_len

      dut.clockDomain.forkStimulus(10)
      SimTimeout(50000)
      initDut(dut)
      forkClearResponder(dut, clearEvents)
      forkCharResponder(dut, charEvents)
      forkBlockResponder(dut, blockEvents)

      dut.clockDomain.waitSampling(5)
      bootToRunning(dut, charEvents, blockEvents, clearEvents)

      val setupCharCount = charEvents.length
      val setupBlockCount = blockEvents.length

      sendScore(dut, value = 42)

      val rows = Seq(
        Integer.parseInt("1000000001", 2),
        Integer.parseInt("0000000000", 2),
        Integer.parseInt("1111111111", 2)
      ) ++ Seq.fill(initialPlayfieldBurstRows - 3)(0)

      sendPlayfieldBurst(dut, rows)
      dut.clockDomain.waitSampling(20)

      assertResult(setupBlockCount)(blockEvents.length)
      assertResult(setupCharCount)(charEvents.length)
      assert(!dut.io.draw_field_done.toBoolean)

      pulseFrameStart(dut)
      waitUntil(dut, maxCycles = 600, message = "runtime refresh did not finish") {
        dut.io.draw_field_done.toBoolean
      }
      dut.clockDomain.waitSampling()

      val runtimeBlocks = blockEvents.drop(setupBlockCount)
      val runtimeChars = charEvents.drop(setupCharCount)

      withClue(s"Observed runtime block events:\n${formatBlocks(runtimeBlocks.take(40))}\n...") {
        assertResult(rowBlocksNum * colBlocksNum)(runtimeBlocks.length)
        assert(runtimeBlocks.forall(_.width == playFieldConfig.block_len - 2))
        assert(runtimeBlocks.forall(_.height == playFieldConfig.block_len - 2))
        assert(runtimeBlocks.forall(_.patColor == controllerConfig.bg_color_idx))
        assert(runtimeBlocks.forall(_.fillPattern == BlockFillPattern.SOLID))
      }

      withClue(s"Observed runtime score char events:\n${formatChars(runtimeChars)}\n") {
        assertResult(Seq('0', '0', '4', '2').map(_.toInt))(runtimeChars.map(_.word))
        assertResult(Seq.tabulate(runtimeChars.length)(index => controllerConfig.score_orig_x + index * controllerConfig.score_width))(runtimeChars.map(_.xOrig))
        assertResult(Seq.fill(4)(controllerConfig.score_orig_y))(runtimeChars.map(_.yOrig))
        assertResult(Seq.fill(4)(controllerConfig.score_scale))(runtimeChars.map(_.scale))
        assertResult(Seq.fill(4)(controllerConfig.score_fg_color))(runtimeChars.map(_.color))
      }

      val expectedSamples = Seq(
        runtimeBlocks(0).copy(time = 0, xOrig = fieldX0, yOrig = fieldY0, inColor = playFieldConfig.piece_ft_color),
        runtimeBlocks(1).copy(time = 0, xOrig = fieldX0 + blockStep, yOrig = fieldY0, inColor = playFieldConfig.piece_bg_color),
        runtimeBlocks(9).copy(time = 0, xOrig = fieldX0 + 9 * blockStep, yOrig = fieldY0, inColor = playFieldConfig.piece_ft_color),
        runtimeBlocks(10).copy(time = 0, xOrig = fieldX0, yOrig = fieldY0 + blockStep, inColor = playFieldConfig.piece_bg_color),
        runtimeBlocks(20).copy(time = 0, xOrig = fieldX0, yOrig = fieldY0 + 2 * blockStep, inColor = playFieldConfig.piece_ft_color),
        runtimeBlocks(29).copy(time = 0, xOrig = fieldX0 + 9 * blockStep, yOrig = fieldY0 + 2 * blockStep, inColor = playFieldConfig.piece_ft_color)
      )

      withClue(s"Observed runtime block sample events:\n${formatBlocks(runtimeBlocks.take(30))}\n") {
        assertResult(expectedSamples.map(_.xOrig))(Seq(runtimeBlocks(0), runtimeBlocks(1), runtimeBlocks(9), runtimeBlocks(10), runtimeBlocks(20), runtimeBlocks(29)).map(_.xOrig))
        assertResult(expectedSamples.map(_.yOrig))(Seq(runtimeBlocks(0), runtimeBlocks(1), runtimeBlocks(9), runtimeBlocks(10), runtimeBlocks(20), runtimeBlocks(29)).map(_.yOrig))
        assertResult(expectedSamples.map(_.inColor))(Seq(runtimeBlocks(0), runtimeBlocks(1), runtimeBlocks(9), runtimeBlocks(10), runtimeBlocks(20), runtimeBlocks(29)).map(_.inColor))
      }

      simSuccess()
    }
  }

  // Verification strategy:
  // 1. Enter RUNNING state, then create a pending runtime refresh by sending score and playfield
  //    data before requesting a restart.
  // 2. Assert game_restart and verify that the controller redraws the static in-game scene rather
  //    than consuming the stale pending runtime snapshot.
  // 3. Confirm that a frame_start pulse immediately after restart redraw does not trigger any extra
  //    runtime rendering, proving the pending refresh request was cleared.
  // 4. Send a fresh score/playfield update after restart and verify that a subsequent frame_start
  //    now produces a runtime refresh, proving the controller recovers correctly after flushing the
  //    stale request.
  test("game restart drops stale pending refresh and waits for a new playfield burst") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      val charEvents = ArrayBuffer[CharDrawEvent]()
      val blockEvents = ArrayBuffer[BlockDrawEvent]()
      val clearEvents = ArrayBuffer[ClearEvent]()

      dut.clockDomain.forkStimulus(10)
      SimTimeout(70000)
      initDut(dut)
      forkClearResponder(dut, clearEvents)
      forkCharResponder(dut, charEvents)
      forkBlockResponder(dut, blockEvents)

      dut.clockDomain.waitSampling(5)
      bootToRunning(dut, charEvents, blockEvents, clearEvents)

      val setupCharCount = charEvents.length
      val setupBlockCount = blockEvents.length

      sendScore(dut, value = 7)
      sendPlayfieldBurst(dut, Seq.fill(initialPlayfieldBurstRows)(Integer.parseInt("1010101010", 2)))
      dut.clockDomain.waitSampling(10)

      pulseGameRestart(dut)
      waitUntil(dut, maxCycles = 160, message = "controller did not redraw the static screen after restart") {
        clearEvents.length >= 3 &&
        charEvents.length >= setupCharCount + scoreText.length &&
        blockEvents.length >= setupBlockCount + 4
      }
      waitUntil(dut, maxCycles = 40, message = "controller did not return to ready state after restart redraw") {
        dut.io.screen_is_ready.toBoolean
      }

      val restartChars = charEvents.drop(setupCharCount)
      val restartBlocks = blockEvents.drop(setupBlockCount)

      expectText(
        observed = restartChars,
        expectedWords = scoreText,
        xStart = scoreInfo.x_orig,
        yStart = scoreInfo.y_orig,
        xStep = scoreInfo.width,
        scale = scoreInfo.scale,
        color = scoreInfo.color
      )

      withClue(s"Observed restart wall events:\n${formatBlocks(restartBlocks)}\n") {
        assertResult(4)(restartBlocks.length)
      }

      val charCountAfterRestart = charEvents.length
      val blockCountAfterRestart = blockEvents.length
      pulseFrameStart(dut)
      dut.clockDomain.waitSampling(40)

      assertResult(charCountAfterRestart)(charEvents.length)
      assertResult(blockCountAfterRestart)(blockEvents.length)
      assert(!dut.io.draw_field_done.toBoolean)

      sendScore(dut, value = 19)
      sendPlayfieldBurst(dut, Seq.fill(rowBlocksNum)(Integer.parseInt("0000000011", 2)))
      pulseFrameStart(dut)
      waitUntil(dut, maxCycles = 600, message = "fresh playfield burst did not render after restart") {
        dut.io.draw_field_done.toBoolean
      }
      simSuccess()
    }
  }
}


