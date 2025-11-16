package IPS.playfield
import IPS.play_field.PlayFieldConfig
import config.{ACTION, TYPE}
import spinal.core._
import spinal.lib._
import utils._
import spinal.lib.fsm.{EntryPoint, State, StateFsm, StateMachine}
import config.TetrominoesConfig._
import spinal.core.TimingEndpointType.CLOCK_EN

import utils.UniDmaConfig._

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




class playfield(val config : PlayfieldConfig, sim : Boolean = false )  extends Component {

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
    val lock = in Bool()
    val read = in Bool()
    val row_val = master Flow (Bits(colBlocksNum bits))
    val playfield_backdoor = if (sim) slave Flow (Playfield_Row_Data(rowBitsWidth, colBlocksNum)) else null
    val motion_is_allowed = out Bool()
    val fsm_is_idle = out Bool()
    val flow_backdoor = if (sim) flow_region_Data(rowBitsWidth, colBlocksNum) else null
    val checker_backdoor = if (sim) flow_region_Data(rowBitsWidth, colBlocksNum) else null
    val start_collision_check = if (sim) in Bool() else null
    val fsm_reset = if (sim) in Bool() else null
    val fsm_contrl = if (sim) in Bool() else null

  }

  noIoPrefix()

  // Capture with 1 cycle
  val piece = io.piece_in.m2sPipe(holdPayload = true)


  val cur_top_row = RegInit(U(0, rowBitsWidth bits))

  val load_piece = False

  val action = RegInit(ACTION.NO)


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
    val rot_backup = RegInit(U(0, 2 bit))

    val left_shift_all = False allowOverride()
    val right_shift_all = False allowOverride()

    case class PieceRegion(colBlocksNum: Int) extends Bundle {
      // There are 2 extra points on both left and right, which represent wall
      val region_extra = Vec.fill(4)(Bits(colBlocksNum + 4 bits)) setAsReg()


      val region = Vec.fill(4)(Bits(colBlocksNum bits))

      var left_overflow = False
      var right_overflow = False
      for (j <- 0 until 4) {
        left_overflow = left_overflow | region_extra(j)(colBlocksNum + 2, 2 bit).orR
        right_overflow = right_overflow | region_extra(j)(0, 2 bit).orR
      }

      val overflow = left_overflow | right_overflow

      def load(content: List[Int]) = {
        for (j <- 0 until 4) {
          region_extra(j) := content(j) << ((colBlocksNum / 2))
        }
      }

      def steup_logic() = {
        for (j <- 0 until 4) {
          region(j) := region_extra(j)(2, colBlocksNum bit)
        }

      }

      def shift_left() = {
        for (j <- 0 until 4) {
          region_extra(j) := region_extra(j) |<< 1
        }
      }

      def shift_right() = {
        for (j <- 0 until 4) {
          region_extra(j) := region_extra(j) |>> 1
        }
      }


    }

    val pieces = Vec(PieceRegion(colBlocksNum), 4)
    for (j <- 0 until 4) pieces(j).steup_logic()


    when(piece.valid) {
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

    when(left_shift_all) {
      pieces.foreach(_.shift_left())
    }

    when(right_shift_all) {
      pieces.foreach(_.shift_right())
    }

    def restore_rot() = {
      rot_cur := rot_backup
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
    val row_backup = RegInit(U(0, rowBitsWidth bits))

    val read_req = False allowOverride()
    val addr_access_port = Flow(UInt(2 bits))

    val region = Vec.fill(4)(Bits(colBlocksNum bits)) setAsReg()

    // sync read
    val readout = RegNext(region(addr_access_port.payload))

//    val dma_region = dma(start = read_req,
//      data_in = readout,
//      word_count = 4,
//      U(0) -> addr_access_port
//    )
//    val read_out_port = dma_region.read_sync()




    // input control signals
    val restore = False
    val right_shift = False allowOverride()
    val left_shift = False allowOverride()


    val overflowIfLeft = region(0).msb || region(1).msb || region(2).msb | region(3).msb
    val overflowIfRight = region(0).lsb || region(1).lsb || region(2).lsb | region(3).lsb


    val overflowIfDown = (row === (rowBlocksNum - 1)) |
      ((row === (rowBlocksNum - 2)) && region(1).orR) |
      ((row === (rowBlocksNum - 3)) && region(2).orR) |
      ((row === (rowBlocksNum - 4)) && region(3).orR)


    //    val shift_cnt = RegInit ( U(0, colBitsWidth bits )  )
    //    val shift_counter = Counter2( shift_cnt , right_shift | left_shift )
    //
    //    def load_shift_cnt ( n : UInt ) = {
    //      shift_cnt := n - 1 ;
    //      shift_counter.clear()
    //    }

    def setup_logic(source: Vec[Bits]): Unit = {

      val start_pos = colBlocksNum / 2 - 2
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


    def store_row(): Unit = {
      row := row_backup
    }

    if (sim) {
      when(io.checker_backdoor.valid) {
        region := io.checker_backdoor.data
        row := io.checker_backdoor.row
        row_backup := io.checker_backdoor.row
      }
    }


  }


  //-----------------------------------------------------------------------
  //        playfield Area
  //-----------------------------------------------------------------------

  case class VecSelector() extends Bundle {
    val start = UInt(rowBitsWidth bit)
    val size = UInt(rowBitsWidth bit)
  }

  val playfield = new Area {

    /** *****************************************************
     * Interface
     * * ******************************************************/
    val reset = False
    val freeze = False.allowOverride()
    val clear = False.allowOverride()

    val access_row_base = U(0, rowBitsWidth bits) allowOverride()


    val read_req_port = Flow(UInt(rowBitsWidth bits)).allowOverride()
    val write_req_port = Flow(UInt(rowBitsWidth bits)).allowOverride()

    val addr_access_port = Flow(UInt(rowBitsWidth bits))
    //val lock_addr_access_port = Flow(UInt(2 bits))
    val readout = Reg(Bits(colBlocksNum bits))


    /* ******************************************************
     * P layfield DMA
     * -  Single Access ( read-only with one cycle delay )
     * -  command req ( in ) :  read_req_port : valid and word_count
     * -  address req ( out ):  base addres = row, address bust = addr_access_port
     * -  data in ( in ) :   readout ( region sync-readout )
     * -  data out (out ) :  readout_port
     * * ***************************************************** */

    read_req_port.valid := False
    read_req_port.payload := U(0)


    write_req_port.valid := False
    write_req_port.payload := U(0)

//    val dma_region = dma(start = freeze ? write_req_port | read_req_port,
//      data_in = readout,
//      access_row_base -> addr_access_port,
//      U(0, 2 bits) -> lock_addr_access_port
//    )


//    val read_out_port = dma_region.read_sync()
//    val write_in = Bits(colBlocksNum bits)
    val write_in_port = Flow( Bits(colBlocksNum bits) )

    def load_read_req(valid: Bool, word_count: Int, addr_base: UInt) = {
      read_req_port.valid := valid
      read_req_port.payload := U(word_count - 1)
      access_row_base := addr_base
    }

    def load_write_req(valid: Bool, word_count: Int, addr_base: UInt) = {
      write_req_port.valid := valid
      write_req_port.payload := U(word_count - 1)
      access_row_base := addr_base
    }


    def addr_access_eqaul(target: UInt): Bool = {
      addr_access_port.payload === target
    }

    /* *****************************************************
     * W hole Playfield
     * * ***************************************************** */
    val region = Vec(Reg(Bits(colBlocksNum bits)) init (0), size = rowBlocksNum)

    /*******************************************************
     * A ddress Access Initiate
     *******************************************************/


    val row_sel = Bits(rowBlocksNum bits)



    // *********************************
    //      ROW asynchronous decoder
    // *********************************
    row_sel := B(0)
    switch(addr_access_port.payload) {
      for (i <- 0 until rowBlocksNum) {
        is(U(i)) {
          row_sel(i) := True
        }
      }
    }


    val address_beyond_limit = addr_access_port.payload > (rowBlocksNum - 1)

    when(address_beyond_limit) {
      readout.setAll() // all 1s act as bottom wall
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
//        when(write_in_port.valid && addr_access_port.valid) {
        when(write_in_port.valid ) {
          when(row_sel(i)) {
            region(i) := write_in_port.payload
          }
        }
      }
    }

    when(reset) {
      region.clearAll()
    }


    // Row clean

    val ones = RegInit(U(0, rowBlocksNum bits))
    for (i <- 0 until rowBlocksNum) {
      ones(i) := region(i).andR
    }

    val count = RegNext(CountOne(ones), init = U(0))


    val isRowFull = ones.orR


    val lowestOne = ones & (~(ones - 1))

    //    val mask = U( rowBlocksNum bit, default -> True )
    //    val rows_to_clear = ~( lowestOne - 1) & mask
//    val rows_to_clear = ~(lowestOne - 1)
    val rows_to_clear = lowestOne - 1

    for (i <- 0 until (rowBlocksNum - 1)) {
      when(clear && rows_to_clear(i)) {
        region(i+1) := region(i )
      }
    }

    when(clear) { // Top row is empty
      region(0) := 0
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
    val addr_access_port = Flow(UInt(2 bits))


    val region = Vec(Reg(Bits(colBlocksNum bits)) init (0), size = 4)

    // Async read
    //val readout = region(addr_access_port.payload)
    val readout = RegNext( region(addr_access_port.payload) )

//    val dma_region = dma(start = read_req,
//      data_in = readout,
//      word_count = 4,
//      U(0) -> addr_access_port
//    )
//
//    val read_out_port = dma_region.read_async()

    val update = False

    when(update) {
      region := checker.region
      row := checker.row
    }

    val row_occuppied = Bits(4 bits)
    for (i <- 0 to 3) {
      row_occuppied(i) := region(i).orR
    }

    val touch_bottom = OHToUInt(row_occuppied)

    if (sim) {
      when(io.flow_backdoor.valid) {
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
    val collision_bits = Reg(Flow(Bool()))

    val src_0, src_1 = Flow(Bits(colBlocksNum bit))

//    collision_bits.valid.init(False)
//    collision_bits.valid := playfield.read_out_port.valid
//    collision_bits.payload := (playfield.read_out_port.payload & checker.read_out_port.payload).orR
    collision_bits.valid := src_0.valid
    collision_bits.payload := ( src_0.payload & src_1.payload ) .orR

    val check_status = RegNextWhen(True,
      collision_bits.valid & collision_bits.payload,
      False
    ) clearWhen (start)

    val check_is_done = collision_bits.valid.fall(False)

    val is_collision = Flow(Bool())
    is_collision.valid := collision_bits.valid.fall(False)
    is_collision.payload := check_status
  }


  val output_en = False allowOverride()
  val playfield_dataout, src_0, src_1, src_2 = Flow(Bits( colBlocksNum bit ))
//  io.row_val.valid := src_0.valid && output_en
  src_0 := playfield_dataout.stage()   // flow readout is later one cycle to playfeild. So playfield readout have be delayed one cycle

  io.row_val.valid := src_0.valid && output_en
  io.row_val.payload :=src_0.payload
  val row_merged = src_0.payload | src_1.payload
  when(src_0.valid & src_1.valid) {
    io.row_val.payload := row_merged
  }

  val row_out_done =  src_0.valid.fall(False)


  //-----------------------------------------------------------------------
  //        locker
  // ------------------------------------
  //  -
  //-----------------------------------------------------------------------



//  val row_merged = playfield.read_out_port.payload | flow.read_out_port.payload

  val locker = new Area {

    val freeze = False allowOverride()

    val addr_access_port = Flow(UInt(2 bits))

    val region = Mem(Bits(colBlocksNum bits), 4)

    val data_in_port = Flow(Bits( colBlocksNum bit ))
    region.addAttribute("ram_style", "distributed")

//    val region_access_port = playfield.lock_addr_access_port.m2sPipe

    //val region_access_port = Flow( UInt( 2 bits ))
    //val readou_is_done = playfield.lock_addr_access_port.valid.fall(False)


//    region.write(
//      enable = region_access_port.valid && data_in_port.valid,
//      address = region_access_port.payload,
//      data = data_in_port.payload
//    )

//    playfield.write_in := region.readAsync(
//      //enable  = playfield.lock_addr_access_port.valid,
//      address = region_access_port.payload
//    )

//    val readout  = region.readSync(
//      enable = region_access_port.valid,
//      address =  region_access_port.payload
//    )

    region.write(
          enable = addr_access_port.valid && data_in_port.valid,
          address = addr_access_port.payload,
          data = data_in_port.payload
        )


    val readout  = region.readSync(
        enable = addr_access_port.valid,
        address =  addr_access_port.payload
      )

//    val readou_is_done = Delay( addr_access_port.valid.fall(False), 2 )
    val readou_is_done = addr_access_port.valid.fall(False)



  }


  val dma = new Area {

    //**********************************************
    //        Playfield dma
    //**********************************************

    val playfieldDmaConfig = UniDmaConfig (
      dataWidth =  colBlocksNum,
      count = 4,
      mappings = Seq (
        (0, "read" ) -> (0, 1 ),
        ( 1, "write" ) -> (2)
      )
    )

    val playfield_dma = new UniDma ( addr_port = playfield.addr_access_port, playfieldDmaConfig )

    playfield_dma  << (0, playfield.readout)
    playfield_dma  << (1, src_2.payload )

    collision_checker.src_0 := playfield_dma(0)
    playfield_dataout       := playfield_dma(1)
    playfield.write_in_port := playfield_dma(2)


    //**********************************************
    //        Checker DMA
    //**********************************************

    val checkerDmaConfig = UniDmaConfig (
      colBlocksNum,
      4,
      mappings = Seq (
        (0, "read" ) -> (0)
      )
    )

    val checker_dma = new UniDma ( checker.addr_access_port, checkerDmaConfig )

    checker_dma << (0, checker.readout)
    collision_checker.src_1 := checker_dma(0)

    //**********************************************
    //        Flow DMA
    //**********************************************

    val flowDmaConfig = UniDmaConfig (
      colBlocksNum,
      4,
      mappings = Seq (
        (0, "read" ) -> ( 0 )
      )
    )

    val flow_dma = new UniDma( flow.addr_access_port, flowDmaConfig )
    flow_dma << (0, flow.readout)
    src_1 := flow_dma(0)

    //**********************************************
    //        LOKCER DMA
    //**********************************************
    val lockerDmaConfig = UniDmaConfig (
      colBlocksNum,
      4,
      mappings = Seq (
        (0, "write" ) -> ( 0 ) ,
        (1, "read" ) -> ( 1 )
      )
    )

    val locker_dma = new UniDma( locker.addr_access_port, lockerDmaConfig )

    locker_dma << (0, row_merged )
    locker_dma << (1, locker.readout)

    locker.data_in_port := locker_dma(0)
    src_2 := locker_dma(1)


    // Process on readout
    def execute_playfield_readout() = {
      playfield_dma.enableChannel(1)
      playfield_dma.setBaseAddr(U(0))
      playfield_dma.setWordCount(rowBlocksNum)
      playfield_dma.startTrans()
    }

    def after_playfield_readout() = {
      playfield_dma.disableChannel(1)
      playfield_dma.stopTrans()
    }

    def execute_flow_readout() = {
      flow_dma.startTrans()
    }


    def after_flow_readout() = {
      flow_dma.stopTrans()
    }

    // Process on collision

    def execute_playfield_collision() = {
      playfield_dma.enableChannel(0)
      playfield_dma.setBaseAddr(checker.row)
      playfield_dma.setWordCount(4)
      playfield_dma.startTrans()
    }

    def after_playfield_collision() = {
      playfield_dma.disableChannel(0)
      playfield_dma.stopTrans()
    }

    def execute_checker_collision() = {
      checker_dma.startTrans()
    }

    def after_checker_collision() = {
      checker_dma.stopTrans()
    }

    // Process on write to Locker
    def execute_playfield_write_locker() = {
      playfield_dma.enableChannel(1)
      playfield_dma.setBaseAddr( flow.row )
      playfield_dma.setWordCount(4)
      playfield_dma.startTrans()
    }

    def after_playfield_write_locker() = {
      playfield_dma.disableChannel(1)
      playfield_dma.stopTrans()
    }

    def execute_flow_write_locker() = {
      flow_dma.startTrans()
    }

    def after_flow_write_locker() = {
      flow_dma.stopTrans()
    }

    def execute_locker_write() = {
      locker_dma.enableChannel(0)
      locker_dma.startTrans()
    }

    def after_locker_write() = {
      locker_dma.disableChannel(0)
      locker_dma.stopTrans()
    }


    def execute_write_locker () ={
      execute_playfield_write_locker()
      execute_flow_write_locker()
      execute_locker_write()
    }

    def after_write_locker() = {
      after_playfield_write_locker()
      after_flow_write_locker()
      after_locker_write()
    }

    // Process on read Locker to playfield

    def execute_locker_read() = {
      locker_dma.enableChannel(1)
      locker_dma.startTrans()
    }

    def after_locker_read() = {
      locker_dma.disableChannel(1)
      locker_dma.stopTrans()
    }

    def execute_playfield_write() = {
      playfield_dma.enableChannel(2)
      playfield_dma.setBaseAddr(flow.row)
      playfield_dma.setWordCount(4)
      playfield_dma.startTrans()
    }

    def after_playfield_write() = {
      playfield_dma.disableChannel(2)
      playfield_dma.stopTrans()
    }

    def execute_transfer_from_locker_to_playfield () = {
      execute_locker_read()
      execute_playfield_write()
    }

    def after_transfer_from_locker_to_playfield () = {
      after_locker_read()
      after_playfield_write()
    }




  }

//  io.row_val.valid := playfield.read_out_port.valid && output_en
//  io.row_val.payload := playfield.read_out_port.payload
//  when(playfield.read_out_port.valid & flow.read_out_port.valid) {
//    io.row_val.payload := row_merged
//  }

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

      dma.flow_dma.enableAllChannel()
      dma.checker_dma.enableAllChannel()

      if (sim) {
        when(io.fsm_contrl) {
          goto(WAIT_CONTROL)
        }

      }

      when(piece.valid) {
        // piece is being selected in terms of type and rot
        action := ACTION.PLACE
        goto(LOAD_TO_CHECKER)
      }

      if (sim) {
        when(io.start_collision_check) {
          goto(COLLISION_CHECK)
        }
      }
    }

    val READOUT: State = new State {
      onEntry {
//        playfield.load_read_req(valid = True, word_count = rowBlocksNum, addr_base = U(0))
        dma.execute_playfield_readout()
      }

      whenIsActive {
        output_en := True
        when(playfield.addr_access_eqaul(flow.row)) {
//          flow.read_req := True
          dma.execute_flow_readout()
        }
//        when(!playfield.dma_region.is_busy) {
        when ( row_out_done ) {
          goto(WAIT_CONTROL)
        }
      }

      onExit {
        dma.after_playfield_readout()
        dma.after_flow_readout()

      }
    }

    val LOAD_TO_CHECKER: State = new State {

      // Piecee in piece_buffer is copied to checker.region
      whenIsActive {
        load_piece := True
        goto(COLLISION_CHECK)
      }
    }


    val COLLISION_CHECK: State = new State {
      onEntry {
//        playfield.load_read_req(valid = True, word_count = 4, addr_base = checker.row)
//        checker.read_req := True
        collision_checker.start := True
        dma.execute_playfield_collision()
        dma.execute_checker_collision()
      }

      whenIsActive {
        when(collision_checker.is_collision.valid) {
          when(collision_checker.is_collision.payload) {
            goto(REPORT_COLLISION)
          } otherwise {
            goto(PASS)
          }
        }
      }

      onExit {
        dma.after_playfield_collision()
        dma.after_checker_collision()
      }

    }

    val REPORT_COLLISION: State = new State {
      whenIsActive {
        io.status.valid := True
        io.status.payload := True
        when(action === ACTION.PLACE) {
          goto(IDLE) // game over
        }.otherwise {

          when(action === ACTION.ROTATE) {
            piece_buffer.restore_rot()
          }
          goto(END_OF_COLLISION)

        }
      }
    }

    val END_OF_COLLISION: State = new State {
      whenIsActive {

        when(action === ACTION.LEFT || action === ACTION.RIGHT) {
          load_piece := True // restore origin piece
        }

        when(action === ACTION.DOWN) {
          checker.restore()
        }

        when(action === ACTION.ROTATE) {
          load_piece := True // restore origin piece
        }

        action := ACTION.NO

        goto(WAIT_CONTROL)

      }

    }

    val PASS: State = new State {

      onEntry {
        io.status.valid := True
        io.status.payload := False
      }
      whenIsActive {
        when(action === ACTION.PLACE) {
          flow.update := True
        }

        when(action === ACTION.LEFT) {
          flow.update := True
          piece_buffer.left_shift_all := True
        }

        when(action === ACTION.RIGHT) {
          flow.update := True
          piece_buffer.right_shift_all := True
        }

        when(action === ACTION.DOWN) {
          flow.update := True
          checker.row_backup := checker.row
        }

        when(action === ACTION.ROTATE) {
          flow.update := True
          piece_buffer.rot_backup := piece_buffer.rot_cur
        }


        goto(WAIT_CONTROL)
      }

    }


    val WAIT_CONTROL = new State {


      whenIsActive {

        if (sim) {
          when(io.fsm_reset) {
            goto(IDLE)
          }

        }

        when(io.read) {
          goto(READOUT)
        }

        when(io.move_in.left) {
          when(checker.overflowIfLeft) {
            goto(REPORT_COLLISION)
          } otherwise {
            action := ACTION.LEFT
            checker.left_shift := True
            goto(PRE_CHECK)
          }
        }

        when(io.move_in.right) {
          when(checker.overflowIfRight) {
            goto(REPORT_COLLISION)
          } otherwise {
            action := ACTION.RIGHT
            checker.right_shift := True
            goto(PRE_CHECK)
          }
        }

        when(io.move_in.down) {
          when(checker.overflowIfDown) {
            goto(REPORT_COLLISION)
          } otherwise {
            checker.row := checker.row + 1
            action := ACTION.DOWN
            goto(PRE_CHECK)
          }
        }

        when(io.move_in.rotate) {
          piece_buffer.rot_cur := piece_buffer.rot_cur + 1
          goto(ROTATION)
        }

        when(io.lock) {
          goto(LOCKER_WRITE_0)
        }

      }
    }

    val ROTATION = new State {
      whenIsActive {
        when(piece_buffer.pieces(piece_buffer.rot_cur).overflow) {
          goto(REPORT_COLLISION)
        } otherwise {
          load_piece := True
          action := ACTION.ROTATE
          goto(PRE_CHECK)
        }
      }

    }

    val PRE_CHECK = new State {
      whenIsActive {
        goto(COLLISION_CHECK)
      }
    }

    // Read from both playfield and flow region
    val LOCKER_WRITE_0 = new State {
      onEntry {
//        playfield.load_read_req(valid = True, word_count = 4, addr_base = flow.row)
        dma.execute_playfield_write_locker()
      }

      whenIsActive {
        dma.execute_flow_write_locker()
        //dma.execute_locker_write()
        goto( LOCKER_WRITE_1 )
      }

    }

    //write merged data to locker region

    val LOCKER_WRITE_1 = new State {

      whenIsActive {
        dma.execute_locker_write()
        goto( WAIT_LOCKER_WRITE_DONE )

      }
    }



    val WAIT_LOCKER_WRITE_DONE = new State {

      whenIsActive {
//        locker.freeze := True
//        flow.read_req := locker.freeze.rise(False)
        //        when(locker.end_of_access) {
        when( row_out_done ) {
          goto(LOCKER_READ)
        }
      }

      onExit {
        dma.after_write_locker()
      }

    }

    val LOCKER_READ = new State {
      onEntry {
//        playfield.load_write_req(valid = True, word_count = 4, addr_base = flow.row)
//        dma.execute_transfer_from_locker_to_playfield()
        dma.execute_locker_read()
        playfield.freeze := True
      }
      whenIsActive {
        dma.execute_playfield_write()
        goto(WAIT_LOCKER_READ_DONE)
      }

    }


    val WAIT_LOCKER_READ_DONE = new State {

      whenIsActive {
        playfield.freeze := True
        when(locker.readou_is_done) {
          goto(CLEAR_REGION)
        }
      }
      onExit {
        dma.after_transfer_from_locker_to_playfield()
      }

    }


    val CLEAR_REGION = new State {

      whenIsActive {
        piece_buffer.rot_cur := 0
        piece_buffer.rot_backup := 0

        flow.region.clearAll()
        flow.row := 0
        checker.row := 0
        checker.row_backup := 0
        goto(CHECK_ROW_FULL)
      }
    }

    val CHECK_ROW_FULL : State = new State {

      whenIsActive {
        when(playfield.isRowFull) {

          goto(ROW_REMOVE)
        } otherwise {
          goto(IDLE)
        }
      }
    }

    val ROW_REMOVE = new State {

      whenIsActive {
        playfield.clear := True
        goto(ROW_REMOVE_DONE)
      }
    }

    val ROW_REMOVE_DONE = new State {
      whenIsActive {
        goto(CHECK_ROW_FULL)
      }
    }

  }

  checker.setup_logic(flow.region)

  io.motion_is_allowed := main_fsm.isActive(main_fsm.WAIT_CONTROL)
  io.fsm_is_idle       := main_fsm.isActive(main_fsm.IDLE )
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