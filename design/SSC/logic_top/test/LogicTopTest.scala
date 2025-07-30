package SSC.logic_top

import spinal.core._
import config.runSimConfig
import spinal.core.sim._
import org.scalatest.funsuite.AnyFunSuite
import utils.PathUtils

import IPS.play_field._

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import java.awt.{BasicStroke, Color, Font, Graphics2D}
import java.awt.image.BufferedImage
import java.io.File
import java.util.concurrent.CountDownLatch
import javax.imageio.ImageIO
import javax.swing.WindowConstants
import scala.swing._
import scala.swing.event._



class LogicTopTest extends AnyFunSuite {

  val rowNum : Int = 23   // include bottom wall
  val colNum :Int = 12    // include left and right wall
  val rowBlocksNum = rowNum - 1   // working field for Tetromino
  val colBlocksNum = colNum - 2   // working field for Tetromino
  val lastCol = colNum - 1   /* 0 and 11 are col index of left and right wall */
  val bottomRow = rowNum - 1

  val config = LogicTopConfig( rowNum, colNum )

  // ***************************************
  //  CUSTOM CODE END
  // ***************************************

  //val compiler : String = "verilator"
  val compiler : String = "vcs"

  val runFolder : String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SSC", targetName = "sim").toString
  lazy val compiled : SimCompiled[logic_top] = runSimConfig(runFolder, compiler)
    .compile {
      val c = new logic_top(config, test= true)  /* Test = true is ONLY for standalone DUT test */
      c.main_fsm_debug.simPublic()
      c.playfield_fsm_debug.simPublic()
      c.debug_move_type.simPublic()
      c.update.simPublic()
      c.score.total_score.simPublic()
      c.play_field.rowsblocks.simPublic()
      c.play_field.enable_rows.simPublic()
      c.play_field.io.update.simPublic()
      c.play_field.io.block_pos.simPublic()
      c
    }

  var obs_left_mem = mutable.Queue[ArrayBuffer[BigInt]]()
  type pos_type = ArrayBuffer[(Int, String, ArrayBuffer[BigInt], Int )]
  var obs_array : pos_type = ArrayBuffer()
  var drawFrameInstance: Option[MainFrame] = None
  var tOpArray = ArrayBuffer[  ArrayBuffer[(Int, String, ArrayBuffer[BigInt], Int )]  ] ()

  def init(dut: logic_top): Unit = {
    dut.clockDomain.waitSampling()
    dut.io.game_start #= false
    dut.io.move_left #= false
    dut.io.move_right #= false
    dut.io.move_down #= false
    dut.io.rotate #= false
    dut.io.screen_is_ready #= true
    dut.io.force_refresh #= true  // start refresh immediately
    dut.io.draw_field_done #= true // Simulate refresh done
    dut.clockDomain.waitSampling()
  }

  def readPlayFieldBackDoor(dut: play_field): ArrayBuffer[BigInt] = {
    dut.clockDomain.waitSampling()
    dut.enable_rows #= true
    dut.clockDomain.waitSampling(2)
    val ret = ArrayBuffer[BigInt]()
    for (a <- dut.rowsblocks) {
      println("[DEBUG] Read Mem = b" + a.toInt.toBinaryString)
      ret += a.toBigInt
    }
    dut.clockDomain.waitSampling()
    dut.enable_rows #= false
    ret

  }

