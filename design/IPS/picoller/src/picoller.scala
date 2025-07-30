package IPS.picoller


import spinal.core._
import spinal.lib._
import utils.PathUtils

import IPS.piece_checker._
import IPS.collision_checker._
import utils._

case class PicollerConfig ( colBitsWidth : Int, rowBitsWidth : Int )

class picoller ( config : PicollerConfig ) extends Component {

  import config._

  val io = new Bundle {
    val piece_in = slave Stream (Piece(colBitsWidth, rowBitsWidth))
    val collision_out = master Flow( Bool() )
    val update = in Bool()
    val block_set = in Bool()
    val block_skip_en = in Bool()

    val block_pos = master Flow  ( Block(colBitsWidth , rowBitsWidth)  )
    val block_val = slave  Flow  ( Bool() )

  }

  noIoPrefix()

  /* Instantiation */
  val piece_checker = new piece_checker(colBitsWidth, rowBitsWidth)
  val collision_checker = new collision_checker()

  // IO <->   piece_checker
  io.piece_in <> piece_checker.io.piece_in
  io.collision_out <> piece_checker.io.collision_out


  // piece_checker <-> collision_checker
  piece_checker.io.blocks_out.toFlow <> collision_checker.io.block_in
  piece_checker.io.hit_status <> collision_checker.io.hit_status
  collision_checker.io.block_wr_en := io.update && io.block_set
  collision_checker.io.block_skip_en := io.block_skip_en

  //  collision_checker <-> playfield
  io.block_pos <> collision_checker.io.block_pos
  io.block_val <> collision_checker.io.block_val

}


object PicollerMain{
  def main(args: Array[String]) {
    val rowNum : Int = 23   // include bottom wall
    val colNum :Int = 12    // include left and right wall
    val rowBitsWidth = log2Up(rowNum)
    val colBitsWidth = log2Up(colNum)

    val config =  PicollerConfig( colBitsWidth, rowBitsWidth)

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new picoller(config)
    )
  }
}