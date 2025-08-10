package IPS.string_draw_engine

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._
import utils.PathUtils

import scala.collection.mutable
import config._

case class StringDrawEngConfig (
                                IDX_W : Int = 4,
                                FB_X_ADDRWIDTH : Int,
                                FB_Y_ADDRWIDTH : Int,
                                bg_color_idx  : Int ,
                                playFieldConfig : TetrisPlayFeildConfig
                              ) {
  case class charInfo(
                       x_orig : Int,
                       y_orig : Int,
                       width  : Int,
                       scale  : Int,
                       color  : Int
                     )

  import playFieldConfig._
  val stringList = mutable.LinkedHashMap(
    // Content -> x,_orig, y_orig, width(include margin) , scale, color
    "Tetris"  -> charInfo(28,  66, 46, 2,  6 ),
    "Score"   -> charInfo(218, 23, 12, 0,  6 )
  )

  val wallInfoLsit = List(
    //x, y , width, height, color, pattern_colorm, fill_pattern
    List(x_orig, y_orig, wall_width, wall_height, 0, 15, 3),   /* Left Wall */
    List(getRightWallOrig._1, getRightWallOrig._2, wall_width, wall_height, 0, 15, 3), /*Right Wall */
    List(getBaseOrig._1, getBaseOrig._2, base_width, base_height, 0, 15, 3), /* Base */
    List(218, 10, 2, 222, 15, 14 , 0 )  /* Split */
  )

  def wallRomInit( bitLengths : List[Int] ) = wallInfoLsit.map { row =>  /* First word is stored at the least position */
    val (packedWord, _) = (row zip bitLengths).foldLeft(BigInt(0), 0) { case ((accWord, currentShift), (value, bitLength)) =>
      println(f"[DEBUG] value = 0x${value}%x , currentShift = ${currentShift}%d, accWord = 0x${accWord}%x")
      val shiftedValue = BigInt(value) << currentShift
      (accWord | shiftedValue, currentShift + bitLength)
    }
    println(f"0x${packedWord}%x ")
    packedWord
  }
}

class string_draw_engine ( config : StringDrawEngConfig )  extends Component {

  import config._

  val io = new Bundle {
    val draw_openning_start = in Bool()
    val game_start = in Bool()
    val clear_playfield = in Bool()
    val draw_done = in Bool()
    val screen_is_ready = out Bool()
    val draw_char_start     = out Bool()
    val draw_char_word = out UInt (7 bit)
    val draw_char_scale = out UInt (3 bits)
    val draw_char_color = out UInt (IDX_W bits)
    val draw_block_start = out Bool() default False
    val draw_x_orig = out UInt (FB_X_ADDRWIDTH bits) default 0
    val draw_y_orig = out UInt (FB_Y_ADDRWIDTH bits) default 0
    val draw_block_width = out UInt (8 bits) default 0
    val draw_block_height = out UInt (8 bits) default 0
    val draw_block_color = out UInt (IDX_W bits) default 0
    val draw_block_pat_color = out UInt (IDX_W bits) default 0
    val draw_block_fill_pattern = out UInt (2 bits) default 0

  }

  noIoPrefix()

  val charactors = new Area {



    val keyLengths = stringList.keys.map(_.length).toList

    //val offset = keyLengths.scanLeft(0)(_ + _).dropRight(1)
    val offset =  stringList.keys zip ( keyLengths.scanLeft(0)(_ + _).dropRight(1) )  toMap

    val rom = Mem(UInt(7 bits), keyLengths.sum )
    rom.addAttribute("ram_style", "distributed")

    val romInitialContent = scala.collection.mutable.ArrayBuffer[BigInt]()

    stringList.keys.foreach { keyString =>
      romInitialContent ++=  keyString.map{ char => BigInt(char.toInt.toHexString, 16) }
    }

    romInitialContent.foreach( a => println(s"$a"))
    rom.initBigInt(romInitialContent)

    val cnt = Counter(rom.wordCount)

    val isLast = offset.map {
      case (key, value) =>
        println(s"key = $key, value = $value, offset = ${value + key.length - 1}")
        key -> (cnt === (value + key.length - 1))
    }
    io.draw_char_word := rom.readAsync(cnt)

  } .setName("")

  val wall = new Area {

    val x = cloneOf(io.draw_x_orig)
    val y = cloneOf(io.draw_y_orig)
    val outputList = List(x,y, io.draw_block_width, io.draw_block_height, io.draw_block_color, io.draw_block_pat_color, io.draw_block_fill_pattern)

    val bitLengths = outputList.map( _.getBitsWidth )

    val wordWidth = bitLengths.sum

    val wall_rom = Mem(Bits(wordWidth bits), wallInfoLsit.size)

    wall_rom.initBigInt( wallRomInit(bitLengths) )

    val cnt = Counter(wallInfoLsit.size)

    val blockInfo = wall_rom.readAsync(cnt)

    //  Unpack and connect
    def getOffsetAfterConnect(l: List[UInt]): Int = l match {
      case Nil => 0
      case h :: l =>
        val offset = getOffsetAfterConnect(l)
        //h := blockInfo(offset, h.getBitsWidth bits)  // word extraction and connect
        h.assignFromBits( blockInfo(offset, h.getBitsWidth bits) )
        h.getBitsWidth + offset
    }

    getOffsetAfterConnect(outputList.reverse)
  }

