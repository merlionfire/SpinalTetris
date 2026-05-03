package IPS.color_palettes

import config.ColorSystemConfig
import spinal.core._
import spinal.lib.{LatencyAnalysis, master}
import utils.PathUtils


case class ColorPalettesConfig(
                                colorNum    : Int    = 16,
                                colorW      : Int    = 12,
                                paletteName : String = "Teleport"
                              ) {
  val colorSystem: ColorSystemConfig = ColorSystemConfig(
    paletteName = paletteName,
    colorNum = colorNum,
    colorW = colorW
  )

  // Derived — computed once per config instance
  val idxW    : Int         = colorSystem.idxW

  // Palette access delegates to shared system config.
  def palette : Seq[BigInt] = colorSystem.palette
}

object ColorPalettesConfig {
  def apply(colorSystem: ColorSystemConfig): ColorPalettesConfig = {
    ColorPalettesConfig(
      colorNum = colorSystem.colorNum,
      colorW = colorSystem.colorW,
      paletteName = colorSystem.paletteName
    )
  }
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