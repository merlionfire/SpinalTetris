package SSC.logic_top


import spinal.core._
import spinal.lib._
import IPS.seven_bag_rng._
import IPS.picoller._
import IPS.play_field._
import config.TYPE
import utils._
import spinal.lib.fsm.{State, StateFsm, StateMachine}


case class  LogicTopConfig ( rowNum : Int, colNum : Int  ) {

  val rowBitsWidth = log2Up(rowNum)
  val colBitsWidth = log2Up(colNum)
  val rowBlocksNum = rowNum - 1   // working field for Tetromino
  val colBlocksNum = colNum - 2   // working field for Tetromino

  // 437 ms / ( 1 / 50 MHz ) = 437 * 50 * 1000
  val levelFallInCycle = 473 * 50000
  val lockDownInCycle  = 500 * 50000

  val playFieldConfig = PlayFieldConfig(
    rowBlocksNum = rowBlocksNum,
    colBlocksNum = colBlocksNum,
    rowBitsWidth = rowBitsWidth,
    colBitsWidth = colBitsWidth
  )

  val picollerConfig =  PicollerConfig( colBitsWidth, rowBitsWidth)

}

class logic_top ( config : LogicTopConfig, test : Boolean = false  ) extends Component {

  import config._

  val io = new Bundle {
    val game_start = in Bool()
    val move_left = in Bool()
    val move_right = in Bool()
    val move_down = in Bool()
    val rotate = in Bool()
    val row_val = master Flow( Bits(colBlocksNum bits) )
    val draw_field_done = in Bool()
    val screen_is_ready = in Bool()
    val force_refresh = in Bool()
    val ctrl_allowed = out Bool()
  }


  noIoPrefix()


  //***********************************************************
  //              Instantiation
  //***********************************************************

  val piece_gen = new seven_bag_rng()
  val picoller_inst = new picoller(picollerConfig)
  val play_field = new play_field(playFieldConfig)


  val piece_req =  Stream (Piece(colBitsWidth, rowBitsWidth))
  val update =  RegInit(False)
  val block_set = RegInit(False)
  val clear_start  = RegInit(False)
  val restart = RegInit(False)

  val collision_in = Flow( Bool() )

  //***********************************************************
  //              Connection with IPS
  //***********************************************************

  piece_req >> picoller_inst.io.piece_in
  collision_in <> picoller_inst.io.collision_out

  //  picoller_inst <-> playfield
  play_field.io.block_pos <> picoller_inst.io.block_pos
  play_field.io.block_val <> picoller_inst.io.block_val

  play_field.io.row_val <> io.row_val

  /*
  playfield_top_inst.io.restart := restart
  playfield_top_inst.io.clear_start := clear_start
  playfield_top_inst.io.update := update
  playfield_top_inst.io.block_set := block_set
    val clear_done = playfield_top_inst.io.clear_done

  val lines_cleared_num = playfield_top_inst.io.lines_cleared.stage()
  */
  picoller_inst.io.update := update
  picoller_inst.io.block_set := block_set

  play_field.io.restart := restart
  play_field.io.clear_start := clear_start
  play_field.io.update := update
  play_field.io.block_set := block_set

  val clear_done = play_field.io.clear_done
  val lines_cleared_num = play_field.io.lines_cleared.stage()

  val piece_gen_flow = piece_gen.io.shape

  val id_debug = RegInit(U(0, 5 bits ))

  //val gen_shape = RegNextWhen(piece_gen_flow.payload, piece_gen_flow.valid )


  val gen_piece_en = Reg(Bool()) init False

  piece_gen.io.enable := gen_piece_en

  val block_skip_en = RegInit(False)
  picoller_inst.io.block_skip_en := block_skip_en

  // temp change begin
  //val start_x = RegInit(U(colNum/2-1, log2Up(colNum) bit  ))
  //val start_y = RegInit(U(0, log2Up(rowNum) bit ))
  val start_x = U(colNum/2-1, log2Up(colNum) bit )
  val start_y = U(0, log2Up(rowNum) bit )


  val pos_x_cur = RegInit( U(0, log2Up(colNum) bit ) )
  val pos_y_cur = RegInit( U(0, log2Up(rowNum) bit ) )


  val rot_cur = RegInit( U(0, 2 bit ))
  val shape_cur = Reg(TYPE())
  val req_valid = RegInit(False)

  val pos_x_chk = RegInit( U(0, log2Up(colNum) bit ) )
  val pos_y_chk = RegInit( U(0, log2Up(rowNum) bit ) )
  val rot_chk = RegInit( U(0, 2 bit ))
  val shape_chk = Reg(TYPE())

  piece_req.orign.x := pos_x_cur
  piece_req.orign.y := pos_y_cur
  piece_req.rot := rot_cur
  piece_req.`type` := shape_cur


  req_valid := False
  update := False

  block_set := True

  piece_req.valid := req_valid

