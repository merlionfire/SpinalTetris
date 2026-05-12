package IPS.display_controller

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._
import config._
import utils.PathUtils
import IPS.bcd._

import scala.collection.immutable.ListMap
import scala.language.postfixOps

case class DisplayControllerConfig(
                                 IDX_W : Int = 4,
                                 FB_X_ADDRWIDTH : Int,
                                 FB_Y_ADDRWIDTH : Int,
                                 bg_color_idx  : Int ,
                                 playFieldConfig : TetrisPlayFeildConfig,
                                 scoreBitsWidth : Int = 10
                               ) {
  case class CharInfo(
                       x_orig : Int,
                       y_orig : Int,
                       width  : Int,
                       scale  : Int,
                       color  : Int
                     )

  import playFieldConfig._

  val stringList: ListMap[String, CharInfo] = ListMap(
    // Content -> x_orig, y_orig, width(include margin), scale, color
    "Tetris" -> CharInfo(24, 66, 46, 2, 6),
    "Score"  -> CharInfo(210, 23, 12, 0, 6)
  )

  val keyLengths: List[Int] = stringList.keys.map(_.length).toList
  val offset: Map[String, Int] = stringList.keys.zip(keyLengths.scanLeft(0)(_ + _).dropRight(1)).toMap  // offset = Map( "Tetris" -> 0, "Score" -> 6)

  val score_orig_x = 214
  val score_orig_y = 80
  val score_scale = 0
  val score_fg_color = 6
  val score_width = 12

  // width and height are stored as N-1 because draw_block_engine expects inclusive end counts.
  val wallInfoList: List[List[Int]] = List(
    List(x_orig, y_orig, wall_width - 1, wall_height - 1, 0, 15, 3),
    List(getRightWallOrig._1, getRightWallOrig._2, wall_width - 1, wall_height - 1, 0, 15, 3),
    List(getBaseOrig._1, getBaseOrig._2, base_width - 1, base_height - 1, 0, 15, 3),
    List(190, 10, 2, 222, 15, 14, 0)
  )

  def wallRomInit(bitLengths: List[Int]): List[BigInt] = wallInfoList.map { row =>
    (row zip bitLengths).foldLeft((BigInt(0), 0)) {
      case ((accWord, currentShift), (value, bitLength)) =>
        (accWord | (BigInt(value) << currentShift), currentShift + bitLength)
    }._1
  }
}


class draw_char_if(colorBitsWidth: Int) extends Bundle with IMasterSlave {
  val start: Bool = Bool()
  val word: UInt = UInt(7 bit)
  val scale: UInt = UInt(3 bits)
  val color: UInt = UInt(colorBitsWidth bits)
  val done: Bool = Bool()

  override def asMaster(): Unit = {
    out(start, word, scale, color)
    in(done)
  }

  override def asSlave(): Unit = {
    in(start, word, scale, color)
    out(done)
  }
}

class draw_block_if(colorBitsWidth: Int) extends Bundle with IMasterSlave {
  val start: Bool = Bool() default False
  val width: UInt = UInt(8 bits) default 0
  val height: UInt = UInt(8 bits) default 0
  val in_color: UInt = UInt(colorBitsWidth bits) default 0
  val pat_color: UInt = UInt(colorBitsWidth bits) default 0
  val fill_pattern: UInt = UInt(2 bits) default 0
  val done: Bool = Bool() default False

  override def asMaster(): Unit = {
    out(start, width, height, in_color, pat_color, fill_pattern)
    in(done)
  }

  override def asSlave(): Unit = {
    in(start, width, height, in_color, pat_color, fill_pattern)
    out(done)
  }
}


case class DisplayCharCommand(colorBitsWidth: Int, xWidth: Int, yWidth: Int) extends Bundle {
  val start: Bool = Bool()
  val x_orig: UInt = UInt(xWidth bits)
  val y_orig: UInt = UInt(yWidth bits)
  val word: UInt = UInt(7 bit)
  val scale: UInt = UInt(3 bits)
  val color: UInt = UInt(colorBitsWidth bits)
}

case class DisplayBlockCommand(colorBitsWidth: Int, xWidth: Int, yWidth: Int) extends Bundle {
  val start: Bool = Bool()
  val x_orig: UInt = UInt(xWidth bits)
  val y_orig: UInt = UInt(yWidth bits)
  val width: UInt = UInt(8 bits)
  val height: UInt = UInt(8 bits)
  val in_color: UInt = UInt(colorBitsWidth bits)
  val pat_color: UInt = UInt(colorBitsWidth bits)
  val fill_pattern: UInt = UInt(2 bits)

  def payloadFields: List[UInt] = List(x_orig, y_orig, width, height, in_color, pat_color, fill_pattern)
}

