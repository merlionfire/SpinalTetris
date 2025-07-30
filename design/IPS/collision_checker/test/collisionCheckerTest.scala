package IPS.collision_checker

import IPS.play_field._
import config._
import spinal.core._
import spinal.lib._
import utils._
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.sim._
import spinal.lib.sim.{FlowMonitor, ScoreboardInOrder, StreamDriver, StreamMonitor, StreamReadyRandomizer}
import utils.PathUtils.getRtlOutputPath

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import scala.util.Random


case class blockSim (x : Int, y : Int, time : Long )

//////////////////////////////////////////////////////
//        Top : collision_checker + play_field
//////////////////////////////////////////////////////

class collisionCheckerTop ( config : PlayFieldConfig ) extends  Component {

  import config._

  val io = new Bundle {
    val block_in = slave Flow (Block(colBitsWidth , rowBitsWidth))
    val hit_status = master Flow (hitStatus())
    val restart = in Bool()
    //val shift = in Bool()
    val update = in Bool()
    val clear_start = in Bool()
    //val enable_rows = in Bool()
    val clear_done = out Bool()

  }

  /* Instantiation */
  val collision_checker = new collision_checker()
  val play_field = new play_field(config)


  // Interface <-> collision_checker
  io.block_in <> collision_checker.io.block_in
  io.hit_status <> collision_checker.io.hit_status
  collision_checker.io.block_skip_en := False
  collision_checker.io.block_wr_en := False

  //  collision_checker <-> playfield
  play_field.io.block_pos <> collision_checker.io.block_pos
  play_field.io.block_val <> collision_checker.io.block_val
  play_field.io.restart  := io.restart
  //play_field.io.shift  := io.shift
  play_field.io.update  := io.update
  play_field.io.clear_start := io.clear_start
  //play_field.io.enable_rows := io.enable_rows
  play_field.io.block_set := False
  play_field.io.fetch := False
  io.clear_done := play_field.io.clear_done

}


//////////////////////////////////////////////////////
//        Test Main
//////////////////////////////////////////////////////
class collisionCheckerTest extends AnyFunSuite {


  val compiler : String = "verilator"
  //val compiler: String = "vcs"

  val receivedHitStatus, expectedHitStatus = mutable.Queue[(Boolean, Boolean)]()
  val detailed_result = new StringBuilder()

  val debug = false

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

  //test("compile") {
  lazy val compiled: SimCompiled[collisionCheckerTop] = runSimConfig(getRtlOutputPath(getClass, targetName = "sim").toString, compiler)
    .compile {
      val c = new collisionCheckerTop(config)
      c.play_field.io.block_pos.simPublic()
      c.play_field.io.block_val.simPublic()
      c.play_field.rowsblocks.simPublic()
      c
    }

