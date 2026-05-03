package IPS.linebuffer

import config._
import utils.PathUtils

import spinal.core.sim._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.{Bits, ClockDomain}
import spinal.lib.sim.FlowMonitor

import scala.collection.mutable
import scala.util.Random


class lineBufferTest extends AnyFunSuite {

  //val compiler: String = "verilator"
  var compiler : String = "vcs"
  val FRAME_WIDTH = 64
  val FRAME_HEIGHT = 20
  val PIX_BITS = 4

  private def compileLineBuffer(rdScale: Int): SimCompiled[LineBuffer[Bits]] = {
    runSimConfig(
      PathUtils.getRtlOutputPath(getClass, targetName = s"sim/rdscale_$rdScale").toString,
      compiler
    ).compile {
      val c = new LineBuffer[Bits](
        dataType = Bits().setWidth(PIX_BITS),
        FRAME_WIDTH,
        rdScale,
        wrClock = ClockDomain.external("wr"),
        rdClock = ClockDomain.external("rd")
      )
      c.rd.enable.simPublic()
      c
    }
  }

  private def runSanity(rdScale: Int, stimulusSeed: Int): Unit = {
    val compiled = compileLineBuffer(rdScale)
    compiled.doSimUntilVoid(seed = 42) { dut =>
      val rng = new Random(stimulusSeed)


      // Prepare reproducible test data for whole frame buffer.
      val testWriteFrameData = ( 0 until FRAME_HEIGHT ).map { _ =>
        (0 until FRAME_WIDTH).map { _ =>  rng.nextInt(1 << PIX_BITS) }.toList
      }.toList

      val writeLinePixels = mutable.Queue[Int]()
      val readLinePixels = mutable.Queue[Int]()


      dut.wrClock.forkStimulus( 20  )  // cycle duty = 20 ps
      dut.rdClock.forkStimulus( 50  )  // cycle duty = 50 ps
      SimTimeout(200000)


      dut.io.wr_in.valid #= false
      dut.io.wr_in.payload #= 0
      dut.io.rd_start #= false


      val wrThread = fork {
        dut.wrClock.waitSampling(10)
        for ( line <- testWriteFrameData ) {
          dut.wrClock.waitSampling(1)
          println(s"[Debug] @${simTime()} Write process is starting ...." )
          for ( pix <- line ) {
            dut.io.wr_in.valid #= true
            dut.io.wr_in.payload #= pix
            dut.wrClock.waitSampling()
          }
          dut.io.wr_in.valid #= false
          dut.io.wr_in.payload.randomize()
          dut.wrClock.waitSampling(20)
          println(s"[Debug] @${simTime()} Write process end !! " )


          dut.rdClock.waitSampling()
          dut.io.rd_start #= true
          dut.rdClock.waitSampling()
          dut.io.rd_start #= false
          // wait for starting read process
          dut.rdClock.waitSampling(2)
          // Wait for end of read process
          dut.rdClock.waitSamplingWhere(! dut.rd.enable.toBoolean)

          println(s"[Debug] @${simTime()} Read process end !! " )
        }
      }

      dut.wrClock.waitSampling(5)
      FlowMonitor(dut.io.wr_in, dut.wrClock) { payload =>
        writeLinePixels.enqueue(payload.toInt )
      }

      FlowMonitor(dut.io.rd_out, dut.rdClock) { payload =>
        readLinePixels.enqueue(payload.toInt )
      }

      wrThread.join()

      println(s"[Debug] @${simTime()} Waiting for sim stop  !! " )

      dut.rdClock.waitSampling(20)

      // scoreboard
      assert(
        writeLinePixels.length == testWriteFrameData.flatten.size,
        s" The total number of writeLinePixels (${writeLinePixels.length}) did NOT match the expected ${testWriteFrameData.flatten.size}"
      )


      val writeFrameData = writeLinePixels.grouped(FRAME_WIDTH).map(_.toList).toList
      val writeRowMatched = testWriteFrameData.zip(writeFrameData).map { case (exp, got) => exp == got }
      val writeMatchedRows = writeRowMatched.count(identity)
      val writeFailedRows = FRAME_HEIGHT - writeMatchedRows
      println(
        "=" * 80 + "\n" +
        s"[Summary][write] rows matched=$writeMatchedRows/$FRAME_HEIGHT, failed=$writeFailedRows" + "\n" +
        "=" * 80 + "\n"
      )
      for ((line, row) <- testWriteFrameData.zipWithIndex) {
        if (line.zip(writeFrameData(row)).forall { case (a, b) => a == b }) {
          println(s"<$row> write pixels matched !!")
        } else {
          println(s"<$row> write pixels mismatched - Fail!!")
          println(s"\t\t Expected  : ${line}")
          println(s"\t\t Write obs : ${writeFrameData(row)}")
          fail(s"write row mismatch at row=$row")
        }
      }

      val testReadFrameData = testWriteFrameData.map { _.flatMap(List.fill(rdScale)(_)) }
      assert(
        readLinePixels.length == testReadFrameData.flatten.size,
        s" The total number of readLinePixels (${readLinePixels.length}) did NOT match the expected ${testReadFrameData.flatten.size}"
      )
      val readFrameData = readLinePixels.grouped(FRAME_WIDTH * rdScale).map(_.toList).toList
      val readRowMatched = testReadFrameData.zip(readFrameData).map { case (exp, got) => exp == got }
      val readMatchedRows = readRowMatched.count(identity)
      val readFailedRows = FRAME_HEIGHT - readMatchedRows
      println(
        "=" * 80 + "\n" +
        s"[Summary][read ] rows matched=$readMatchedRows/$FRAME_HEIGHT, failed=$readFailedRows" + "\n" +
        "=" * 80 + "\n"
      )
      for ((line, row) <- testReadFrameData.zipWithIndex) {
        if (line.zip(readFrameData(row)).forall { case (a, b) => a == b }) {
          println(s"<$row> read  pixels matched !!")
        } else {
          println(s"<$row read pixels mismatched - Fail!!")
          println(s"\t\t Expected  : ${line}")
          println(s"\t\t Read obs : ${readFrameData(row)}")
          fail(s"read row mismatch at row=$row")
        }
      }


      //dut.clockDomain.waitSampling(2)

      println(f"\n\n@${simTime()} ns Simulation Ending !!! ")
      simSuccess() // Simulation success after sending pieces

    }
  }

  test("sanity test rd_scale=1") {
    runSanity(rdScale = 1, stimulusSeed = 42)
  }

  test("sanity test rd_scale=2") {
    runSanity(rdScale = 2, stimulusSeed = 43)
  }
}