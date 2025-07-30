package IPS.piece_draw_engine

import IPS.string_draw_engine.StringDrawEngConfig
import spinal.core._
import spinal.lib._
import spinal.lib.fsm._
import config._
import utils.PathUtils

case class PieceDrawEngConfig (
                                IDX_W : Int = 4,
                                FB_X_ADDRWIDTH : Int,
                                FB_Y_ADDRWIDTH : Int,
                                playFieldConfig : TetrisPlayFeildConfig
                              )


class piece_draw_engine(config : PieceDrawEngConfig )  extends Component {
  import config._
  import config.playFieldConfig._

  val io = new Bundle {
    val row_val =  slave Flow( Bits(colBlocksNum bits) )
    val length    = out UInt (8 bits)
    val ft_color  = out UInt (IDX_W bits)
    val fill_pattern = out UInt(2 bits)  // 0:solid, 1:border, 2: border+dot
    val start_draw = out Bool()
    val draw_x_orig = out UInt(FB_X_ADDRWIDTH bits )
    val draw_y_orig = out UInt(FB_Y_ADDRWIDTH bits )
    val draw_done = in Bool()
    val gen_done = out Bool()
  }

  noIoPrefix()

  // Sync-write and Sync-read
  val memory = Mem(Bits(colBlocksNum bits), rowBlocksNum)


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

  when( io.gen_done ) {
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

  io.draw_x_orig := x
  io.draw_y_orig := y



  io.ft_color := ft_color
  io.length := U( block_len-1 ) // -1 because draw_block_engine.io.width = N-1 where N is total width
  io.fill_pattern := U(0) // solid
  io.gen_done := False
  io.start_draw := False

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
        io.start_draw := True
        goto(WAIT_DONE)
      }

    }

    val WAIT_DONE : State = new State {
      whenIsActive {
        when(io.draw_done) {
          when(row_cnt.willOverflowIfInc && col_cnt.willOverflowIfInc ) {
            row_cnt_inc := True
            col_cnt_inc := True
            io.gen_done := True
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

}


object pieceDrawGenMain{
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

    val config = PieceDrawEngConfig(
      FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
      FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
      IDX_W = 4,
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
      gen = new piece_draw_engine(config)
    )
  }
}