  def drawPlayField( g: Graphics2D, allBlocks : ArrayBuffer[BigInt],  x_origin : Int, y_origin : Int  ) = {


    // Temp to reduce size for more blocks in single image
    //val blockSize = 30
    val blockSize = 20

    val padding = 2
    //val t_step = 250
    val t_step = 150

    def drawTetromino(g: Graphics2D, x: Int, y: Int, filled: Boolean): Unit = {

      if ( ! filled ) return

      val borderWidth = 1
      val padding = 1

      g.setStroke(new BasicStroke(borderWidth))

      g.setColor(new Color(255, 102, 88))
      g.fillRect(x + padding+1, y + padding+1, blockSize - 2 * padding, blockSize - 2 * padding)

    }


    val bs = new BasicStroke(1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_ROUND, 10.0f, Array[Float](10.0f, 5.0f), 0.0f)

    g.setColor(java.awt.Color.GRAY)
    g.setStroke(bs)

    var (t_x, t_y) = (x_origin, y_origin)
    for (cy <- 0 to rowBlocksNum) {
      g.drawLine(x_origin, y_origin + cy * blockSize, x_origin + colBlocksNum * blockSize, y_origin + cy * blockSize)
    }

    for (cx <- 0 to colBlocksNum) {
      g.drawLine(x_origin + cx * blockSize, y_origin, x_origin + cx * blockSize, y_origin + rowBlocksNum * blockSize)
    }


    val walls = ArrayBuffer[(Int, Int)]()

    for (cx <- List(-1, colBlocksNum); cy <- 0 until rowNum) {
      val a = ((x_origin + cx * blockSize), (y_origin + cy * blockSize))
      walls += a
    }

    for ( cx <- 0 until colBlocksNum )  {
      val a = ((x_origin + cx * blockSize), (y_origin + bottomRow * blockSize))
      walls += a
    }

    val borderWidth = 1

    // 1. Solid Color Interior with Black Border
    g.setColor(java.awt.Color.BLACK)
    g.setStroke(new BasicStroke(borderWidth))

    for ((x, y) <- walls) {
      g.drawRect(x, y, blockSize, blockSize) // Draw the border
    }

    g.setColor(new Color(153, 102, 0))
    g.setStroke(new BasicStroke(borderWidth))
    for ((x, y) <- walls) {
      g.drawRect(x+1, y+1, blockSize-2, blockSize-2) // Draw the border
    }

    g.setColor(new Color(102, 51, 0)) // Set interior color
    for ((x, y) <- walls) {
      g.fillRect(x + padding+1, y + padding+1, blockSize - 2 * padding, blockSize - 2 * padding) //
    }

    val patternImage = new BufferedImage(10, 10, BufferedImage.TYPE_INT_RGB)


    for ( rowValue <- allBlocks ) {
      t_x = x_origin
      for (col <- 0 until colBlocksNum ) { // Int has 32 bits
        val bit = (rowValue >> col ) & 1 // Unsigned right shift and bitwise AND
        drawTetromino(g, t_x, t_y, bit == 1 )
        t_x += blockSize
      }
      t_y += blockSize
    }


  }

