package IPS.controller


import spinal.core._
import spinal.lib._
import IPS.seven_bag_rng._
import IPS.picoller._
import IPS.play_field._
import SSC.logic_top.LogicTopConfig
import config.TYPE
import spinal.core
import utils._
import spinal.lib.fsm.{State, StateFsm, StateMachine}


case class ControllerConfig (
                              rowNum : Int,
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

//  val playFieldConfig = PlayFieldConfig(
//    rowBlocksNum = rowBlocksNum,
//    colBlocksNum = colBlocksNum,
//    rowBitsWidth = rowBitsWidth,
//    colBitsWidth = colBitsWidth
//  )

//  val picollerConfig =  PicollerConfig( colBitsWidth, rowBitsWidth)
}


class controller ( config : ControllerConfig, sim : Boolean = false     ) extends Component {
  import config._

  val io = new Bundle {
    val game_start = in Bool()
    val move_left = in Bool()
    val move_right = in Bool()
    val move_down = in Bool()
    val rotate = in Bool()
    val drop = in Bool()
    val screen_is_ready = in Bool()
    val playfiedl_in_idle = in Bool()
    val playfiedl_allow_action = in Bool()
    val game_restart = out Bool()
    val softReset = out Bool()
    val gen_piece_en = out Bool()
    val collision_status = slave Flow (Bool())
    val move_out = new Bundle {
      val left = out Bool()
      val right = out Bool()
      val rotate = out Bool()
      val down = out Bool()
    }
    val lock = out Bool()
    val debug_place_new = out Bool()
    val controller_in_lockdown = sim generate( out Bool () )
    val controller_in_end     = sim generate( out Bool () )
    val controller_in_place   = sim generate( out Bool () )
  }


  noIoPrefix()

  //***********************************************************
  //              Instantiation
  //***********************************************************


  val drop_timeout = Timeout( if ( sim ) 10000 else levelFallInCycle )  // Timeout who tick after 10 ms
  val lock_timeout = Timeout( if ( sim ) 100 else lockDownInCycle  )  // Timeout who tick after 10 ms



  //***********************************************************
  //              Motion request voter
  //***********************************************************

//  val motion_is_allowed = fsm.isActive(fsm.FALLING)

  val motion_request = RegInit(B(0, 5 bit))

  /*
      priority  : Highest Priority
      b00000000 : LSB, 0 bit
  */
  val priority = cloneOf(motion_request) setAsReg() init B(1)  // LSB

  val drop, move_down, move_left, move_right, rotate = Bool()

  val motion_trans_with_indx = Seq(
    io.drop         -> drop,
    io.move_down    -> move_down,
    io.move_left    -> move_left,
    io.move_right   -> move_right,
    io.rotate       -> rotate,
  ).zipWithIndex

  for ( ( ( sig, _ ), i ) <- motion_trans_with_indx )  {
//    when ( sig.rise(False) ) {
//      motion_request(i) := True
//    }
    when ( io.game_start || io.game_restart ) {
      motion_request(i) := False
    } .elsewhen( sig.rise(False) ) {
      motion_request(i) := True
    }

  }

  val motion_voted = OHMasking.roundRobin( requests = motion_request,ohPriority = priority  )

  for ( ( ( _, sig ), i ) <- motion_trans_with_indx ) {
    sig := motion_voted(i)
  }



  //***********************************************************
  //              FSM
  //***********************************************************

  val debug_place_new_cnt = Counter(stateCount = 2  )

  io.debug_place_new.addAttribute("keep")
  io.debug_place_new  := debug_place_new_cnt.willOverflow



