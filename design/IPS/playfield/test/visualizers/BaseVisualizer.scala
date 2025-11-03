package IPS.playfield.visualizers

import IPS.playfield.PlayfieldConfig
import utils.PathUtils


/**
 * Base class for all visualizers - contains common utilities
 */
abstract class BaseVisualizer(
                               protected val testClass: Class[_],
                               protected val blockSize: Int = 20
                             ) {

  /**
   * Reverse lower N bits for display (tetris blocks are stored MSB-first)
   */
  protected def reverseLow10Bits(value: Int): Int = {
    var result = 0
    var temp = value & 0x3FF
    for (i <- 0 until 10) {
      result = (result << 1) | (temp & 1)
      temp >>= 1
    }
    result
  }

  /**
   * Calculate grid layout step sizes
   */
  protected def calculateStepSizes: (Int, Int) = {
    val xStep = (config.colBlocksNum + 4) * blockSize
    val yStep = (config.rowBlocksNum + 2) * blockSize
    (xStep, yStep)
  }

  /**
   * Get output directory path for specific test type
   */
  protected def getOutputPath(subdir: String): String = {
    PathUtils.getRtlOutputPath(testClass, targetName = s"sim/img/$subdir").toString
  }

  /**
   * Format binary data for debug output
   */
  protected def formatBinary(value: Int, width: Int = 10): String = {
    String.format(s"%${width}s", Integer.toBinaryString(value)).replace(' ', '0')
  }

}