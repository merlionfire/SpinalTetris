package SSC.logic_top

import spinal.core._
import spinal.core.sim._

import scala.collection.mutable

//import IPS.playfield.executors.MotionTestExecutorBase
import IPS.playfield.visualizers.MotionVisualizer
import utils.PlayFieldScoreboard
import utils.TestPatterns.TestMotionPatternGroup
import IPS.playfield.{PlayfieldBackdoorAPI, PlayfieldTestBase, playfield}
import utils.MotionPatternGenerators
import utils.MotionPatternGenerators._


import scala.util.control.Breaks.{break, breakable}


trait MotionTestExecutorBase {

  def printMotionActionHeader(
                               action: Seq[Pattern],
                               roundIndex: Int,
                             ): Unit = {
    println(s"\n${"=" * 100}\n")
    println(s"\t\tExecuting Round ${roundIndex + 1} : ${getMotionsDescription(action)}")
    println(s"\n${"=" * 100}")
  }

  def printMotionTestSummary(actionsByRound: Seq[Seq[Pattern]]): Unit = {
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tMotion Test Group Summary\n")
    println(f"\t\t\tMotions")

    for ( ( pat, i )  <- actionsByRound.zipWithIndex ) {
      println(f"\t${i + 1}:\t${getMotionsDescription(pat)} ")
    }
    println(s"\n${"=" * 120}")
  }
}


trait MotionTestExecutor extends MotionTestExecutorBase  {


  def executeTestMotionActions(
                                dut: logic_top,
                                scbd: PlayFieldScoreboard,
                                length: Int,
                                width: Int,
                                actions: Seq[Seq[MotionPatternGenerators.Pattern]],
                                verbose: Boolean
                              ): Unit = {


    val visualizer = new MotionVisualizer(
      xStart = 100, yStart = 100,
      width = dut.config.colBlocksNum,
      height = dut.config.rowBlocksNum,
      testClass = getClass ,
      middlePath =  "design/SSC"
    )
    printMotionTestSummary(actions)

    startGame(dut)

    var round = 0

    dut.clockDomain.waitSamplingWhere(condAnd = dut.io.new_piece_valid.toBoolean)
    // Main Body
//    for ( ( round,  roundIndex  )  <- actions.zipWithIndex  ) { /* One round means one game round */
    for (  ( action, actionIndex )   <- actions.zipWithIndex  ) {
      /* One round means one game round */

      if (verbose) {
        printMotionActionHeader(action, actionIndex)
      }

      val motionNames = mutable.Queue[String]("Place")
      val motionSequence = expandMotionPatterns(action)

      dut.clockDomain.waitSampling(20)

      motionSequence.forall { motion =>
        val isPieceFlow = issueMotion(dut, motion)
        motionNames.enqueue(motion)
        isPieceFlow
      }

      // Wait until new piece is placed
      //      dut.clockDomain.waitSamplingWhere(condAnd = dut.io.new_piece_valid.toBoolean)
      dut.clockDomain.waitSamplingWhere(condAnd = dut.io.controller_in_place.toBoolean )

      val playfieldList = scbd.actualData.grouped(dut.config.rowBlocksNum).toList

      playfieldList.foreach { playfieldState =>

        val motionName = if (motionNames.nonEmpty) motionNames.dequeue() else "DP"
        visualizer.recordFrame(motionName, playfieldState)
      }

      val targetName = s"sim/img/Motion_${round}/Action_${actionIndex}.png"


      visualizer.saveFrameSequence(targetName = targetName)
      // ✅ Clear visualizer for next action
      visualizer.clear()
      scbd.clear()

      println(s"[DEBUG]${simTime()} Checking if dut.io.controller_in_end is asserted ...  " )

      // 25 cycles are enough for duration of piece generation + place collision check
      val gameIsOver = !dut.clockDomain.waitSamplingWhere(25)(condAnd = dut.io.controller_in_end.toBoolean)
      println(s"[DEBUG]${simTime()} gameIsOver = ${gameIsOver}" )

      if (gameIsOver) {
        round = round + 1
        println(s"[DEBUG]${simTime()} Restart game  !!" )
        startGame(dut)
      }
    }

//      breakable {
//        for ((action, actionIndex) <- round.zipWithIndex) {
//
////
////
////
////          // Step 1 - Preload playfield in terms of pattern
////          if (action.p0 != BitPatternGenerators.Hold) {
////
////            val playfieldData = Seq.fill(dut.config.rowBlocksNum)(0)
////            visualizer.recordInitialPlayfield(playfieldData)
////
////          }
////
////          // Step 2 : Generate and Place piece
////          val (pieceType, rot) = PiecePatternGenerators.generatePiecePattern(action.p1).sample match {
////            case Some((pieceType, rot)) => (pieceType, rot)
////            case None => simFailure("[ERROR] No Piece is created !!!");
////          }
////
////          issuePlacePiece(dut, pieceType)
////
////          // check if game over
////          dut.clockDomain.waitSamplingWhere(dut.io.status.valid.toBoolean)
////          if ( dut.io.status.payload.toBoolean ) {
////            gameExitStatus = "FAIL"
////            break
////          }
////
////          // ✅ Record placement action
////          val playfieldAfterPlace = readCurrentPlayfield(dut, scbd)
////          visualizer.recordFrame("PLACE", playfieldAfterPlace)
////
////          // Step 7: Execute motion sequence
//          val motionSequence = expandMotionPatterns(action.p2)
//          val motionCompleted = executeMotionSequenceWithVisualization(
//            dut,
//            scbd,
//            motionSequence,
//            visualizer
//          )
//
//          if ( motionCompleted ) {
//            println(s"[INFO] @${simTime()} Motion sequence is done but piece has NOT been landed" )
//          } else {
//            println(s"[INFO] @${simTime()} Motion sequence interrupted - piece landed")
//          }
//
//          lockPiece(dut)
//
//          // Step 9: Save visualization for this action
//          visualizer.saveFrameSequence(
//            roundIndex = roundIndex,
//            actionIndex = actionIndex,
//            playfieldPattern = action.p0.toString,
//            piecePattern = action.p1.toString
//          )
//          // ✅ Clear visualizer for next action
//          visualizer.clear()
//
//        }
//
//        gameExitStatus
//      }  // end of breakable


//      if ( gameExitStatus == "PASS ") {
//        println(s"[INFO] @${simTime()} all motions have been executed. The game exits here ")
//      }
//
//      if ( gameExitStatus == "FAIL ") {
//        println(s"[INFO] @${simTime()} Placing a new piece failed. Game is over here ")
//      }

  }

