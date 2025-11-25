package IPS.playfield.visualizers

import utils.ImageGenerator
import utils.ImageGenerator._
import utils._
import java.awt.Color
import scala.collection.mutable


class MotionVisualizer (
                        xStart: Int,
                        yStart: Int,
                        width : Int,
                        height : Int,
                        testClass: Class[_],
                        middlePath : String = "design/IPS",
                        blockSize: Int = 20
                        ) extends BaseVisualizer( testClass, blockSize )  {
  private val frameQueue = mutable.Queue[(String, Seq[Int])]()

  private val xCount = 5  // Frames per row in the grid

  /**
   * Record a single frame (action + playfield state)
   */
  def recordFrame(actionName: String, playfieldState: Seq[Int]): Unit = {
    frameQueue.enqueue((actionName, playfieldState))
  }

  /**
   * Convenience method for recording initial playfield
   */
  def recordInitialPlayfield(playfieldState: Seq[Int]): Unit = {
    recordFrame("INIT", playfieldState)
  }

  /**
   * Save all recorded frames as a grid image
   */
  def saveFrameSequence(
                         roundIndex: Int,
                         actionIndex: Int,
                         playfieldPattern: String,
                         piecePattern: String
                       ): Unit = {

    val frames = frameQueue.toSeq
    if (frames.isEmpty) {
      println(s"[WARN] No frames to visualize for action $actionIndex")
      return
    }

    val gridTasks = buildGridLayout(frames)
    val (totalWidth, totalHeight) = calculateCanvasSize(frames.size)

    ImageGenerator.fromGridLayout(totalWidth, totalHeight, gridTasks)
      .buildAndSave(
        PathUtils.getRtlOutputPath(testClass, middlePath= middlePath,  targetName = s"sim/img/Motions_$roundIndex").toString +
          s"/Action_${actionIndex}_${playfieldPattern}_${piecePattern}.png"
      )
  }

  def saveFrameSequence( targetName : String )  :Unit = {

    val frames = frameQueue.toSeq
    if (frames.isEmpty) {
      println(s"[WARN] No frames to visualize for this action")
      return
    }

    val gridTasks = buildGridLayout(frames)
    val (totalWidth, totalHeight) = calculateCanvasSize(frames.size)

    ImageGenerator.fromGridLayout(totalWidth, totalHeight, gridTasks)
      .buildAndSave(
        PathUtils.getRtlOutputPath(testClass, middlePath= middlePath,  targetName = targetName ) .toString )
  }


  /**
   * Clear all recorded frames for next action
   */
  def clear(): Unit = {
    frameQueue.clear()
  }

  /**
   * Get statistics about recorded frames
   */
  def getFrameCount: Int = frameQueue.size

  // ===== Private Helper Methods =====

  private def buildGridLayout(frames: Seq[(String, Seq[Int])]): mutable.Queue[GridItem] = {
    val gridTasks = mutable.Queue[GridItem]()
    val originPoints = calculateGridPositions(frames.size)

    frames.zipWithIndex.foreach { case ((actionName, playfieldData), i) =>
      gridTasks.enqueue(
        PlaceTetromino(
          x_start = originPoints(i)._1,
          y_start = originPoints(i)._2,
          sizeInPixel = blockSize,
          width = width,
          allBlocks = playfieldData.map(reverseLow10Bits),
          blockColor = new Color(100, 120, 120)
        ),
        TextLabel(
          x = originPoints(i)._1 - 50,
          y = originPoints(i)._2 + 50,
          text = actionName,
          color = Color.BLACK
        )
      )
    }

    gridTasks
  }

  private def calculateGridPositions(frameCount: Int): Seq[(Int, Int)] = {
    val yCount = math.ceil(frameCount.toDouble / xCount).toInt
    val xStep = (width + 4) * blockSize
    val yStep = (height + 2) * blockSize

    for {
      y <- 0 until yCount
      x <- 0 until xCount
      if y * xCount + x < frameCount
    } yield (xStart + x * xStep, yStart + y * yStep)
  }

  private def calculateCanvasSize(frameCount: Int): (Int, Int) = {
    val xStep = (width + 4) * blockSize
    val yStep = (height + 2) * blockSize
    val yCount = math.ceil(frameCount.toDouble / xCount).toInt

    val totalWidth = xStart + xCount * xStep
    val totalHeight = yStart + yCount * yStep

    (totalWidth, totalHeight)
  }

//  def reverseLow10Bits(value: Int): Int = {
//    var result = 0
//    var temp = value & 0x3FF
//    for (i <- 0 until 10) {
//      result = (result << 1) | (temp & 1)
//      temp >>= 1
//    }
//    result
//  }
}
