package IPS.playfield.executors

import IPS.playfield.visualizers.MotionVisualizer
import IPS.playfield.{PlayfieldBackdoorAPI, PlayfieldTestBase, playfield}
import spinal.core._
import spinal.core.sim._
import utils.ImageGenerator.{GridItem, PlaceTetromino, TextLabel}
import utils.TestPatterns._
import utils._

import java.awt.Color
import scala.collection.mutable
import scala.util.control.Breaks.{break, breakable}


trait MotionTestExecutorBase {

  def printMotionActionHeader(
                                       action: TestMotionPatternGroup,
                                       roundIndex: Int,
                                       actionIndex: Int,
                                       totalActions: Int
                                     ): Unit = {
    println(s"\n${"=" * 100}\n")
    println(s"\t\tExecuting Round ${roundIndex + 1}, Action ${actionIndex + 1}/${totalActions}")
    println(s"\t\tPurpose\t: ${action.description}")
    println(s"\t\tPattern\t: ${action.p0} : ${action.p1} ${action.getMotionsDescription}")
    println(s"\n${"=" * 100}")
  }

  /**
   * Splits a sequence of test motion pattern groups into rounds based on their pattern types.
   *
   * This method organizes motion patterns into separate rounds, where each round begins with
   * a non-Hold pattern (typically AllZeros or other initialization patterns, it acts as game start scenario) and continues
   * with subsequent Hold patterns that belong to the same round. Each non-Hold pattern starts
   * a new round ( new game ) , while Hold patterns are appended to the most recent round.
   *
   * The splitting logic:
   * - Any non-Hold pattern starts a new round containing that single element
   * - Hold patterns are appended to the current (last) round
   * - The first element must be a non-Hold pattern; otherwise an exception is thrown
   *
   * @param allActions the complete sequence of motion pattern groups to be split into rounds.
   *                   Must start with a non-Hold pattern type.
   * @return a list of rounds, where each round is a list of TestMotionPatternGroup elements.
   *         Each round starts with a non-Hold pattern followed by zero or more Hold patterns.
   * @throws IllegalStateException if the first element is a Hold pattern, or if a Hold pattern
   *                               is encountered when no prior round exists
   */
  def splitMotionsByRound ( allActions : Seq[TestMotionPatternGroup] ) : List[List[TestMotionPatternGroup]] = {
    allActions.foldLeft( List.empty[List[TestMotionPatternGroup]]) {
      case ( acc, elem @ TestMotionPatternGroup(playfieldPattern , _,_,_ ) )
        if playfieldPattern != BitPatternGenerators.Hold => acc :+ List(elem )
      case ( acc :+ last , elem @ TestMotionPatternGroup(BitPatternGenerators.Hold , _,_,_) ) =>  acc :+ (last :+ elem )
      case (Nil, elem) =>
        throw new IllegalStateException(
          s"Unexpected first element: expected not BitPatternGenerators.HOLD, but got ${elem.p0}"
        )
      case (_, elem) =>
        throw new IllegalStateException(
          s"Unexpected pattern type: ${elem.p0}. Expected  BitPatternGenerators pattern."
        )
    }
  }

  def printMotionTestSummary(actionsByRound: List[List[TestMotionPatternGroup]]): Unit = {
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tMotion Test Group Summary\n")
    println(f"\t\t\tPlayfield\tx\tPiece\t:\tMotions")
    for ((round, i) <- actionsByRound.zipWithIndex) {
      println(f"\tRound ${i + 1}:")
      for (pattern <- round) {
        println(f"\t\t${pattern.p0}%10s\tx\t${pattern.p1}%5s\t:\t${pattern.getMotionsDescription}")
      }
    }
    println(s"\n${"=" * 120}")
  }

}


trait MotionTestExecutor extends  MotionTestExecutorBase {

  this: PlayfieldTestBase with PlayfieldBackdoorAPI =>

