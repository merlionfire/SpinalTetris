package IPS.color_palettes


import config.{ColorPaletteCatalog, ColorSystemConfig, runSimConfig}
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.sim._
import utils.PathUtils

import scala.util.Random

class ColorPaletteTest extends AnyFunSuite {

  //var compiler: String = "verilator"
  var compiler: String = "vcs"

  private def simulationTargetName(paletteName: String): String = {
	val sanitizedName = paletteName.replaceAll("[^A-Za-z0-9]+", "_").replaceAll("_+", "_")
	s"color_palette_$sanitizedName"
  }

  private def formatHexValue(value: BigInt, width: Int): String = {
	val hexDigits = math.max(1, (width + 3) / 4)
	val hexValue = value.toString(16).toUpperCase
	val paddedHexValue = if (hexValue.length >= hexDigits) {
	  hexValue
	} else {
	  ("0" * (hexDigits - hexValue.length)) + hexValue
	}
	s"0x$paddedHexValue"
  }

  private def printPaletteSummary(
	  paletteName: String,
	  spec: config.PaletteSpec,
	  colorSystem: ColorSystemConfig,
	  simTargetName: String): Unit = {
	val rawData = spec.values.map(value => formatHexValue(value, spec.entryWidth)).mkString(" ")

		println("=" * 30 )
		println(s"[Debug] [$paletteName] palette summary start")
		println(s"[Debug] [$paletteName] sim folder : $simTargetName")
		println(s"[Debug] [$paletteName] parameters  : colorNum=${colorSystem.colorNum}, colorW=${colorSystem.colorW}, idxW=${colorSystem.idxW}")
		println(s"[Debug] [$paletteName] colors      : $rawData")
		println(s"[Debug] [$paletteName] palette size: depth=${spec.depth}, entryWidth=${spec.entryWidth}")
		println("=" * 30 )
  }

  private def checkRomForPalette(paletteName: String): Unit = {
	val spec = ColorPaletteCatalog.byName(paletteName)
	val colorSystem = ColorSystemConfig(
	  paletteName = paletteName,
	  colorNum = spec.depth,
	  colorW = spec.entryWidth
	)
  val simTargetName = simulationTargetName(paletteName)

  printPaletteSummary(paletteName, spec, colorSystem, simTargetName)
  println(s"[Debug] [${paletteName}] Compile start: depth=${spec.depth}, width=${spec.entryWidth}")

		val simConfig = runSimConfig(
			PathUtils.getRtlOutputPath(getClass, targetName = s"sim/${simTargetName}").toString,
			compiler
		)

		val compiled = (if (compiler == "verilator") simConfig.withWaveDepth(99) else simConfig).compile {
			new ColorPalette(ColorPalettesConfig(colorSystem))
		}

		println(s"[Debug] [${paletteName}] Compile done")

		compiled.doSimUntilVoid(seed = 42) { dut =>
			def checkOrFail(condition: Boolean, message: String): Unit = {
				if (!condition) {
					simFailure(message)
				}
			}

			println(s"[Debug] [${paletteName}] Simulation start @${simTime()}")
			dut.clockDomain.forkStimulus(10)
			SimTimeout(10000) // adjust timeout as needed
			dut.clockDomain.waitSampling(20)

			dut.io.rd_en #= false
			dut.io.addr #= 0
			dut.clockDomain.waitSampling(2)
			checkOrFail(
				!dut.io.color.valid.toBoolean,
				s"[$paletteName] expected color.valid=0 during initial warmup, observed=1 @${simTime()}"
			)

			val boundaryAddresses = Seq(0, spec.depth - 1, 1, spec.depth - 2).distinct
			val random = new Random(0xC010 + paletteName.hashCode)
			val randomAddresses = Seq.fill(80)(random.nextInt(spec.depth))
			val addresses = boundaryAddresses ++ randomAddresses

			println(s"[Debug] [${paletteName}] Read check start: ${addresses.length} addresses")

			var expectedPrevAddress: Option[Int] = None
			var checkedCount = 0

			for (addr <- addresses) {
				dut.io.addr #= addr
				dut.io.rd_en #= true
				dut.clockDomain.waitSampling()

				expectedPrevAddress match {
					case Some(prevAddr) =>
						checkOrFail(
							dut.io.color.valid.toBoolean,
							s"[$paletteName] expected color.valid=1 for pipelined read at addr=$prevAddr @${simTime()}"
						)
					val expected = spec.values(prevAddr)
					val observed = dut.io.color.payload.toBigInt
						checkOrFail(
							observed == expected,
							s"palette=$paletteName addr=$prevAddr expected=${formatHexValue(expected, spec.entryWidth)} observed=${formatHexValue(observed, spec.entryWidth)} @${simTime()}"
					)
					checkedCount += 1
					case None =>
						checkOrFail(
							!dut.io.color.valid.toBoolean,
							s"[$paletteName] expected color.valid=0 for first read latency cycle @${simTime()}"
						)
				}

				expectedPrevAddress = Some(addr)
			}

			dut.io.rd_en #= false
			dut.clockDomain.waitSampling()
			checkOrFail(
				dut.io.color.valid.toBoolean,
				s"[$paletteName] expected color.valid=1 on drain cycle after rd_en deassert @${simTime()}"
			)
			expectedPrevAddress.foreach { prevAddr =>
				val expected = spec.values(prevAddr)
				val observed = dut.io.color.payload.toBigInt
				checkOrFail(
					observed == expected,
					s"palette=$paletteName drain addr=$prevAddr expected=${formatHexValue(expected, spec.entryWidth)} observed=${formatHexValue(observed, spec.entryWidth)} @${simTime()}"
				)
				checkedCount += 1
			}

			dut.clockDomain.waitSampling()
			checkOrFail(
				!dut.io.color.valid.toBoolean,
				s"[$paletteName] expected color.valid=0 after drain completion @${simTime()}"
			)
			println(s"[Debug] [${paletteName}] Read check done: verified=${checkedCount}")
			dut.clockDomain.waitSampling(100)
			println(s"[Debug] [${paletteName}] Simulation end @${simTime()}")
			simSuccess()
		}

		if (compiler == "verilator") {
			Thread.sleep(500)
		}
  }

  private def runPaletteSubTest(paletteName: String): Unit = {
		println(s"[Debug] Starting ColorPaletteTest with compiler=$compiler")
		println(s"[Debug] Begin palette: $paletteName")
		checkRomForPalette(paletteName)
		println(s"[Debug] End palette: $paletteName")
  }

  test("Test Greyscale") {
		runPaletteSubTest("Greyscale")
  }

  test("Test Sepia") {
		runPaletteSubTest("Sepia")
  }

  test("Test Teleport") {
		runPaletteSubTest("Teleport")
  }

  test("Test Sweetie") {
		runPaletteSubTest("Sweetie")
  }

  test("Test PICO-8") {
		runPaletteSubTest("PICO-8")
  }

  test("Test Fading") {
		runPaletteSubTest("Fading")
  }
}