private object BlockFillPattern {
  val SOLID = 0
}


class display_controller(config: DisplayControllerConfig) extends Component {

  import config._
  import config.playFieldConfig._

  val io: Bundle {
    val game_restart: Bool
    val draw_openning_start: Bool
    val game_start: Bool
    val row_val: Flow[Bits]
    val score_val: Flow[UInt]
    val screen_is_ready: Bool
    val draw_char: draw_char_if
    val draw_block: draw_block_if
    val draw_x_orig: UInt
    val draw_y_orig: UInt
    val draw_field_done: Bool
    val bf_clear_start: Bool
    val bf_clear_done: Bool
  } = new Bundle {
    val game_restart: Bool = in(Bool())
    val draw_openning_start: Bool = in(Bool())
    val game_start: Bool = in(Bool())
    val row_val: Flow[Bits] = slave(Flow(Bits(colBlocksNum bits)))
    val score_val: Flow[UInt] = slave(Flow(UInt(scoreBitsWidth bits)))
    val screen_is_ready: Bool = out(Bool())

    val draw_char: draw_char_if = master(new draw_char_if(IDX_W))
    val draw_block: draw_block_if = master(new draw_block_if(IDX_W))

    val draw_x_orig: UInt = out(UInt(FB_X_ADDRWIDTH bits)) default 0
    val draw_y_orig: UInt = out(UInt(FB_Y_ADDRWIDTH bits)) default 0

    val draw_field_done: Bool = out(Bool())
    val bf_clear_start: Bool = out(Bool())
    val bf_clear_done: Bool = in(Bool())
  }

  noIoPrefix()

  private def clearCharCommand(cmd: DisplayCharCommand): Unit = {
    cmd.start := False
    cmd.x_orig := 0
    cmd.y_orig := 0
    cmd.word := 0
    cmd.scale := 0
    cmd.color := 0
  }

  private def clearBlockCommand(cmd: DisplayBlockCommand): Unit = {
    cmd.start := False
    cmd.x_orig := 0
    cmd.y_orig := 0
    cmd.width := 0
    cmd.height := 0
    cmd.in_color := 0
    cmd.pat_color := 0
    cmd.fill_pattern := 0
  }

  private def driveTextCommand(
      cmd: DisplayCharCommand,
      xOrig: UInt,
      yOrig: UInt,
      scale: UInt,
      color: UInt,
      word: UInt
  ): Unit = {
    //clearCharCommand(cmd)
    cmd.start := True
    cmd.x_orig := xOrig
    cmd.y_orig := yOrig
    cmd.scale := scale
    cmd.color := color
    cmd.word := word
  }

  io.screen_is_ready := False
  io.draw_field_done := False
  io.bf_clear_start := False

  private val runtimeRenderEnable: Bool = Bool()
  private val runtimeRenderBusy: Bool = Bool()
  private val runtimeRenderStart: Bool = Bool()
  private val clearPendingPlayfieldRender: Bool = Bool()

  runtimeRenderEnable := False
  runtimeRenderBusy := False
  runtimeRenderStart := False
  clearPendingPlayfieldRender := False

  private val setupCharDone: Bool = Bool()
  private val runtimeScoreCharDone: Bool = Bool()
  private val setupBlockDone: Bool = Bool()
  private val runtimeFieldBlockDone: Bool = Bool()


  private val scoreCache: Area {
    val digits: Vec[UInt]
  } = new Area {
    private val bcdInst = new bcd(binaryWidth = scoreBitsWidth)

    bcdInst.io.data_in_bin << io.score_val

    private val scoreReg: Bits = Reg(Bits(bcdInst.bcdWidth bits)) init 0
    when(bcdInst.io.data_out_dec.valid) {
      scoreReg := bcdInst.io.data_out_dec.payload
    }

    // BCD 9A2B -> scoreReg : 1001 1010 0010 1011 (4 bits per digit)
    // digits(0) = 9
    // digits(1) = A,
    // digits(2) = 2,
    // digits(3) = B
    val digits: Vec[UInt] = Vec.fill(bcdInst.bcdDigits)(UInt(4 bits))

    for (digitIndex <- 0 until bcdInst.bcdDigits) {
      val digitMsb = bcdInst.bcdWidth - 1 - digitIndex * 4
      digits(digitIndex) := scoreReg(digitMsb downto digitMsb - 3).asUInt
    }
  }.setName("score_cache")

