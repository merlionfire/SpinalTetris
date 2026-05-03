package IPS.color_palettes

import config.{ColorPaletteCatalog, ColorSystemConfig}
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.log2Up

class ColorPalettesConfigTest extends AnyFunSuite {

  test("catalog exposes expected palette names") {
    val expected = Set("Fading", "Greyscale", "PICO-8", "Sepia", "Sweetie", "Teleport")
    assert(ColorPaletteCatalog.availableNames == expected)
  }

  test("config accepts every catalog palette with matching depth and width") {
    for (paletteName <- ColorPaletteCatalog.availableNames.toSeq.sorted) {
      val spec = ColorPaletteCatalog.byName(paletteName)
      val cfg = ColorPalettesConfig(
        colorNum = spec.depth,
        colorW = spec.entryWidth,
        paletteName = paletteName
      )

      assert(cfg.idxW == log2Up(spec.depth))
      assert(cfg.palette == spec.values)
    }
  }

  test("config rejects unknown palette name") {
    assertThrows[IllegalArgumentException] {
      ColorPalettesConfig(
        paletteName = "NotARealPalette"
      )
    }
  }

  test("config rejects colorNum that does not match selected palette depth") {
    assertThrows[IllegalArgumentException] {
      ColorPalettesConfig(
        colorNum = 8
      )
    }
  }

  test("config rejects colorW that does not match selected palette entry width") {
    assertThrows[IllegalArgumentException] {
      ColorPalettesConfig(
        colorW = 10
      )
    }
  }

  test("companion apply builds equivalent config from ColorSystemConfig") {
    val colorSystem = ColorSystemConfig(
      paletteName = "Sepia"
    )

    val cfg = ColorPalettesConfig(colorSystem)

    assert(cfg.colorNum == colorSystem.colorNum)
    assert(cfg.colorW == colorSystem.colorW)
    assert(cfg.paletteName == colorSystem.paletteName)
    assert(cfg.palette == colorSystem.palette)
  }
}

