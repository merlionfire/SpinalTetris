package IPS.playfield
import IPS.play_field.PlayFieldConfig
import config.TYPE
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
    //val piece_in = slave Flow (Piece(colBitsWidth, rowBitsWidth))
    val piece_in = slave Flow TYPE()
    //val blocks_out = master Stream( Block(colBitsWidth, rowBitsWidth ) )
    //val hit_status = slave Flow( hitStatus() )
    val status = master Flow (Bool())
    val move_in = new Bundle {
      val left = in Bool()
      val right = in Bool()
      val rotate = in Bool()
      val down = in Bool()
    }
    val read = in Bool()
    val row_val = master Flow (Bits(colBlocksNum bits))
    val playfield_backdoor = if (sim) slave Flow (Playfield_Row_Data(rowBitsWidth, colBlocksNum)) else null

    val flow_backdoor     = if (sim)  flow_region_Data(rowBitsWidth, colBlocksNum)  else null
    val checker_backdoor  = if (sim)  flow_region_Data(rowBitsWidth, colBlocksNum)  else null
    val start_collision_check  = if (sim)  in Bool()  else null

  }

  noIoPrefix()

  // Capture with 1 cycle
  val piece = io.piece_in.m2sPipe(holdPayload = true)


  val cur_top_row = RegInit( U( 0, rowBitsWidth bits ) )

  val load_piece = False



  val is_collision = RegInit(False)

  //-----------------------------------------------------------------------
  //       selector
  // ------------------------------------
  //  - find the T-piece 4x4 data in terms of type and rotation
  //  - Store it to 4x4 Vec called region
  //  - Region is displayed in next-T window in right-bottom of screen
  //-----------------------------------------------------------------------

