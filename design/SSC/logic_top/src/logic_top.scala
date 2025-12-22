package SSC.logic_top


import spinal.core._
import spinal.lib._
import spinal.lib.PriorityMux._

import IPS.seven_bag_rng._
import IPS.picoller._
import IPS.playfield._
import IPS.controller._
import config.TYPE
import utils._
import spinal.lib.fsm.{State, StateFsm, StateMachine}


case class  LogicTopConfig ( rowNum : Int,
                             colNum : Int ,
                             freeze_screen_in_frames : Int = 40,
                             levelFallInCycle : Int = 473 * 50000,
                             lockDownInCycle  : Int = 500 * 50000
                           ) {

  val rowBitsWidth = log2Up(rowNum)
  val colBitsWidth = log2Up(colNum)
  val rowBlocksNum = rowNum - 1   // working field for Tetromino
  val colBlocksNum = colNum - 2   // working field for Tetromino

  // 437 ms / ( 1 / 50 MHz ) = 437 * 50 * 1000
//  val levelFallInCycle = 473 * 50000
//  val lockDownInCycle  = 500 * 50000

  val playFieldConfig = PlayfieldConfig(
    rowBlocksNum = rowBlocksNum,
    colBlocksNum = colBlocksNum,
    rowBitsWidth = rowBitsWidth,
    colBitsWidth = colBitsWidth
  )

  val controllerConfig = ControllerConfig (
    rowNum = rowNum,
    colNum = colNum,
    freeze_screen_in_frames = freeze_screen_in_frames,
    levelFallInCycle = levelFallInCycle,
    lockDownInCycle = lockDownInCycle
  )

  val picollerConfig =  PicollerConfig( colBitsWidth, rowBitsWidth)


}

class logic_top ( val config : LogicTopConfig, sim  : Boolean = false  ) extends Component {

  import config._

  val io = new Bundle {
    val game_start = in Bool()
    val move_left = in Bool()
    val move_right = in Bool()
    val move_down = in Bool()
    val rotate = in Bool()
    val drop = in Bool()
    val row_val = master Flow (Bits(colBlocksNum bits))
    val draw_field_done = in Bool()
    val screen_is_ready = in Bool()
    //val force_refresh = in Bool()
    val vga_sof = in Bool()
    val ctrl_allowed = out Bool()
    val softReset = out Bool()
    val game_restart = out Bool()

    val controller_in_lockdown = sim generate( out Bool () )
    val controller_in_end      = sim generate( out Bool () )
    val controller_in_place    = sim generate( out Bool () )
    val new_piece_valid        = sim generate( out Bool () )
  }


  noIoPrefix()


  //***********************************************************
  //              Instantiation
  //***********************************************************

  val piece_gen_inst = new seven_bag_rng()
  val playfield_inst = new playfield(playFieldConfig, sim = false, enableCollisonReadout = sim )
  val controller_inst = new controller(controllerConfig, sim = sim )


//  //***********************************************************
//  //              Motion request voter
//  //***********************************************************
//
//  val motion_request = RegInit(B(0, 5 bit))
//
//  /*
//      priority  : Highest Priority
//      b00000000 : LSB, 0 bit
//  */
//  val priority = cloneOf(motion_request) setAsReg() init B(0)  // LSB
//
//  val drop, move_down, move_left, move_right, rotate = Bool()
//
//  val motion_trans_with_indx = Seq(
//    io.drop         -> drop,
//    io.move_down    -> move_down,
//    io.move_left    -> move_left,
//    io.move_right   -> move_right,
//    io.rotate       -> rotate,
//  ).zipWithIndex
//
//  for ( ( ( sig, _ ), i ) <- motion_trans_with_indx )  {
//    motion_request(i) := sig.rise(False)
//  }
//  val motion_voted = OHMasking.roundRobin( requests = motion_request,ohPriority = priority  )
//  for ( ( ( _, sig ), i ) <- motion_trans_with_indx ) {
//    sig := motion_voted(i)
//  }



  // Controller Connection

  /* Input - io */
  controller_inst.io.game_start := io.game_start
  controller_inst.io.move_left := io.move_left
  controller_inst.io.move_right := io.move_right
  controller_inst.io.move_down := io.move_down
  controller_inst.io.rotate := io.rotate
  controller_inst.io.drop  := io.drop
  controller_inst.io.screen_is_ready  := io.screen_is_ready


  /* Input <- playfield_inst */
  controller_inst.io.playfiedl_in_idle := playfield_inst.io.fsm_is_idle
  controller_inst.io.playfiedl_allow_action := playfield_inst.io.motion_is_allowed
//  controller_inst.io.collision_status << playfield_inst.io.status
  controller_inst.io.collision_status << playfield_inst.io.status.stage()


  /* output -> piece_gen_inst */
  piece_gen_inst.io.enable := controller_inst.io.gen_piece_en
  playfield_inst.io.piece_in.assignFromBits( piece_gen_inst.io.shape.asBits )

  /* output -> playfield_inst */
  playfield_inst.io.move_in.assignAllByName( controller_inst.io.move_out )

  playfield_inst.io.lock := controller_inst.io.lock
  playfield_inst.io.game_restart := controller_inst.io.game_restart



  /* output -> IO */
  io.softReset := controller_inst.io.softReset
  io.game_restart := controller_inst.io.game_restart
  if (sim ) {
    io.controller_in_lockdown := controller_inst.io.controller_in_lockdown
    io.controller_in_end      := controller_inst.io.controller_in_end
    io.controller_in_place    := controller_inst.io.controller_in_place
    io.new_piece_valid := controller_inst.io.gen_piece_en
  }

  // Playfield Connection

  /* output -> IO */
  io.row_val <<  playfield_inst.io.row_val
  io.ctrl_allowed := playfield_inst.io.motion_is_allowed



//
//  val score = new Area {
//
//    val total_score = RegInit(U"00000000")
//    val score_with_bonus = U(0)
//    switch(lines_cleared_num.payload) {
//      is(U(1)) {
//        score_with_bonus := U(1)
//      }
//      is(U(2)) {
//        score_with_bonus := U(2)
//      }
//      is(U(3)) {
//        score_with_bonus := U(3)
//      }
//      is(U(4)) {
//        score_with_bonus := U(4)
//      }
//    }
//
//    when ( main_fsm.isActive(main_fsm.GAME_START) ) {
//      total_score := U(0)
//    }
//
//    when(lines_cleared_num.valid) {
//      total_score := total_score + score_with_bonus
//    }
//
//  }




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