  def startGame(dut: logic_top ) : Unit = {
    dut.io.game_start #= true
    dut.clockDomain.waitSampling()
    dut.io.game_start #= false
  }

  def issueMotion(dut: logic_top, motion: String): Boolean  = {
    //    dut.clockDomain.waitSamplingWhere(dut.io.motion_is_allowed.toBoolean)
    dut.clockDomain.waitSampling()
    println(s"[INFO] @${simTime()} Issue [${motion}] to DUT via interface")
    motion match {
      case "LF" => dut.io.move_left #= true
      case "RG" => dut.io.move_right #= true
      case "RT" => dut.io.rotate #= true
      case "DN" => dut.io.move_down #= true
      case "DP" => dut.io.drop #= true
    }

    fork {
      dut.clockDomain.waitSampling(3)
      dut.io.move_left #= false
      dut.io.move_right #= false
      dut.io.rotate #= false
      dut.io.move_down #= false
      dut.io.drop #= false
    }

    dut.clockDomain.waitSamplingWhere(40)(condAnd = dut.io.controller_in_lockdown.toBoolean)

  }

  private def readCurrentPlayfield( scbd: PlayFieldScoreboard , rowBlocksNum : Int ): Seq[Int] = {

    val currentState = scbd.actualData.take( rowBlocksNum )

    //    println(s"[INFO] @${simTime()} scbd.actualData has ${currentState.length} item ")
    //    println(s"[INFO] @${simTime()} scbd.actualData is ${currentState.toString()}")
    assert (
      currentState.length == rowBlocksNum,
      s"The number of Playfield rows observed is ${currentState.length} but Expected is ${rowBlocksNum}"
    )
    scbd.actualData.remove(0,currentState.length )

    currentState
  }




}
