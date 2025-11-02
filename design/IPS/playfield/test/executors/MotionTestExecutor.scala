package IPS.playfield.executors

import IPS.playfield.{PlayfieldBackdoorAPI, PlayfieldTestBase, playfield}
import spinal.core._
import spinal.core.sim._
import utils.ImageGenerator.{GridItem, PlaceTetromino, TextLabel}
import utils.TestPatterns._
import utils._

import java.awt.Color
import scala.collection.mutable
import scala.util.control.Breaks.{break, breakable}

trait MotionTestExecutor {

  this: PlayfieldTestBase with PlayfieldBackdoorAPI =>

  def executeTestMotionActions(
                                dut: playfield,
                                scbd: PlayFieldScoreboard,
                                length: Int,
                                width: Int,
                                actions: Seq[TestMotionPatternGroup],
                                verbose: Boolean
                              ): Unit = {

    val playfieldDrawTasks =  mutable.Queue[GridItem] ()

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

    def reverseLow10Bits(value: Int): Int = {
      var result = 0
      var temp = value & 0x3FF  // Mask to get only lower 10 bits

      for (i <- 0 until 10) {
        result = (result << 1) | (temp & 1)
        temp >>= 1
      }

      result
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


    val actionsByRound  = splitMotionsByRound( actions )

    // Print Test suits Summary
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tTest Group Summary\n")
    println(f"\t\t\tPlayfield\tx\tPiece\t:\tMotions")
    for ((action, i) <- actionsByRound.zipWithIndex) {
      print(f"\t${i + 1}:")
      for ( pattern <- actions ) {
        println(f"\t\t${pattern.p0}%10s\tx\t${pattern.p1}%5s\t:\t${pattern.getMotionsDescription}")
      }
    }
    println(s"\n${"=" * 120}")


    // Main Body
    for ( ( round,  roundIndex  )  <- actionsByRound.zipWithIndex  ) { /* One round means one game round */

      var exitInfo : String = "PASS"
      val playfieldPattern = round.head.p0
      breakable {
        for ((action, actionIndex) <- round.zipWithIndex) {


          /* Each round contains all piece operation called action from placing to be locked */
          if (verbose) {
            println(s"\n${"=" * 100}\n")
            println(s"\t\tExecuting Test Round  ${roundIndex + 1}/${actionsByRound.size}")
            println(s"\t\tExecuting Test action ${actionIndex + 1}/${round.size}")
            println(s"\t\tPurpose\t: ${action.description}")
            //println(s"\t\tPattern\t: ${action.p0} : ${action.p1} ${action.getMotionsDescription} ")
            println(s"\t\tPattern\t: ${playfieldPattern} : ${action.p1} ${action.getMotionsDescription} ")
            println(s"\n${"=" * 100}")
          }

          // Step 1 - Preload playfield in terms of pattern
          if (action.p0 != BitPatternGenerators.Hold) {

            val preloadPlayfield : Seq[Int] = {

              val zeros = Seq.fill(6)(0) // First 6 items: all zeros

              val random8Ones = Seq.fill(14) {
                generateRandomBits( count = 8, maxBitIndex =  10 )
              }
              zeros ++ random8Ones

            }

            // Generate and write pattern
            val playfieldData = backdoorWritePlayfieldWithPattern(
              dut,
              length,
              width,
              action.p0,
              ref = if ( action.p0 == BitPatternGenerators.Custom ) preloadPlayfield else null
            )
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
            exitInfo = "FAIL"
            break
          }

          motionsQueue.enqueue("PL")
          readWholePlayfield(dut)

          // Step 3 : Traver all motions pattern
          val motions = action.p2.flatMap {
            case MotionPatternGenerators.Left(step) => List.fill(step)("LF")
            case MotionPatternGenerators.Right(step) => List.fill(step)("RG")
            case MotionPatternGenerators.Rotate(step) => List.fill(step)("RT")
            case MotionPatternGenerators.Down(step) => List.fill(step)("DN")
            case MotionPatternGenerators.Drop => List.fill(20)("DN")
          }

          def issueMotion(motion: String): Boolean = {
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

          // Traver all motion actions of current Piece until "Down" action failed.
          motions.forall { motion =>
            val status = issueMotion(motion) /* 1 : collision, 0 : OK */
            motionsQueue.enqueue(motion)
            readWholePlayfield(dut)
            if (status && (motion == "DN")) {
              false
            } else {
              true
            }
          }

          println(s"[INFO] @${simTime()} Down action fails due to touch bottom or below Block. Finish current Piece by locking it")

          lockPiece(dut)

          val x_start = 100
          var y_start = 100
          // transverse to execute test patterns

          val blocSize = 20

          val y_step = (dut.config.rowBlocksNum + 2) * blocSize
          val x_step = (dut.config.colBlocksNum + 4) * blocSize

          val x_count = 5
          val y_count = 8

          val originPoint = {
            for {
              y <- 0 until y_count
              x <- 0 until x_count
            } yield (x_start + x * x_step, y_start + y * y_step)
          }.toList


          for ((frame, i) <- scbd.actualData.grouped(dut.config.rowBlocksNum).zipWithIndex) {

            playfieldDrawTasks.enqueue(
              PlaceTetromino(
                x_start = originPoint(i)._1,
                y_start = originPoint(i)._2,
                sizeInPixel = blocSize,
                width = dut.config.colBlocksNum,
                allBlocks = frame.map(reverseLow10Bits),
                blockColor = new Color(100, 120, 120)
              ),
              TextLabel(
                x = originPoint(i)._1 - 50,
                y = originPoint(i)._2 + 50,
                text = motionsQueue.dequeue(),
                color = Color.BLACK
              )
            )

            y_start += y_step
          }

          ImageGenerator.fromGridLayout(
            totalWidth = originPoint.map(_._1).max + x_step,
            totalHeight = originPoint.map(_._2).max + y_step,
            gridData = playfieldDrawTasks
          ).buildAndSave(
            PathUtils.getRtlOutputPath(getClass, targetName = s"sim/img/Motions_${roundIndex}").toString + s"/Action_${actionIndex}_${action.p0}_${action.p1}.png"
          )

          playfieldDrawTasks.clear()
          motionsQueue.clear()
          scbd.clear()

        }

        exitInfo
      }  // end of breakable


      if ( exitInfo == "PASS ") {
        println(s"[INFO] @${simTime()} all motions have been executed. The game exits here ")
      }

      if ( exitInfo == "FAIL ") {
        println(s"[INFO] @${simTime()} Placing a new piece failed. Game is over here ")
      }

    }

  } // executeTestMotionActions end
}