  object GuiHelper {
    def launchGui(imageTitle : String = "")   = {

      val guiClosedLatch = new CountDownLatch(1)
      val imageFile = s"${runFolder}/${compiler}/${imageTitle.replace(" ", "_")}.png"

      val gui = fork {
        // All Swing UI code must run on the Event Dispatch Thread (EDT).
        // Swing.onEDT ensures this.
        Swing.onEDT {
          // Drawing after simulation
          object DrawFrame extends MainFrame {
            var closed = false

            title = imageTitle
            // 1. Take full control of the close operation.
            // This ensures that clicking 'X' ONLY fires the WindowClosing event.
            peer.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE)

            val blockSize = 30
            val padding = 0
            val t_step = 250
            val (x_origin, y_origin) = (200, 100)


            val N = 8
            val groupById = obs_array.groupBy(_._1).toSeq.sortBy(_._1)

            for ( (id, entities) <- groupById )  {
              entities.sliding(N,N).foreach{ a => tOpArray += a }

            }

            val width =  ( tOpArray.map(_.length).max  + 1 ) * blockSize * colNum + 500
            //val width = obs_array.map(_._2.length).max  * blockSize * colNum

            val height = ( 2 +  tOpArray.size ) * blockSize * rowNum

            preferredSize = new Dimension(width , height)
            contents = new Panel {
              preferredSize = new Dimension(width , height )
              private var cachedImage: Option[BufferedImage] = None


              // Create a simple image
              def createImage(): BufferedImage = {
                val img = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB)
                val g = img.createGraphics()

                g.setColor(java.awt.Color.WHITE)
                g.fillRect(0, 0, img.getWidth, img.getHeight)


                //drawPlayField(g, obs_left_mem, x_origin + colNum * (blockSize + 4), y_origin)

                //var x_pos = x_origin + 2 * colNum * (blockSize + 4)
                var x_pos = x_origin
                val x_step = (colNum + 3) * blockSize

                var y_pos = y_origin
                var y_step = blockSize * (rowNum + 1)

                var index = 0

                for (tRowArray <- tOpArray) {

                  for ((id, dir, obs_mem, score) <- tRowArray) {
                    g.setPaint(java.awt.Color.BLACK)
                    g.setFont(new Font("Arial", Font.BOLD, 16))

                    g.drawString(f"${dir}", (x_pos-100) , y_pos + 100)
                    g.drawString(f"(${id})", (x_pos-95) , y_pos + 120)
                    g.drawString(f"<${score}>", (x_pos-95) , y_pos + 140)
                    drawPlayField(g, obs_mem, x_pos, y_pos)
                    x_pos += x_step
                  }
                  x_pos = x_origin
                  y_pos += y_step

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

  val stateMap = Map(
    "I" -> 0,
    "J" -> 1,
    "L" -> 2,
    "O" -> 3,
    "S" -> 4,
    "T" -> 5,
    "Z" -> 6,
    "STANDBY" -> 0,
    "MOVE" -> 1,
    "CHECK" -> 2,
    "ERASE" -> 3,
    "UPDATE" -> 4,
    "STATUS" -> 7,
    "IDLE" -> 0,
    "GAME_START" -> 1,
    "RANDOM_GEN" -> 2,
    "PLACE" -> 3,
    "END" -> 4,
    "FALLING" -> 5,
    "LOCK" -> 6,
    "LOCKDOWN" -> 7,
    "PATTERN" -> 8
  )




  def waitForMainState(dut: logic_top, state : String ) = {
    println(f"@${simTime()} [DEBUG] Wait FSM state  : <$state> ...... ")
    dut.clockDomain.waitSamplingWhere(dut.main_fsm_debug.toInt == stateMap(state)  )
    println(f"@${simTime()} [DEBUG] State <$state> is active now ! ")
    dut.clockDomain.waitSampling(1)
  }

  def waitForSubState( dut: logic_top, state : String ) = {
    println(f"@${simTime()} [DEBUG] Wait FSM state  : <$state> ...... ")
    dut.clockDomain.waitSamplingWhere(dut.playfield_fsm_debug.toInt == stateMap(state)  )
    println(f"@${simTime()} [DEBUG] State <$state> is active now ! ")
    dut.clockDomain.waitSampling(1)
  }


  test("usecase <1> - transverse all states of FSM ") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      var id = 0
      var obs_mem = mutable.Queue[ArrayBuffer[BigInt]]()

      dut.clockDomain.forkStimulus(10)
      SimTimeout(0.5 ms) // adjust timeout as needed
      dut.clockDomain.waitSampling(20)

      init(dut)

      /* ********************************************************
              Monitor
      - Once playfield is updated,
        layout is read via backdoor and store to array with id and operation type of this block.
      ********************************************************** */


      val playfield_backdoor_monitor = fork {
        println(f"@${simTime()} [DEBUG] Thread playfield_backdoor_monitor is started ! ")

        while (true) {
          waitForSubState(dut, "UPDATE")
          waitForSubState(dut, "STATUS")

          val operation = dut.debug_move_type.toInt match {
            case 1 => "Left"
            case 2 => "Right"
            case 3 => "Down"
            case 4 => "Rotate"
            case 5 => "Drop"
            case 6 => "Place"
            case _ => "Nil"
          }
          //obs_array += ((id, operation, readPlayFieldBackDoor(dut.playfield_top_inst.play_field)))

          obs_array += ((id, operation, readPlayFieldBackDoor(dut.play_field), dut.score.total_score.toInt ))
        }

      }
      /* ********************************************************
              Monitor
      - It is for increasing id once a new block is created.
      ********************************************************** */

      val new_block_monitor = fork {
        while (true) {
          waitForMainState(dut, "PLACE")
          id += 1
          waitForMainState(dut, "FALLING")
        }
      }


      //===============================================
      // Monitor : game ending and display final result.
      //===============================================

      val game_end_monitor = fork {
        while (true) {
          waitForMainState(dut, "END")
          println("[DEBUG] Game finished !!!!. Final score : " + dut.score.total_score.toInt )
          dut.clockDomain.waitSampling(100)
          dut.io.game_start #= true
          waitForMainState(dut, "RANDOM_GEN")
          dut.io.game_start #= false
        }
      }

      //===============================================
      //    Start Game
      // ==============================================
      dut.clockDomain.waitSampling(4)
      dut.io.game_start #= true

      waitForMainState(dut, "MOVE")
      dut.clockDomain.waitSampling(1)


      obs_array += ((id, "orignal", readPlayFieldBackDoor(dut.play_field),dut.score.total_score.toInt ))


      def waitState(dut: logic_top, state: String) = {
        println(f"@${simTime()} [DEBUG] Wait FSM state  : <$state> ...... ")
        dut.clockDomain.waitSamplingWhere(dut.main_fsm_debug.toInt == stateMap(state))
        println(f"@${simTime()} [DEBUG] State <$state> is active now ! ")
        dut.clockDomain.waitSampling(1)
      }

      def waitSubState(dut: logic_top, state: String) = {
        println(f"@${simTime()} [DEBUG] Wait FSM state  : <$state> ...... ")
        dut.clockDomain.waitSamplingWhere(dut.playfield_fsm_debug.toInt == stateMap(state))
        println(f"@${simTime()} [DEBUG] State <$state> is active now ! ")
        dut.clockDomain.waitSampling(1)
      }


      def test_move(dir: String, steps: Int) = {

        for (_ <- 1 to steps) {
          //dut.clockDomain.waitSampling(1)
          waitSubState(dut, "MOVE")
          println(f"[DEBUG]  Try to move block to $dir ......  ")
          dir match {
            case "left" => dut.io.move_left #= true
            case "right" => dut.io.move_right #= true
            case "down" => dut.io.move_down #= true
            case "rotate" => dut.io.rotate #= true
            case _ => println(f"[ERROR]  dir = $dir is invalid and it must be left|right|down ! ")
          }
          waitSubState(dut, "STATUS")
          dir match {
            case "left" => dut.io.move_left #= false
            case "right" => dut.io.move_right #= false
            case "down" => dut.io.move_down #= false
            case "rotate" => dut.io.rotate #= false
            case _ => println(f"[ERROR]  dir = $dir is invalid and it must be left|right|down ! ")
          }
          dut.clockDomain.waitSampling(1)
        }
      }

      //===============================================
      //    Stimulate move control : left/right/rotate/down
      // ==============================================

      val moveSequences: Seq[Seq[(String, Int)]] = Seq(
        Seq(("left", 4), ("down", 2)),   /* T */
        Seq(("down", 2), ("left", 1)),   /* L */
        Seq(("down", 1), ("right", 2), ("right", 1)),  /* o */
        Seq(("down", 1), ("left", 3)),   /* Z */
        Seq(("down", 1), ("rotate", 1), ("left", 2)), /* S */
        Seq(("down", 1), ("rotate", 1)),   /* I */
        Seq(("rotate", 1), ("right", 2)),  /* J */  /* Clear <1> */
        Seq(("left", 4)),     /* O */
        Seq(("right", 2)),    /* Z */
        Seq(("rotate", 3)),   /* T */
        Seq(("rotate", 3), ("right", 4)), /* L */
        Seq(("down", 1), ("left", 1), ("down", 1)),  /* S */
        Seq(("rotate", 1), ("left", 7)),   /* I */  /* Clear <3> */
        Seq(("rotate", 1), ("down", 3)),   /* L */
        Seq(("down", 4)),  /* O */
        Seq(("rotate", 1 ), ("down", 4)),  /* Z */
        Seq(("rotate", 1 ), ("down", 4)),  /* T */
        Seq(("rotate", 1 ), ("down", 4)),  /* L */
        Seq(("down", 4)),   /* S */
        Seq(("down", 4)),
        Seq(("down", 4))
      )

      moveSequences.zipWithIndex.foreach { case( moves, index )  =>

        if (index !=0) waitState(dut, "PLACE")
        waitState(dut, "FALLING")
        moves.foreach{ case ( action, times) =>
          test_move(action, times)
        }

      }


      // Wait for new block is created and then stop
      waitState(dut, "PLACE")
      dut.clockDomain.waitSampling(20)



      println("[DEBUG] doSim is exited !!!")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      GuiHelper.launchGui("Piece generation and drop off")

      println("simTime : " + simTime())
      simSuccess()


    } // ned of compiled.doSumUnitlVoid
  }
}
