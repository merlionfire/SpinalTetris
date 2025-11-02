package IPS.playfield.executors

import IPS.playfield.{PlayfieldBackdoorAPI, PlayfieldTestBase, playfield}
import config.TetrominoesConfig.binaryTypeOffsetTable
import spinal.core._
import spinal.core.sim._
import utils.ImageGenerator.{GridItem, PlaceTetromino, TextLabel}
import utils.TestPatterns._
import utils._

import java.awt.Color
import scala.collection.mutable

trait PlaceTestExecutor {

  this: PlayfieldTestBase with PlayfieldBackdoorAPI =>

  def executeTestPlaceActions(
                               dut: playfield,
                               scbd: PlayFieldScoreboard,
                               length: Int,
                               width: Int,
                               row: Int,
                               actions: Seq[TestPiecePatternPair],
                               verbose: Boolean
                             ): Unit = {

    assert(
      row >= 0 && row <= (length - 1),
      s"Row options $row is out of the expected range [0, ${length - 1}]."
    )

    val playfieldDrawTasks =  mutable.Queue[GridItem] ()

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


    printPlacementTestSummary(actions, row)


    var actionIndex = 0

    // transverse to execute test patterns

    val blocSize = 20

    var y_step  = 6 * blocSize

    for (action <- actions) {
      if (verbose) {
        println(s"\n${"=" * 100}\n")
        println(s"\t\tExecuting Test Action ${actionIndex + 1}/${actions.size}")
        println(s"\t\tPurpose\t: ${action.getDescription}")
        println(s"\t\tPattern\t: ${action.p0} x ${action.p1}, Count: ${action.count}")
        println(s"\n${"=" * 100}")
      }

      var x_start = 100
      var y_start = 100

      var pieceIsDraw = false

      for (iteration <- 0 until action.count) {
        if (verbose && action.count > 1) {
          println(s"\t\t Round ${iteration + 1}/${action.count}")
        }
        // Generate Place piece
        val (pieceType, rot  ) = PiecePatternGenerators.generatePiecePattern(action.p1).sample match {
          case Some ( (pieceType, rot  ) ) =>  (pieceType, rot  )
          case None => simFailure("[ERROR] No Piece is created !!!");
        }

        // Generate and write pattern
        val playfieldData = backdoorWritePlayfieldWithPattern(
          dut,
          length,
          width,
          action.p0
        )

        val ref = playfieldData.slice(row, row + 4).padTo(4, Int.MaxValue & ((1 << dut.config.colBlocksNum) - 1))

        issuePlacePiece(dut,  pieceType )
        dut.clockDomain.waitSamplingWhere(dut.io.status.valid.toBoolean) // Wait collision result
        val placePieceData = binaryTypeOffsetTable(pieceType)(0) map ( _ << ( (dut.config.colBlocksNum / 2 )  - 2 ) )
        placePieceData.zipWithIndex.foreach { case (data, i) =>
          println(s"[INFO] place row[$i] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')} ")
        }
        val expectedData = model(playfieldData, placePieceData, row)
        scbd.addExpected(expectedData)

        if ( ! pieceIsDraw ) {
          playfieldDrawTasks.enqueue (
            PlaceTetromino(
              x_start = x_start, y_start = y_start,
              sizeInPixel = blocSize,
              width = dut.config.colBlocksNum,
              allBlocks = placePieceData
            ),
            TextLabel(
              x = x_start - 50 ,
              y = y_start + 50,
              text = pieceType.toString(),
              color = Color.BLACK
            )
          )
          pieceIsDraw = true
          y_start += y_step
        }

        playfieldDrawTasks.enqueue(
          PlaceTetromino(
            x_start =  x_start, y_start =  y_start,
            sizeInPixel = blocSize,
            width = dut.config.colBlocksNum,
            allBlocks = playfieldData.map(reverseLow10Bits).take(4),
            blockColor = new Color(100,120, 120 )
          ),
          TextLabel(
            x = x_start - 50 ,
            y = y_start + 50,
            text = s"$iteration",
            color = Color.BLACK
          )
        )

        y_start += y_step

        dut.clockDomain.waitSampling(10)
        forceFsmToIdle(dut )


        val allMatch = scbd.compare()

        println(scbd.report())

        if (!allMatch) {
          ImageGenerator.fromGridLayout(totalWidth = 400,  totalHeight = (action.count + 3 ) * ( y_step + 1 ) , playfieldDrawTasks )
            .buildAndSave( PathUtils.getRtlOutputPath(getClass, targetName = "sim/img").toString + s"/PlaceImg_${actionIndex}_${action.p0}x${action.p1}.png" )
          simFailure("Scoreboard Reports Error ")
        }
        scbd.clear()
      }

      ImageGenerator.fromGridLayout(totalWidth = 400,  totalHeight = (action.count + 3 ) * ( y_step + 1 )  , playfieldDrawTasks )
        .buildAndSave( PathUtils.getRtlOutputPath(getClass, targetName = "sim/img").toString + s"/PlaceImg_${actionIndex}_${action.p0}x${action.p1}.png" )

      playfieldDrawTasks.clear()

      actionIndex += 1
    }



  }

  private def printPlacementTestSummary(
                                         actions: Seq[TestPiecePatternPair],
                                         row: Int
                                       ): Unit = {
    println(s"\n${"=" * 120}\n")
    println(s"\t\t\t\tPlacement Test Group Summary\n")
    println(s"\tChecker Region based on Row : $row")
    println(f"\tTest Pattern :\t Playfield  x\t Place item\t\tCount")
    actions.zipWithIndex.foreach { case (action, i) =>
      println(f"\t\t\t${i + 1}\t: ${action.p0}%12s\tx\t${action.p1}%12s\t\t\t${action.count}")
    }
    println(s"\n${"=" * 120}")
  }



}
