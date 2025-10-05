package SSC.checkers_playfield

import utils.PathUtils
import config._

import spinal.core._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.sim._
import spinal.lib.sim.{FlowMonitor, ScoreboardInOrder, StreamDriver, StreamMonitor, StreamReadyRandomizer}
import IPS.piece_checker.pieceSim

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import scala.util.Random

class CheckersPlayFieldTest  extends AnyFunSuite {

  val receivedHitStatus, expectedHitStatus = mutable.Queue[Boolean]()
  val detailed_result = new StringBuilder()
  val sentPieces = mutable.Queue[pieceSim]()

  // ***************************************
  //  CUSTOM CODE END
  // ***************************************
  val compiler : String = "verilator"
  //val compiler : String = "vcs"
  val runFolder : String = PathUtils.getRtlOutputPath(getClass, middlePath = "design/SSC", targetName = "sim").toString

  val rowNum : Int = 23   // include bottom wall
  val colNum :Int = 12    // include left and right wall

  val config =  CheckersPlayFieldConfig( rowNum, colNum)

  //test("compile") {
  lazy val compiled : SimCompiled[checkers_playfield] = runSimConfig(runFolder, compiler)
    .compile {
      val c = new checkers_playfield(config)
      c.play_field.io.block_pos.simPublic()
      c.play_field.io.block_val.simPublic()
      c.play_field.rowsblocks.simPublic()
      c
    }
  // }



  def init(dut: checkers_playfield ): Unit = {
    // Initialization
    dut.io.piece_in.`type` #= TYPE.T
    dut.io.piece_in.rot #= 1
    dut.io.piece_in.orign.x #= 0x0F
    dut.io.piece_in.orign.y #= 0x0F
    dut.io.piece_in.valid #= false
    dut.io.restart  #= false
    dut.io.update  #= false
    dut.io.clear_start  #= false
    //dut.io.enable_rows #= false
  }

  def initPlayfieldByAllZero(dut: checkers_playfield ): Unit = {
    //initMemByRows(dut)
    // Clear all blocks in play field
    dut.clockDomain.waitSampling(1)
    dut.io.restart #= true
    dut.clockDomain.waitSampling(2)
    dut.io.restart #= false
    dut.clockDomain.waitSampling(2)
  }

  // 0 -> rowIndex = 0
  // rowIndex -> rowNum -1 = 1
  def initMemByRows(dut: checkers_playfield, rowIndex : Int = bottomRow ): Unit = {
    for ( row <- 0 until rowNum ) {
      if (row <= rowIndex) {
        //setBigInt(dut.play_field.mem, row, 0)
      } else {
        //setBigInt(dut.play_field.mem, row, BigInt("000000000000111111111111", 2))
      }
    }
  }

  def initMemByArray(dut: checkers_playfield)(a: ArrayBuffer[Int] ): Unit = {

    for (row <- 0 until rowNum) {

      //setBigInt(dut.play_field.mem, row, a(row) )
    }
  }


  val memory = Array.fill[BigInt](rowBlocksNum)(0)

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

  def setPlayFieldByRow(dut: checkers_playfield, row: Int, value: Int): Unit = {
    println(f"[DEBUG][Update] \tMem[${row}%2d] <= b" + value.toInt.toBinaryString)
    dut.clockDomain.waitSampling()
    dut.io.update #= true
    memory(row) = value
    for (col <- 1 to colBlocksNum if ((value & (1 << (col - 1))) != 0)) {
      dut.clockDomain.waitSampling()
      dut.play_field.io.block_pos.valid #= true
      dut.play_field.io.block_pos.y #= row
      dut.play_field.io.block_pos.x #= col
    }
    dut.clockDomain.waitSampling()
    dut.play_field.io.block_pos.valid #= false
    dut.clockDomain.waitSampling()
    dut.io.update #= false
    dut.clockDomain.waitSampling()
  }

