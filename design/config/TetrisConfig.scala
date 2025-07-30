import spinal.core.log2Up
import spinal.core._

package object config {
  // Temp to rduce for speed-up sim
  val rowNum : Int = 23   // include bottom wall
  //val rowNum : Int = 16   // include bottom wall

  val colNum :Int = 12    // include left and right wall
  val lastCol = colNum - 1   /* 0 and 11 are col index of left and right wall */
  val bottomRow = rowNum - 1
  val rowBitsWidth = log2Up(rowNum)
  val colBitsWidth = log2Up(colNum)
  val rowBlocksNum = rowNum - 1   // working field for Tetromino
  val colBlocksNum = colNum - 2   // working field for Tetromino

  case class TetrisPlayFeildConfig ( block_len : Int,
                                     wall_width : Int,
                                     x_orig : Int,
                                     y_orig : Int,
                                     piece_ft_color : Int,
                                     piece_bg_color : Int
                                   ) {

    def wall_height : Int = block_len * rowBlocksNum
    def base_width : Int = 2 * wall_width +  colBlocksNum  * block_len
    def base_height : Int = wall_width
    def getRightWallOrig = ( x_orig+wall_width+ colBlocksNum *block_len, y_orig)
    def getBaseOrig = (x_orig, y_orig + wall_height )
    def getFieldOrig :(Int, Int) = ( x_orig + wall_width, y_orig)

  }

  object TYPE extends SpinalEnum {
    val I = newElement("I")
    val J = newElement("J")
    val L = newElement("L")
    val O = newElement("O")
    val S = newElement("S")
    val T = newElement("T")
    val Z = newElement("Z")

  }

  object TetrominoesConfig {
    val typeOffsetTable = Map(
      TYPE.I -> Map(
        0 -> List((0, 1), (1, 1), (2, 1), (3, 1)),
        1 -> List((2, 0), (2, 1), (2, 2), (2, 3)),
        2 -> List((0, 2), (1, 2), (2, 2), (3, 2)),
        3 -> List((1, 0), (1, 1), (1, 2), (1, 3))
      ),
      TYPE.J -> Map(
        0 -> List((0,0) , (0,1) , (1,1) , (2,1)),
        1 -> List((2,0) , (1,0) , (1,1) , (1,2)),
        2 -> List((2,2) , (2,1) , (1,1) , (0,1)),
        3 -> List((0,2) , (1,2) , (1,1) , (1,0))
      ),
      TYPE.L -> Map(
        0 -> List((0,1) , (1,1) , (2,0) , (2,1)),
        1 -> List((1,0) , (1,1) , (2,2) , (1,2)),
        2 -> List((2,1) , (1,1) , (0,2) , (0,1)),
        3 -> List((1,2) , (1,1) , (0,0) , (1,0))
      ),
      TYPE.O -> Map(
        0 -> List((1,0) , (1,1) , (2,0) , (2,1)),
        1 -> List((1,0) , (1,1) , (2,0) , (2,1)),
        2 -> List((1,0) , (1,1) , (2,0) , (2,1)),
        3 -> List((1,0) , (1,1) , (2,0) , (2,1))
      ),
      TYPE.S -> Map(
        0 -> List((0,1) , (1,0) , (1,1) , (2,0)),
        1 -> List((1,0) , (2,1) , (1,1) , (2,2)),
        2 -> List((2,1) , (1,2) , (1,1) , (0,2)),
        3 -> List((1,2) , (0,1) , (1,1) , (0,0))
      ),
      TYPE.T -> Map(
        0 -> List((0,1) , (1,0) , (1,1) , (2,1)),
        1 -> List((1,0) , (2,1) , (1,1) , (1,2)),
        2 -> List((2,1) , (1,2) , (1,1) , (0,1)),
        3 -> List((1,2) , (0,1) , (1,1) , (1,0))
      ),
      TYPE.Z -> Map(
        0 -> List((0,0) , (1,0) , (1,1) , (2,1)),
        1 -> List((2,0) , (2,1) , (1,1) , (1,2)),
        2 -> List((2,2) , (1,2) , (1,1) , (0,1)),
        3 -> List((0,2) , (0,1) , (1,1) , (1,0))
      )
    )

  }
}


