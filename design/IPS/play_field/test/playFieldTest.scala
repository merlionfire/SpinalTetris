package IPS.play_field

import spinal.core._
import spinal.core.sim.{SimCompiled, _}
import config._
import org.scalatest.funsuite.AnyFunSuite
import spinal.lib.sim.FlowMonitor
import utils.PathUtils

import scala.collection.mutable
import scala.util.Random
import scala.collection.mutable.ArrayBuffer
import java.awt.{BasicStroke, Color, Font, Graphics2D}
import java.awt.image.BufferedImage
import java.io.File
import java.util.concurrent.CountDownLatch
import javax.imageio.ImageIO
import javax.swing.WindowConstants
import scala.swing._
import scala.swing.event._


class playFieldTest extends AnyFunSuite  {


  var compiler : String = "verilator"
  //val compiler : String = "vcs"

  val runFolder : String = PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString


  var drawFrameInstance: Option[MainFrame] = None
  val expectedData, receivedData = ArrayBuffer[Int]()
  val receivedHitStatus = mutable.Queue[Boolean]()
  val receivedRowValue = mutable.Queue[Int]()


  val rowNum: Int = 23 // include bottom wall
  val colNum: Int = 12 // include left and right wall

  val rowBitsWidth = log2Up(rowNum)
  val colBitsWidth = log2Up(colNum)
  val rowBlocksNum = rowNum - 1 // working field for Tetromino
  val colBlocksNum = colNum - 2 // working field for Tetromino

  val config = PlayFieldConfig(
    rowBlocksNum = rowBlocksNum,
    colBlocksNum = colBlocksNum,
    rowBitsWidth = rowBitsWidth,
    colBitsWidth = colBitsWidth
  )


  val memory = ArrayBuffer.fill[BigInt](rowBlocksNum)(0)
  var obs_mem = ArrayBuffer[BigInt]()
  val shift_mem = mutable.Queue[ArrayBuffer[BigInt]]()

  //test("compile") {
  lazy val compiled : SimCompiled[play_field]  = runSimConfig(runFolder, compiler)
    .compile {
      val c = new play_field(config)
      c.rowsblocks.simPublic()
      c.rows_full.simPublic()
      c.clear.simPublic()
      c.shift.simPublic()
      c
    }
  //}

  def init(dut: play_field): Unit = {
    dut.clockDomain.waitSampling()
    //dut.io.shift #= false
    //dut.io.block_set #= true
    setLong(dut.io.block_set,1)
    dut.io.fetch #= false
    dut.io.update #= false
    dut.io.clear_start #= false
    dut.io.block_set #= false
    dut.io.restart #= false
    //dut.io.lock  #= false
    //dut.io.enable_rows #= false
    dut.clockDomain.waitSampling()
  }

  def initPlayField(dut: play_field, a: ArrayBuffer[Int]): Unit = {
    dut.io.block_set #= true
    dut.clockDomain.waitSampling()
    dut.io.update #= true


    for {row <- 0 until rowBlocksNum
         col <- 1 to colBlocksNum
         if (a(row) & (1 << (col - 1))) != 0} {
      //setBigInt(dut.mem, row, a(row) )
      dut.clockDomain.waitSampling()
      dut.io.block_pos.valid #= true
      dut.io.block_pos.y #= row
      dut.io.block_pos.x #= col
      println(f"[DEBUG][Initialization] <${col}%2d, ${row}%2d>")
      dut.clockDomain.waitSampling()
      dut.io.block_pos.valid #= false
      dut.io.block_pos.payload.randomize()
    }
    dut.clockDomain.waitSampling(6)
    dut.io.update #= false
    dut.io.block_set #= false
  }

  // At least 4 blocks are occupied
  def randomWithAtLeast4Ones(bitWidth: Int = 10): Int = {
    require(bitWidth >= 4, "bitWidth must be at least 4")

    val random = new Random()
    var value = 0

    while (value.toBinaryString.count(_ == '1') < 4) {
      value = random.nextInt(1 << bitWidth)
      value |= (1 << random.nextInt(bitWidth)) // Set at least one bit to 1
    }

    value
  }


  def setPlayFieldByRow(dut: play_field, row: Int, value: Int): Unit = {
    println(f"[DEBUG][Update] \tMem[${row}%2d] <= b" + value.toInt.toBinaryString)
    dut.clockDomain.waitSampling()
    dut.io.update #= true
    dut.io.block_set #= true
    memory(row) = value
    for (col <- 1 to colBlocksNum if ((value & (1 << (col - 1))) != 0)) {
      dut.clockDomain.waitSampling()
      dut.io.block_pos.valid #= true
      dut.io.block_pos.y #= row
      dut.io.block_pos.x #= col
    }
    dut.clockDomain.waitSampling()
    dut.io.block_pos.valid #= false
    dut.clockDomain.waitSampling()
    dut.io.update #= false
    dut.io.block_set #= false
    dut.clockDomain.waitSampling()
  }

