package IPS.racing_beam

import spinal.core._
import spinal.lib.graphic.{Rgb, RgbConfig}
import spinal.lib.{LatencyAnalysis, PackedBundle, master}
import utils.PathUtils


case class RacingBeamConfig(
                             pattern : Int = 0,
                             V_WIDTH : Int = 480,
                             H_WIDTH : Int = 640,
                             COLOR_NUM : Int = 16,
                             LINE_NUM  : Int = 2,
                             BAR_COLOR_INIT : Int = 0x126,
                           ) {
  val xBitsWidth : Int = log2Up(H_WIDTH)
  val yBitsWidth : Int = log2Up(V_WIDTH)
}



class racing_beam( rgbConfig: RgbConfig, config : RacingBeamConfig ) extends Component {

  import utils.RgbPrefs._
  import config._

  val io = new Bundle {
    val x = in UInt (xBitsWidth bits)
    val y = in UInt (yBitsWidth bits)
    val sof = in  Bool()
    val color_en = in Bool()
    val color = master Flow  Rgb(rgbConfig)

  }

  noIoPrefix()


  val eol = io.color_en.fall()

  val roster_bar = new Area {
    val color = Rgb(rgbConfig).setAsReg()
    val inc = RegInit(False)
    val color_cnt = RegInit( U(0, log2Up(COLOR_NUM) bits) )
    val line_cnt = RegInit( U(0, log2Up(LINE_NUM) bits) )


    when( io.sof ) {
      color <= BAR_COLOR_INIT
      inc := True
      color_cnt <= 0
      line_cnt <= 0
    } elsewhen (eol) {
      when (line_cnt === LINE_NUM-1) {
        line_cnt.clearAll()
        when(color_cnt === COLOR_NUM-1) {
          inc := ~inc
          color_cnt.clearAll()
        } otherwise {
          color := inc ? (color + 0x111) | (color - 0x111)
          color_cnt := color_cnt + 1
        }
      } otherwise {
        line_cnt := line_cnt + 1
      }
    }

  }

  val hitomezashi = new Area {

    val color = Rgb(rgbConfig).setAsReg()

    //val vStart = U"01100_00101_00110_10011_10101_10101_01111_01101"
    val vStart = U"10110_11110_10101_10101_11001_01100_10100_00110"
    //val hStart = U"10111_01001_00001_10100_00111_01010"
    val hStart = U"01010_11100_00101_10000_10010_11101"

    val last_h_stitch  = RegInit(False)
    val v_line = io.x( 3 downto 0 ) === U(0)
    val h_line = io.y( 3 downto 0 ) === U(0)
    val v_on = io.y(4) ^ vStart( io.x( 9 downto 4 ) )
    val h_on = io.x(4) ^ hStart( io.y( 8 downto 4 ) )
    val stitch = ( v_line && v_on ) || ( h_line && h_on ) || last_h_stitch

    last_h_stitch := h_line && h_on

    color.r := stitch ? U(0xF, 4 bits) | U(0x1, 4 bits)
    color.g := stitch ? U(0xC, 4 bits) | U(0x3, 4 bits)
    color.b := stitch ? U(0x0, 4 bits) | U(0x7, 4 bits )

  }


  io.color.payload := {
    pattern match {
      case 0 => roster_bar.color
      case 1 => hitomezashi.color

    }
  }

  io.color.valid := RegNext(io.color_en)

  val delay_num = LatencyAnalysis(io.color_en, io.color.valid)
  println( "[INFO] io.color_en -> io.color.valid  = " + delay_num )

}


object racingBeamMain{
  def main(args: Array[String]) {

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new racing_beam( RgbConfig(4, 4, 4), RacingBeamConfig() )
    )
  }
}