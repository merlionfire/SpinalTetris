package utils

import java.awt.image.BufferedImage
import java.awt.{BasicStroke, Color, Font, Graphics2D, RenderingHints}
import java.io.File
import javax.imageio.ImageIO
import scala.collection.mutable

/**
 * Professional image generation utility for creating various types of images.
 * Provides a fluent API for image creation and manipulation.
 */
object ImageGenerator {

  // Common image creation strategy
  trait ImageCreationStrategy {
    def create(width: Int, height: Int): BufferedImage
    def save(image: BufferedImage, filePath: String): Unit = {
      val outputFile = new File(filePath)
      outputFile.getParentFile.mkdirs() // Ensure directory exists
      ImageIO.write(image, "png", outputFile)
      println(s"Image saved to ${outputFile.getAbsolutePath}")
    }
  }

  // Builder for image creation
  class ImageBuilder(val width: Int, val height: Int) {
    private var backgroundColor: Color = Color.WHITE
    private var antiAlias: Boolean = true
    private val drawOperations = mutable.ArrayBuffer[Graphics2D => Unit]()

    def withBackground(color: Color): ImageBuilder = {
      backgroundColor = color
      this
    }

    def withAntiAlias(enabled: Boolean): ImageBuilder = {
      antiAlias = enabled
      this
    }

    def addDrawOperation(op: Graphics2D => Unit): ImageBuilder = {
      drawOperations += op
      this
    }

    def build(): BufferedImage = {
      val img = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)
      val g = img.createGraphics()

      // Set rendering hints
      if (antiAlias) {
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON)
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON)
      }

      // Draw background
      g.setColor(backgroundColor)
      g.fillRect(0, 0, width, height)

      // Execute all draw operations
      drawOperations.foreach(_(g))

      g.dispose()
      img
    }

    def buildAndSave(filePath: String): BufferedImage = {
      val img = build()
      val outputFile = new File(filePath)
      outputFile.getParentFile.mkdirs()
      ImageIO.write(img, "png", outputFile)
      println(s"Image saved to ${outputFile.getAbsolutePath}")
      img
    }
  }
  // Factory methods for common image types

  /**
   * Create a grid-based image from pixel data
   */
  def fromPixelData(
                     width: Int,
                     height: Int,
                     pixelData: mutable.Queue[Int],
                     colorConverter: Int => Int = identity
                   ): ImageBuilder = {
    new ImageBuilder(width, height)
      .addDrawOperation { g =>
        val img = g.getDeviceConfiguration.createCompatibleImage(width, height)
        for (y <- 0 until height) {
          for (x <- 0 until width) {
            if (pixelData.nonEmpty) {
              val rgb = pixelData.dequeue()
              img.setRGB(x, y, colorConverter(rgb))
            }
          }
        }
        g.drawImage(img, 0, 0, null)

        if (pixelData.nonEmpty) {
          println(s"[Warning] Pixel data queue not empty: ${pixelData.size} items remaining")
        }
      }
  }

  /**
   * Create a grid layout image with multiple panels
   */
  def fromGridLayout(
                      totalWidth: Int,
                      totalHeight: Int,
                      gridData: Seq[GridItem]
                    ): ImageBuilder = {
    new ImageBuilder(totalWidth, totalHeight)
      .addDrawOperation { g =>
        gridData.foreach { item =>
          item.draw(g)
        }
      }
  }

  /**
   * Create empty canvas for custom drawing
   */
  def createCanvas(width: Int, height: Int): ImageBuilder = {
    new ImageBuilder(width, height)
  }

  // Helper classes for structured drawing

  /**
   * Represents a drawable item in a grid
   */
  trait GridItem {
    def draw(g: Graphics2D): Unit
  }

  /**
   * A labeled panel with custom content
   */
  case class LabeledPanel(
                           x: Int,
                           y: Int,
                           label: String,
                           subLabel: String = "",
                           scoreLabel: String = "",
                           drawContent: Graphics2D => Unit
                         ) extends GridItem {

    override def draw(g: Graphics2D): Unit = {
      // Draw labels
      g.setColor(Color.BLACK)
      g.setFont(new Font("Arial", Font.BOLD, 16))

      var labelY = y + 100
      if (label.nonEmpty) {
        g.drawString(label, x - 100, labelY)
        labelY += 20
      }
      if (subLabel.nonEmpty) {
        g.drawString(subLabel, x - 95, labelY)
        labelY += 20
      }
      if (scoreLabel.nonEmpty) {
        g.drawString(scoreLabel, x - 95, labelY)
      }

      // Draw custom content
      drawContent(g)
    }
  }

  /**
   * A playfield renderer
   */