  def genOutputReg[T <: Data](that: T, isReg : Boolean = true): T = {
    val ret = cloneOf(that)
    if (isReg)  ret setAsReg()
    that := ret
    ret
  }

  val x = genOutputReg(io.draw_x_orig)
  val y = genOutputReg(io.draw_y_orig)
  val scale = genOutputReg(io.draw_char_scale)
  val color = genOutputReg(io.draw_char_color)

  val start_char_draw = genOutputReg( io.draw_char_start, false )
  val start_block_draw = genOutputReg( io.draw_block_start , false )

  def load_chars_info( str : String, colorRm : Boolean = false ) = {
    x := stringList(str).x_orig
    y := stringList(str).y_orig
    scale := stringList(str).scale
    if ( colorRm ) {  // Remove it by painting background color
      color := bg_color_idx
    } else {
      color := stringList(str).color
    }
  }

  val logoHasRm = RegInit(False)


  val fsm = new StateMachine {

    start_char_draw := False
    start_block_draw := False
    io.screen_is_ready := False

    charactors.cnt.willIncrement := False

    val IDLE = makeInstantEntry()

    IDLE.whenIsActive {
      when( io.draw_openning_start ) {
        load_chars_info("Tetris")
        goto(START_DRAW_OPEN)
      }

    }

    val START_DRAW_OPEN : State = new State {
      whenIsActive {
        start_char_draw := True
        goto(WAIT_DRAW_OPEN_DONE)
      }

    }

    val WAIT_DRAW_OPEN_DONE :  State = new State {

      whenIsActive {
        when(io.draw_done) {
          charactors.cnt.increment()
          when(charactors.isLast("Tetris")) {
            goto(WAIT_GAME_START)
          } otherwise {
            x := x + stringList("Tetris").width
            goto(START_DRAW_OPEN)
          }
        }
      }
    }

    val WAIT_GAME_START : State = new State {
      whenIsActive {
        when ( logoHasRm ) {
          load_chars_info("Score")
          logoHasRm := False
          goto(START_DRAW_STRING)
        } .elsewhen( io.game_start ) {
          load_chars_info("Tetris", true )
          logoHasRm := True
          charactors.cnt.clear()
          goto(START_DRAW_OPEN)
        }
      }

    }

    val START_DRAW_STRING : State = new State {
      whenIsActive {
        start_char_draw := True
        goto(WAIT_DRAW_STRING_DONE)
      }
    }

    val WAIT_DRAW_STRING_DONE :  State = new State {

      whenIsActive {
        when(io.draw_done) {
          charactors.cnt.increment()
          when(charactors.isLast("Score")) {
            goto(WAIT_DRAW_SCORE)
          } otherwise {
            x := x + stringList("Score").width
            goto(START_DRAW_STRING)
          }
        }
      }
    }


    val WAIT_DRAW_SCORE : State = new State {

      whenIsActive {
        goto(PRE_DRAW_WALL)
      }

    }

    val PRE_DRAW_WALL : State = new State {
      whenIsActive {
        x := wall.x
        y := wall.y
        goto(START_DRAW_WALL )
      }

    }

    val START_DRAW_WALL : State = new State {
      whenIsActive {
        start_block_draw := True
        goto(WAIT_DRAW_WALL_DONE)
      }
    }

    val WAIT_DRAW_WALL_DONE : State = new State {

      whenIsActive {
        when ( io.draw_done ) {
          wall.cnt.increment()
          when ( wall.cnt.willOverflow ) {
            goto(DRAW_SCORE)
          } otherwise {
            goto(PRE_DRAW_WALL)
          }
        }
      }

    }

    val DRAW_SCORE : State = new State {

      whenIsActive {
        io.screen_is_ready := True
        x := 0
        y := 0
      }
    }

  }


  val fsm_debug = Bits()

  fsm.postBuild{
    fsm_debug := fsm.stateReg.asBits
  }

}

object drawFsmMain{
  def main(args: Array[String]) {


    val FB_WIDTH = 320
    val FB_HEIGHT  = 240
    val pfConfig = TetrisPlayFeildConfig(
      block_len = 9,
      wall_width = 9,
      x_orig = 50,
      y_orig = 20,
      piece_ft_color = 9,
      piece_bg_color = 2
    )

    val config = StringDrawEngConfig(
      FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
      FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
      IDX_W = 4,
      bg_color_idx = 2,
      playFieldConfig = pfConfig
    )

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new string_draw_engine(config)
    )
  }
}