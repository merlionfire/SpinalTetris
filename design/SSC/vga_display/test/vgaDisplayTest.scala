package SSC.vga_display

import utils.PathUtils
import config._

import spinal.core._
import spinal.core.sim._

import org.scalatest.funsuite.AnyFunSuite
import spinal.core.{Bits, ClockDomain}
import spinal.lib.sim.FlowMonitor

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import scala.util.Random
import java.awt.{BasicStroke, Color, Font, Graphics2D}
import java.awt.image.BufferedImage
import java.io.File
import java.util.concurrent.CountDownLatch
import javax.imageio.ImageIO
import javax.swing.WindowConstants
import scala.collection.mutable
import scala.swing._
import scala.swing.event._

class vgaDisplayTest extends AnyFunSuite {


    val compiler : String = "verilator"
    //var compiler: String = "vcs"
    val runFolder : String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SSC", targetName = "sim").toString

    val memory_model : String  = compiler match  {
      case "verilator" => "RAMB16_S9_VERILATOR.v"
      case "vcs" => "RAMB16_S9.v"
    }
    var compiled: SimCompiled[vga_display] = null

    val xilinxPath = System.getenv("XILINX")

    println("[DEBUG] xilinxPath = " + xilinxPath)

    var drawFrameInstance: Option[MainFrame] = None

    val expectedData, receivedData = ArrayBuffer[Int]()
    val receivedHitStatus = mutable.Queue[Boolean]()
    var obs_mem = mutable.Queue[(Int, Int, Int)]()
    val shift_mem = mutable.Queue[ArrayBuffer[BigInt]]()


    compiled = runSimConfig(runFolder, compiler)
      .addRtl(s"${xilinxPath}/glbl.v")
      .addRtl(s"${xilinxPath}/unisims/${memory_model}")
      .addRtl("design/utils/ascii_font16x8.v")
      .withTimeScale( 1 ns)
      .withTimePrecision(1 ps)
      .compile {
          val c = new vga_display(VgaDisplayConfig())
          c.vga.rb.io.color.simPublic()
          c.vga.pixel_debug.simPublic()
          c.vga.vga_sync.io.sof.simPublic()
          c
      }

    object GuiHelper {
        def vga4BitTo8Bit(color: (Int, Int, Int)): Int = {
            // Scale the 4-bit value (0-15) to the 8-bit range (0-255)
            // Multiplying by 17 (255 / 15 is approximately 17) often works well for this.
            // (value & 0xF) * 17
            // Alternatively, you can also try bit shifting and replication:
            // (value & 0xF) | ((value & 0xF) << 4)
            val r = color._1 | color._1 << 4
            val g = color._2 | color._2 << 4
            val color8bit = List(color._1, color._2, color._3).map(x => x | (x << 4))
            color8bit(0) << 16 | color8bit(1) << 8 | color8bit(2)

        }

        def launchGui() = {

            // A CountDownLatch is a reliable way to have one thread wait for another.
            // We initialize it to 1, meaning we're waiting for one event to happen.
            val guiClosedLatch = new CountDownLatch(1)
            val imageTitle = "VGA Display Example"
            val imageFile = s"${runFolder}/${compiler}/${imageTitle.replace(" ", "_")}.png"

            val gui = fork {
                // All Swing UI code must run on the Event Dispatch Thread (EDT).
                // Swing.onEDT ensures this.
                Swing.onEDT {
                    // Drawing after simulation
                    object DrawFrame extends MainFrame {
                        var closed = false
                        val width = 640
                        val height = 480
                        title = imageTitle
                        // 1. Take full control of the close operation.
                        // This ensures that clicking 'X' ONLY fires the WindowClosing event.
                        peer.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE)

                        preferredSize = new Dimension(width, height)
                        contents = new Panel {
                            preferredSize = new Dimension(width, height)
                            private var cachedImage: Option[BufferedImage] = None

                            // Create a simple image
                            def createImage(): BufferedImage = {
                                val img = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)
                                val g = img.createGraphics()

                                for (y <- 0 until height) {
                                    for (x <- 0 until width) {
                                        val rgb = obs_mem.dequeue()
                                        img.setRGB(x, y, vga4BitTo8Bit(rgb))
                                    }
                                }
                                if (obs_mem.nonEmpty) {
                                    println(f"[Error] obs_mem is NOT empty and number of the remaining items : ${obs_mem.size}")
                                }
                                g.dispose()
                                val outputFile = new File(imageFile)
                                ImageIO.write(img, "png", outputFile)
                                println(s"Image saved to ${outputFile.getAbsolutePath}")
                                img

                            }
                            //Initial generate image
                            cachedImage = Some(createImage())

                            override def paintComponent(g: Graphics2D): Unit = {
                                super.paintComponent(g)
                                println("DEBUG][GUI]paintComponent() is called now ! ")
                                cachedImage match {
                                    case Some(image) => g.drawImage(image, 0, 0, size.width, size.height, null) // Scale if needed.
                                    case None => // Handle the case where the image hasn't been generated yet
                                }

                            }

                        }

                        // 2. Listen for the user's direct intent to close the window.
                        reactions += {
                            case _: WindowClosing =>
                                println("[DEBUG] Window closing event received. Manually disposing and releasing latch.")
                                // 3. Perform shutdown actions explicitly and in order.
                                dispose() // Manually dispose the window to free resources.
                                guiClosedLatch.countDown() // Unblock the waiting thread.
                        }
                    }

                    DrawFrame.visible = true
                    drawFrameInstance = Some(DrawFrame)
                } // end of onEDT

                try {
                    println("[DEBUG] GUI thread waiting for window to close.")
                    guiClosedLatch.await()
                } catch {
                    case e: InterruptedException => Thread.currentThread().interrupt()
                }
                println("[DEBUG] GUI thread is now finished.")
            }

            println("[DEBUG] Waiting GUI exiting .... ")
            gui.join()
            println("[DEBUG] GUI has exited cleanly. Application will now terminate.")

        }
    } // end of launchGUi

  test("Test Raster Bar - ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      //dut.clockDomain.forkStimulus(10)   // 10ns ==> 100
      dut.coreClockDomain.forkStimulus(4 ns)
      dut.vgaClockDomain.forkStimulus(10 ns)

      dut.io.softRest #= true
      //SimTimeout(10000000) // adjust timeout as needed

      SimTimeout(20 ms)

      dut.vgaClockDomain.waitSampling(20)
      dut.vgaClockDomain.forkSimSpeedPrinter()

      FlowMonitor(dut.vga.pixel_debug, dut.vgaClockDomain) { payload =>
        obs_mem.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      dut.vgaClockDomain.waitSampling()
      dut.io.softRest #= false

      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 1st frame has been started now !")
      dut.vgaClockDomain.waitSampling(10)
      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 2nd frame has been started and then stop sim now !")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      GuiHelper.launchGui()

      println("simTime : " + simTime())
      simSuccess()

    }
  }

}