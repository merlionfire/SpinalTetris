package IPS.color_palettes

import spinal.core._
import spinal.lib.{LatencyAnalysis, master}
import utils.PathUtils

object ColorPaletteLib {
  // From: https://lospec.com/palette-list
  private val raw = Map[String, String](
    "Greyscale" -> "000 111 222 333 444 555 666 777 888 999 AAA BBB CCC DDD EEE FFF",
    "Sepia"     -> "000 100 210 321 432 543 654 765 876 987 A98 BA9 CBA DCB EDC FED",
    "Teleport" -> "825 B15 F05 F52 FA0 FC1 FF2 7E2 0E3 0B4 085 19A 3BF 59C 87A 847",
    "Sweetie"   -> "223 626 B45 F85 FD7 AF7 4B6 278 337 46D 4AF 7FF FFF 9BC 578 345", /* https://lospec.com/palette-list/sweetie-16 */
    "PICO-8"    -> "000 235 825 085 B53 655 CCC FFF F05 FA0 FF2 0E3 3BF 87A F7B FCA", /* https://lospec.com/palette-list/pico-8 */
    "Fading"    -> "DDA CB8 C86 A55 745 544 556 687 9A8 655 988 BA9 886 BA6 876 B96"  /* https://lospec.com/palette-list/fading-16 */
  )

  // Eagerly parsed at object initialization — pay cost once
  val palettes: Map[String, Seq[BigInt]] = raw.map { case (k, v) =>
      k -> v.split(" ").map(BigInt(_, 16)).toSeq
    }

  val availableNames: Set[String] = palettes.keySet

  def apply(name: String): Seq[BigInt] = palettes.getOrElse(
    name,
    throw new IllegalArgumentException(
      s"Unknown palette '$name'. Available: ${availableNames.mkString(", ")}"
    )
  )

}


case class ColorPalettesConfig(
                                colorNum    : Int    = 16,
                                colorW      : Int    = 12,
                                paletteName : String = "Teleport"
                              ) {
  // Validation

  require(isPow2(colorNum), s"colorNum must be power of 2, got $colorNum")

  paletteName match {
    case _ if ColorPaletteLib.availableNames.contains(paletteName) =>
      require( colorW == 12, s"colorW must be 12 for palette '$paletteName', got $colorW" )
    case _ => throw new IllegalArgumentException(
        s"Unknown palette '$paletteName'. Available: ${ColorPaletteLib.availableNames.mkString(", ")}"
      )
  }

  require( colorNum == palette.length, s"colorNum ($colorNum) must match palette length (${palette.length}) for palette '$paletteName'" )


  // Derived — computed once per config instance
  val idxW    : Int         = log2Up(colorNum)

  // Palette access delegates to library — no data stored in config
  def palette : Seq[BigInt] = ColorPaletteLib(paletteName)
}

class ColorPalette(val g : ColorPalettesConfig ) extends Component {

  import g._
  definitionName = s"color_palette"

  val io = new Bundle {
    val addr = in UInt( idxW bits)
    val rd_en = in Bool()
    val color = master Flow Bits(colorW bits )
  }

  noIoPrefix()

  val rom = Mem( Bits( colorW bits), colorNum)

  rom.initBigInt( palette )
  rom.addAttribute("ram_style", "distributed")

  io.color.payload := rom.readSync(io.addr, io.rd_en)
  io.color.valid := RegNext( io.rd_en, init = False  )


  val delay_num = LatencyAnalysis(io.rd_en, io.color.valid)
  println( "[INFO] io.rd_en -> io.color.valid  = " + delay_num )

}


object ColorPalettesMain{
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
      gen = new ColorPalette(ColorPalettesConfig())
    )
  }
}