  // rowsHavePieces : num of rows pieces are resident in from bottom.
  //                  It stimulates real scenario where pieces are stacked from the bottom
  def createPlayField(dut: play_field, rowsHavePieces: Int = 0, isRandom: Boolean = true): Unit = {

    // Clear all blocks in play field
    dut.io.restart #= true
    dut.clockDomain.waitSampling(2)
    dut.io.restart #= false
    dut.clockDomain.waitSampling(2)


    for (i <- 1 to rowsHavePieces if rowsHavePieces != 0) {

      //val rowValue = Random.nextInt(1<< (colBlocksNum-2) + 4 )

      val rowValue = if (isRandom) randomWithAtLeast4Ones() else (1 << colBlocksNum - 1)
      setPlayFieldByRow(dut, rowBlocksNum - i, rowValue)

    }

    dut.clockDomain.waitSampling()
    dut.io.block_pos.valid #= false
    dut.io.block_pos.payload.randomize()
    dut.clockDomain.waitSampling(2)
    dut.io.update #= false
    dut.io.block_set #= false
    dut.clockDomain.waitSampling(2)
    //setBigInt(dut.play_field.mem, bottomRow, BigInt("000000000000111111111111", 2) )
  }

  def createPlayFieldWithFullOccupiedRows(dut: play_field, rowsFullOccupied: Int = 1): Unit = {

    val allOne = (1 << colBlocksNum) - 1
    createPlayField(dut, rowBlocksNum) // fill all rows by random blocks
    setPlayFieldByRow(dut, rowBlocksNum - 1, allOne)
    setPlayFieldByRow(dut, 4, allOne)
    setPlayFieldByRow(dut, 12, allOne)
  }

  def readPlayFieldBackDoor(dut: play_field): ArrayBuffer[BigInt] = {
    //dut.clockDomain.waitSampling(1)
    //dut.io.enable_rows #= true
    val ret = ArrayBuffer[BigInt]()
    for (a <- dut.rowsblocks) {
      println("[DEBUG] Read Mem = b" + a.toInt.toBinaryString)
      ret += a.toBigInt
    }
    //dut.clockDomain.waitSampling()

    ret

  }


