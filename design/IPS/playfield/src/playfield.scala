package IPS.playfield
import IPS.play_field.PlayFieldConfig
import spinal.core._
import spinal.lib._
import utils._
import spinal.lib.fsm.{EntryPoint, State, StateFsm, StateMachine}
import config.TetrominoesConfig._

case class PlayfieldConfig(
                            rowBlocksNum : Int,
                            colBlocksNum : Int,
                            rowBitsWidth : Int,
                            colBitsWidth : Int,
                            placeOffset  : Int = 3
                          ) {
}

case class Playfield_Row_Data(rowBitsWidth : Int, colBlocksNum : Int ) extends Bundle {
  val row  = UInt( rowBitsWidth bit )
  val data = Bits( colBlocksNum bit )
}

case  class flow_region_Data  (rowBitsWidth : Int, colBlocksNum : Int ) extends Bundle {
  val valid = in Bool()
  val row  = in UInt( rowBitsWidth bit )
  val data = in  Vec( Bits( colBlocksNum bit ), size = 4 )
}

class playfield(config : PlayfieldConfig, sim : Boolean = false )  extends Component {
  import config._

  val io = new Bundle {
    val piece_in = slave Flow (Piece(colBitsWidth, rowBitsWidth))
    //val blocks_out = master Stream( Block(colBitsWidth, rowBitsWidth ) )
    //val hit_status = slave Flow( hitStatus() )
    val status = master Flow (Bool())

    val read = in Bool()
    val row_val = master Flow (Bits(colBlocksNum bits))
    val playfield_backdoor = if (sim) slave Flow (Playfield_Row_Data(rowBitsWidth, colBlocksNum)) else null

    val flow_backdoor = if (sim)  flow_region_Data(rowBitsWidth, colBlocksNum)  else null

  }

  noIoPrefix()

  // Capture with 1 cycle
  val piece = io.piece_in.m2sPipe(holdPayload = true)


  val cur_top_row = RegInit( U( 0, rowBitsWidth bits ) )
  val row_origin_chk = RegInit( U( 0, rowBitsWidth bits ) )
  val col_origin_chk = RegInit( U( 0, colBitsWidth bits ) )

  val load_piece = False




  val is_collision = RegInit(False)

  //-----------------------------------------------------------------------
  //       selector
  // ------------------------------------
  //  - find the T-piece 4x4 data in terms of type and rotation
  //  - Store it to 4x4 Vec called region
  //  - Region is displayed in next-T window in right-bottom of screen
  //-----------------------------------------------------------------------

  lazy val selector = new Area {

    val region = Vec.fill(4)(Bits(4 bit)) setAsReg()

    switch(piece.`type`) {
      for ((pieceType, rotations) <- binaryTypeOffsetTable) {
        is(pieceType) {
          switch(piece.rot) {
            for ((rotation, positions) <- rotations) {
              is(rotation) {
                for (j <- 0 until 4) {
                  region(j) := positions(j)
                }
              }
            }
          }
        }
      }
    }
  }

  //-----------------------------------------------------------------------
  //        checker Area
  // ------------------------------------
  //  - 4 Rows including T be compared
  //  - piece_load : load region in selector to most-left of region
  //  - move action like left/right/rotate shift all rows if wall is not touched
  //  - move down will not affect this region and only cur_row is changed
  //  - can store previous region by region in flow area
  //  - this region is invisible to VGA display
  //-----------------------------------------------------------------------

  val checker = new Area {

    val row = RegInit(U(0, rowBitsWidth bits))

    val region = Vec.fill(4)(Bits(colBlocksNum bits)) setAsReg()

    // input control signals
    val right_shift, left_shift, piece_load, restore = False

    right_shift setAsReg()
    left_shift setAsReg()


    val shift_cnt = RegInit ( U(0, colBitsWidth bits )  )
    val shift_counter = Counter2( shift_cnt , right_shift | left_shift )

    def load_shift_cnt ( n : UInt ) = {
      shift_cnt := n - 1 ;
      shift_counter.clear()
    }

    def setup_logic(source : Vec[Bits] ): Unit = {

      for (i <- 0 to 3) {
        when(piece_load) {
          region(i) := Cat( selector.region(i), B(0, (colBlocksNum - 4 ) bits))
        }

        when(right_shift) {
          region(i) := region(i) |>> 1
        }

        when(left_shift) {
          region(i) := region(i) |<< 1

        }

        when(restore) {
          region(i) := source(i)
        }

      }
    }

  }


