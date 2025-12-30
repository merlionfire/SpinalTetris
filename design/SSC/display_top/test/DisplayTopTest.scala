package SSC.display_top

import SSC.tetris_core.tetris_core
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


class DisplayTopTest extends AnyFunSuite {

  // ***************************************
  //  CUSTOM CODE BEGIN
  // ***************************************

  val debugMode : Boolean =  false   // True : drive each draw engines signals instead of FSM ( default )
  // ***************************************
  //  CUSTOM CODE END
  // ***************************************
  //val compiler : String = "verilator"
  val compiler : String = "vcs"
  val runFolder : String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SSC", targetName = "sim").toString
  val workFolder = runFolder+"/"+compiler

  val memory_model : String  = compiler match  {
    case "verilator" => "RAMB16_S9_VERILATOR.v"
    case "vcs" => "RAMB16_S9.v"
  }


  val xilinxPath = System.getenv("XILINX")

  println("[DEBUG] xilinxPath = " + xilinxPath)

  var drawFrameInstance: Option[MainFrame] = None

  val expectedData, receivedData = ArrayBuffer[Int]()
  val receivedHitStatus = mutable.Queue[Boolean]()
  var obs_mem = mutable.Queue[(Int, Int, Int)]()

  val shift_mem = mutable.Queue[ArrayBuffer[BigInt]]()

  val  config = DisplayTopConfig(offset_x = 32 )

  lazy val compiled: SimCompiled[display_top] = runSimConfig(runFolder, compiler)
    .addRtl(s"${xilinxPath}/glbl.v")
    .addRtl(s"${xilinxPath}/unisims/${memory_model}")
    //.addRtl("design/utils/ascii_font16x8.v")
    .withTimeScale( 1 ns)
    .withTimePrecision(10 ps)
    .compile {
      val c = new display_top( config,debugMode)
      c.vga.pixel_debug.simPublic()
      c.vga.vga_sync.io.sof.simPublic()
      c.core.draw_controller.setup_fsm.fsm_debug.simPublic()
      c
    }

  import config.pfConfig._

  object GuiHelper {
    def vga4BitTo8Bit(color : ( Int, Int, Int) ): Int = {
      // Scale the 4-bit value (0-15) to the 8-bit range (0-255)
      // Multiplying by 17 (255 / 15 is approximately 17) often works well for this.
      // (value & 0xF) * 17
      // Alternatively, you can also try bit shifting and replication:
      // (value & 0xF) | ((value & 0xF) << 4)
      val r = color._1 | color._1 << 4
      val g = color._2 | color._2 << 4
      val color8bit = List( color._1, color._2,color._3 ).map(  x => x | ( x << 4 ))
      color8bit(0) << 16 | color8bit(1) << 8 | color8bit(2)

    }

