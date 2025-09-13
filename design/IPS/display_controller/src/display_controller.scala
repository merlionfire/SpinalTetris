package IPS.display_controller

import IPS.string_draw_engine.StringDrawEngConfig
import spinal.core._
import spinal.lib._
import spinal.lib.fsm._
import config._
import utils.PathUtils

import scala.collection.mutable


case class DisplayControllerConfig(
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
    // Content -> x,_orig, y_orig, width(include margin) , scale, in_color
    "Tetris"  -> charInfo(24,  66, 46, 2,  6 ),
    "Score"   -> charInfo(210, 23, 12, 0,  6 )
  )


  val keyLengths = stringList.keys.map(_.length).toList

  //val offset = keyLengths.scanLeft(0)(_ + _).dropRight(1)
  val offset =  stringList.keys zip ( keyLengths.scanLeft(0)(_ + _).dropRight(1) )  toMap


  val wallInfoLsit = List(
    //x, y , width, height, in_color, pattern_colorm, fill_pattern
    List(x_orig, y_orig, wall_width, wall_height, 0, 15, 3),   /* Left Wall */
    List(getRightWallOrig._1, getRightWallOrig._2, wall_width, wall_height, 0, 15, 3), /*Right Wall */
    List(getBaseOrig._1, getBaseOrig._2, base_width, base_height, 0, 15, 3), /* Base */
    List(190, 10, 2, 222, 15, 14 , 0 )  /* Split */
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


class draw_char_if( colorBitsWidth : Int) extends Bundle with IMasterSlave {
  val start = Bool()
  val word  = UInt (7 bit)
  val scale = UInt (3 bits)
  val color = UInt ( colorBitsWidth bits)
  val done  = Bool ()


  override def asMaster(): Unit = {
    out(start, word, scale, color )
    in(done)
  }

  override def asSlave(): Unit = {
    in(start, word, scale, color )
    out(done)
  }
}

class draw_block_if( colorBitsWidth : Int) extends Bundle with IMasterSlave {
  val start = Bool() default False
  val width  = UInt (8 bits) default 0
  val height = UInt (8 bits) default 0
  val in_color =  UInt (colorBitsWidth bits) default 0
  val pat_color =  UInt (colorBitsWidth bits) default 0
  val fill_pattern = UInt (2 bits) default 0
  val done = Bool() default( False )

  override def asMaster(): Unit = {
    out(start, width, height, in_color, pat_color, fill_pattern  )
    in(done)
  }

  override def asSlave(): Unit = {
    in(start, width,height, in_color, pat_color, fill_pattern  )
    out(done)
  }

  def getList = List( width, height, in_color,pat_color, fill_pattern )
}




class display_controller ( config : DisplayControllerConfig )  extends Component  {

  import config._
  import config.playFieldConfig._

  val io = new Bundle {
    val game_restart  = in Bool()
    val draw_openning_start = in Bool()
    val game_start = in Bool()
    val row_val =  slave Flow( Bits(colBlocksNum bits) )
    val screen_is_ready = out Bool()

    val draw_char = master( new draw_char_if(IDX_W))
    val draw_block = master( new draw_block_if(IDX_W))

    val draw_x_orig = out UInt (FB_X_ADDRWIDTH bits) default 0
    val draw_y_orig = out UInt (FB_Y_ADDRWIDTH bits) default 0

    val draw_field_done = out Bool()
    val bf_clear_start = out Bool()
    val bf_clear_done = in Bool()
  }

  noIoPrefix()

  val update_playfield = new Area {

    // Sync-write and Sync-read
    val memory = Mem(Bits(colBlocksNum bits), rowBlocksNum)
    memory.addAttribute("ram_style", "distributed")

    //*****************************************************
    //              Write
    //*****************************************************
    val wr_row_cnt = Counter(stateCount = rowBlocksNum, io.row_val.valid )

    memory.write(
      address = wr_row_cnt,
      data    = io.row_val.payload,
      enable  = io.row_val.valid
    )

    //*****************************************************
    //              Read
    //*****************************************************

    val rd_en = Bool()
    val row_cnt_inc = Bool()
    val col_cnt_inc = Bool()
    val col_cnt = Counter(stateCount = colBlocksNum, col_cnt_inc  )
    val row_cnt = Counter(stateCount = rowBlocksNum, row_cnt_inc  )


    val row_value = memory.readSync(
      address = row_cnt,
      enable = rd_en
    )


    val load = Bool()
    val shift_en = Bool()
    val row_bits = cloneOf(row_value ) setAsReg()
    val row_bits_next = row_bits |>> 1
    val gen_start = io.row_val.valid.fall(False)

    when ( load ) {
      row_bits := row_value
    } .elsewhen( shift_en ) {
      row_bits := row_bits_next
    }

    val ft_color = U(piece_bg_color, IDX_W bits)
    when (row_bits.lsb ) {
      ft_color  := piece_ft_color
    }


    val x = RegInit( U(0,  FB_X_ADDRWIDTH bits) )
    val y = RegInit( U(0,  FB_Y_ADDRWIDTH bits) )
    val x_next = x + U(block_len)
    val y_next = y + U(block_len)

    when (gen_start ) {
      x := U(getFieldOrig._1)
      y := U(getFieldOrig._2)
    }

    when( io.draw_field_done ) {
      x := U(0)
      y := U(0)
    } .otherwise {

      when(col_cnt.willOverflow) {
        x := U(getFieldOrig._1)
      }.elsewhen(col_cnt_inc) {
        x := x_next
      }

      when(row_cnt_inc) {
        y := y_next
      }

    }

    val itf = new draw_block_if(IDX_W)

    itf.start := False
    itf.in_color := ft_color
    itf.width := U( block_len-1 ) // -1 because draw_block_engine.io.width = N-1 where N is total width
    itf.height:= U( block_len-1 ) // -1 because draw_block_engine.io.width = N-1 where N is total width
    itf.fill_pattern := U(0) // solid
    itf.pat_color := U(0)
    io.draw_field_done := False


    val fsm = new StateMachine {

      rd_en := False
      load := False
      col_cnt_inc := False
      row_cnt_inc := False
      shift_en := False

      val IDLE = makeInstantEntry()
      IDLE.whenIsActive {
        when(gen_start ) {
          goto(FETCH)
        }
      }

      val FETCH : State = new State {
        whenIsActive {
          rd_en := True
          goto(DATA_READY)
        }
      }

      val DATA_READY : State = new State {
        whenIsActive {
          load := True
          goto(DRAW)
        }
      }

      val DRAW : State = new State {
        whenIsActive {
          itf.start := True
          goto(WAIT_DONE)
        }

      }

      val WAIT_DONE : State = new State {
        whenIsActive {
          when(itf.done) {
            when(row_cnt.willOverflowIfInc && col_cnt.willOverflowIfInc ) {
              row_cnt_inc := True
              col_cnt_inc := True
              io.draw_field_done := True
              goto(IDLE)
            } otherwise {
              col_cnt_inc := True
              when(col_cnt.willOverflowIfInc) {
                row_cnt_inc := True
                goto(FETCH)
              } otherwise {
                shift_en := True
                goto(DRAW)
              }
            }
          }
        }
      }


    }


  } .setName("")



  val allStrings = new Area {

    val itf = new draw_char_if(IDX_W)
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

    itf.word := rom.readAsync(cnt)

  } .setName("")

  val wall = new Area {

    /*

    val outputList = List(x,y, io.draw_block.width, io.draw_block.height, io.draw_block.in_color, io.draw_block.pat_color, io.draw_block.fill_pattern)
*/
    val x = cloneOf(io.draw_x_orig)
    val y = cloneOf(io.draw_y_orig)
    val itf = new draw_block_if( IDX_W )
    val outputList = x :: y :: itf.getList

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

  } .setName("")



  val setup_fsm = new Area {
    def genOutputReg[T <: Data](that: T, isReg: Boolean = true): T = {
      val ret = cloneOf(that)
      if (isReg) ret setAsReg()
      that := ret
      ret
    }

    /*
    val x = genOutputReg(io.draw_x_orig)
    val y = genOutputReg(io.draw_y_orig)
    */
    val x = RegInit( U(0,  FB_X_ADDRWIDTH bits) )
    val y = RegInit( U(0,  FB_Y_ADDRWIDTH bits) )



    val scale = genOutputReg(allStrings.itf.scale)
    val color = genOutputReg(allStrings.itf.color)

    val start_char_draw = genOutputReg(allStrings.itf.start,  false)
    val start_block_draw = genOutputReg(wall.itf.start,       false)

    def load_chars_info(str: String, colorRm: Boolean = false) = {
      x := stringList(str).x_orig
      y := stringList(str).y_orig
      scale := stringList(str).scale
      if (colorRm) { // Remove it by painting background in_color
        color := bg_color_idx
      } else {
        color := stringList(str).color
      }
    }


    //val logoHasRm = RegInit(False)
    val game_is_running = RegInit(False)

    val fsm = new StateMachine {

      start_char_draw := False
      start_block_draw := False
      io.screen_is_ready := False
      io.bf_clear_start := False
      allStrings.cnt.willIncrement := False

      val SETUP_IDLE = makeInstantEntry()

      SETUP_IDLE.whenIsActive {
        game_is_running := False
        when(io.draw_openning_start) {
          goto(CLEAN_SCREEN)
        }

      }

      val CLEAN_SCREEN : State = new State {
        onEntry {
          io.bf_clear_start := True
        }

        whenIsActive {
          when ( io.bf_clear_done ) {
            when ( game_is_running )  {
              load_chars_info("Score")
              allStrings.cnt.load( offset("Score") )  // Reset offset index to "Score"
              goto(START_DRAW_STRING)
            } .otherwise {
              load_chars_info("Tetris")
              goto(START_DRAW_OPEN)
            }

          }

        }
      }

      val START_DRAW_OPEN: State = new State {
        whenIsActive {
          start_char_draw := True
          goto(WAIT_DRAW_OPEN_DONE)
        }

      }

      val WAIT_DRAW_OPEN_DONE: State = new State {

        whenIsActive {
          when(allStrings.itf.done) {
            allStrings.cnt.increment()
            when(allStrings.isLast("Tetris")) {
              goto(WAIT_GAME_START)
            } otherwise {
              x := x + stringList("Tetris").width
              goto(START_DRAW_OPEN)
            }
          }
        }
      }

      val WAIT_GAME_START: State = new State {
        whenIsActive {
          /*
          when(logoHasRm) {
            load_chars_info("Score")
            logoHasRm := False
            goto(START_DRAW_STRING)
          }.elsewhen(io.game_start) {
            load_chars_info("Tetris", true)
            logoHasRm := True
            allStrings.cnt.clear()
            goto(START_DRAW_OPEN)
          }
*/
          when (io.game_start) {
            game_is_running := True
            goto(CLEAN_SCREEN)
          }

        }

      }

      val START_DRAW_STRING: State = new State {
        whenIsActive {
          start_char_draw := True
          goto(WAIT_DRAW_STRING_DONE)
        }
      }

      val WAIT_DRAW_STRING_DONE: State = new State {

        whenIsActive {
          when(allStrings.itf.done) {
            allStrings.cnt.increment()
            when(allStrings.isLast("Score")) {
              goto(WAIT_DRAW_SCORE)
            } otherwise {
              x := x + stringList("Score").width
              goto(START_DRAW_STRING)
            }
          }
        }
      }


      val WAIT_DRAW_SCORE: State = new State {

        whenIsActive {
          goto(PRE_DRAW_WALL)
        }

      }

      val PRE_DRAW_WALL: State = new State {
        whenIsActive {
          x := wall.x
          y := wall.y
          goto(START_DRAW_WALL)
        }

      }

      val START_DRAW_WALL: State = new State {
        whenIsActive {
          start_block_draw := True
          goto(WAIT_DRAW_WALL_DONE)
        }
      }

      val WAIT_DRAW_WALL_DONE: State = new State {

        whenIsActive {
          when(wall.itf.done) {
            wall.cnt.increment()
            when(wall.cnt.willOverflow) {
              goto(DRAW_SCORE)
            } otherwise {
              goto(PRE_DRAW_WALL)
            }
          }
        }

      }

      val DRAW_SCORE: State = new State {

        whenIsActive {
          io.screen_is_ready := True
          x := 0
          y := 0

          when ( io.game_restart ) {
            goto(CLEAN_SCREEN)
          }
        }
      }

    }

    val fsm_debug = Bits()

    fsm.postBuild {
      fsm_debug := fsm.stateReg.asBits
    }
  } .setName("stepup")


  // connect draw_char_engine interface
  io.draw_char <> allStrings.itf

  // connect draw_block_engine interface
  io.draw_block.start :=  update_playfield.itf.start  || wall.itf.start
  io.draw_block.width := update_playfield.itf.start  ? update_playfield.itf.width | wall.itf.width
  io.draw_block.height := update_playfield.itf.start  ? update_playfield.itf.height | wall.itf.height
  io.draw_block.in_color := update_playfield.itf.start  ? update_playfield.itf.in_color | wall.itf.in_color
  io.draw_block.pat_color := wall.itf.pat_color  // ?
  io.draw_block.fill_pattern := update_playfield.itf.start  ? update_playfield.itf.fill_pattern | wall.itf.fill_pattern
  update_playfield.itf.done := io.draw_block.done
  wall.itf.done := io.draw_block.done

  // connect fb_addr interface
  io.draw_x_orig := update_playfield.x |  setup_fsm.x
  io.draw_y_orig := update_playfield.y |  setup_fsm.y


}

object displayControllerMain{
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

    val config = DisplayControllerConfig(
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
      mergeAsyncProcess = true,
      inlineRom = true
    ).generateVerilog(
      gen = new display_controller((config))
    )
  }
}