//  lazy val selector = new Area {
//
//    val region = Vec.fill(4)(Bits(4 bit)) setAsReg()
//
//    switch(piece.`type`) {
//      for ((pieceType, rotations) <- binaryTypeOffsetTable) {
//        is(pieceType) {
//          switch(piece.rot) {
//            for ((rotation, positions) <- rotations) {
//              is(rotation) {
//                for (j <- 0 until 4) {
//                  region(j) := positions(j)
//                }
//              }
//            }
//          }
//        }
//      }
//    }
//  }

  val piece_buffer = new Area {

    val rot_cur = RegInit(U(0, 2 bit))
    val rot_checked = RegInit(U(0, 2 bit))

    case class PieceRegion(colBlocksNum: Int) extends Bundle {
      // There are 2 extra points on both left and right, which represent wall
      val region_extra = Vec.fill(4)( Bits( colBlocksNum + 4   bits ) ) setAsReg()


      val region = Vec.fill(4)( Bits( colBlocksNum  bits ) )

//      val region = Vec( region_extra(0)(2, colBlocksNum bit),


//      for ( j <- 0 until 4 ) {
//        region(j) := region_extra(j)(2, colBlocksNum bit)
//      }




      var left_overflow = False
      var right_overflow = False
      for ( j <- 0 until 4 ) {
         left_overflow = left_overflow | region_extra(j)( colBlocksNum+2, 2 bit  ).orR
         right_overflow = right_overflow | region_extra(j)( 1, 2 bit  ).orR
      }

      def load( content : List[Int] ) = {
        for ( j <- 0 until 4 ) {
          region_extra(j) := content(j) << ( (colBlocksNum / 2 ) )
        }
      }

      def steup_logic () = {
        for ( j <- 0 until 4 ) {
          region(j) := region_extra(j)(2, colBlocksNum bit)
        }

      }

    }

    val pieces = Vec(PieceRegion(colBlocksNum), 4)
    for ( j <- 0 until 4 )  pieces(j).steup_logic()


    when (piece.valid ) {
      switch(piece.payload) {
          for ((pieceType, rotations) <- binaryTypeOffsetTable) {
            is(pieceType) {
              for ((rotation, positions) <- rotations) {
                pieces(rotation).load(positions)
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
    val read_req = False allowOverride()
    val addr_access_port = Flow( UInt(2 bits ) )

    val region = Vec.fill(4)(Bits(colBlocksNum bits)) setAsReg()

    // sync read
    val readout = RegNext( region(addr_access_port.payload) )

    val dma_region = dma( start = read_req,
      data_in = readout,
      word_count =  4,
      U(0) -> addr_access_port
    )
    val read_out_port = dma_region.read_sync()


    // input control signals
    val right_shift, left_shift, restore = False

    right_shift setAsReg()
    left_shift setAsReg()


    val shift_cnt = RegInit ( U(0, colBitsWidth bits )  )
    val shift_counter = Counter2( shift_cnt , right_shift | left_shift )

    def load_shift_cnt ( n : UInt ) = {
      shift_cnt := n - 1 ;
      shift_counter.clear()
    }

    def setup_logic(source : Vec[Bits] ): Unit = {

      val  start_pos = colBlocksNum / 2 -2
      for (i <- 0 to 3) {
        when(load_piece) {
          region(i) := piece_buffer.pieces(piece_buffer.rot_cur).region(i)
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

    if ( sim ) {
      when( io.checker_backdoor.valid ) {
        region := io.checker_backdoor.data
        row := io.checker_backdoor.row
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

    val read_row_base = U(0, rowBitsWidth bits) allowOverride()


    val read_req_port = Flow(UInt(rowBitsWidth bits) ) .allowOverride()
    val addr_access_port = Flow( UInt(rowBitsWidth bits ) )
    val readout =   Reg( Bits( colBlocksNum bits ) )
    /*******************************************************
     Playfield DMA
     - Single Access ( read-only with one cycle delay )
     - command req ( in ) :  read_req_port : valid and word_count
     - address req ( out ):  base addres = row, address bust = addr_access_port
     - data in ( in ) :   readout ( region sync-readout )
     - data out (out ) :  readout_port
     ********************************************************/

    read_req_port.valid := False
    read_req_port.payload := U(0)

    val dma_region = dma( start = read_req_port,
                          data_in = readout,
                          read_row_base -> addr_access_port
                      )
    val read_out_port = dma_region.read_sync()


    def load_read_req ( valid : Bool, word_count : Int, addr_base : UInt ) = {
      read_req_port.valid := valid
      read_req_port.payload := U( word_count - 1 )
      read_row_base := addr_base
    }

    def addr_access_eqaul( target : UInt ) : Bool = {
      addr_access_port.payload === target
    }
    /*******************************************************
     Whole Playfield
     ********************************************************/
    val region = Vec( Reg( Bits(colBlocksNum bits) )  init(0), size = rowBlocksNum )

    /*******************************************************
              Address Access Initiate
    *******************************************************/


    val row_sel = Bits(rowBlocksNum bits)

    val freeze = False.allowOverride()

    // *********************************
    //      ROW asynchronous decoder
    // *********************************
    row_sel := B(0)
    switch(addr_access_port.payload ) {
      for (i <- 0 until rowBlocksNum) {
        is(U(i)) {
          row_sel(i) := True
        }
      }
    }

    val readin = Bits(colBlocksNum bits) default (0)

    val address_beyond_limit = addr_access_port.payload > ( rowBlocksNum - 1 )

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
    val addr_access_port = Flow( UInt(2 bits ) )

    val region = Vec( Reg( Bits(colBlocksNum bits) )  init(0), size = 4 )

    // Async read
    val readout = region(addr_access_port.payload)

    val dma_region = dma( start = read_req,
                          data_in = readout,
                          word_count =  4,
                          U(0) -> addr_access_port
    )

    val read_out_port = dma_region.read_async()

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

    //val enable = False allowOverride()

    val start = False allowOverride()
    val collision_bits = Reg( Flow(Bool()) )
    collision_bits.valid.init(False)
    collision_bits.valid := playfield.read_out_port.valid
    collision_bits.payload := ( playfield.read_out_port.payload & checker.read_out_port.payload ) .orR

    val check_status = RegNextWhen( True,
      collision_bits.valid & collision_bits.payload,
      False
    ) clearWhen( start )

    val check_is_done = collision_bits.valid.fall(False)

    val is_collision = Flow( Bool() )
    is_collision.valid := collision_bits.valid.fall(False)
    is_collision.payload := check_status
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
        goto(LOAD_TO_CHECKER)
      }

      if ( sim ) {
        when ( io.start_collision_check ) {
          goto(COLLISION_CHECK)
        }
      }
    }

    val READOUT : State = new State {
      onEntry{
        playfield.load_read_req( valid =  True, word_count = rowBlocksNum, addr_base = U(0) )
      }

      whenIsActive {
        when ( playfield.addr_access_eqaul(flow.row ) ) { flow.read_req := True  }
        when ( ! playfield.dma_region.is_busy ) {
          goto(IDLE)
        }
      }
    }

    val LOAD_TO_CHECKER: State = new State  {

      // Piecee in piece_buffer is copied to checker.region
      whenIsActive {
        load_piece := True
        goto(COLLISION_CHECK)
      }
    }



    val COLLISION_CHECK : State = new State {
      onEntry {
        playfield.load_read_req( valid =  True, word_count = 4, addr_base = checker.row )
        checker.read_req := True
        collision_checker.start := True
      }

      whenIsActive{
        when ( collision_checker.is_collision.valid ) {
          when ( collision_checker.is_collision.payload ) {
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