  def executeTestMotionActions(
                                dut: playfield,
                                scbd: PlayFieldScoreboard,
                                length: Int,
                                width: Int,
                                actions: Seq[TestMotionPatternGroup],
                                verbose: Boolean
                              ): Unit = {

    val motionsQueue = mutable.Queue[String]()

    /**
     * Overlays sequence `b` onto sequence `a` using a bitwise OR operation.
     *
     * @param a   The base sequence.
     * @param b   The sequence to overlay.
     * @param row The starting index in `a` where the operation begins.
     * @return A new sequence with the result of the OR operation.
     */

    def model(a: Seq[Int], b: Seq[Int], row: Int): Int = {

      val region_overlap = a.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << dut.config.colBlocksNum) - 1))

      val ret = region_overlap.zip(b).map { case (a, b) => (a & b).toInt > 0 }

      region_overlap.foreach { a => println(f"Compared Playield data : 0b${String.format("%10s", Integer.toBinaryString(a)).replace(' ', '0')} ") }
      ret.foldLeft(false)(_ | _) toInt

    }

    val actionsByRound  = splitMotionsByRound( actions )

    val visualizer = new MotionVisualizer(
      xStart = 100, yStart = 100,
      width = dut.config.colBlocksNum,
      height = dut.config.rowBlocksNum,
      getClass
    )
    printMotionTestSummary(actionsByRound)

    // Main Body
    for ( ( round,  roundIndex  )  <- actionsByRound.zipWithIndex  ) { /* One round means one game round */

      var gameExitStatus = "PASS"
      val playfieldPattern = round.head.p0

      breakable {
        for ((action, actionIndex) <- round.zipWithIndex) {

          /* Each round contains all piece operation called action from placing to be locked */
          if (verbose) {
            printMotionActionHeader(action, roundIndex, actionIndex, round.size)
          }

          // Step 1 - Preload playfield in terms of pattern
          if (action.p0 != BitPatternGenerators.Hold) {

            val playfieldData = preparePlayfield(dut, action, length, width)
            visualizer.recordInitialPlayfield(playfieldData)

          }

          // Step 2 : Generate and Place piece
          val (pieceType, rot) = PiecePatternGenerators.generatePiecePattern(action.p1).sample match {
            case Some((pieceType, rot)) => (pieceType, rot)
            case None => simFailure("[ERROR] No Piece is created !!!");
          }
          issuePlacePiece(dut, pieceType)

          // check if game over
          dut.clockDomain.waitSamplingWhere(dut.io.status.valid.toBoolean)
          if ( dut.io.status.payload.toBoolean ) {
            gameExitStatus = "FAIL"
            break
          }

          // ✅ Record placement action
          val playfieldAfterPlace = readCurrentPlayfield(dut, scbd)
          visualizer.recordFrame("PLACE", playfieldAfterPlace)

          // Step 7: Execute motion sequence
          val motionSequence = expandMotionPatterns(action.p2)
          val motionCompleted = executeMotionSequenceWithVisualization(
            dut,
            scbd,
            motionSequence,
            visualizer
          )

          if ( motionCompleted ) {
            println(s"[INFO] @${simTime()} Motion sequence is done but piece has NOT been landed" )
          } else {
            println(s"[INFO] @${simTime()} Motion sequence interrupted - piece landed")
          }

          lockPiece(dut)

          // Step 9: Save visualization for this action
          visualizer.saveFrameSequence(
            roundIndex = roundIndex,
            actionIndex = actionIndex,
            playfieldPattern = action.p0.toString,
            piecePattern = action.p1.toString
          )
          // ✅ Clear visualizer for next action
          visualizer.clear()

        }

        gameExitStatus
      }  // end of breakable


      if ( gameExitStatus == "PASS ") {
        println(s"[INFO] @${simTime()} all motions have been executed. The game exits here ")
      }

      if ( gameExitStatus == "FAIL ") {
        println(s"[INFO] @${simTime()} Placing a new piece failed. Game is over here ")
      }

    }

  } // executeTestMotionActions end

  /**
   * Execute motion sequence and record each frame for visualization
   */
  private def executeMotionSequenceWithVisualization(
                                                      dut: playfield,
                                                      scbd: PlayFieldScoreboard,
                                                      motions: Seq[String],
                                                      visualizer: MotionVisualizer
                                                    ): Boolean = {

    motions.forall { motion =>
      // Issue motion command
      val collisionDetected = issueMotion(dut, motion)

      // Read playfield state after motion
      val playfieldState = readCurrentPlayfield(dut, scbd)

      // ✅ Record this frame with motion label
      visualizer.recordFrame(motion, playfieldState)

      // Stop if DOWN motion collides (piece has landed)
      !(collisionDetected && motion == "DN")
    }
  }


  /**
   * Read current playfield state from scoreboard
   * This captures the actual state after each motion
   */
  private def readCurrentPlayfield(
                                    dut: playfield,
                                    scbd: PlayFieldScoreboard
                                  ): Seq[Int] = {

    // Trigger readout
    readWholePlayfield(dut)
    dut.clockDomain.waitSamplingWhere(dut.io.motion_is_allowed.toBoolean ) // wait for read done

    dut.clockDomain.waitSampling(10)
    // Get data from scoreboard (actualData contains the readout)
    val currentState = scbd.actualData.take( dut.config.rowBlocksNum )

//    println(s"[INFO] @${simTime()} scbd.actualData has ${currentState.length} item ")
//    println(s"[INFO] @${simTime()} scbd.actualData is ${currentState.toString()}")
    assert (
      currentState.length == dut.config.rowBlocksNum,
      s"The number of Playfield rows observed is ${currentState.length} but Expected is ${dut.config.rowBlocksNum}"
    )
    scbd.actualData.remove(0,currentState.length )

    currentState
  }

