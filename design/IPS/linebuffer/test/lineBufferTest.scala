package IPS.linebuffer

import config._
import utils.PathUtils

import spinal.core.sim._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.{Bits, ClockDomain}
import spinal.lib.sim.FlowMonitor

import java.util.concurrent.Semaphore
import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import scala.util.Random


class lineBufferTest extends AnyFunSuite {

  //var compiler : String = "verilator"
  var compiler : String = "vcs"

  var compiled: SimCompiled[linebuffer[Bits]] = null

  val generated_blocks = ArrayBuffer[Int] ()


  val FRAME_WIDTH = 64
  val FRAME_HEIGHT = 20
  val PIX_BITS = 1
  val RD_SCALE = 1 << 1// RD_SCALE is 1<<n where n = 0 , 1, 2, 3,
  compiled = runSimConfig(PathUtils.getRtlOutputPath(getClass, targetName="sim").toString, compiler )
    .compile {
      val c =  new linebuffer[Bits](
        dataType= Bits().setWidth(PIX_BITS) ,
        FRAME_WIDTH,
        RD_SCALE,
        wrClock = ClockDomain.external("wr"),
        rdClock = ClockDomain.external("rd")
      )
      c.rd.enable.simPublic()
      c
    }



  test("sanity test ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      val semaphore = new Semaphore(0)


      // Prepare the test date for whole frame buffer
      val testWriteFrameData = ( 0 until FRAME_HEIGHT ).map { _ =>
        (0 until FRAME_WIDTH).map { _ =>
          Random.nextInt(1 << PIX_BITS)
        }.toList
      }.toList

      val writeLinePixels = mutable.Queue[Int]()
      val readLinePixels = mutable.Queue[Int]()


      dut.wrClock.forkStimulus( 20  )  // cycle duty = 20 ps
      dut.rdClock.forkStimulus( 50  )  // cycle duty = 50 ps
      //SimTimeout(500)


      dut.io.wr_in.valid #= false
      dut.io.wr_in.payload #= 0
      dut.io.rd_start #= false

      // Fork a thread to manage the clock domains signals
      // Manually generate clock
      /*
      val wrClocksThread = fork {
        dut.wrClock.fallingEdge()
        dut.rdClock.fallingEdge()
        dut.wrClock.deassertReset()
        dut.rdClock.deassertReset()
        println(s"[Debug] @${simTime()} Enter wrClock reset ...." )
        // Do the resets.
        dut.wrClock.assertReset()
        dut.rdClock.assertReset()
        sleep(10)
        println(s"[Debug] @${simTime()} Release wrClock reset ...." )
        dut.wrClock.deassertReset()
        dut.rdClock.deassertReset()
        sleep(1)
        println(s"[Debug] @${simTime()} Begin to create wr clock ...." )
        while ( true ) {
          dut.wrClock.clockToggle()
          dut.rdClock.clockToggle()
          sleep(5)
        }
        //simSuccess()
      }
*/


      val wrThread = fork {
        dut.wrClock.waitSampling(10)
        for ( line <- testWriteFrameData ) {
          //semaphore.acquire()
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
          //semaphore.release()


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


      val writeFrameData = writeLinePixels.grouped(FRAME_WIDTH).map( _.toList).toList
      for ( ( line, row) <- testWriteFrameData.zipWithIndex ) {
        if ( line.zip(writeFrameData(row)).forall{ case (a,b) => a == b  }  )  {
          println(s"<$row> write pixels matched !!")
        } else  {
          println(s"<$row> write pixels mismatched - Fail!!")
          println(s"\t\t Expected  : ${line}")
          println(s"\t\t Write obs : ${writeFrameData(row)}")
        }
      }

      val testReadFrameData = testWriteFrameData.map { _.flatMap ( List.fill(RD_SCALE)(_) )  }
      assert(
        readLinePixels.length == testReadFrameData.flatten.size,
        s" The total number of readLinePixels (${readLinePixels.length}) did NOT match the expected ${testReadFrameData.flatten.size}"
      )
      val readFrameData = readLinePixels.grouped(FRAME_WIDTH * RD_SCALE ).map( _.toList).toList
      for ( ( line, row) <- testReadFrameData.zipWithIndex ) {
        if ( line.zip(readFrameData(row)).forall{ case (a,b) => a == b  }  )  {
          println(s"<$row> read  pixels matched !!")
        } else  {
          println(s"<$row read pixels mismatched - Fail!!")
          println(s"\t\t Expected  : ${line}")
          println(s"\t\t Read obs : ${readFrameData(row)}")
        }
      }


      //dut.clockDomain.waitSampling(2)

      println(f"\n\n@${simTime()} ns Simulation Ending !!! ")
      simSuccess() // Simulation success after sending pieces

    }
  }
}