  //-----------------------------------------------------------------------
  //        playfield Area
  //-----------------------------------------------------------------------

  case class VecSelector () extends Bundle {
    val  start   = UInt( rowBitsWidth bit )
    val  size   = UInt( rowBitsWidth bit )
  }

  val playfield = new Area {

    /*******************************************************
               Interface
     ********************************************************/
    val reset = False
    val read_req_port = Flow(VecSelector())
    val read_out_port = Flow(Bits(colBlocksNum bits) )


    /*******************************************************
     Playfield access address
     - input  :  read_req_port <flow>
     - output :  read_out_port <flow>
     ********************************************************/

    read_req_port.valid := False
    read_req_port.start := U(0)
    read_req_port.size  := U(0)

    val row_address = Counter2(
      read_req_port.valid,
      read_req_port.start,
      read_req_port.size
    )

    val readout = RegInit(B(colBlocksNum bits, default -> true))
    read_out_port.valid := RegNext(row_address.willIncrement  )
    read_out_port.payload := readout



    /*******************************************************
     Whole Playfield
     ********************************************************/
    val region = Vec( Reg( Bits(colBlocksNum bits) )  init(0), size = rowBlocksNum )


    /*******************************************************
              Address Access Initiate
    *******************************************************/


    val row_sel = Bits(rowBlocksNum bits)

    //val row_req = UInt(rowBitsWidth bits)
    // Add 3 rows for bottom




    val freeze = False.allowOverride()

    // *********************************
    //      ROW asynchronous decoder
    // *********************************
    row_sel := B(0)
    switch(row_address.value) {
      for (i <- 0 until rowBlocksNum) {
        is(U(i)) {
          row_sel(i) := True
        }
      }
    }

    val readin = Bits(colBlocksNum bits) default (0)

    val address_beyond_limit = row_address.value > ( rowBlocksNum - 1 )

    when( address_beyond_limit ) {
      readout.setAll()  // all 1s act as bottom wall
    }.otherwise {
      for (i <- 0 until rowBlocksNum) {
        //*****************************************************
        //             Synchronous  Read
        //*****************************************************
        when(row_sel(i)) {
          readout := region(i)
        }
        //*****************************************************
        //              Write
        //*****************************************************
        when(row_sel(i) & freeze) {
          region(i) := readin
        }
      }
    }

    when(reset) {
      region.clearAll()
    }


    // Backdoor access for simulation only

    if (sim) {
      when(io.playfield_backdoor.valid) {
        region(io.playfield_backdoor.row) := io.playfield_backdoor.data
      }
    }


  }


  //-----------------------------------------------------------------------
  //        flow Area
  // ------------------------------------
  //  - 4 Rows for storing the T to has pass the collision checker in checker Area
  //  - row content will be ORed with the corresponding row of playfield to VGA display
  //  - Once freeze, all rows will be written back to playfield row by row
  //  - After write back, all region is reset
  //-----------------------------------------------------------------------

  val flow = new Area {

    val row = RegInit(U(0, rowBitsWidth bits))
    val read_req = False allowOverride()
    val read_out_port = Flow(Bits(colBlocksNum bits) )

    val region = Vec( Reg( Bits(colBlocksNum bits) )  init(0), size = 4 )

    val row_address_inc = RegNextWhen( True, read_req, False )
    val row_address =  Counter( 4, row_address_inc   )
    when ( read_req ) { row_address.clear() }
    row_address_inc.clearWhen( row_address.willOverflow )

    val update = False

    when ( update ) {
      region := checker.region
      row := checker.row
    }

    val row_occuppied = Bits( 4 bits)
    for ( i <- 0 to 3 ) {
      row_occuppied(i) := region(i).orR
    }

    val touch_bottom = OHToUInt(row_occuppied)


    val readout = RegNext( region(row_address) )

    read_out_port.valid := RegNext(row_address.willIncrement  )
    read_out_port.payload := readout

    if ( sim ) {
      when( io.flow_backdoor. valid ) {
        region := io.flow_backdoor.data
        row := io.flow_backdoor.row
      }
    }
  }


  //-----------------------------------------------------------------------
  //        collision_checker
  // ------------------------------------
  //  -
  //-----------------------------------------------------------------------