  // rowsHavePieces : num of rows pieces are resident in from bottom.
  //                  It stimulates real scenario where pieces are stacked from the bottom
  def createPlayField(dut: checkers_playfield, rowsHavePieces : Int  = 0 ): Unit = {

    //setBigInt(dut.play_field.mem, bottomRow, BigInt("000000000000111111111111", 2) )
    // Clear all blocks in play field
    initPlayfieldByAllZero(dut)

    dut.io.update #= true
    for (i <- 1 to rowsHavePieces if rowsHavePieces != 0) {

      val rowValue = randomWithAtLeast4Ones()
      /*
      val row = rowBlocksNum - i
      memory(row) = rowValue
      for (col <- 1 to colBlocksNum if  ( ( rowValue  &  ( 1 << ( col-1) ) ) !=0 )  ) {
        dut.clockDomain.waitSampling()
        dut.play_field.io.block_pos.valid #= true
        dut.play_field.io.block_pos.y #= rowBlocksNum - i
        dut.play_field.io.block_pos.x #= col
      }
      */
      setPlayFieldByRow(dut, rowBlocksNum - i, rowValue)

    }

    dut.clockDomain.waitSampling()
    dut.play_field.io.block_pos.valid #= false
    dut.play_field.io.block_pos.y.randomize()
    dut.play_field.io.block_pos.x.randomize()

    dut.clockDomain.waitSampling(2)
    dut.io.update #= false

    println("[DEBUG] play field has been initialized as follows ... ")
    for ( ( value,  row ) <- memory.zipWithIndex  ) {
      println(f"[DEBUG]\tMem[${row}%2d] = b" + value.toInt.toBinaryString)
    }
  }


  def readMemBackDoor(dut: checkers_playfield): ArrayBuffer[Int]  = {

    val ret = ArrayBuffer[Int] ()
    for (row <- 0 until rowNum) {
      //ret  += getBigInt(dut.play_field.mem, row ).toInt
    }
    ret
  }

  def sendWithRandomTiming(dut: checkers_playfield)(x : Int, y : Int, rot : Int, shape :  SpinalEnumElement[TYPE.type]  ) = {
    dut.clockDomain.waitSampling(Random.nextInt(6))

    dut.io.piece_in.valid #= true
    dut.io.piece_in.`type` #= shape
    dut.io.piece_in.rot #= rot
    dut.io.piece_in.orign.x #= x
    dut.io.piece_in.orign.y #= y

    dut.clockDomain.waitSampling()
    dut.io.piece_in.valid #= false
    dut.io.piece_in.orign.x #= Random.nextInt(12)
    dut.io.piece_in.orign.y #= Random.nextInt(18)
    dut.io.piece_in.`type`.randomize()
    dut.io.piece_in.rot.randomize()

  }


  def beatifyB(x : Boolean) :String  = f"( $x%5s )"

  def scoreBoardResult() = {
    var fail_num = 0
    if ( expectedHitStatus.size != receivedHitStatus.size ) {
      println( f"[Scorboard] [Fail] The number of received result ( ${receivedHitStatus.size} ) Mismatch the expected ( ${expectedHitStatus.size} ) !! ")
    } else {

      expectedHitStatus.zip(receivedHitStatus).zipWithIndex.foreach{
        case ( (a, b), i ) =>
          detailed_result ++= f"\t<$i> ${beatifyB(a)}\t\t ${beatifyB(b)}"
          detailed_result ++= {
            if (a == b) {
              "\n"
            } else {
              fail_num += 1
              "\t** Fail **\n "
            }
          }
      }
    }

    println("*" * 60 )
    println("\t\t\t Result Summary")
    println("*" * 60 )
    println( f"\tThe number of received result : ${receivedHitStatus.size} " )
    println( f"\tThe number of expected result : ${expectedHitStatus.size} " )
    println( f"\tThe number of failed tests\t  : $fail_num\n")

    println("*" * 60 )
    println("\t\t\t Detailed Result")
    println("*" * 60 )
    println(f"\n\t\tExpected \t\t Received\t\t Result")
    println(f"\n \t( Collision )\n" )
    println(detailed_result)
  }


  def scoreBoardPreprocess() = {
    println(f"Total Number of Piece is ${sentPieces.size} ")
    var index = 0
    while ( sentPieces.nonEmpty ) {
      val piece = sentPieces.dequeue()
      println( f" <$index> @ ${piece.time} ns ( ${piece.x}, ${piece.y} ) , ${piece.shape.name} , ${piece.rot}" )
      val expectedBlocks = mutable.Queue[(Int, Int)]()
      val expected_p = TetrominoesConfig.typeOffsetTable(piece.shape)(piece.rot)
      for ((x, y) <- expected_p) {
        expectedBlocks.enqueue((x + piece.x , y + piece.y))
      }

      // Since wall hist is higher priority than occupied in HW, model will checker if block hit wall followed by occupied.
      val result = expectedBlocks.toList.map[(Boolean,Boolean), List[(Boolean,Boolean)]] {
        // checker if any block hits wall
        case (0, _) => {
          println(f"[DEBUG] Hit left Wall");
          (false, true)
        }
        case (col, _) if (col >= `lastCol`) => {
          println(f"[DEBUG] Hit right Wall. lastCol = ${lastCol}");
          (false, true)
        }
        case (_, row) if (row >= `bottomRow`) => {
          println(f"[DEBUG] Hit Bottom");
          (false, true)
        }
        //case (x, y) if (((memory(y) >> x) & 1) == BigInt(0)) => {
        case (x, y) if (((memory(y) >> (x-1) ) & 1) == BigInt(0)) => {
          println(f"[DEBUG] No occupied !");
          (false, false)
        }
        case (_, _) => println(f"[DEBUG] Occupied !"); (true, false)
      }.foldLeft((false,false))( (a,b) => ( ( a._1 | b._1), (a._2 | b._2)) ) match {
        case (true, true ) => ( false, true)  // When occpied and wall hit are asserted and then keep wall_hit.
        case  a => a
      }

      expectedHitStatus.enqueue(result._1 |result._2)

      index += 1
    }

  }