//  case class PlayfieldPanel(
//                             x: Int,
//                             y: Int,
//                             sizeInPixel: Int,
//                             playfield: Any, // Your playfield type
//                             renderer: (Graphics2D, Any, Int, Int, Int) => Unit
//                           ) extends GridItem {
//
//    override def draw(g: Graphics2D): Unit = {
//      renderer(g, playfield, x, y, sizeInPixel)
//    }
//  }

    case class PlaceTetromino(
                               x_start: Int,
                               y_start: Int,
                               sizeInPixel: Int,
                               width : Int,
                               allBlocks : Seq[Int],
                               blockColor : Color  = new Color(255, 102, 88)
                             ) extends GridItem {

      val borderWidth = 1
      val padding = 1

      override def draw(g: Graphics2D): Unit = {



        val height = allBlocks.length

        val x_end = x_start + sizeInPixel * width
        val y_end = y_start + sizeInPixel * height

        // public BasicStroke(
        //   float width,
        //   int cap,
        //   int join,
        //   float miterlimit,
        //   float[] dash,
        //   float dash_phase
        // )

        // 1. width:       (1f) The stroke width in pixels.
        // 2. cap:         (CAP_BUTT) The style for line endings.
        //                 - CAP_BUTT:  Ends lines with no cap (flat).
        //                 - CAP_ROUND: Adds a round end.
        //                 - CAP_SQUARE: Adds a square end.
        // 3. join:        (JOIN_ROUND) The style for joining two line segments.
        //                 - JOIN_ROUND: Rounds the corner.
        //                 - JOIN_BEVEL: Bevels (flattens) the corner.
        //                 - JOIN_MITER: Extends the corner to a sharp point.
        // 4. miterlimit:  (10.0f) For JOIN_MITER, this limits how far the sharp
        //                 point can extend. Ignored for other join types.
        // 5. dash:        (Array[Float](10.0f, 5.0f)) The dashing pattern.
        //                 Alternates "draw" and "skip".
        //                 This means "draw 10 pixels, skip 5 pixels".
        // 6. dash_phase:  (0.0f) An offset (in pixels) of where to start the
        //                 dashing pattern. 0.0f starts at the beginning.

        val bs = new BasicStroke(1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_ROUND, 10.0f, Array[Float](10.0f, 5.0f), 0.0f)

        g.setColor(java.awt.Color.GRAY)
        g.setStroke(bs)

        // Draw lines
        for ( x <- x_start to x_end by sizeInPixel) {
          g.drawLine(x, y_start, x, y_end )
        }

        for ( y <- y_start to y_end by sizeInPixel) {
          g.drawLine(x_start, y, x_end, y)
        }

        // Draw wall

        // 1. Define the coordinate ranges first.
        val x_side_wall_range = List(-1, width).map(cx => x_start + cx * sizeInPixel)
        val y_side_wall_range = y_start until (y_start + height * sizeInPixel) by sizeInPixel

        // 2. Use 'for...yield' to create the side walls immutably.
        val side_walls = for {
          x <- x_side_wall_range
          y <- y_side_wall_range
        } yield (x, y)

        // 3. Define the coordinates for the bottom wall.
        val y_bottom = y_start + ( height ) * sizeInPixel
        val x_bottom_range = x_start until ( x_start + width * sizeInPixel) by sizeInPixel

        // 4. Use 'for...yield' to create the bottom wall.
        val bottom_wall = for (x <- x_bottom_range) yield (x, y_bottom)

        // 5. Combine the immutable lists. This is your final 'walls'.
        val walls = side_walls ++ bottom_wall



        // 1. Solid Color Interior with Black Border
        g.setColor(java.awt.Color.BLACK)
        g.setStroke(new BasicStroke(borderWidth))

        for ((x, y) <- walls) {
          g.drawRect(x, y, sizeInPixel, sizeInPixel) // Draw the border
        }

        g.setColor(new Color(153, 102, 0))
        g.setStroke(new BasicStroke(borderWidth))

        for ((x, y) <- walls) {
          g.drawRect(x+1, y+1, sizeInPixel-2, sizeInPixel-2) // Draw the border
        }

        g.setStroke(new BasicStroke(borderWidth))
        g.setColor( blockColor )
        for ( (rowValue, rowIndex) <- allBlocks.zipWithIndex ) {

          val y = y_start + rowIndex * sizeInPixel

          for (col <- 0 until  width) {

            // 'x' is also an immutable 'val' calculated from the col index
            val x = x_start + col * sizeInPixel

            val bit = (rowValue >> col) & 1
            if ( bit == 1) {
              g.fillRect(x + padding  , y + padding, sizeInPixel - 2 * padding + 1 , sizeInPixel - 2 * padding + 1)

            }
          }
        }

      }
    }

  /**
   * Text label
   */
  case class TextLabel(
                        x: Int,
                        y: Int,
                        text: String,
                        font: Font = new Font("Arial", Font.PLAIN, 12),
                        color: Color = Color.BLACK
                      ) extends GridItem {

    override def draw(g: Graphics2D): Unit = {
      g.setColor(color)
      g.setFont(font)
      g.drawString(text, x, y)
    }
  }
}