  val collision_checker = new Area {

    val enable = False allowOverride()
    val check_is_running = enable & playfield.read_out_port.valid
    val src_checker_addr = Counter(4, check_is_running )
    val src_checker = checker.region(src_checker_addr)

    val src_playfield = playfield.read_out_port.payload

    /*  0 : no-overlap 1: overlap */
    val check_status = ( src_playfield & src_checker ) .orR

    val is_collision = RegNextWhen( True, check_is_running & check_status, False )
    val check_is_done = check_is_running.fall(False)
  }


  io.row_val.valid := playfield.read_out_port.valid
  io.row_val.payload := playfield.read_out_port.payload
  when ( playfield.read_out_port.valid & flow.read_out_port.valid ) {
    io.row_val.payload := playfield.read_out_port.payload | flow.read_out_port.payload
  }

  //-----------------------------------------------------------------------
  //        FSM
  // ------------------------------------
  //  -
  //  -
  //  -
  //  -
  //-----------------------------------------------------------------------

  val main_fsm = new StateMachine {

    io.status.valid := False
    io.status.payload := False

    val IDLE = makeInstantEntry()
    IDLE.whenIsActive {

      when(io.read) {
        goto(READOUT)
      }

      when(piece.valid) {
        // piece is being selected in terms of type and rot
        goto(PIECE_SELECTION)
      }
    }

    val READOUT : State = new State {
      onEntry{
        playfield.read_req_port.valid := True
        playfield.read_req_port.start := U(0)
        playfield.read_req_port.size  := U( rowBlocksNum )
        when ( flow.row  === U(0) ) {
          flow.read_req := True
        }
      }

      whenIsActive {
        when ( playfield.row_address.valueNext === flow.row ) { flow.read_req := True  }
        when (playfield.row_address.willOverflow ) {
          goto(IDLE)
        }
      }
    }

    val PIECE_SELECTION: State = new State  {

      // Piecee is stored in selector.region within this state
      whenIsActive {
        row_origin_chk := 0
        col_origin_chk := 3
        load_piece := True
        //playfield.row_address.load( cur_top_row )
        goto(LOAD_TO_CHECKER)
      }
    }


    val LOAD_TO_CHECKER: State = new State {

      // Piece has been stored into checker/region
      // row_origin_chk and col_origin_chk has been updated
      whenIsActive {
        //if col_index is 0 , it is not needed to shift since piece is loaded at col 0
        when ( col_origin_chk === 0 ) {
          goto(COLLISION_CHECK )
        } otherwise {

          // Counter and Right_shift flag will be set at next cycle
          checker.right_shift := True
          checker.load_shift_cnt(col_origin_chk)
          goto(SHIFT_CHECKER_REGION)
        }
      }
    }

    val SHIFT_CHECKER_REGION : State = new State {

      // Right shift shift_counter times
      // - For place, right shift 3 times to the middle of region
      // - ? For rot, shift to origin position
      // - ? For input
      whenIsActive {

        when(checker.shift_counter.willOverflow ) {
          goto(COLLISION_CHECK)
        }
      }
    }

    val COLLISION_CHECK : State = new State {
      onEntry {

        playfield.read_req_port.valid := True
        playfield.read_req_port.start := checker.row
        playfield.read_req_port.size  := 4
      }

      whenIsActive{
        collision_checker.enable :=  True
        when ( collision_checker.check_is_done ) {
          when ( collision_checker.is_collision ) {
            goto(COLLISION)
          } otherwise {
            goto(PASS)
          }
        }
      }

    }


    val COLLISION : State = new State {
      whenIsActive {
        io.status.valid := True
        io.status.payload := True
        goto(IDLE)
      }
    }

    val PASS : State = new State {
      whenIsActive {
        io.status.valid := True
        io.status.payload := False
        flow.update := True
        goto(IDLE)
      }

    }


  }

  checker.setup_logic(flow.region)
}

object playfieldMain{
  def main(args: Array[String]) {
    val rowNum : Int = 22   // include bottom wall
    val colNum :Int = 10    // include left and right wall

    val rowBitsWidth = log2Up(rowNum)
    val colBitsWidth = log2Up(colNum)
    val rowBlocksNum = rowNum   // working field for Tetromino
    val colBlocksNum = colNum   // working field for Tetromino

    val config = PlayfieldConfig(
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
      gen = new playfield(config, sim = true )
    )
  }
}