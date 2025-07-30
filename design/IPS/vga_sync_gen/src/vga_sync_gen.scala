package IPS.vga_sync_gen

import spinal.core._
import spinal.lib.graphic.RgbConfig
import utils.PathUtils

case class VgaTimingsHV(timingsWidth: Int ) extends Bundle {
  var offset : Int  = 0
  val syncStart = SInt(timingsWidth bit)
  val syncEnd = SInt(timingsWidth bit)
  val colorStart = SInt(timingsWidth bit)
  val colorEnd = SInt(timingsWidth bit)
  val polarity = Bool()
}

case class VgaTimings(timingsWidth: Int,  visible_origin : Boolean = true ) extends Bundle {
  val h = VgaTimingsHV(timingsWidth)
  val v = VgaTimingsHV(timingsWidth)

  def setAs_h640_v480_r60: Unit = {
    h.offset = if (visible_origin) 144 else 0
    v.offset = if (visible_origin) 35 else 0

    h.syncStart := 95 - h.offset
    h.syncEnd := 799 - h.offset
    h.colorStart := 143 - h.offset
    h.colorEnd := 783 - h.offset
    v.syncStart := 1 - v.offset
    v.syncEnd := 524 - v.offset
    v.colorStart := 34 - v.offset
    v.colorEnd := 514 - v.offset
    h.polarity := False
    v.polarity := False
  }
  def setAs_h64_v64_r60: Unit = {
    h.syncStart := 96 - 1
    h.syncEnd := 800 - 1
    h.colorStart := 96 + 16 - 1 + 288
    h.colorEnd := 800 - 48 - 1 - 288
    v.syncStart := 2 - 1
    v.syncEnd := 525 - 1
    v.colorStart := 2 + 10 - 1 + 208
    v.colorEnd := 525 - 33 - 1 - 208
    h.polarity := False
    v.polarity := False
  }

  def setAs(hPixels : Int,
            hSync : Int,
            hFront : Int,
            hBack : Int,
            hPolarity : Boolean,
            vPixels : Int,
            vSync : Int,
            vFront : Int,
            vBack : Int,
            vPolarity : Boolean): Unit = {
    h.syncStart := hSync - 1
    h.colorStart := hSync + hBack - 1
    h.colorEnd := hSync + hBack + hPixels - 1
    h.syncEnd := hSync + hBack + hPixels + hFront - 1
    v.syncStart := vSync - 1
    v.colorStart := vSync + vBack - 1
    v.colorEnd := vSync + vBack + vPixels - 1
    v.syncEnd := vSync + vBack + vPixels + vFront - 1
    h.polarity := Bool(hPolarity)
    v.polarity := Bool(vPolarity)
  }


  def setAs_h1920_v1080_r60: Unit = setAs(
    hPixels    = 1920,
    hSync      = 44,
    hFront     = 88,
    hBack      = 148,
    hPolarity  = true,
    vPixels    = 1080,
    vSync      = 5,
    vFront     = 4,
    vBack      = 36,
    vPolarity  = true
  )

  def setAs_h800_v600_r60: Unit = setAs(
    hPixels    = 800,
    hSync      = 128,
    hFront     = 40,
    hBack      = 88,
    hPolarity  = true,
    vPixels    = 600,
    vSync      = 4,
    vFront     = 1,
    vBack      = 23,
    vPolarity  = true
  )

}




case class vga_sync_gen(rgbConfig: RgbConfig, timingsWidth: Int = 12) extends Component {
  val io = new Bundle {
    val softReset = in Bool() default(False)
    val sof = out Bool()
    val sol = out Bool()
    val sos = out Bool()
    val hSync = out Bool()
    val vSync = out Bool()
    val colorEn = out Bool()
    val vColorEn = out Bool()
    val x = out UInt( (timingsWidth-1) bits )
    val y = out UInt( (timingsWidth-1)  bits )

  }

  val timings   = VgaTimings(timingsWidth)
  timings.setAs_h640_v480_r60


  case class HVArea(timingsHV: VgaTimingsHV, enable: Bool) extends Area {
    val counter = Reg(SInt(timingsWidth bit)) init( S(-timingsHV.offset, timingsWidth bits) )

    val syncStart = counter === timingsHV.syncStart
    val syncEnd = counter === timingsHV.syncEnd
    val colorStart = counter === timingsHV.colorStart
    val colorEnd = counter === timingsHV.colorEnd
    val polarity = timingsHV.polarity

    when(enable) {
      counter := counter + 1
      when(syncEnd) {
        counter := S(-timingsHV.offset, timingsWidth bits )
      }
    }

    /*
    val sync    = RegInit(False) setWhen(syncStart) clearWhen(syncEnd)
    val colorEn = RegInit(False) setWhen(colorStart) clearWhen(colorEnd)
*/

    val sync    = RegInit(False) setWhen(enable & syncStart) clearWhen( enable & syncEnd)
    val colorEn = RegInit(False) setWhen(enable & colorStart) clearWhen(enable & colorEnd)

    when(io.softReset) {
      counter := S(-timingsHV.offset, timingsWidth bits)
      sync := False
      colorEn := False
    }
  }

  val h = ClockDomain.current{ HVArea(timings.h, True) }
  val v = ClockDomain.current { HVArea(timings.v, h.syncEnd) } // h.colorEnd
  val colorEn = h.colorEn && v.colorEn

  io.sof := v.syncStart && h.syncStart

  io.hSync := h.sync ^ h.polarity
  io.vSync := v.sync ^ v.polarity
  io.colorEn := colorEn

  io.x := h.counter.asUInt.resize(timingsWidth-1)
  io.y := v.counter.asUInt.resize(timingsWidth-1)

  io.sol := h.colorStart && v.colorEn
  io.sos := h.syncStart && v.colorEn
  io.vColorEn := v.colorEn
}

object vgaSyncGenMain{
  def main(args: Array[String]) {
    SpinalConfig(
      //targetDirectory = "design/IPS/vga_sync_gen/rtl",
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true

    ).addStandardMemBlackboxing(blackboxAll).generateVerilog(
      gen = vga_sync_gen(RgbConfig(4, 4, 4),  timingsWidth = 11 )
    )
  }
}