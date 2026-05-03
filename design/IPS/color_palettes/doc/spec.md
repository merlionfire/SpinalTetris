# ColorPalette IP Specification

## Functional overview

`ColorPalette` implements a synchronous ROM that maps a palette index (`addr`) to an RGB color value (`color.payload`) selected by `paletteName`.

- Input `rd_en` requests a read at `addr`.
- Output `color.valid` is asserted one cycle after `rd_en`.
- Output `color.payload` returns the palette value for the requested index.

The ROM content is driven by `ColorPalettesConfig` and centralized catalog data from `config.ColorPaletteCatalog`.

## Configuration

`ColorPalettesConfig(colorNum, colorW, paletteName)` wraps `ColorSystemConfig` and provides:

- `colorNum`: palette depth
- `colorW`: palette entry width
- `paletteName`: selected palette in catalog
- `idxW`: address width derived from `colorNum`
- `palette`: palette values used for ROM initialization

Validation rules are applied through `ColorSystemConfig`:

- `colorNum` must be power-of-two
- `paletteName` must exist in `ColorPaletteCatalog`
- `colorNum` must match selected palette depth
- `colorW` must match selected palette entry width

## Interface contract

- `io.addr`: palette index (`UInt(idxW bits)`)
- `io.rd_en`: synchronous read enable
- `io.color.payload`: color word (`Bits(colorW bits)`)
- `io.color.valid`: response valid, 1-cycle delayed from `rd_en`

## Timing behavior

The read path is synchronous:

- Cycle N: `rd_en=1` with `addr=A`
- Cycle N+1: `color.valid=1`, `color.payload=palette[A]`

## Palette catalog usage

To add a new palette:

1. Add a `PaletteSpec` entry in `design/config/ColorSystemConfig.scala` under `ColorPaletteCatalog.palettes`.
2. Set `entryWidth` and `values` to match desired format/depth.
3. Instantiate `ColorSystemConfig` with matching `colorNum` and `colorW`.
4. Build `ColorPalettesConfig(colorSystem)` and pass to `new ColorPalette(...)`.

## Reference figure

See `palette_bar.svg` for a visual reference of all catalog palettes.

