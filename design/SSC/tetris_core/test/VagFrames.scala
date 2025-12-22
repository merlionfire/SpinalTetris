package SSC.tetris_core

import scala.collection.mutable

case class VgaPixel( r: Int, g: Int, b: Int) {
  def vga4BitTo8Bit(): Int = {
    // Scale the 4-bit value (0-15) to the 8-bit range (0-255)
    // Multiplying by 17 (255 / 15 is approximately 17) often works well for this.
    // (value & 0xF) * 17
    // Alternatively, you can also try bit shifting and replication:
    // (value & 0xF) | ((value & 0xF) << 4)

    val color8bit = List( r, g, b ).map(  x => x | ( x << 4 ))
    color8bit(0) << 16 | color8bit(1) << 8 | color8bit(2)

  }
}


class VgaFrame(val width: Int, val height: Int) {


  private val pixels = mutable.Queue[VgaPixel]()

  val framePixelCount = width * height

  def addPixel(pixel: VgaPixel): Unit = {
//    require(pixel.x >= 0 && pixel.x < width, s"x=${pixel.x} out of bounds")
//    require(pixel.y >= 0 && pixel.y < height, s"y=${pixel.y} out of bounds")
    pixels.enqueue(pixel)
  }

  def addPixel(r: Int, g: Int, b: Int): Unit = {
    addPixel(VgaPixel(r, g, b))
  }

  def nextPixel(): Option[VgaPixel] = {
    if (pixels.isEmpty) None else Some(pixels.dequeue())
  }

  def clear(): Unit = pixels.clear()
  def size: Int = pixels.size
  def isEmpty: Boolean = pixels.isEmpty
  def isFull: Boolean = pixels.size >= width * height

//  def getRow(y: Int): Seq[VgaPixel] = pixels.filter(_.y == y).toSeq
//  def getFrameAllPixels: Seq[VgaPixel] = pixels.dequeue()
  def nextFrame : Seq[VgaPixel] = {
    assert( pixels.size >= framePixelCount, s"${pixels.size} items remaining in Pixel data but expxected great than ${framePixelCount}"  )
    ( 1 to framePixelCount).map( _ => pixels.dequeue()).toSeq
  }

  def getAllFrames : Seq[ ( Int, Seq[VgaPixel] ) ] = {
    var frameIndex = 0
    val frames = new scala.collection.mutable.ArrayBuffer[(Int, Seq[VgaPixel])]()

    while (pixels.size >= framePixelCount) {
      val frameData = (1 to framePixelCount).map(_ => pixels.dequeue()).toSeq
      frames += (frameIndex -> frameData)
      frameIndex += 1
    }
    frames.toSeq // Return the final immutable sequence
  }

  override def toString: String = s"VgaFrame(${width}x${height}, ${pixels.size} pixels)"

}

object VgaFrame {
  def apply(width: Int, height: Int): VgaFrame = new VgaFrame(width, height)

  // Common resolutions
  def vga(): VgaFrame = new VgaFrame(640, 480)
  def svga(): VgaFrame = new VgaFrame(800, 600)
  def hd(): VgaFrame = new VgaFrame(1920, 1080)
}
