package IPS.playfield.visualizers

import utils.ImageGenerator
import utils.ImageGenerator._
import utils._
import java.awt.Color
import scala.collection.mutable

/**
 * Handles visualization for piece placement test scenarios
 */
class PlacementVisualizer(
                           xStart: Int,
                           yStart: Int,
                           width : Int,
                           testClass: Class[_],
                           blockSize: Int = 20
                         ) extends BaseVisualizer( testClass, blockSize )  {

  private val drawTasks = mutable.Queue[GridItem]()
  private var currentYPosition = 100
  private val yStepPerAction = 6 * blockSize

  private var pieceDrawn = false

  /**
   * Record the placed piece pattern (only drawn once per action group)
   */
  def recordPiecePlacement(
                            pieceType: String,
                            placePieceData: Seq[Int]
                          ): Unit = {
    if (!pieceDrawn) {
      drawTasks.enqueue(
        PlaceTetromino(
          x_start = xStart,
          y_start = currentYPosition,
          sizeInPixel = blockSize,
          width = width,
          allBlocks = placePieceData
        ),
        TextLabel(
          x = xStart - 50,
          y = currentYPosition + 50,
          text = pieceType,
          color = Color.BLACK
        )
      )
      pieceDrawn = true
      currentYPosition += yStepPerAction
    }
  }

  /**
   * Record playfield state for each iteration
   */
  def recordPlayfieldState(
                            playfieldData: Seq[Int],
                            iterationLabel: String
                          ): Unit = {
    drawTasks.enqueue(
      PlaceTetromino(
        x_start = xStart,
        y_start = currentYPosition,
        sizeInPixel = blockSize,
        width = width,
        allBlocks = playfieldData.map(reverseLow10Bits).take(4), // only fetch top 4 rows for display
        blockColor = new Color(100, 120, 120)
      ),
      TextLabel(
        x = xStart - 50,
        y = currentYPosition + 50,
        text = iterationLabel,
        color = Color.BLACK
      )
    )
    currentYPosition += yStepPerAction
  }

  /**
   * Save the accumulated visualization to file
   */
  def saveToFile(
                  actionIndex: Int,
                  playfieldPattern: String,
                  piecePattern: String,
                  totalIterations: Int
                ): Unit = {

    val totalHeight = (totalIterations + 3) * (yStepPerAction + 1)

    ImageGenerator.fromGridLayout(
      totalWidth = 400,
      totalHeight = totalHeight,
      gridData = drawTasks
    ).buildAndSave(
      PathUtils.getRtlOutputPath(testClass, targetName = "sim/img").toString +
        s"/PlaceImg_${actionIndex}_${playfieldPattern}x${piecePattern}.png"
    )
  }

  /**
   * Reset for next action group
   */
  def resetForNextAction(): Unit = {
    drawTasks.clear()
    currentYPosition = yStart
    pieceDrawn = false
  }

}