  val fsm = new StateMachine {

    def transitionOnCollision(onCollision: State, onNoCollision: State): Unit = {
      when(io.collision_status.valid) {
        when(io.collision_status.payload) {
          goto(onCollision)
        } otherwise {
          goto(onNoCollision)
        }
      }
    }

    io.gen_piece_en    := False
    io.move_out.left   := False
    io.move_out.right  := False
    io.move_out.rotate := False
    io.move_out.down   := False
    io.softReset := False
    io.game_restart := False
    io.lock := False

    val IDLE = makeInstantEntry()
    IDLE.whenIsActive {
      when(io.game_start) {
        goto(GAME_START)
      }
    }

    val GAME_START: State = new State {
      whenIsActive {
        when(io.screen_is_ready) {
          goto(RANDOM_GEN)
        }
      }

    }

    val RANDOM_GEN: State = new State {
      whenIsActive {
        io.gen_piece_en := True
        goto(PLACE)
      }
    }

    val PLACE: State = new State {
      whenIsActive {
        transitionOnCollision( onCollision= END, onNoCollision = FALLING)
      }

      onExit {
        drop_timeout.clear()
        debug_place_new_cnt.increment()
      }
    }

    val END: State  = new State {
      whenIsActive {
        when(io.game_start) {
          io.softReset := True // Game fail and restart the game
          io.game_restart := True
//          goto(IDLE)
          goto(GAME_START)
        }
      }
    }

    val FALLING: State = new State {


      whenIsActive {
        when ( move_down & io.playfiedl_allow_action) {
          goto(DOWN)
        }

        when ( drop & io.playfiedl_allow_action ) {
          goto(DROP)
        }

        when ( move_left  & io.playfiedl_allow_action ) {
          io.move_out.left   := True
          goto(MOVE)
        }

        when (  move_right  & io.playfiedl_allow_action ) {
          io.move_out.right  := True
          goto(MOVE)
        }

        when (  rotate  & io.playfiedl_allow_action ) {
          io.move_out.rotate  := True
          goto(MOVE)
        }

        when ( drop_timeout  )  {
          goto(LOCK)
        }
      }

      onExit(
        motion_request.clearAll()
      )

    }

    val DOWN : State = new State {
      onEntry {
        io.move_out.down := True
      }

      whenIsActive(
        when(io.collision_status.valid) {
          when( !io.collision_status.payload) {
            drop_timeout.clear()   // drop to a new line and restart drop-timer
          }
          goto( FALLING )
        }
      )

    }

    val DROP : State = new State {
      onEntry {
        io.move_out.down := True
      }

      whenIsActive(  // Once it drops on the botton and is locked )
        transitionOnCollision( onCollision= LOCKDOWN, onNoCollision = WAIT_ALLOW_ACTION)
      )

    }

    val WAIT_ALLOW_ACTION = new State {
      whenIsActive {
        when ( io.playfiedl_allow_action )  {
          goto(DROP)
        }
      }
    }


    val MOVE : State = new State {
      whenIsActive(
        when ( io.collision_status.valid ) { goto(FALLING) }
      )

    }


    val LOCK: State = new State {
      onEntry {
        io.move_out.down := True
      }

      whenIsActive(  // Once it drops on the botton and is locked )

        when(io.collision_status.valid) {
          when(io.collision_status.payload) {
            goto(LOCKDOWN)
          } otherwise {
            drop_timeout.clear()
            goto(FALLING)
          }
        }
      )
    }

    val LOCKDOWN: State = new State {
      onEntry {
        lock_timeout.clear()
      }
      whenIsActive {
        when (lock_timeout) {
          io.lock := True
          goto(CLEAN)
        }
      }
    }

    val CLEAN :State = new State {
      whenIsActive {
        when ( io.playfiedl_in_idle ) {
          lock_timeout.clear()
          goto(WAIT_TIME)
        }
      }
    }

    // Wait for a while until all playfield is written into frame buffer
    val WAIT_TIME :State = new State {
      whenIsActive {
        when (lock_timeout) {
          goto(RANDOM_GEN)
        }
      }
    }

  }


  if ( sim ) {
    io.controller_in_lockdown := fsm.isActive(fsm.LOCKDOWN)
    io.controller_in_end      := fsm.isActive(fsm.END)
    io.controller_in_place    := fsm.isActive(fsm.PLACE)
  }
}

object controllerMain{
  def main(args: Array[String]) {
    val rowNum : Int = 23   // include bottom wall
    val colNum :Int = 12    // include left and right wall
    val config = ControllerConfig( rowNum, colNum )
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new controller(config)
    )
  }
}
