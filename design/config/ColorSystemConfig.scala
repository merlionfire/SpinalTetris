package config

import spinal.core.log2Up


final case class PaletteSpec(
    name: String,
    entryWidth: Int,
    values: Vector[BigInt]) {

  val depth: Int = values.length
  val idxW: Int = log2Up(depth)

  require(depth > 0, s"Palette '$name' must not be empty")
  require((depth & (depth - 1)) == 0, s"Palette '$name' depth must be power of 2, got $depth")
  require(entryWidth > 0, s"Palette '$name' entryWidth must be > 0")
  require(
    values.forall(v => v >= 0 && v < (BigInt(1) << entryWidth)),
    s"Palette '$name' has value out of ${entryWidth}-bit range"
  )
}

object ColorPaletteCatalog {
  private def parseHexWords(words: String): Vector[BigInt] = {
    words.trim.split("\\s+").toVector.map(BigInt(_, 16))
  }

  val palettes: Map[String, PaletteSpec] = Map(
    "Greyscale" -> PaletteSpec(
      name = "Greyscale",
      entryWidth = 12,
      values = parseHexWords("000 111 222 333 444 555 666 777 888 999 AAA BBB CCC DDD EEE FFF")
    ),
    "Sepia" -> PaletteSpec(
      name = "Sepia",
      entryWidth = 12,
      values = parseHexWords("000 100 210 321 432 543 654 765 876 987 A98 BA9 CBA DCB EDC FED")
    ),
    "Teleport" -> PaletteSpec(
      name = "Teleport",
      entryWidth = 12,
      values = parseHexWords("825 B15 F05 F52 FA0 FC1 FF2 7E2 0E3 0B4 085 19A 3BF 59C 87A 847")
    ),
    "Sweetie" -> PaletteSpec(
      name = "Sweetie",
      entryWidth = 12,
      values = parseHexWords("223 626 B45 F85 FD7 AF7 4B6 278 337 46D 4AF 7FF FFF 9BC 578 345")
    ),
    "PICO-8" -> PaletteSpec(
      name = "PICO-8",
      entryWidth = 12,
      values = parseHexWords("000 235 825 085 B53 655 CCC FFF F05 FA0 FF2 0E3 3BF 87A F7B FCA")
    ),
    "Fading" -> PaletteSpec(
      name = "Fading",
      entryWidth = 12,
      values = parseHexWords("DDA CB8 C86 A55 745 544 556 687 9A8 655 988 BA9 886 BA6 876 B96")
    )
  )

  val availableNames: Set[String] = palettes.keySet

  def byName(name: String): PaletteSpec = palettes.getOrElse(
    name,
    throw new IllegalArgumentException(
      s"Unknown palette '$name'. Available: ${availableNames.toSeq.sorted.mkString(", ")}"
    )
  )
}

final case class ColorSystemConfig(
    paletteName: String = "Teleport",
    colorNum: Int = 16,
    colorW: Int = 12) {

  val paletteSpec: PaletteSpec = ColorPaletteCatalog.byName(paletteName)

  require((colorNum & (colorNum - 1)) == 0, s"colorNum must be power of 2, got $colorNum")
  require(
    colorNum == paletteSpec.depth,
    s"colorNum ($colorNum) must match palette depth (${paletteSpec.depth}) for '$paletteName'"
  )
  require(
    colorW == paletteSpec.entryWidth,
    s"colorW ($colorW) must match palette entryWidth (${paletteSpec.entryWidth}) for '$paletteName'"
  )

  val idxW: Int = log2Up(colorNum)
  val palette: Seq[BigInt] = paletteSpec.values
}

