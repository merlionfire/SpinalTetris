package utils

import ImageGenerator._

import java.awt.image.BufferedImage
import java.awt.{Color, Font}

object TetrisImageCreator {

  /**
   * Create Tetris playfield grid image
   */
  def createTetrisGridImage(
                             tOpArray: Seq[Seq[(Int, String, Any, Double)]], // (id, direction, obs_mem, score)
                             colNum: Int,
                             rowNum: Int,
                             blockSize: Int = 30,
                             origin: (Int, Int) = (200, 100),
                             playfieldRenderer: (java.awt.Graphics2D, Any, Int, Int) => Unit
                           ): BufferedImage = {

    val (x_origin, y_origin) = origin
    val x_step = (colNum + 3) * blockSize
    val y_step = blockSize * (rowNum + 1)

    val width = (tOpArray.map(_.length).max + 1) * blockSize * colNum + 500
    val height = (2 + tOpArray.size) * blockSize * rowNum

    val gridItems = scala.collection.mutable.ArrayBuffer[GridItem]()

    var y_pos = y_origin

    for (tRowArray <- tOpArray) {
      var x_pos = x_origin

      for ((id, dir, obs_mem, score) <- tRowArray) {
        gridItems += LabeledPanel(
          x = x_pos,
          y = y_pos,
          label = dir,
          subLabel = s"($id)",
          scoreLabel = f"<$score>",
          drawContent = { g =>
            playfieldRenderer(g, obs_mem, x_pos, y_pos)
          }
        )
        x_pos += x_step
      }
      y_pos += y_step
    }

    ImageGenerator
      .fromGridLayout(width, height, gridItems.toSeq)
      .build()
  }

/*
  def createPlayfieldImage(
                            colNum: Int,
                            rowNum: Int,
                            sizeInPixel: Int = 30,
                            origin: (Int, Int) ,

                          ) : BufferedImage = {


  }
  */

}