    def launchGui( imageTitle : String = "VGA Display Example" )  = {
      // A CountDownLatch is a reliable way to have one thread wait for another.
      // We initialize it to 1, meaning we're waiting for one event to happen.
      val guiClosedLatch = new CountDownLatch(1)
      val imageFile = s"${runFolder}/${compiler}/${imageTitle.replace(" ", "_")}.png"

      val gui = fork {
        // All Swing UI code must run on the Event Dispatch Thread (EDT).
        // Swing.onEDT ensures this.
        Swing.onEDT {
          // Drawing after simulation
          object DrawFrame extends MainFrame {
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
  }
  def config_char( dut:display_top,  x : Int, y : Int ,  value : Int, color : Int = 6, scale : Int = 1  ) {
    dut.coreClockDomain.waitSampling(2)
    dut.io.debug.draw_x_orig #= x
    dut.io.debug.draw_y_orig #= y
    dut.io.debug.draw_char_word #= value
    dut.io.debug.draw_char_scale #= scale-1
    dut.io.debug.draw_char_color #= color
    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_char_start #= true
    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_char_start #= false

    dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
    dut.io.debug.draw_x_orig #= 0
    dut.io.debug.draw_y_orig #= 0
    dut.coreClockDomain.waitSampling()
  }

  def config_block( dut : display_top, x : Int, y : Int ,  width : Int , height : Int, color : Int, pat_color : Int, fill_pattern : Int = 0  ) {
    dut.coreClockDomain.waitSampling(2)
    dut.io.debug.draw_x_orig #= x
    dut.io.debug.draw_y_orig #= y
    dut.io.debug.draw_block_width #= width-1
    dut.io.debug.draw_block_height #= height-1
    dut.io.debug.draw_block_in_color #= color
    dut.io.debug.draw_block_pat_color #= pat_color
    dut.io.debug.draw_block_fill_pattern #= fill_pattern

    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_block_start #= true
    dut.coreClockDomain.waitSampling()
    dut.io.debug.draw_block_start #= false
    dut.coreClockDomain.waitSampling(2)

    dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
    dut.io.debug.draw_x_orig #= 0
    dut.io.debug.draw_y_orig #= 0
    dut.coreClockDomain.waitSampling()

  }

  def init(dut:display_top): Unit = {
    dut.io.softRest #= false
    dut.io.game_restart #= false
    dut.io.row_val.valid #= false
    dut.io.score_val.valid #= false
    if (debugMode) {
      dut.io.debug.draw_char_start #= false
      dut.io.debug.draw_block_start #= false

      dut.io.debug.draw_x_orig #= 0
      dut.io.debug.draw_y_orig #= 0
   } else {
      dut.io.game_start #= false

   }
  }


  def createScreenImg () = {
    def vga4BitTo8Bit(color : ( Int, Int, Int) ): Int = {
      // Scale the 4-bit value (0-15) to the 8-bit range (0-255)
      // Multiplying by 17 (255 / 15 is approximately 17) often works well for this.
      // (value & 0xF) * 17
      // Alternatively, you can also try bit shifting and replication:
      // (value & 0xF) | ((value & 0xF) << 4)
      val r = color._1 | color._1 << 4
      val g = color._2 | color._2 << 4
      val color8bit = List( color._1, color._2,color._3 ).map(  x => x | ( x << 4 ))
      color8bit(0) << 16 | color8bit(1) << 8 | color8bit(2)

    }

    val width = config.xWidth
    val height = config.yWidth

    // Define the output directory
    val outputDirName = "screenShotsnap"
    val outputDir = new File(s"${workFolder}/${outputDirName}")

    // Create the directory if it doesn't exist
    if (!outputDir.exists()) {
      if (outputDir.mkdir()) {
        println(s"Created directory: ${outputDir.getAbsolutePath}")
      } else {
        // Handle the case where directory creation fails (e.g., permissions)
        println(s"[Error] Failed to create directory: ${outputDir.getAbsolutePath}. Images might not be saved.")
      }
    }

    var idx = 0
    while ( obs_mem.length >= ( 640 * 480 )   ) {
      println(s"Start to generate screen image : ${idx}")
      val img = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)

      for (y <- 0 until height) {
        for (x <- 0 until width) {
          val rgb = obs_mem.dequeue()
          img.setRGB(x, y, vga4BitTo8Bit(rgb))
        }
      }

      val g = img.createGraphics()
      val image_file_name:String = s"screen_640x480_${idx}.png"
      g.dispose()
      val outputFile = new File(outputDir, image_file_name)
      ImageIO.write(img, "png", outputFile)
      println(s"Image saved to ${outputFile.getAbsolutePath}")
      idx = idx + 1

    }

    if ( obs_mem.nonEmpty ) {
      println(f"[Error] obs_mem is NOT empty and number of the remaining items : ${obs_mem.size}")
    }

  }

  test("Test char and block - ") {

    assert(
      debugMode == true,
      s"\n this test needs dut in debug mode where interfaces of draw_char_engine and draw_block_engine are exposed to dut interface"
    )

    compiled.doSimUntilVoid(seed = 42) { dut =>

      //dut.clockDomain.forkStimulus(10)   // 10ns ==> 100
      dut.coreClockDomain.forkStimulus(4 ns)
      dut.vgaClockDomain.forkStimulus(10 ns)

      init(dut)

      //SimTimeout(10000000) // adjust timeout as needed

      SimTimeout(20 ms)

      dut.vgaClockDomain.waitSampling(20)
      dut.vgaClockDomain.forkSimSpeedPrinter()


      FlowMonitor(dut.vga.pixel_debug, dut.vgaClockDomain) { payload =>
        obs_mem.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      dut.vgaClockDomain.waitSampling(20)
      dut.io.softRest #= false


      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 1st frame has been started now !")

      config_char(dut, 0,0, 0x41, scale=2)

      for ( i <- 1 to 16 ) {
        println("@" + simTime() + "  :  " + i )
        //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
        config_block(dut, 10+(i*16), 20, i, i,  ( i ) % 16 , ( i  +1) % 16,  fill_pattern=1)
      }

      for ( i <- 1 to 16 ) {
        //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
        config_block(dut, 10+(i*16), 80, i, i*2,  ( i ) % 16 , ( i  +1) % 16, fill_pattern = 2)
      }

      for ( i <- 1 to 16 ) {
        //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
        config_block(dut, 10+(i*16), 160, i, i*3,  ( i ) % 16 , ( i ) % 16,  fill_pattern = 3 )
      }


      dut.vgaClockDomain.waitSampling(10)
      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 2nd frame has been started and then stop sim now !")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      GuiHelper.launchGui(imageTitle="Draw char and block")

      println("simTime : " + simTime())
      simSuccess()


    }
  }


  test("Test Tetris Opening Image  - ") {

    assert(
      debugMode == true,
      s"\n this test needs dut in debug mode where interfaces of draw_char_engine and draw_block_engine are exposed to dut interface"
    )

    compiled.doSimUntilVoid(seed = 42) { dut =>
      //dut.clockDomain.forkStimulus(10)   // 10ns ==> 100
      dut.coreClockDomain.forkStimulus(4 ns)
      dut.vgaClockDomain.forkStimulus(10 ns)

      init(dut)


      SimTimeout(10 ms)

      dut.vgaClockDomain.waitSampling(20)
      dut.vgaClockDomain.forkSimSpeedPrinter()


      FlowMonitor(dut.vga.pixel_debug, dut.vgaClockDomain) { payload =>
        obs_mem.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      dut.vgaClockDomain.waitSampling(20)
      dut.io.softRest #= false

      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 1st frame has been started now !")
      println("@" + simTime() + " Draw left wall")

      val (x, y, width, margin) = (15, 60, 50, 18)

      "Tetris".map(_.toByte).zipWithIndex.foreach { case (c, i) =>
          println(s"[DEBUG] @${simTime()} <$i> $c")
          config_char(dut, x + i * width + margin, y, c, scale = 3 )
          //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)

      }


      dut.vgaClockDomain.waitSampling(10)
      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 2nd frame has been started and then stop sim now !")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      GuiHelper.launchGui("Tetris Opening String Demo")

      println("simTime : " + simTime())
      simSuccess()

    }
  }


  test("Test Tetris Layout - wall and score demo") {

    assert(
      debugMode == true,
      s"\n this test needs dut in debug mode where interfaces of draw_char_engine and draw_block_engine are exposed to dut interface"
    )

    compiled.doSimUntilVoid(seed = 42) { dut =>

      // true : use piece_draw_engine to draw playfield
      // false : draw block by block via draw_block_engin
      val drawAllFieldByEngine =  false //

      dut.coreClockDomain.forkStimulus(4 ns)
      dut.vgaClockDomain.forkStimulus(10 ns)

      init(dut)

      SimTimeout(50 ms) // adjust timeout as needed

      //SimTimeout(10 ms)

      dut.vgaClockDomain.waitSampling(20)
      dut.vgaClockDomain.forkSimSpeedPrinter()


      FlowMonitor(dut.vga.pixel_debug, dut.vgaClockDomain) { payload =>
        obs_mem.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      dut.vgaClockDomain.waitSampling(20)
      dut.io.softRest #= false


      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 1st frame has been started now !")
      println("@" + simTime() + " Draw left wall" )
      config_block(dut, x_orig, y_orig,  wall_width, wall_height, 0, 15, fill_pattern=3)



      println("@" + simTime() + " Draw right wall" )
      //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
      val rightWallOrig = getRightWallOrig
      config_block(dut, rightWallOrig._1, rightWallOrig._2,  wall_width, wall_height, 0, 15, fill_pattern=3)


      println("@" + simTime() + " Draw base " )
      //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
      val baseOrig = getBaseOrig
      config_block(dut, baseOrig._1, baseOrig._2,  base_width, base_height, 0, 15, fill_pattern=3)

      //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)

      println("@" + simTime() + " Draw blocks " )


      val blocks_array = for {
        row <- 0 until  rowBlocksNum
        col <- 0 until colBlocksNum
        draw_on = if ( row == 0 || row == (bottomRow-1) || col == 0 || col==(colBlocksNum-1)  )  {
           true
        } else {
           Random.nextDouble() < 0.2
        }
        //if ( draw_on)
      } yield (row, col, draw_on)

      if ( drawAllFieldByEngine ) {
        println(f"[DEBUG] @${simTime()} Start to send playfield to piece_draw_engine !")

        val a = blocks_array.map(_._3).sliding(10,10).toList
        val b = a.map { x =>   /* convert 10 bits in same row to Int */
          val row_value = x.zipWithIndex.foldLeft(0)( (acc, y)  =>
            if ( y._1 ) acc | 1<< y._2
            else  acc )
          row_value
        }

        b.foreach {  x =>  /* drive DUT by row_val stream */
          dut.coreClockDomain.waitSampling()
          println(s"[DEBUG] @${simTime()} Drive data = $x ")
          dut.io.row_val.valid #= true
          dut.io.row_val.payload #= x
        }
        dut.coreClockDomain.waitSampling()
        dut.io.row_val.valid #= false

        println(f"[DEBUG] @${simTime()} All playfield status has been sent. Be waiting for they being stored into FrameBuffer !")
        dut.coreClockDomain.waitSampling(10)
        dut.coreClockDomain.waitSamplingWhere(dut.io.draw_field_done.toBoolean)
      } else {
        blocks_array.filter( _._3 ).map(
          pos => (pos._2 * block_len + x_orig + wall_width, pos._1 * block_len + y_orig)
        ).foreach { case (x, y) =>
          config_block(dut, x, y, block_len, block_len, 10, 11, fill_pattern = 0)
          //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
        }
      }

      val split_x = 200
      val split_y = 10


      config_block(dut, split_x, split_y, 2, 222, 15, 14, fill_pattern = 0)

      val score_string_x = split_x + 14
      val score_string_y = split_y + 12
      val score_x = score_string_x + 8
      val score_y = score_string_y + 22

      //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)
      "Score".map(_.toByte).zipWithIndex.foreach { case (c, i) =>
        println(s"[DEBUG] @${simTime()} <$i> $c")
        config_char(dut,  score_string_x + i * 12  , score_string_y, c, color =6, scale = 1 )
        //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)

      }


      "234".map(_.toByte).zipWithIndex.foreach { case (c, i) =>
        println(s"[DEBUG] @${simTime()} <$i> $c")
        config_char(dut,  score_x + i * 12  , score_y, c, color =3, scale = 2 )
        //dut.coreClockDomain.waitSamplingWhere(dut.io.draw_done.toBoolean)

      }



      dut.vgaClockDomain.waitSampling(10)
      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 2nd frame has been started and then stop sim now !")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      GuiHelper.launchGui("Tetris Layout Demo")

      println("simTime : " + simTime())
      simSuccess()


    }
  }

  test("Test Tetris Openning Screeen - ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      require(!debugMode, "<debugMode> must be false because this test uses draw_fsm to drawn screen" )
      dut.coreClockDomain.forkStimulus(4 ns)
      dut.vgaClockDomain.forkStimulus(10 ns)

      init(dut)

      SimTimeout(20 ms) // adjust timeout as needed

      //SimTimeout(10 ms)

      dut.vgaClockDomain.waitSampling(10)
      dut.vgaClockDomain.forkSimSpeedPrinter()



      dut.vgaClockDomain.waitSampling(20)
      dut.io.softRest #= false


      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 1st frame has been started now !")

      println("@" + simTime() + " Draw Openning Screen" )
      dut.coreClockDomain.waitSampling()

      // Customize code
      dut.coreClockDomain.waitSamplingWhere(dut.core.draw_controller.setup_fsm.fsm_debug.toInt == 4    )  /* WAIT_GAME_START */

      dut.coreClockDomain.waitSampling(10)
      dut.io.game_start #= true
      dut.coreClockDomain.waitSampling(10)
      dut.io.game_start #= false
      // Customize code
      dut.coreClockDomain.waitSamplingWhere(dut.core.draw_controller.setup_fsm.fsm_debug.toInt == 11   ) /* DRAW_SCORE */

      // Testing Piece draw

      dut.io.score_val.valid #= true
      dut.io.score_val.payload #= 987
      dut.coreClockDomain.waitSampling()
      dut.io.score_val.valid #= false
      dut.coreClockDomain.waitSampling(20)


      val blocks_array = for {
        row <- 0 until  rowBlocksNum
        col <- 0 until colBlocksNum
        draw_on = if ( row == 0 || row == (bottomRow-1) || col == 0 || col==(colBlocksNum-1)  )  {
          true
        } else {
          Random.nextDouble() < 0.2
        }
        //if ( draw_on)
      } yield (row, col, draw_on)

      println(f"[DEBUG] @${simTime()} Start to send playfield to piece_draw_engine !")

      val a = blocks_array.map(_._3).sliding(10,10).toList
      val b = a.map { x =>   /* convert 10 bits in same row to Int */
        val row_value = x.zipWithIndex.foldLeft(0)( (acc, y)  =>
          if ( y._1 ) acc | 1<< y._2
          else  acc )
        row_value
      }

      b.foreach {  x =>  /* drive DUT by row_val stream */
        dut.coreClockDomain.waitSampling()
        println(s"[DEBUG] @${simTime()} Drive data = $x ")
        dut.io.row_val.valid #= true
        dut.io.row_val.payload #= x
      }
      dut.coreClockDomain.waitSampling()
      dut.io.row_val.valid #= false

      println(f"[DEBUG] @${simTime()} All playfield status has been sent. Be waiting for they being stored into FrameBuffer !")
      dut.coreClockDomain.waitSampling(10)
      dut.coreClockDomain.waitSamplingWhere(dut.io.draw_field_done.toBoolean)


      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 2nd frame has been started and then stop sim now !")


      FlowMonitor(dut.vga.pixel_debug, dut.vgaClockDomain) { payload =>
        obs_mem.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      dut.vgaClockDomain.waitSamplingWhere(dut.vga.vga_sync.io.sof.toBoolean)
      println(f"[DEBUG] @${simTime()} The 3nd frame has been started and then stop sim now !")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      GuiHelper.launchGui("game_openning_image.png")

      println("simTime : " + simTime())
      simSuccess()


    }
  }

  test("Test : Stimulate that game fails and then screen is cleared ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      require(!debugMode, "<debugMode> must be false because this test uses draw_fsm to drawn screen")
      dut.coreClockDomain.forkStimulus(4 ns)
      dut.vgaClockDomain.forkStimulus(10 ns)

      init(dut)

      SimTimeout(20 ms) // adjust timeout as needed

      FlowMonitor(dut.vga.pixel_debug, dut.vgaClockDomain) { payload =>
        obs_mem.enqueue((payload.r.toInt, payload.g.toInt, payload.b.toInt))
      }

      dut.vgaClockDomain.waitSampling(10)
      // Customize code
      dut.coreClockDomain.waitSamplingWhere(dut.core.draw_controller.setup_fsm.fsm_debug.toInt == 4    )  /* WAIT_GAME_START */

      dut.coreClockDomain.waitSamplingWhere(dut.io.sof.toBoolean)
      dut.io.game_start #= true
      dut.coreClockDomain.waitSampling(10)
      dut.io.game_start #= false

      // Wait a new Frame
      dut.coreClockDomain.waitSamplingWhere(dut.io.sof.toBoolean)
      dut.vgaClockDomain.waitSampling(10)

      // Assert input softReset
      dut.io.game_restart #= true
      dut.coreClockDomain.waitSampling(10)
      dut.io.game_restart #= false

      // Wait a new Frame
      dut.coreClockDomain.waitSamplingWhere(dut.io.sof.toBoolean)
      println("[DEBUG] doSim is exited !!!")
      println("simTime : " + simTime())
      createScreenImg ()
      simSuccess()

    }
  }


}