  def init(dut: collisionCheckerTop): Unit = {
    // Initialization
    dut.io.block_in.x #= 0x0F
    dut.io.block_in.y #= 0x0F
    dut.io.block_in.valid #= false
    dut.io.restart #= false
    //dut.io.shift  #= false
    dut.io.update #= false
    dut.io.clear_start #= false
    //dut.io.enable_rows #= false
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

  // rowsHavePieces : num of rows pieces are resident in from bottom.
  //                  It stimulates real scenario where pieces are stacked from the bottom
  def createPlayField(dut: collisionCheckerTop, rowsHavePieces: Int = 0): Unit = {

    // Clear all blocks in play field
    dut.io.restart #= true
    dut.clockDomain.waitSampling(2)
    dut.io.restart #= false
    dut.clockDomain.waitSampling(2)

    dut.io.update #= true
    for (i <- 1 to rowsHavePieces if rowsHavePieces != 0) {

      //val rowValue = Random.nextInt(1<< (colBlocksNum-2) + 4 )
      val rowValue = randomWithAtLeast4Ones()
      for (col <- 1 to colBlocksNum if ((rowValue & (1 << (col - 1))) != 0)) {
        dut.clockDomain.waitSampling()
        dut.io.block_in.valid #= true
        dut.io.block_in.y #= rowBlocksNum - i
        dut.io.block_in.x #= col

      }
    }
    dut.clockDomain.waitSampling()
    dut.io.block_in.valid #= false
    dut.io.block_in.payload.randomize()
    dut.clockDomain.waitSampling(2)
    dut.io.update #= false

    //setBigInt(dut.play_field.mem, bottomRow, BigInt("000000000000111111111111", 2) )
  }

  def readMemBackDoor(dut: collisionCheckerTop): ArrayBuffer[Int] = {
    dut.clockDomain.waitSampling(2)
    //dut.io.enable_rows #= true
    val ret = ArrayBuffer[Int]()
    for (a <- dut.play_field.rowsblocks) {
      println("[DEBUG] Read Mem = b" + a.toInt.toBinaryString)
      ret += a.toInt
    }
    dut.clockDomain.waitSampling()

    ret

  }


  def beatifyTuple(x: (Boolean, Boolean)): String = {
    val (a, b) = x
    f"( $a%5s, $b%5s )"
  }

  def scoreBoardResult() = {
    var fail_num = 0
    if (expectedHitStatus.size != receivedHitStatus.size) {
      println(f"[Scorboard] [Fail] The number of received result ( ${receivedHitStatus.size} ) Mismatch the expected ( ${expectedHitStatus.size} ) !! ")
    } else {

      expectedHitStatus.zip(receivedHitStatus).zipWithIndex.foreach {
        case ((a, b), i) =>
          //detailed_result ++= f"\t<$i> $a  \t $b"
          detailed_result ++= f"\t<$i%2d>  ${beatifyTuple(a)} \t${beatifyTuple(b)}"
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

    println("*" * 60)
    println("\t\t\t Result Summary")
    println("*" * 60)
    println(f"\tThe number of received result : ${receivedHitStatus.size} ")
    println(f"\tThe number of expected result : ${expectedHitStatus.size} ")
    println(f"\tThe number of failed tests\t  : $fail_num\n")

    println("*" * 60)
    println("\t\t\t Detailed Result")
    println("*" * 60)
    println(f"\n\t\t\tExpected \t\t   Received\t\t\tResult")
    println(f"\n ( is_occupied,is_wall )\n")
    println(detailed_result)
  }

  def driveStimulus(dut: collisionCheckerTop, num: Int = 1) = {

    for (_ <- 0 until num) {
      dut.clockDomain.waitSampling()
      dut.io.block_in.valid #= true
      dut.io.block_in.x #= Random.nextInt(colNum) /* 0, 1, 2 , .... , lastCol-1 are x of origin of possible Tetromino */
      dut.io.block_in.y #= Random.nextInt(rowNum) /* 0, 1, 2 , .... , bottomRow-1 are y of origin of possible Tetromino */
    }
    dut.clockDomain.waitSampling()
    dut.io.block_in.valid #= false
    dut.io.block_in.payload.randomize()

  }


  test("random single - transfer one position to check if it is wall-hit or occupied ") {
    compiled.doSimUntilVoid(seed = 44) { dut =>
      init(dut)

      dut.clockDomain.forkStimulus(10)
      SimTimeout(1000 * 5000) // adjust timeout as needed
      val sentPieces = mutable.Queue[blockSim]()

      println("*" * 60)
      println(" Play filed initialized ..........")
      println("*" * 60)

      createPlayField(dut, 1) //
      val num = 444
      dut.clockDomain.waitSampling(40)
      val inputThread = fork {
        for (i <- 1 to num) {
          dut.clockDomain.waitSampling(Random.nextInt(10))
          driveStimulus(dut)
          dut.clockDomain.waitSamplingWhere(dut.io.hit_status.valid.toBoolean)
        }

      }
      /* Monitor input stream */

      FlowMonitor(dut.io.block_in, dut.clockDomain) { payload =>
        sentPieces.enqueue(
          blockSim(payload.x.toInt, payload.y.toInt, simTime())
        )

      }

      var response_idx = 0
      /* Monitor output stream */
      FlowMonitor(dut.io.hit_status, dut.clockDomain) { payload =>
        if (debug) println(f"[DEBUG MON] <$response_idx>  @${simTime()}")
        receivedHitStatus.enqueue((payload.is_occupied.toBoolean, payload.is_wall.toBoolean))
        response_idx += 1
      }

      inputThread.join()


      /* Scoreboad  */

      dut.clockDomain.waitSampling(40)
      println("x" * 40)
      println(f" \t\t Test is done !!! @ ${simTime()} ns")
      println("x" * 40)

      val play_field = readMemBackDoor(dut)
      println(f"Total Number of Piece is ${sentPieces.size} ")
      var index = 0
      while (sentPieces.nonEmpty) {
        val piece = sentPieces.dequeue()
        println(f" <$index> @ ${piece.time} ns ( ${piece.x}, ${piece.y} ) ")

        // Since wall hist is higher priority than occupied in HW, model will check if block hit wall followed by occupied.
        (piece.x, piece.y) match { // check if any block hits wall
          case (0, _) => {
            println(f"[DEBUG] Hit left Wall");
            expectedHitStatus.enqueue((false, true));
            true
          }
          case (col, _) if (col >= `lastCol`) => {
            println(f"[DEBUG] Hit right Wall. lastCol = ${lastCol}");
            expectedHitStatus.enqueue((false, true));
            true
          }
          case (_, row) if (row >= `bottomRow`) => {
            println(f"[DEBUG] Hit Bottom");
            expectedHitStatus.enqueue((false, true));
            true
          }
          case (x, y) if (((play_field(y) >> (x - 1)) & 1) == BigInt(0)) => {
            println(f"[DEBUG] No occupied !");
            expectedHitStatus.enqueue((false, false))
          }
          case (_, _) => println(f"[DEBUG] Occupied !"); expectedHitStatus.enqueue((true, false))
        }

        index += 1
      }

      scoreBoardResult()

      println(f"\n\n@${simTime()} ns Simulation Ending !!! ")
      simSuccess() // Simulation success after sending pieces


    }

  }

  test("random four- Stimulate real T-Piece collision checking where 4 positions in one burst are transferred") {
    compiled.doSimUntilVoid(seed = 44) { dut =>
      init(dut)

      dut.clockDomain.forkStimulus(10)
      SimTimeout(1000 * 5000) // adjust timeout as needed

      //val receivedHitStatus, expectedHitStatus = mutable.Queue[(Boolean, Boolean)]()
      val sentPieces = mutable.Queue[blockSim]()

      //val detailed_result = new StringBuilder()

      println("*" * 60)
      println(" Play filed initialized ..........")
      println("*" * 60)
      //createPlayField(dut, 0)  // All Empty
      createPlayField(dut, 4) //
      val num = 444

      val inputThread = fork {
        for (i <- 1 to num) {
          dut.clockDomain.waitSampling(Random.nextInt(10))
          driveStimulus(dut, 4)
          dut.clockDomain.waitSamplingWhere(dut.io.hit_status.valid.toBoolean)
        }

      }
      /* Monitor input stream */

      FlowMonitor(dut.io.block_in, dut.clockDomain) { payload =>
        sentPieces.enqueue(
          blockSim(payload.x.toInt, payload.y.toInt, simTime())
        )

      }

      var response_idx = 0
      /* Monitor output stream */
      FlowMonitor(dut.io.hit_status, dut.clockDomain) { payload =>
        println(f"[DEBUG MON] <$response_idx>  @${simTime()}")
        receivedHitStatus.enqueue((payload.is_occupied.toBoolean, payload.is_wall.toBoolean))
        response_idx += 1
      }

      inputThread.join()


      /* Scoreboad  */

      dut.clockDomain.waitSampling(40)
      println("x" * 60)
      println(f" \t\t Test is done !!! @ ${simTime()} ns")
      println("x" * 60)

      val play_field = readMemBackDoor(dut)
      println(f"Total Number of Piece is ${sentPieces.size} ")
      var index = 0
      while (sentPieces.nonEmpty) {

        val blocks_pos = (0 until 4) map { idx =>
          val piece = sentPieces.dequeue()
          println(f" <$index>.<$idx> @ ${piece.time} ns ( ${piece.x}, ${piece.y} ) ")
          (piece.x, piece.y)
        }

        // Since wall hist is higher priority than occupied in HW, model will check if block hit wall followed by occupied.

        val result = blocks_pos.toList.map[(Boolean, Boolean), List[(Boolean, Boolean)]] {
          // check if any block hits wall
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
          case (x, y) if (((play_field(y) >> (x - 1)) & 1) == BigInt(0)) => {
            println(f"[DEBUG] No occupied !");
            (false, false)
          }
          case (_, _) => println(f"[DEBUG] Occupied !"); (true, false)
        }.foldLeft((false, false))((a, b) => ((a._1 | b._1), (a._2 | b._2))) match {
          case (true, true) => (false, true) // When occpied and wall hit are asserted and then keep wall_hit.
          case a => a
        }

        expectedHitStatus.enqueue(result)
        index += 1
      }
      scoreBoardResult()


      println(f"\n\n@${simTime()} ns Simulation Ending !!! ")
      simSuccess() // Simulation success after sending pieces


    }

  }
}