  private class TextRomArea extends Area {
    private val rom: Mem[UInt] = Mem(UInt(7 bits), keyLengths.sum)
    rom.addAttribute("ram_style", "distributed")

    private val romInitialContent: Seq[BigInt] = stringList.keys.toSeq.flatMap { text =>
      text.map(char => BigInt(char.toInt))
    }
    rom.initBigInt(romInitialContent)

    val charCounter: Counter = Counter(rom.wordCount)
    val word: UInt = rom.readAsync(charCounter)

    def isLast(text: String): Bool = {
      charCounter === (offset(text) + text.length - 1)
    }
  }

  private val textRom: TextRomArea = new TextRomArea().setName("text_rom")

  private val wallRom: Area {
    val wallCounter: Counter
    val command: DisplayBlockCommand
  } = new Area {
    val wallCounter: Counter = Counter(wallInfoList.size)
    val command: DisplayBlockCommand = DisplayBlockCommand(IDX_W, FB_X_ADDRWIDTH, FB_Y_ADDRWIDTH)
    command.start := True //False

    private val bitLengths: List[Int] = command.payloadFields.map(_.getBitsWidth)
    private val wordWidth: Int = bitLengths.sum

    private val wallMem: Mem[Bits] = Mem(Bits(wordWidth bits), wallInfoList.size)
    wallMem.initBigInt(wallRomInit(bitLengths))

    private val blockInfo: Bits = wallMem.readAsync(wallCounter)

    def unpackFields(fields: List[UInt]): Int = fields match {
      case Nil => 0
      case head :: tail =>
        val offsetAfterTail = unpackFields(tail)
        head.assignFromBits(blockInfo(offsetAfterTail, head.getBitsWidth bits))
        offsetAfterTail + head.getBitsWidth
    }

    unpackFields(command.payloadFields.reverse)
  }.setName("wall_rom")

  private val pendingPlayfieldRender: Bool = RegInit(False)

  private val playfieldStorage: Area {
    val memory: Mem[Bits]
  } = new Area {
    val memory: Mem[Bits] = Mem(Bits(colBlocksNum bits), rowBlocksNum)
    memory.addAttribute("ram_style", "distributed")

    val writeRowCounter = Counter(stateCount = rowBlocksNum, inc = io.row_val.valid)

    memory.write(
      address = writeRowCounter,
      data = io.row_val.payload,
      enable = io.row_val.valid
    )

    // Functional fix: keep the existing no-stall burst contract, but store the completion as an explicit pending request.
    private val rowBurstComplete: Bool = io.row_val.valid.fall(False)

    when(clearPendingPlayfieldRender) {
      pendingPlayfieldRender := False
    } otherwise {
      when(rowBurstComplete) {
        pendingPlayfieldRender := True
      } otherwise {
        when(runtimeRenderStart) {
          pendingPlayfieldRender := False
        }
      }
    }
  }.setName("playfield_storage")

