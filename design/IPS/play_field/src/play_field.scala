package IPS.play_field

import spinal.core._
import spinal.lib._
import spinal.lib.fsm.{State, StateMachine}
import utils._

import scala.collection.mutable.ArrayBuffer

case class PlayFieldConfig(
                            rowBlocksNum : Int,
                            colBlocksNum : Int,
                            rowBitsWidth : Int,
                            colBitsWidth : Int
)

class shift_ctrl () extends  Component {

  val io = new Bundle {
    val full_in = in Bool()
    val full_out = out Bool()
    val full_locked = in Bool()
    val lock = in Bool()
    val restart = in Bool()
    val shift = in Bool()
    val clear = in Bool()
    val holes_in = in Bool()
    val holes_out = out Bool()
    val shift_en = out Bool()
    val clear_en = out Bool()
  }

  val full_wire = Bool()
  val full_reg = RegNext(full_wire) init False

  when ( io.lock ) {
    full_wire := io.full_locked
  } elsewhen( io.shift_en ) {
    full_wire := io.full_in
  } otherwise {
    full_wire := full_reg
  }



  io.full_out := full_reg
  io.holes_out := io.holes_in || full_reg
  io.shift_en := io.holes_out && io.shift
  io.clear_en := io.restart || ( io.clear && full_reg )
}


class row_blocks(colBitsWidth : Int )  extends Component{

  val io = new Bundle {
    val row = in Bool()
    val cols = in Bits( colBitsWidth bits )
    val block_pos = in Bits(colBitsWidth bits )
    val shift = in Bool()
    val update = in Bool()
    val block_set = in Bool()
    val clear = in Bool()
    val blocks_out = out Bits (colBitsWidth bits )
    val full = out Bool()

  }

  io.full := io.blocks_out.andR
  val clear_blocks = io.clear
  val row_update = io.update & io.row

  case class block(  col_idx : Int  ) extends Area {
    val set_enable =   row_update &  io.cols(col_idx)
    val p =  RegNextWhen(io.block_pos(col_idx), io.shift ) init(False)
    //p.clearWhen(clear_blocks)
    //p.setWhen(set_enable)
    p.setWhen(set_enable & io.block_set)
    p.clearWhen(clear_blocks || ( set_enable & ! io.block_set ))

    io.blocks_out(col_idx) := io.row & p
  }

  for( col_idx <- 0 until colBitsWidth ) {
    block(col_idx)
  }

}

class play_field (config : PlayFieldConfig ) extends Component {

  import config._

  val io = new Bundle {
    val block_pos  = slave  Flow( Block(colBitsWidth , rowBitsWidth) )
    //val block_pos = slave Stream (rdMemBus(log2Up(rowNum)))
    //val wr = slave Stream (wrMemBus(log2Up(rowNum), colNum))
    //val rd_data = out Bits (colNum bits)
    val update = in Bool()
    val clear_start = in Bool()
    val block_set = in Bool()
    val restart = in Bool()
    val fetch = in Bool()
    val clear_done = out Bool()
    val block_val=  master Flow( Bool() )
    val row_val =  master Flow( Bits(colBlocksNum bits) )
    val lines_cleared = master Flow(UInt(log2Up(rowBlocksNum) bits )) setAsReg()
  }

  noIoPrefix()
  val enable_rows = Bool()
  val lock = Bool()
  val clear = Bool()
  val shift = Bool()
  val shift_done = Bool()

  val rows_full = Reg( Bits( rowBlocksNum bits ) ) init 0

  io.lines_cleared.valid.init(False)
  io.lines_cleared.payload := CountOne(rows_full)



  // Comment it because of usage of normal registers for each blocks taking up play field rather than memory
  // This change is due to more flexible functions of register to match multiple Tetromino process like update, line remove.
  /*
  val mem = Mem(Bits(colNum bits), wordCount = rowNum) simPublic()

  //mem.addAttribute("ram_style", "distributed")

  mem.write(
    enable = io.wr.valid,
    address = io.wr.address,
    data = io.wr.data
  )

  io.rd_data := mem.readSync(
    enable = io.rd.valid,
    address = io.rd.address
  )

  io.rd.ready := True
  io.wr.ready := True



  val debug_content = Vec.fill(rowNum)(Bits(colNum bits))

  for ( i <- 0 until rowNum ) {
    debug_content(i) := mem(U(i, log2Up(rowNum) bits))

  }
  */

  //io.block_pos.ready := True
  //io.rd.ready := True
  //io.wr.ready := True

  //-----------------------------------------------------------
  //     address decoder
  //-----------------------------------------------------------

  val rowsblocks = Vec(Bits (colBlocksNum bits ), rowBlocksNum )

  val cols_select = Reg(Bits( colBlocksNum  bits )) init B(0)

  when ( io.block_pos.valid) {
    switch(io.block_pos.x) {
      for (col <- 1 to colBlocksNum) {
        is(U(col, colBitsWidth bits)) {
          cols_select := B((1 << col - 1), colBlocksNum bits)
        }
      }

      default {
        cols_select := Bits(colBlocksNum bits).assignDontCare()
      }

    }
  }

  val rows_select = Reg(Bits( rowBlocksNum  bits ) ) init B(0)

