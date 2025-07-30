package IPS.draw_block_engine

import spinal.core._
import spinal.lib.Delay
import utils._


case class DrawBlockEngConfig (
                               IDX_W : Int = 4,
                               FB_X_ADDRWIDTH : Int,
                               FB_Y_ADDRWIDTH : Int,
                             )

class draw_block_engine ( config : DrawBlockEngConfig ) extends Component {

  import config._

  val io = new Bundle {

    val start     = in Bool()
    val width     = in UInt (8 bits)
    val height    = in UInt (8 bits)
    val in_color  = in UInt (IDX_W bits)
    val pat_color = in UInt ( IDX_W bits )
    val fill_pattern = in UInt( 2 bits)  // 0:solid, 1:border, 2: border+dot
    val h_cnt     = out UInt (FB_X_ADDRWIDTH bits)
    val v_cnt     = out UInt (FB_Y_ADDRWIDTH bits)
    val is_running = out Bool()
    val out_valid = out Bool()
    val out_color = out UInt (IDX_W bits)
    val done      = out Bool()
  }

  noIoPrefix()

  // Stage 1
  val in_color = RegNextWhen(io.in_color, io.start)
  val width_reg = RegNextWhen(io.width, io.start) init (0)
  val height_reg = RegNextWhen(io.height, io.start) init (0)
  val fill_pattern_reg = RegNextWhen(io.fill_pattern, io.start) init (0)

  val addr_comp_active = RegInit(False)
  val h_cnt = Counter2(width_reg, addr_comp_active)

  // Add addr_comp_active as increase condition is because of the special case where
  //   when io.width == 0, that is block width is 1, h_cnt.willOverflowIfInc is always 1.
  // In order to handle this corner case, add extra guard signal addr_comp_active.
  val v_cnt = Counter2(height_reg, h_cnt.willOverflowIfInc && addr_comp_active )

  val cnt_last = v_cnt.willOverflowIfInc && h_cnt.willOverflowIfInc

  when( io.start ) {
    addr_comp_active := True
  } elsewhen(  cnt_last  ) {
    addr_comp_active := False
  }

  // Stage 2
  val active_1d = RegNext(addr_comp_active) init (False)

  val border_en = RegInit(False)
  val fill_en = RegInit(False)

  val no_pattern = RegNext ( ( fill_pattern_reg === 0  )|| ( width_reg < 3) || ( height_reg < 3), False)


  border_en :=  ( h_cnt === U(0) || h_cnt.willOverflowIfInc || v_cnt === U(0) || v_cnt.willOverflowIfInc  ) && ! ( fill_pattern_reg === 0)

  switch ( fill_pattern_reg ) {
    is(2) {
      fill_en := ! ( h_cnt.value.lsb  || v_cnt.value.lsb )
    }
    is(3) {
      fill_en := h_cnt.value(1 downto 0 ) === v_cnt.value(1 downto 0 )
    }
    default {
      fill_en := False
    }
  }


  // Stage 3
  val active_2d = RegNext(active_1d) init (False)
  val out_color = Delay(in_color,2)
  when ( ( border_en  || fill_en ) && ! no_pattern )  {
    out_color := Delay(io.pat_color,3)
  }

  // Interface
  io.out_valid := active_2d
  io.out_color := out_color
  io.done      := ( ~ active_1d  ) & active_2d

  io.h_cnt := h_cnt.value.resize(FB_X_ADDRWIDTH)
  io.v_cnt := v_cnt.value.resize(FB_Y_ADDRWIDTH)
  io.is_running := addr_comp_active
}

object drawBlockEngMain{

  def main(args: Array[String]) {
    val FB_WIDTH = 160
    val FB_HEIGHT  = 120
    val config = DrawBlockEngConfig(
      FB_X_ADDRWIDTH = log2Up(FB_WIDTH),
      FB_Y_ADDRWIDTH = log2Up(FB_HEIGHT),
      IDX_W = 4
    )

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new draw_block_engine(config)
    )
  }
}