  val runtimeRenderer = new Area {
    val blockCommand: DisplayBlockCommand = DisplayBlockCommand(IDX_W, FB_X_ADDRWIDTH, FB_Y_ADDRWIDTH)
    val scoreCommand: DisplayCharCommand = DisplayCharCommand(IDX_W, FB_X_ADDRWIDTH, FB_Y_ADDRWIDTH)
    clearBlockCommand(blockCommand)
    clearCharCommand(scoreCommand)

    private val readEnable: Bool = Bool()
    readEnable := False
    readEnable.addAttribute("keep")

    private val rowCounter: Counter = Counter(stateCount = rowBlocksNum)
    private val colCounter: Counter = Counter(stateCount = colBlocksNum)
    private val scoreDigitCounter: Counter = Counter(stateCount = scoreCache.digits.length)

    private val rowValue: Bits = playfieldStorage.memory.readSync(
      address = rowCounter,
      enable = readEnable
    )

    private val rowBits: Bits = Reg(Bits(colBlocksNum bits)) init 0
    private val fieldX: UInt = Reg(UInt(FB_X_ADDRWIDTH bits)) init 0
    private val fieldY: UInt = Reg(UInt(FB_Y_ADDRWIDTH bits)) init 0
    private val scoreX: UInt = Reg(UInt(FB_X_ADDRWIDTH bits)) init 0

    private val fieldColor: UInt = U(piece_bg_color, IDX_W bits)
    when(rowBits.msb) {
      fieldColor := piece_ft_color
    }

    val fsm: StateMachine = new StateMachine {

      lazy val IDLE: State = makeInstantEntry()

      IDLE.whenIsActive {
        when(pendingPlayfieldRender && io.draw_openning_start && runtimeRenderEnable) {
          // Functional fix: start only from a latched pending request so the frame pulse is consumed exactly once.
          runtimeRenderStart := True
          rowCounter.clear()
          colCounter.clear()
          scoreDigitCounter.clear()
          fieldX := U(getFieldOrig._1, FB_X_ADDRWIDTH bits)
          fieldY := U(getFieldOrig._2, FB_Y_ADDRWIDTH bits)
          goto(FETCH_ROW)
        }
      }

      val FETCH_ROW: State = new State {
        whenIsActive {
          runtimeRenderBusy := True
          readEnable := True
          goto(LOAD_ROW)
        }
      }

      val LOAD_ROW: State = new State {
        whenIsActive {
          runtimeRenderBusy := True
          rowBits := rowValue
          goto(DRAW_FIELD_BLOCK)
        }
      }

      val DRAW_FIELD_BLOCK: State = new State {
        whenIsActive {
          runtimeRenderBusy := True
          //clearBlockCommand(blockCommand)
          blockCommand.start := True
          blockCommand.x_orig := fieldX
          blockCommand.y_orig := fieldY
          blockCommand.width := U(block_len - 2)
          blockCommand.height := U(block_len - 2)
          blockCommand.in_color := fieldColor
          blockCommand.pat_color := U(bg_color_idx)
          blockCommand.fill_pattern := U(BlockFillPattern.SOLID)
          goto(WAIT_FIELD_BLOCK_DONE)
        }
      }

      val WAIT_FIELD_BLOCK_DONE: State = new State {
        whenIsActive {
          runtimeRenderBusy := True
          when(runtimeFieldBlockDone) {
            when(rowCounter.willOverflowIfInc && colCounter.willOverflowIfInc) {
              scoreDigitCounter.clear()
              scoreX := U(score_orig_x, FB_X_ADDRWIDTH bits)
              goto(DRAW_SCORE_DIGIT)
            } otherwise {
              when(colCounter.willOverflowIfInc) {
                colCounter.clear()
                rowCounter.increment()
                fieldX := U(getFieldOrig._1, FB_X_ADDRWIDTH bits)
                fieldY := fieldY + U(block_len)
                goto(FETCH_ROW)
              } otherwise {
                colCounter.increment()
                rowBits := rowBits |<< 1
                fieldX := fieldX + U(block_len)
                goto(DRAW_FIELD_BLOCK)
              }
            }
          }
        }
      }

      val DRAW_SCORE_DIGIT: State = new State {
        whenIsActive {
          runtimeRenderBusy := True
          driveTextCommand(
            cmd = scoreCommand,
            xOrig = scoreX,
            yOrig = U(score_orig_y, FB_Y_ADDRWIDTH bits),
            scale = U(score_scale, 3 bits),
            color = U(score_fg_color, IDX_W bits),
            word = U(3, 3 bits) @@ scoreCache.digits(scoreDigitCounter.value)
          )
          goto(WAIT_SCORE_DIGIT_DONE)
        }
      }

      val WAIT_SCORE_DIGIT_DONE: State = new State {
        whenIsActive {
          runtimeRenderBusy := True
          when(runtimeScoreCharDone) {
            when(scoreDigitCounter.willOverflowIfInc) {
              goto(COMPLETE)
            } otherwise {
              scoreDigitCounter.increment()
              scoreX := scoreX + U(score_width)
              goto(DRAW_SCORE_DIGIT)
            }
          }
        }
      }

      val COMPLETE: State = new State {
        whenIsActive {
          io.draw_field_done := True
          goto(IDLE)
        }
      }
    }
  }.setName("runtime_renderer")


val setupRenderer = new Area {
    val charCommand: DisplayCharCommand = DisplayCharCommand(IDX_W, FB_X_ADDRWIDTH, FB_Y_ADDRWIDTH)
    val blockCommand: DisplayBlockCommand = DisplayBlockCommand(IDX_W, FB_X_ADDRWIDTH, FB_Y_ADDRWIDTH)
    clearCharCommand(charCommand)
    clearBlockCommand(blockCommand)

    private val textX: UInt = Reg(UInt(FB_X_ADDRWIDTH bits)) init 0
    private val textY: UInt = Reg(UInt(FB_Y_ADDRWIDTH bits)) init 0
    private val textScale: UInt = Reg(UInt(3 bits)) init 0
    private val textColor: UInt = Reg(UInt(IDX_W bits)) init 0
    private val gameIsRunning: Bool = RegInit(False)

    def loadTextInfo(text: String, useBackgroundColor: Boolean = false): Unit = {
      textX := U(stringList(text).x_orig, FB_X_ADDRWIDTH bits)
      textY := U(stringList(text).y_orig, FB_Y_ADDRWIDTH bits)
      textScale := U(stringList(text).scale, 3 bits)
      if (useBackgroundColor) {
        textColor := U(bg_color_idx, IDX_W bits)
      } else {
        textColor := U(stringList(text).color, IDX_W bits)
      }
    }

    private val fsm: StateMachine = new StateMachine {
      lazy val SETUP_IDLE: State = makeInstantEntry()

      SETUP_IDLE.whenIsActive {
        when(io.draw_openning_start) {
          textRom.charCounter.clear()
          wallRom.wallCounter.clear()
          goto(CLEAN_SCREEN)
        }
      }

      val CLEAN_SCREEN: State = new State {
        onEntry {
          io.bf_clear_start := True
        }

        whenIsActive {
          when(io.bf_clear_done) {
            wallRom.wallCounter.clear()
            when(gameIsRunning) {
              textRom.charCounter.load(offset("Score"))
              loadTextInfo("Score")
              goto(DRAW_STATIC_TEXT)
            } otherwise {
              textRom.charCounter.clear()
              loadTextInfo("Tetris")
              goto(DRAW_OPENING_TEXT)
            }
          }
        }
      }

      val DRAW_OPENING_TEXT: State = new State {
        whenIsActive {
          driveTextCommand(
            cmd = charCommand,
            xOrig = textX,
            yOrig = textY,
            scale = textScale,
            color = textColor,
            word = textRom.word
          )
          goto(WAIT_OPENING_TEXT_DONE)
        }
      }

      val WAIT_OPENING_TEXT_DONE: State = new State {
        whenIsActive {
          when(setupCharDone) {
            when(textRom.isLast("Tetris")) {
              goto(WAIT_GAME_START)
            } otherwise {
              textRom.charCounter.increment()
              textX := textX + U(stringList("Tetris").width)
              goto(DRAW_OPENING_TEXT)
            }
          }
        }
      }

      val WAIT_GAME_START: State = new State {
        whenIsActive {
          when(io.game_start) {
            gameIsRunning := True
            goto(CLEAN_SCREEN)
          }
        }
      }

      val DRAW_STATIC_TEXT: State = new State {
        whenIsActive {
          driveTextCommand(
            cmd = charCommand,
            xOrig = textX,
            yOrig = textY,
            scale = textScale,
            color = textColor,
            word = textRom.word
          )
          goto(WAIT_STATIC_TEXT_DONE)
        }
      }

      val WAIT_STATIC_TEXT_DONE: State = new State {
        whenIsActive {
          when(setupCharDone) {
            when(textRom.isLast("Score")) {
              goto(DRAW_WALL)
            } otherwise {
              textRom.charCounter.increment()
              textX := textX + U(stringList("Score").width)
              goto(DRAW_STATIC_TEXT)
            }
          }
        }
      }

      val DRAW_WALL: State = new State {
        whenIsActive {
          blockCommand := wallRom.command
//          blockCommand.start := True
          goto(WAIT_WALL_DONE)
        }
      }

      val WAIT_WALL_DONE: State = new State {
        whenIsActive {
          when(setupBlockDone) {
            when(wallRom.wallCounter.willOverflowIfInc) {
              goto(RUNNING)
            } otherwise {
              wallRom.wallCounter.increment()
              goto(DRAW_WALL)
            }
          }
        }
      }

      val RUNNING: State = new State {
        whenIsActive {
          runtimeRenderEnable := True
          io.screen_is_ready := True

          when(io.game_restart) {
            // Functional fix: drop stale playfield requests on restart so UI redraw cannot replay old field data.
            clearPendingPlayfieldRender := True
            when(runtimeRenderBusy) {
              goto(WAIT_RUNTIME_IDLE)
            } otherwise {
              goto(CLEAN_SCREEN)
            }
          }
        }
      }

      val WAIT_RUNTIME_IDLE: State = new State {
        whenIsActive {
          clearPendingPlayfieldRender := True
          when(!runtimeRenderBusy) {
            goto(CLEAN_SCREEN)
          }
        }
      }
    }

    val fsmDebug = Bits()
    fsm.postBuild {
      fsmDebug := fsm.stateReg.asBits
    }


  }.setName("setup_renderer")