  when ( enable_rows ) { rows_select.setAll() }
  when ( io.block_pos.valid) {
    switch(io.block_pos.y) {
      for (row <- 0 until rowBlocksNum) {
        is(U(row, rowBitsWidth bits)) {
          rows_select := B((1 << row), rowBlocksNum bits)
        }
      }
      default {
        rows_select := Bits(rowBlocksNum bits).assignDontCare()
      }
    }
  }



  val fetch_runing = RegInit( False )
  when ( io.fetch ) {
    fetch_runing.set()
    rows_select := (0 -> true, default -> false)
  } .elsewhen(rows_select.msb ) {
    fetch_runing.clear()
  }

  /*
  when ( fetch_runing || io.fetch ) {
    rows_select := rows_select.takeLow(rowBlocksNum-1) ## io.fetch
  }
  */

  when ( fetch_runing ) {
    rows_select := rows_select |<< 1
  }


  val clear_fsm = new StateMachine {

    enable_rows := False
    lock := False
    clear := False
    shift := False
    io.clear_done := False
    io.lines_cleared.valid := False

    val IDLE = makeInstantEntry()
    IDLE.whenIsActive{
      when ( io.clear_start ) {
        goto(ENABLE_ROWS)
      }

    }


    val ENABLE_ROWS : State = new State {
      whenIsActive {
        enable_rows := True
        goto(ROWS_FULL_READY)
      }

    }

    val ROWS_FULL_READY : State = new State {
      whenIsActive {
        goto(LOCK)
      }

    }

    val LOCK : State = new State {
      whenIsActive {
        lock := True
        goto( CHECK )
      }


    }

    val CHECK :State = new State {
      whenIsActive {

        when ( rowCtrl(0).io.holes_out ) {
          goto(CLEAR)
        } otherwise  {
          io.clear_done := True
          goto(IDLE)
        }
      }

      onExit {
        when ( ! io.clear_done ) {
          io.lines_cleared.valid := True
        }


      }


    }


    val CLEAR :State = new State {

      whenIsActive {
        clear := True
        goto( SHIFT )
      }
    }

    val SHIFT :State = new State {

      whenIsActive {
        shift := True

        when ( shift_done ) {
          goto(ENABLE_ROWS)
        }
      }
    }

  }


  //-----------------------------------------------------------
  //     instantiate each row component
  //-----------------------------------------------------------

  val update_en = RegNext( io.block_pos.valid & io.update )
  val rowBlock = ArrayBuffer[row_blocks]()
  val rowCtrl = ArrayBuffer[shift_ctrl]()


  for ( row <- 0 until rowBlocksNum ) {
    rowBlock += new row_blocks(colBlocksNum) setName (f"row_$row")
    rowCtrl += new shift_ctrl() setName (f"shift_ctrl_$row")
  }



  for ( row <- 0 until rowBlocksNum ) {
    rowCtrl(row).io.shift := shift
    rowCtrl(row).io.lock := lock
    rowCtrl(row).io.clear := clear
    rowCtrl(row).io.restart := io.restart
    //rowCtrl(row).io.full_locked :=   rowBlock(row).io.full
    rowCtrl(row).io.full_locked := rows_full(row)

    row match {
      case 0 => rowCtrl(0).io.full_in := False
      case _ => rowCtrl(row).io.full_in := rowCtrl(row - 1).io.full_out
    }

    row match {
      case i if i == (rowBlocksNum - 1 )  => rowCtrl(i).io.holes_in := False
      case n => rowCtrl(n).io.holes_in := rowCtrl(n + 1).io.holes_out
    }

    row match {
      case 0 => rowBlock(row).io.block_pos := B(0)
      case _ => rowBlock(row).io.block_pos := rowsblocks(row - 1)
    }

    rowBlock(row).io.shift  := rowCtrl(row).io.shift_en
    rowBlock(row).io.clear  := rowCtrl(row).io.clear_en
    //rowBlock(row).io.update := io.update
    rowBlock(row).io.update := update_en
    rowBlock(row).io.block_set := io.block_set

    rowBlock(row).io.row := rows_select(row)
    rowBlock(row).io.cols := cols_select
    //io.rows_full(row) := rowBlock(row).io.full
    rows_full(row) := rowBlock(row).io.full
    rowsblocks(row) := rowBlock(row).io.blocks_out


  }

  shift_done := RegNext( ! rowCtrl(0).io.holes_out ) init False


  io.block_val.valid := RegNext( io.block_pos.valid ) init False
  val row_status = rowsblocks.foldLeft(B(0,colBlocksNum bits) )(_|_)
  io.block_val.payload := ( row_status & cols_select ).orR


  io.row_val.valid   := RegNext(fetch_runing )  init(False)
  io.row_val.payload := RegNext(row_status )

}



object playFieldMain{
  def main(args: Array[String]) {

    val rowNum : Int = 23   // include bottom wall
    val colNum :Int = 12    // include left and right wall

    val rowBitsWidth = log2Up(rowNum)
    val colBitsWidth = log2Up(colNum)
    val rowBlocksNum = rowNum - 1   // working field for Tetromino
    val colBlocksNum = colNum - 2   // working field for Tetromino

    val config = PlayFieldConfig(
      rowBlocksNum = rowBlocksNum,
      colBlocksNum = colBlocksNum,
      rowBitsWidth = rowBitsWidth,
      colBitsWidth = colBitsWidth
    )

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new play_field(config)
    )
  }
}