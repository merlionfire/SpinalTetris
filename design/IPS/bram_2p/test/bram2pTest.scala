package IPS.bram_2p

import config._
import utils.PathUtils
import spinal.core.sim._
import spinal.core._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.log2Up



class bram2pTest extends AnyFunSuite {

  //val compiler : String = "verilator"
  val compiler: String = "vcs"

  var compiled: SimCompiled[Bram2p] = null

  val FB_SCALE = 1 << 1
  val FB_WIDTH = 640 / FB_SCALE
  val FB_HEIGHT = 480 / FB_SCALE
  val FB_PIXELS = FB_WIDTH * FB_HEIGHT
  val FB_ADDRWIDTH = log2Up(FB_PIXELS)
  val FB_WORDWIDTH = log2Up(16)

  val default_value = 2
  val fbConfig = Bram2pConfig(
    wordWidth = FB_WORDWIDTH,
    depth = FB_PIXELS,
    initFileName = "",
    default_value = default_value
  )

  compiled = runSimConfig(PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString, compiler)
    .withTimeScale(1 ns)
    .withTimePrecision(10 ps)
    .compile {
      val c = new Bram2p(fbConfig)
      c
    }


  test("sanity test ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      dut.clockDomain.forkStimulus(10)
      SimTimeout(3 * 10 * FB_PIXELS) // adjust timeout as needed

      //--------------------------------------------------------------------
      //          initialize ports
      //--------------------------------------------------------------------

      dut.io.clear_start #= false
      dut.io.wr.en #= false
      dut.io.wr.addr.randomize()
      dut.io.wr.data.randomize()
      dut.io.rd.en #= false
      dut.io.rd.addr.randomize()
      dut.clockDomain.waitSampling(20)

      //--------------------------------------------------------------------
      //          initialize all content by background color index
      //--------------------------------------------------------------------

      println(s"@${simTime()} Start initialization by clear_start signal")
      dut.io.clear_start #= true
      dut.clockDomain.waitSampling()
      dut.io.clear_start #= false

      dut.clockDomain.waitSamplingWhere(dut.io.clear_done.toBoolean)

      //--------------------------------------------------------------------
      //          Read each item and checker if it is background color index
      //--------------------------------------------------------------------
      println(s"@${simTime()} Start read content of memory and checker if it is 2 ")
      val readContentThread = fork {
        dut.io.rd.en #= true
        for (addr <- 0 until FB_PIXELS) {
          dut.io.rd.addr #= addr
          dut.clockDomain.waitSampling()
        }
        dut.io.rd.addr.randomize()
        dut.io.rd.en #= false
        dut.clockDomain.waitSampling()

      }

      var idx = 0
      dut.clockDomain.onFallingEdges {
        if (dut.io.rd.data.valid.toBoolean) {
          val data = dut.io.rd.data.payload.toInt
          if (data != default_value) {
            println(s"@${simTime()} [ERROR] Mem[${idx}] = ${dut.io.rd.data.payload.toInt} is unexpected ( ${default_value} )")
            simFailure("Simulation Failed because incorrected written data ")
          }
          idx = idx + 1
        }
      }

      readContentThread.join()
      dut.clockDomain.waitSampling(10)

      println(f"\n\n@${simTime()} ns Simulation Ending !!! ")
      if ( idx == FB_PIXELS )  {  println(s"@${simTime()} [PASS] all ${idx} items are written properly !!")  }
      else {
        println(s"@${simTime()} [WARN] only ${idx} items are observed properly but expected items is ${FB_PIXELS} !!")
      }

      simSuccess() // Simulation success after sending pieces

    }

  }
}