  def mainBody(dut : checkers_playfield, rowCoccupied: Int = 0, pieceNum : Int = 10  ): Unit = {
    init(dut)

    dut.clockDomain.forkStimulus(10)
    SimTimeout(1000 * 5000) // adjust timeout as needed

    createPlayField(dut, rowCoccupied)

    println( "*" * 40)
    println(" Memory initialized ..........")
    println( "*" * 40)


    val inputThread = fork {
      for (i <- 1 to pieceNum) {

        dut.clockDomain.waitSampling(Random.nextInt(10) )
        dut.io.piece_in.valid #= true
        dut.io.piece_in.`type`.randomize()
        dut.io.piece_in.rot.randomize()
        dut.io.piece_in.orign.x #= Random.nextInt(lastCol)    /* 0, 1, 2 , .... , lastCol-1 are x of origin of possible Tetromino */
        dut.io.piece_in.orign.y #= Random.nextInt(bottomRow ) /* 0, 1, 2 , .... , bottomRow-1 are y of origin of possible Tetromino */

        dut.clockDomain.waitSampling()
        dut.io.piece_in.valid #= false
        dut.io.piece_in.payload.randomize()
        dut.clockDomain.waitSamplingWhere(dut.io.collision_out.valid.toBoolean)

      }

    }

    /* Monitor input stream */
    StreamMonitor(dut.io.piece_in, dut.clockDomain) { payload =>
      sentPieces.enqueue(
        pieceSim( payload.orign.x.toInt,
          payload.orign.y.toInt,
          payload.`type`.toEnum,
          payload.rot.toInt,
          simTime()
        )
      )

    }

    /* Monitor output stream */
    FlowMonitor(dut.io.collision_out, dut.clockDomain) { payload =>
      receivedHitStatus.enqueue(  payload.toBoolean )
    }

    inputThread.join()

    /* Scoreboad  */

    dut.clockDomain.waitSampling(40)
    println("x"* 40)
    println(f" \t\t Test is done !!! @ ${simTime()} ns")
    println("x" * 40)

    scoreBoardPreprocess()
    scoreBoardResult()

  }

  test("usecase") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      init(dut)

      dut.clockDomain.forkStimulus(10)
      SimTimeout(10 * 5000) // adjust timeout as needed

      // Track received pieces and expected positions

      val expected_p = mutable.Queue[(Int, Int)]()

      createPlayField(dut,1)
      println( "*" * 60)
      println(" PlayField is initialized ..........")
      println( "*" * 60)

      // Prepare input data
      val pos_x = 0
      val pos_y = 0
      val p_type = TYPE.I
      val p_rot = 1

      // Sanity test

      sendWithRandomTiming(dut)(pos_x,pos_y,p_rot, p_type )
      dut.clockDomain.waitSamplingWhere(dut.io.collision_out.valid.toBoolean)

      receivedHitStatus.enqueue(  dut.io.collision_out.payload.toBoolean )

      sentPieces.enqueue( pieceSim( pos_x, pos_y, p_type,p_rot , simTime() )  )

      scoreBoardPreprocess()
      scoreBoardResult()

      dut.clockDomain.waitSampling(20)
      simSuccess() // Simulation success after sending pieces
    }
  }

  test("random") {
    compiled.doSimUntilVoid(seed = 44) { dut =>

      //mainBody(dut, 0, 444 )
      mainBody(dut, 3, 444 )
      //mainBody(dut, 2, 444 )
      //mainBody(dut, 1, 444 )

      println(f"\n\n@${simTime()} ns Simulation Ending !!! ")
      simSuccess() // Simulation success after sending pieces

    }
  }

}