  val move_en = RegInit( False)
  val ctrl_en = RegInit( False)
  val drop_down = RegInit( False)
  val place_en = RegInit( False)
  val playfield_fsm_result = RegInit( False)
  val playfield_fsm_reset = RegInit( False)

  val fsm_is_place = Bool()

  /* Debug signal  */
  val debug_move_type = RegInit( U(0, 3 bits))

  val playfield_fsm = new StateMachine {

    play_field.io.fetch := False   // temp

    val STANDBY = makeInstantEntry()
    STANDBY.whenIsActive {
      when( move_en ) {
        goto(MOVE)
      }
    }


    val MOVE: State = new State {
      whenIsActive {

        //temp add
        block_set := False

        pos_x_chk := pos_x_cur
        pos_y_chk := pos_y_cur
        rot_chk := rot_cur
        shape_chk := shape_cur

        when(ctrl_en && io.move_left) {
          pos_x_chk := pos_x_cur - 1
          goto(CHECK)
        }

        when(ctrl_en && io.move_right) {
          pos_x_chk := pos_x_cur + 1
          goto(CHECK)
          debug_move_type := 2
        }

        when(ctrl_en && io.rotate) {
          rot_chk := rot_cur + 1
          goto(CHECK)
          debug_move_type := 3
        }

        when( (ctrl_en && io.move_down ) || drop_down  ) {
          pos_y_chk := pos_y_cur + 1
          goto(CHECK)


        }

        when ( ctrl_en ) {
          when (io.move_left )          {  debug_move_type := 1 }
            .elsewhen ( io.move_right )  {  debug_move_type := 2 }
            .elsewhen ( io.move_down )  {  debug_move_type := 3 }
            .elsewhen ( io.rotate )     {  debug_move_type := 4 }
        }.elsewhen ( drop_down )        {  debug_move_type := 5 }
          .elsewhen ( place_en  )        {  debug_move_type := 6 }

        // Since main main_fsm is "Place", enter CHECK directly
        when ( place_en ) {
          goto(CHECK)
        }

      }

      onExit {
        playfield_fsm_result := False
      }
    }

    val CHECK: State = new State {
      onEntry {
        req_valid := True

      }
      whenIsActive {
        piece_req.orign.x := pos_x_chk
        piece_req.orign.y := pos_y_chk
        piece_req.rot := rot_chk

        // Chengtao temp to change
        //  New block does not compare with previous block. It leads this T always to be checked.
        block_skip_en := ! fsm_is_place

        /* chengtao temp to change
        when(collision_in.valid) {

          when(collision_in.payload) {
            goto(STATUS)
          } otherwise {
            goto(ERASE)  /* ? if this is new block from random, no need to enter ERASE */
          }
        }

        onExit {
          block_skip_en := False
        }
        */
        when(collision_in.valid) {

          when(collision_in.payload) {
            goto(STATUS)
          } elsewhen ( fsm_is_place  ) {
            goto(UPDATE)
          } otherwise {
            goto(ERASE)  /* ? if this is new block from random, no need to enter ERASE */
          }
        }
      }
      onExit {
        block_skip_en := False
      }

    }

    val ERASE: State = new State {

      onEntry {
        req_valid := True

      }
      whenIsActive {
        update := True
        block_set := False
        when(collision_in.valid) {
          goto(UPDATE)
        }
      }

      onExit {
        pos_x_cur := pos_x_chk
        pos_y_cur := pos_y_chk
        rot_cur := rot_chk

      }
    }

    /*
        val UPDATE: State = new State {
          onEntry {
            req_valid := True
          }

          whenIsActive{
            update := True

            when (collision_in.valid )  {
              playfield_fsm_result := True
              goto(STATUS)
            }
          }

        }
    */
    val UPDATE: State = new State {
      onEntry {
        req_valid := True
      }

      whenIsActive{
        update := True

        when (collision_in.valid )  {
          playfield_fsm_result := True
          if ( test )  {
            goto(STATUS)
          } else {
            goto(START_REFRESH)
          }
        }
      }

    }

    val START_REFRESH : State = new State {
      whenIsActive {
        block_set := False
        when(  io.force_refresh ) {
          play_field.io.fetch := True
          goto(WAIT_FRESH_DONE)
        }

      }

    }

    val WAIT_FRESH_DONE : State = new State {
      whenIsActive{
        when(io.draw_field_done ) {
          goto(STATUS)
        }
      }
    }


    val STATUS: State = new State {

      whenIsActive{
        //temp add
        block_set := False
        goto(MOVE)
      }
    }


  }

  io.ctrl_allowed := playfield_fsm.isActive(playfield_fsm.MOVE )

  val main_fsm = new StateMachine {

    gen_piece_en := False
    drop_down := False
    move_en := False
    //ctrl_en := False
    place_en := False
    restart := False

    playfield_fsm_reset :=  False
    clear_start := False

    val drop_timeout = Timeout( if ( test ) 10000 else levelFallInCycle )  // Timeout who tick after 10 ms
    val lock_timeout = Timeout( if ( test ) 100 else lockDownInCycle  )  // Timeout who tick after 10 ms

    val IDLE = makeInstantEntry()
    IDLE.whenIsActive {
      restart := True
      when(io.game_start) {
        goto(GAME_START)
      }
    }

    val GAME_START: State = new State {

      whenIsActive {
        when ( io.screen_is_ready ) {
          goto(RANDOM_GEN)
        }
      }

    }

    val RANDOM_GEN: State = new State {
      onEntry {
        move_en := True  // Initiate sub FSM
        gen_piece_en := True
      }

      whenIsActive {
        when(piece_gen_flow.valid) {
          goto(PLACE)
        }
      }

      onExit{
        pos_x_cur := start_x
        pos_y_cur := start_y
        rot_cur := U(0)
        shape_cur.assignFromBits(piece_gen_flow.payload.asBits)
      }

    }

    val PLACE: State = new State {

      onEntry {
        place_en := True
        id_debug := id_debug + 1
      }

      whenIsActive {
        when ( playfield_fsm.isActive(playfield_fsm.STATUS) ) {
          when(playfield_fsm_result) {
            goto(FALLING)
          } otherwise {
            goto(END)
          }
        }

      }
    }

    val END: State  = new State {
      whenIsActive {
        goto(IDLE)
      }
    }

    /* ****************************************************************
    FALLING PHASE :
      - Entry:
          + Generation of Tetrimino is done
      - During :
          + Can move right/left, rotate, Soft Drop, Hard Drop.
       - Exit :
          + Fall & Drop Speed by one line:
            Level	Fall Speed (seconds per line)
              1	1.0
              2	0.793
              3	0.618
              4	0.473
              5	0.355
              6	0.262
              7	0.190
              8	0.135
              9	0.094
              10	0.064
              11	0.043
              12	0.028
              13	0.018
              14	0.011
              15	0.007
    ****************************************************************** */

    val FALLING: State = new State {
      onEntry {
        drop_timeout.clear()
        ctrl_en := True
      }

      whenIsActive {

        when ( drop_timeout && playfield_fsm.isActive(playfield_fsm.MOVE) )  {
          goto(LOCK)
        }
      }

    }

    /*
    LOCK_PHASE :
      - Entry
        + The Tetrimino enters from Falling Phase Once it lands on a Surface
        + The Tetrimino is Hard Dropped.

      - During
        + Can move left/right/rotate.

      - Exit
        + if moving or rotating a Tetrimino causes it to fall again, that is, enter a new line, re-enters Falling Phase
        + Enter the Patter Phase once the Tetrimino is fulling locked down ( 0.5 s )

     */

    val LOCK: State = new State {
      onEntry {
        ctrl_en := False
        drop_down := True
      }

      whenIsActive {
        when ( playfield_fsm.isActive(playfield_fsm.STATUS) ) {
          when(playfield_fsm_result) {
            goto(FALLING)
          } otherwise {
            goto(LOCKDOWN)
          }
        }
      }

    }


    val LOCKDOWN: State = new State {

      onEntry {
        lock_timeout.clear()
      }
      whenIsActive {
        when (lock_timeout) {
          goto(PATTERN)
        }
      }
    }


    /*
    Pattern Phase
      - Entry
        Lock Phase
      - During
        + Line Clear ( Do not take up game time ) by checking if no full row occuppied
    */

    val PATTERN:State = new State {
      onEntry{
        playfield_fsm_reset := True
        clear_start := True
      }

      whenIsActive {
        when (clear_done ) {
          goto(RANDOM_GEN)
        }
      }

    }


  }

  fsm_is_place  := main_fsm.isActive(main_fsm.PLACE)


  val main_fsm_debug = Bits()

  main_fsm.postBuild{
    main_fsm_debug := main_fsm.stateReg.asBits
  }
  val playfield_fsm_debug = Bits()

  playfield_fsm.postBuild{
    playfield_fsm_debug := playfield_fsm.stateReg.asBits
  }


  val score = new Area {

    val total_score = RegInit(U"00000000")
    val score_with_bonus = U(0)
    switch(lines_cleared_num.payload) {
      is(U(1)) {
        score_with_bonus := U(1)
      }
      is(U(2)) {
        score_with_bonus := U(2)
      }
      is(U(3)) {
        score_with_bonus := U(3)
      }
      is(U(4)) {
        score_with_bonus := U(4)
      }
    }

    when ( main_fsm.isActive(main_fsm.GAME_START) ) {
      total_score := U(0)
    }

    when(lines_cleared_num.valid) {
      total_score := total_score + score_with_bonus
    }

  }
}

object gameLogicMain{
  def main(args: Array[String]) {
    val rowNum : Int = 23   // include bottom wall
    val colNum :Int = 12    // include left and right wall
    val config = LogicTopConfig( rowNum, colNum )
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SSC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new logic_top(config)
    )
  }
}