  def drawPlayField( g: Graphics2D, allBlocks : ArrayBuffer[BigInt],  x_origin : Int, y_origin : Int  ) = {


    val blockSize = 30
    val padding = 2
    val t_step = 250

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
    def launchGui( imageTitle : String = "" )  = {
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

            title = imageTitle
            // 1. Take full control of the close operation.
            // This ensures that clicking 'X' ONLY fires the WindowClosing event.
            peer.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE)

            preferredSize = new Dimension(2000, 1000)
            val blockSize = 30
            val padding = 0
            val t_step = 250
            val (x_origin, y_origin) = (100, 100)

            val width = ( shift_mem.size + 4 )  * blockSize * colNum

            contents = new Panel {
              preferredSize = new Dimension(width + 200 , 1000)
              private var cachedImage: Option[BufferedImage] = None


              // Create a simple image
              def createImage(): BufferedImage = {
                val img = new BufferedImage(  width , 900, BufferedImage.TYPE_INT_RGB)
                val g = img.createGraphics()

                g.setColor(java.awt.Color.WHITE)
                g.fillRect(0, 0, img.getWidth, img.getHeight)

                drawPlayField(g, memory, x_origin, y_origin)

                drawPlayField(g, obs_mem, x_origin + colNum * (blockSize + 4), y_origin)

                var x_pos = x_origin + 2 * colNum * (blockSize + 4)
                val x_step = (colNum + 3)  * blockSize

                while (shift_mem.nonEmpty) {
                  drawPlayField(g, shift_mem.dequeue(), x_pos, y_origin)
                  x_pos += x_step
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

  test("usecase 1 - random fill all pixel and read-back check") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      dut.clockDomain.forkStimulus(10)
      SimTimeout(10 * 5000) // adjust timeout as needed
      dut.clockDomain.waitSampling(20)

      init(dut)


      for (_ <- 0 until rowBlocksNum) {
        expectedData += Random.nextInt(1 << colBlocksNum)
      }
      initPlayField(dut, expectedData)

      dut.clockDomain.waitSampling(20)

      val inputThread = fork {
        for {row <- 0 until rowBlocksNum
             col <- 1 to colBlocksNum
             } {
          dut.clockDomain.waitSampling(Random.nextInt(5) + 1)
          dut.io.block_pos.valid #= true
          dut.io.block_pos.y #= row
          dut.io.block_pos.x #= col
          println(f"[DEBUG] <${col}%2d, ${row}%2d>")
          dut.clockDomain.waitSampling()
          dut.io.block_pos.valid #= false
          dut.io.block_pos.payload.randomize()
        }
      }

      var response_idx = 0
      /* Monitor output stream */
      FlowMonitor(dut.io.block_val, dut.clockDomain) { payload =>
        println(f"[DEBUG MON] <$response_idx>  @${simTime()}")
        receivedHitStatus.enqueue(payload.toBoolean)
        response_idx += 1
      }

      inputThread.join()
      dut.clockDomain.waitSampling(20)

      for (row <- 0 until rowBlocksNum) {
        var row_val = 0
        for (col <- 0 until colBlocksNum) {
          row_val = row_val | (receivedHitStatus.dequeue().toInt << col)
        }
        receivedData += row_val
      }

      println("")
      println("\t\t    Recieved\tExpected\tresult")
      for (i <- 0 until rowBlocksNum) {
        print(f"\t\t<$i%2d> : ${receivedData(i)}%4d  : \t${expectedData(i)}%4d\t")
        println(if (receivedData(i) == expectedData(i)) "Pass" else "Fail")
      }
      dut.clockDomain.waitSampling(20)
      simSuccess() // Simulation success after sending pieces
    }
  }


  test("usecase 2 - clear row and followed by shift ") {


    compiled.doSimUntilVoid(seed = 42) { dut =>
      //  compiled.doSim(seed = 42) { dut =>

      dut.clockDomain.forkStimulus(10)
      SimTimeout(20 * 5000) // adjust timeout as needed
      dut.clockDomain.waitSampling(20)

      init(dut)


      dut.clockDomain.waitSampling(10)
      createPlayFieldWithFullOccupiedRows(dut, 2)
      dut.clockDomain.waitSampling(10)

      println("[DEBUG] play field has been initialized as follows ... ")
      for ((value, row) <- memory.zipWithIndex) {
        println(f"[DEBUG] [Pre-clear] \tMem[${row}%2d] = b" + value.toInt.toBinaryString)
      }


      //*************************************************************
      //        Before Clear stage
      //*************************************************************

      /** Monitor rows_full status from all rows with all-1s **/
      //dut.io.enable_rows #= true
      dut.clockDomain.waitSampling(1)
      dut.io.clear_start #= true
      dut.clockDomain.waitSampling(2)
      dut.io.clear_start #= false
      println(f"[DEBUG] [Pre-clear] @${simTime()} rows with all 1 = b" + dut.rows_full.toInt.toBinaryString)
      val indxOfRows = dut.rows_full.toInt.toBinaryString.reverse.zipWithIndex.filter(a => a._1 == '1').map(a => a._2)

      println("[DEBUG] [Pre-clear] " + indxOfRows)


      //*************************************************************
      //        Clear all-1s row
      //*************************************************************

      /** Monitor rows_full status from all rows with all-1s **/
      dut.clockDomain.waitSamplingWhere(dut.clear.toBoolean)
      //dut.clockDomain.waitSampling(1)
      println(f"[DEBUG] [After-clear] @${simTime()}  rows with all 1 = b" + dut.rows_full.toInt.toBinaryString.padTo(colBlocksNum, '0'))


      /** read all row valuess via backdoor -> obs_left_mem **/
      obs_mem = readPlayFieldBackDoor(dut)
      for ((value, row) <- obs_mem.zipWithIndex) {
        println(f"[DEBUG] [After-clear] @${simTime()} \tMem[${row}%2d] = b" + value.toInt.toBinaryString)
      }


      /** Shift Stage **/
      dut.clockDomain.waitSamplingWhere(dut.shift.toBoolean)
      while ( dut.shift.toBoolean ) {
        println(f"[DEBUG] [Shift] @${simTime()}")
        shift_mem.enqueue(readPlayFieldBackDoor(dut))
        dut.clockDomain.waitSampling(1)
      }

      dut.clockDomain.waitSamplingWhere(dut.io.clear_done.toBoolean)
      dut.clockDomain.waitSampling(10)
      println("[DEBUG] doSim is exited !!!")

      //*************************************************************
      //        GUI Entry Point
      //*************************************************************
      GuiHelper.launchGui("Row Clean followed by Shift")

      println("simTime : " + simTime())
      simSuccess()


    }

  }

  test("usecase 3 - fetch all rows of seqeunce status") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      dut.clockDomain.forkStimulus(10)
      SimTimeout(10 * 5000) // adjust timeout as needed
      dut.clockDomain.waitSampling(20)

      init(dut)

      for (_ <- 0 until rowBlocksNum) {
        expectedData += Random.nextInt(1 << colBlocksNum)
      }
      initPlayField(dut, expectedData)

      var response_idx = 0
      /* Monitor output stream */
      FlowMonitor(dut.io.row_val, dut.clockDomain) { payload =>
        println(f"[DEBUG MON] <$response_idx>  @${simTime()}")
        receivedRowValue.enqueue(payload.toInt)
        response_idx += 1
      }

      dut.clockDomain.waitSampling(20)
      dut.io.fetch #= true
      dut.clockDomain.waitSampling()
      dut.io.fetch #= false

      dut.clockDomain.waitSampling(400)


      println("")
      println("\t\t    Recieved\tExpected\tresult")
      for (i <- 0 until rowBlocksNum) {
        print(f"\t\t<$i%2d> : ${ receivedRowValue(i)}%4d  : \t${expectedData(i)}%4d\t")
        println(if ( receivedRowValue(i) == expectedData(i)) "Pass" else "Fail")
      }
      dut.clockDomain.waitSampling(20)
      simSuccess() // Simulation success after sending pieces
    }

  }

}