  private val selectedCharCommand: DisplayCharCommand = DisplayCharCommand(IDX_W, FB_X_ADDRWIDTH, FB_Y_ADDRWIDTH)
  private val selectedBlockCommand: DisplayBlockCommand = DisplayBlockCommand(IDX_W, FB_X_ADDRWIDTH, FB_Y_ADDRWIDTH)
  clearCharCommand(selectedCharCommand)
  clearBlockCommand(selectedBlockCommand)

  private val charStartCollision: Bool = setupRenderer.charCommand.start && runtimeRenderer.scoreCommand.start
  private val blockStartCollision: Bool = setupRenderer.blockCommand.start && runtimeRenderer.blockCommand.start
  private val drawStartCollision: Bool =
    setupRenderer.charCommand.start && (setupRenderer.blockCommand.start || runtimeRenderer.blockCommand.start) ||
    runtimeRenderer.scoreCommand.start && (setupRenderer.blockCommand.start || runtimeRenderer.blockCommand.start)

  assert(!charStartCollision, "display_controller: setup and runtime score char commands must not start together", severity = FAILURE)
  assert(!blockStartCollision, "display_controller: setup and runtime block commands must not start together", severity = FAILURE)
  assert(!drawStartCollision, "display_controller: char and block engines must not receive start in the same cycle", severity = FAILURE)