//  private def printMotionTestSummary(actionsByRound: List[List[TestMotionPatternGroup]]): Unit = {
//    println(s"\n${"=" * 120}\n")
//    println(s"\t\t\t\tMotion Test Group Summary\n")
//    println(f"\t\t\tPlayfield\tx\tPiece\t:\tMotions")
//    for ((round, i) <- actionsByRound.zipWithIndex) {
//      println(f"\tRound ${i + 1}:")
//      for (pattern <- round) {
//        println(f"\t\t${pattern.p0}%10s\tx\t${pattern.p1}%5s\t:\t${pattern.getMotionsDescription}")
//      }
//    }
//    println(s"\n${"=" * 120}")
//  }

//  private def printMotionActionHeader(
//                                       action: TestMotionPatternGroup,
//                                       roundIndex: Int,
//                                       actionIndex: Int,
//                                       totalActions: Int
//                                     ): Unit = {
//    println(s"\n${"=" * 100}\n")
//    println(s"\t\tExecuting Round ${roundIndex + 1}, Action ${actionIndex + 1}/${totalActions}")
//    println(s"\t\tPurpose\t: ${action.description}")
//    println(s"\t\tPattern\t: ${action.p0} : ${action.p1} ${action.getMotionsDescription}")
//    println(s"\n${"=" * 100}")
//  }
//
//  /**
//   * Splits a sequence of test motion pattern groups into rounds based on their pattern types.
//   *
//   * This method organizes motion patterns into separate rounds, where each round begins with
//   * a non-Hold pattern (typically AllZeros or other initialization patterns, it acts as game start scenario) and continues
//   * with subsequent Hold patterns that belong to the same round. Each non-Hold pattern starts
//   * a new round ( new game ) , while Hold patterns are appended to the most recent round.
//   *
//   * The splitting logic:
//   * - Any non-Hold pattern starts a new round containing that single element
//   * - Hold patterns are appended to the current (last) round
//   * - The first element must be a non-Hold pattern; otherwise an exception is thrown
//   *
//   * @param allActions the complete sequence of motion pattern groups to be split into rounds.
//   *                   Must start with a non-Hold pattern type.
//   * @return a list of rounds, where each round is a list of TestMotionPatternGroup elements.
//   *         Each round starts with a non-Hold pattern followed by zero or more Hold patterns.
//   * @throws IllegalStateException if the first element is a Hold pattern, or if a Hold pattern
//   *                               is encountered when no prior round exists
//   */
//  def splitMotionsByRound ( allActions : Seq[TestMotionPatternGroup] ) : List[List[TestMotionPatternGroup]] = {
//    allActions.foldLeft( List.empty[List[TestMotionPatternGroup]]) {
//      case ( acc, elem @ TestMotionPatternGroup(playfieldPattern , _,_,_ ) )
//        if playfieldPattern != BitPatternGenerators.Hold => acc :+ List(elem )
//      case ( acc :+ last , elem @ TestMotionPatternGroup(BitPatternGenerators.Hold , _,_,_) ) =>  acc :+ (last :+ elem )
//      case (Nil, elem) =>
//        throw new IllegalStateException(
//          s"Unexpected first element: expected not BitPatternGenerators.HOLD, but got ${elem.p0}"
//        )
//      case (_, elem) =>
//        throw new IllegalStateException(
//          s"Unexpected pattern type: ${elem.p0}. Expected  BitPatternGenerators pattern."
//        )
//    }
//  }

  /**
   * Prepare playfield based on pattern
   */
  private def preparePlayfield(
                                dut: playfield,
                                action: TestMotionPatternGroup,
                                length: Int,
                                width: Int
                              ): Seq[Int] = {

//    val ref = if (action.p0 == BitPatternGenerators.Custom) {
//      generateCustomPlayfield(length, width)
//    } else {
//      null
//    }
//
//    backdoorWritePlayfieldWithPattern(dut, length, width, action.p0, ref)
//        val ref = if (action.p0 == BitPatternGenerators.Custom) {
//          generateCustomPlayfield(length, width)
//        } else {
//          null
//        }

        backdoorWritePlayfieldWithPattern(dut, length, width, action.p0 )

  }

  /**
   * Generate custom playfield for stress testing
   *  Top 6 row : Empty
   *  Remaining : Single block is free
   */
  private def generateCustomPlayfield(length: Int, width: Int): Seq[Int] = {
    import scala.util.Random
    val zeros = Seq.fill(6)(0)
    val random8Ones = Seq.fill(14) {
      val positions = Random.shuffle( (0 to 9).toList ).take(9)  // Can change for other pattern
      positions.foldLeft(0) { (acc, pos) => acc | (1 << pos) }
    }
    zeros ++ random8Ones
  }

  /**
   * Generate piece from pattern
   */
  private def generatePieceFromPattern(
                                        pattern: PiecePatternGenerators.Pattern
                                      ): (SpinalEnumElement[config.TYPE.type], Int) = {
    PiecePatternGenerators.generatePiecePattern(pattern).sample match {
      case Some((pieceType, rot)) => (pieceType, rot)
      case None => simFailure("[ERROR] No Piece is created !!!")
    }
  }

  /**
   * Generates a single Int where 'count' number of bits are randomly set
   * within the range [0, maxBitIndex].
   *
   * @param count The number of bits to randomly set (e.g., 8)
   * @param maxBitIndex The maximum index (exclusive) for the random bits (e.g., 10 for indices 0-9)
   * @return An Int with 'count' bits set.
   */
  def generateRandomBits(count: Int, maxBitIndex: Int): Int = {
    import scala.util.Random

    // 1. Generate a List of all possible bit indices (e.g., 0 to 9)
    val allIndices = (0 until maxBitIndex).toList

    // 2. Shuffle them and take the required number of positions
    val positions = Random.shuffle(allIndices).take(count)

    // 3. Fold over the positions to create the final bit pattern
    // For each position 'pos', add the bit (1 << pos) to the accumulator
    positions.foldLeft(0) { (acc, pos) => acc | (1 << pos) }
  }

  /**
   * Expand motion patterns into motion sequence
   */
  private def expandMotionPatterns(
                                    patterns: Seq[MotionPatternGenerators.Pattern]
                                  ): Seq[String] = {
    patterns.flatMap {
      case MotionPatternGenerators.Left(step) => List.fill(step)("LF")
      case MotionPatternGenerators.Right(step) => List.fill(step)("RG")
      case MotionPatternGenerators.Rotate(step) => List.fill(step)("RT")
      case MotionPatternGenerators.Down(step) => List.fill(step)("DN")
      case MotionPatternGenerators.Drop => List.fill(20)("DN")
    }
  }

  def issueMotion(dut: playfield, motion: String): Boolean = {
    dut.clockDomain.waitSamplingWhere(dut.io.motion_is_allowed.toBoolean)
    println(s"[INFO] @${simTime()} Issue [${motion}] to playfield via interface")

    motion match {
      case "LF" => dut.io.move_in.left #= true
      case "RG" => dut.io.move_in.right #= true
      case "RT" => dut.io.move_in.rotate #= true
      case "DN" => dut.io.move_in.down #= true
    }

    fork {
      dut.clockDomain.waitSampling()
      dut.io.move_in.left #= false
      dut.io.move_in.right #= false
      dut.io.move_in.rotate #= false
      dut.io.move_in.down #= false
    }
    dut.clockDomain.waitSamplingWhere(dut.io.status.valid.toBoolean)
    dut.io.status.payload.toBoolean
  }

}
