package IPS.collision_checker


import spinal.core._
import spinal.lib._

import utils._
import config._

class collision_checker extends Component {

  val io = new Bundle {
    val block_in = slave Flow( Block(colBitsWidth, rowBitsWidth) )
    val block_skip_en = in Bool()
    val block_wr_en = in Bool()

    val block_pos = master Flow  ( Block(colBitsWidth, rowBitsWidth)  )
    val block_val = slave  Flow  ( Bool() )
    val hit_status = master Flow( hitStatus() )

  }

  noIoPrefix()

  val blocks_prev_reset = Block(colBitsWidth,rowBitsWidth)
  blocks_prev_reset.x := U(0)
  blocks_prev_reset.y := U(0)

  val blocks_prev = History(
    that = io.block_in.payload,
    range = 1 to  4,
    when = ( io.block_in.valid & io.block_wr_en )  ,
    init = blocks_prev_reset
  )


  val block_req = Flow( Block(colBitsWidth,rowBitsWidth))
  val block_skip = blocks_prev.foldLeft(False)(  ( x, y )  => x || ( y === io.block_in.payload) ) && io.block_skip_en

  block_req.payload := io.block_in.payload
  block_req.valid  :=  ( ! block_skip ) && io.block_in.valid

  io.block_pos <> block_req

  val bit_sel = RegNext(block_req.x) init 0
  val wall_hit = Reg(Bool()) init False

  /*   bottom hit checker */
  // lastRow = rowNum-1 : Bottom wall
  // lastCol
  val bottom_hit = RegNext( block_req.y >= U(bottomRow) )  init (false)
  val left_wall_hit  = ! bit_sel.orR
  val right_wall_hit = bit_sel >= U(lastCol )
  val wall_hit_pre = bottom_hit || left_wall_hit || right_wall_hit || wall_hit

  //val valid_1d = RegNext( block_req.valid ) init False
  //val valid_fall_edge = ! block_req.valid & valid_1d
  val valid_1d = RegNext( io.block_in.valid ) init False
  val valid_fall_edge = ! io.block_in.valid & valid_1d

  val valid_fall_edge_1d = RegNext(valid_fall_edge) init False

  wall_hit.clearWhen(valid_fall_edge_1d)
  when ( valid_1d) {
    wall_hit := wall_hit_pre
  }

  /* Occupied checker */

  val occupied_enable = Bool()
  val occupied = RegNextWhen(  io.block_val.payload , occupied_enable  ) init False

  occupied_enable := io.block_val.valid & ! occupied

  occupied.clearWhen(valid_fall_edge_1d)

  /* Response */
  io.hit_status.valid := valid_fall_edge_1d
  io.hit_status.payload.is_wall := wall_hit
  io.hit_status.payload.is_occupied := occupied & ! wall_hit

  println( "io.block_in.valid -> io.hit_status.valid  = " + LatencyAnalysis(io.block_in.valid, io.hit_status.valid)  )
  println( "io.block_in.valid -> valid_1d             = " + LatencyAnalysis(io.block_in.valid, valid_1d)  )
  println( "io.block_in.valid -> valid_fall_edge      = " + LatencyAnalysis(io.block_in.valid, valid_fall_edge)  )
  println( "valid_fall_edge   -> valid_fall_edge_1d   = " + LatencyAnalysis(valid_fall_edge, valid_fall_edge_1d  )  )

  //assert( LatencyAnalysis(io.block_in.valid, io.hit_status.valid) == 2 )


}



object collisionCheckerMain{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new collision_checker()
    )
  }
}