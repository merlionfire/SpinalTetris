package SSC.checkers_playfield

// Description
//  piece_checker + collision_checker + play_field

import spinal.core._
import spinal.lib._
import IPS.play_field._
import IPS.piece_checker._
import IPS.collision_checker._
import utils._

case class CheckersPlayFieldConfig  ( rowNum : Int, colNum : Int  ) {

  val rowBitsWidth = log2Up(rowNum)
  val colBitsWidth = log2Up(colNum)
  val rowBlocksNum = rowNum - 1   // working field for Tetromino
  val colBlocksNum = colNum - 2   // working field for Tetromino

  val playFieldConfig = PlayFieldConfig(
    rowBlocksNum = rowBlocksNum,
    colBlocksNum = colBlocksNum,
    rowBitsWidth = rowBitsWidth,
    colBitsWidth = colBitsWidth
  )
}

class checkers_playfield( config : CheckersPlayFieldConfig  )  extends Component {

  import config._

  val io = new Bundle {
    val piece_in = slave Stream (Piece(colBitsWidth, rowBitsWidth))
    val collision_out = master Flow( Bool() )
    val update = in Bool()
    val block_set = in Bool()
    val block_skip_en = in Bool()
    val clear_start  = in Bool()
    val restart = in Bool()
    val clear_done = out Bool()
    val lines_cleared = master Flow(UInt(log2Up(rowBlocksNum) bits ))
  }

  noIoPrefix()

  /* Instantiation */
  val piece_checker = new piece_checker(colBitsWidth, rowBitsWidth)
  val collision_checker = new collision_checker()
  val play_field = new play_field(playFieldConfig)


  // IO <->   piece_checker
  io.piece_in <> piece_checker.io.piece_in
  io.collision_out <> piece_checker.io.collision_out


  // piece_checker <-> collision_checker
  piece_checker.io.blocks_out.toFlow <> collision_checker.io.block_in
  piece_checker.io.hit_status <> collision_checker.io.hit_status
  collision_checker.io.block_wr_en := io.update && io.block_set
  collision_checker.io.block_skip_en := io.block_skip_en

  //  collision_checker <-> playfield
  play_field.io.block_pos <> collision_checker.io.block_pos
  play_field.io.block_val <> collision_checker.io.block_val

  // IO <-> playfield
  play_field.io.restart  := io.restart
  play_field.io.clear_start  := io.clear_start
  play_field.io.update  := io.update
  play_field.io.block_set := io.block_set
  io.clear_done := play_field.io.clear_done
  io.lines_cleared << play_field.io.lines_cleared

  play_field.io.fetch := False
}


object chekersPlayfieldMain{
  def main(args: Array[String]) {

    val rowNum : Int = 23   // include bottom wall
    val colNum :Int = 12    // include left and right wall

    val config =  CheckersPlayFieldConfig( rowNum, colNum)
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass,middlePath = "design/SSC").toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).addStandardMemBlackboxing(blackboxAll).generateVerilog(
      gen = new checkers_playfield (config)
    )
  }
}