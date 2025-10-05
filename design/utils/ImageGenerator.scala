package utils

import java.awt.image.BufferedImage
import java.awt.{Graphics2D, Color, Font, RenderingHints}
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
  case class PlayfieldPanel(
                             x: Int,
                             y: Int,
                             blockSize: Int,
                             playfield: Any, // Your playfield type
                             renderer: (Graphics2D, Any, Int, Int, Int) => Unit
                           ) extends GridItem {

    override def draw(g: Graphics2D): Unit = {
      renderer(g, playfield, x, y, blockSize)
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