  when(setupRenderer.charCommand.start) {
    selectedCharCommand := setupRenderer.charCommand
  } otherwise {
    when(runtimeRenderer.scoreCommand.start) {
      selectedCharCommand := runtimeRenderer.scoreCommand
    }
  }

  when(setupRenderer.blockCommand.start) {
    selectedBlockCommand := setupRenderer.blockCommand
  } otherwise {
    when(runtimeRenderer.blockCommand.start) {
      selectedBlockCommand := runtimeRenderer.blockCommand
    }
  }

  private val charOwnerIsSetup: Bool = RegInit(False)
  when(selectedCharCommand.start) {
    charOwnerIsSetup := setupRenderer.charCommand.start
  }

  private val blockOwnerIsSetup: Bool = RegInit(False)
  when(selectedBlockCommand.start) {
    blockOwnerIsSetup := setupRenderer.blockCommand.start
  }

  setupCharDone := io.draw_char.done && charOwnerIsSetup
  runtimeScoreCharDone := io.draw_char.done && !charOwnerIsSetup
  setupBlockDone := io.draw_block.done && blockOwnerIsSetup
  runtimeFieldBlockDone := io.draw_block.done && !blockOwnerIsSetup

  io.draw_char.start := selectedCharCommand.start
  io.draw_char.word := selectedCharCommand.word
  io.draw_char.scale := selectedCharCommand.scale
  io.draw_char.color := selectedCharCommand.color

  io.draw_block.start := selectedBlockCommand.start
  io.draw_block.width := selectedBlockCommand.width
  io.draw_block.height := selectedBlockCommand.height
  io.draw_block.in_color := selectedBlockCommand.in_color
  io.draw_block.pat_color := selectedBlockCommand.pat_color
  io.draw_block.fill_pattern := selectedBlockCommand.fill_pattern

  io.draw_x_orig := 0
  io.draw_y_orig := 0
  when(selectedCharCommand.start) {
    io.draw_x_orig := selectedCharCommand.x_orig
    io.draw_y_orig := selectedCharCommand.y_orig
  } otherwise {
    when(selectedBlockCommand.start) {
      io.draw_x_orig := selectedBlockCommand.x_orig
      io.draw_y_orig := selectedBlockCommand.y_orig
    }
  }
}

object displayControllerMain {
  def main(args: Array[String]): Unit = {
    val FB_WIDTH = 320
    val FB_HEIGHT = 240
    val pfConfig = TetrisPlayFeildConfig(
      block_len = 9,
      wall_width = 9,
      x_orig = 50,
      y_orig = 20,
      piece_ft_color = 9,
      piece_bg_color = 2
    )

    val config = DisplayControllerConfig(
      FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
      FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
      bg_color_idx = 2,
      playFieldConfig = pfConfig
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
      gen = new display_controller(config)
    )
  }
}
