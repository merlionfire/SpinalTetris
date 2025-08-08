package IPS.color_palettes

import spinal.core._
import spinal.lib.{LatencyAnalysis, master}
import utils.PathUtils

case class ColorPalettesConfig(COLOR_NUM : Int = 16,
                               COLOR_W   : Int = 12,
                               Palettes_name : String = "Teleport",
                               bg_color_idx : Int = 2 ) {

  assert(
    assertion = bg_color_idx < COLOR_NUM,
    message = s" bg_color_idx($bg_color_idx) should be 0 to ${COLOR_NUM-1}"
  )

  val IDX_W : Int = log2Up(COLOR_NUM)
  // From: https://lospec.com/palette-list
  val cPalettes16 = Map(
    "Greyscale" -> "000 111 222 333 444 555 666 777 888 999 AAA BBB CCC DDD EEE FFF",
    "Sepia"     -> "000 100 210 321 432 543 654 765 876 987 A98 BA9 CBA DCB EDC FED",
    "Teleport" -> "825 B15 F05 F52 FA0 FC1 FF2 7E2 0E3 0B4 085 19A 3BF 59C 87A 847",
    "Sweetie"   -> "223 626 B45 F85 FD7 AF7 4B6 278 337 46D 4AF 7FF FFF 9BC 578 345", /* https://lospec.com/palette-list/sweetie-16 */
    "PICO-8"    -> "000 235 825 085 B53 655 CCC FFF F05 FA0 FF2 0E3 3BF 87A F7B FCA", /* https://lospec.com/palette-list/pico-8 */
    "Fading"    -> "DDA CB8 C86 A55 745 544 556 687 9A8 655 988 BA9 886 BA6 876 B96"  /* https://lospec.com/palette-list/fading-16 */
  ).map { case (k, v) =>
    val vList = v.split(" ").map(BigInt(_, 16)).toSeq
    (k, vList)
  }

  def get_palette : Seq[BigInt] = cPalettes16(Palettes_name)

}

class color_palettes ( val g : ColorPalettesConfig ) extends Component {

  import g._

  val io = new Bundle {
    val addr = in UInt( IDX_W bits)
    val rd_en = in Bool()
    val color = master Flow Bits(COLOR_W bits )
  }

  val rom = Mem( Bits( COLOR_W bits), COLOR_NUM)

  //rom.initBigInt( cPalettes16(Palettes_name))
  rom.initBigInt( get_palette )
  rom.addAttribute("ram_style", "distributed")

  io.color.payload := rom.readSync(io.addr, io.rd_en)
  io.color.valid := RegNext( io.rd_en )

  val delay_num = LatencyAnalysis(io.rd_en, io.color.valid)
  println( "[INFO] io.rd_en -> io.color.valid  = " + delay_num )

}


object colorPalettesMain{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true,
      inlineRom = true
    ).generateVerilog(
      gen = new color_palettes(ColorPalettesConfig())
    )
  }
}