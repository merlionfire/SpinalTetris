package IPS.piece_checker


import spinal.core._
import spinal.lib._
import utils._
import config.TetrominoesConfig._


/* Note
   Piece.orign is NOT passed as stream to test_blk_pos for addition.
   It is for area saving and timing loose.
   But it requires the gap of 2 successive inputs to be at least 4 cycles
 */

class piece_checker(val colBitsWidth : Int, val rowBitsWidth : Int )  extends Component {

  val io = new Bundle {
    val piece_in = slave Stream( Piece(colBitsWidth, rowBitsWidth) )
    val blocks_out = master Stream( Block(colBitsWidth, rowBitsWidth ) )
    val hit_status = slave Flow( hitStatus() )
    val collision_out = master Flow( Bool() )
  }

  noIoPrefix()


  val blks_offset = RegInit(Vec.fill(4)(Offset(0,0)))

  val piece = io.piece_in.m2sPipe(holdPayload = true )

  val blk_offset = Stream(Offset())

  switch(piece.`type`) {
    for ( (pieceType, rotations) <- typeOffsetTable ) {
      is(pieceType) {
        switch ( piece.rot) {
          for ( (rotation, positions ) <- rotations ) {
            is(rotation)  {
              for ( j <- 0 until 4 ) {
                blks_offset(j) := positions(j)
              }
            }
          }
        }
      }
    }
  }

  val piece_offset = piece.stage().translateWith(blks_offset)

  val adapter = StreamWidthAdapter(piece_offset, blk_offset )

  val test_blk_pos = piece.orign + blk_offset.payload

  io.blocks_out << blk_offset.translateWith(test_blk_pos).m2sPipe()

  io.collision_out  << io.hit_status.translateWith( io.hit_status.is_occupied  |io.hit_status.is_wall )

}


object pieceCheckerMain{
  def main(args: Array[String]) {
    val rowNum : Int = 23   // include bottom wall
    val colNum :Int = 12    // include left and right wall
    val rowBitsWidth = log2Up(rowNum)
    val colBitsWidth = log2Up(colNum)

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new piece_checker(colBitsWidth,rowBitsWidth)
    )
  }
}

