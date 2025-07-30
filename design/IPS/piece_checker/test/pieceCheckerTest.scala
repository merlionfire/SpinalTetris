package IPS.piece_checker

import config._
import utils.PathUtils._
import utils.SimUtils._

import org.scalatest.funsuite.AnyFunSuite
import spinal.core._
import spinal.core.sim._
import spinal.lib.sim.StreamMonitor

import scala.collection.mutable
import scala.util.Random


case class pieceSim (x : Int, y : Int, shape : SpinalEnumElement[TYPE.type ] ,  rot : Int, time : Long )


class pieceCheckerTest  extends AnyFunSuite{

  //var compiler : String = "verilator"
  var compiler : String = "vcs"

  val rowNum : Int = 23   // include bottom wall
  val colNum :Int = 12    // include left and right wall
  val rowBitsWidth = log2Up(rowNum)
  val colBitsWidth = log2Up(colNum)

  lazy val compiled : SimCompiled[piece_checker] = runSimConfig(getRtlOutputPath(getClass, targetName="sim").toString, compiler )
    .compile {
      val c =  new piece_checker(colBitsWidth,rowBitsWidth)
      c
    }

  def init( dut : piece_checker ): Unit = {
    // Initialization
    dut.io.piece_in.`type` #= TYPE.T
    dut.io.piece_in.rot #= 1
    dut.io.piece_in.orign.x #=  maskInt(colBitsWidth)
    dut.io.piece_in.orign.y #= maskInt(rowBitsWidth)
    dut.io.piece_in.valid #= false
    dut.io.blocks_out.ready #= true
  }

  test("sanity") {
    compiled.doSimUntilVoid(seed = 42) { dut =>

      init(dut)

      dut.clockDomain.forkStimulus(10)
      SimTimeout(10 * 5000) // adjust timeout as needed

      // Track received pieces and expected positions

      val receivedBlocks, expectedBlocks = mutable.Queue[(Int, Int)]()

      //val scoreboard = ScoreboardInOrder[Int]()
      StreamMonitor

      // Prepare input data
      val pos_x = 0
      val pos_y = 0
      val p_type = TYPE.I
      val p_rot = 1

      // Sanity test
      dut.clockDomain.waitSampling()
      dut.io.piece_in.`type` #= p_type
      dut.io.piece_in.rot #= p_rot
      dut.io.piece_in.orign.x #= pos_x
      dut.io.piece_in.orign.y #= pos_y
      dut.io.piece_in.valid #= true
      dut.clockDomain.waitSampling()
      dut.io.piece_in.valid #= false
      dut.io.piece_in.orign.x #= Random.nextInt(12)
      dut.io.piece_in.orign.y #= Random.nextInt(24)

      val expected_p = TetrominoesConfig.typeOffsetTable(p_type)(p_rot)

      for ( (x,y)  <- expected_p ) {
        expectedBlocks.enqueue(  (x+pos_x, y + pos_y) )
      }

      dut.clockDomain.waitSamplingWhere(dut.io.piece_in.ready.toBoolean)
      dut.io.piece_in.valid #= false


      for ( _ <- 1 to 4 ) {
        dut.clockDomain.waitSamplingWhere(dut.io.blocks_out.valid.toBoolean)
        receivedBlocks.enqueue((dut.io.blocks_out.x.toInt, dut.io.blocks_out.y.toInt))
      }


      println(f"Input data: ")
      println(f"\tposition\t: ($pos_x, $pos_y) ")
      println(f"\ttype\t: ${p_type.name}")
      println(f"\trot\t: $p_rot")

      println(f"Comparison: ")
      println(f"\tExpected\tReceived\tResult")
      for ( _ <- 1 to 4 ) {
        val a = expectedBlocks.dequeue()
        val b = receivedBlocks.dequeue()
        print(f"\t $a\t  |\t $b\t|  ")
        if ( a == b ) {
          println("  Pass")
        } else {
          println("** Fail**")
        }

      }

      dut.clockDomain.waitSampling(20)
      simSuccess() // Simulation success after sending pieces
    }
  }


  test("random") {
    compiled.doSimUntilVoid(seed = 42) { dut =>
      // Track received pieces and expected positions

      val receivedBlocks, expectedBlocks = mutable.Queue[(Int, Int)]()
      val sentPieces = mutable.Queue[pieceSim]()

      val shape_bins = mutable.Map[ (String, Int),Int ]()

      for( (a,b)  <-  TetrominoesConfig.typeOffsetTable;  (rot, _ ) <- b )  shape_bins +=( (a.name, rot) -> 0)

      // Customize begin
      val num = 100

      // Customize end

      init(dut)

      dut.clockDomain.forkStimulus(10)
      SimTimeout(100000 * 80) // adjust timeout as needed

      val inputThread = fork {
        for( i <- 1 to num ) {

          dut.clockDomain.waitSampling( Random.nextInt(10)+1 )
          dut.io.piece_in.valid #= true
          dut.io.piece_in.`type`.randomize()
          dut.io.piece_in.rot.randomize()
          dut.io.piece_in.orign.x #=  Random.nextInt(12)
          dut.io.piece_in.orign.y #=  Random.nextInt(24)

          dut.clockDomain.waitSampling( )

          dut.io.piece_in.valid #= false
          dut.io.piece_in.payload.randomize()
          dut.clockDomain.waitSampling(4)

        }

        dut.clockDomain.waitSampling( 10 )
        println("*" * 40)
        println(f" \t\tSimulation Result: ")
        println("*" * 40)

        println(f"Total Number of Piece is ${sentPieces.size} ")

        println(f"\tExpected\tReceived\t\tResult")


        var idx = 1
        while (expectedBlocks.nonEmpty) {
          for ( i <- 1 to 4) {
            val a = expectedBlocks.dequeue()
            val b = receivedBlocks.dequeue()
            var time = 0L
            var f = ""
            if ( i == 1 ) {
              val c = sentPieces.dequeue()
              f = f"  -- ( ${c.x}, ${c.y} ) , ${c.shape.name} , ${c.rot}"
              time = c.time

              val count = shape_bins.getOrElse( ( c.shape.name, c.rot),  0 )
              shape_bins  += ( ( c.shape.name, c.rot) -> (count+1) )
            }

            print(f"${idx}%2d|\t $a  |\t $b  \t|  ")
            if (a == b) {
              print("   Pass  ")
            } else {
              print("** Fail**")
              print(s" @${time} ps")
            }
            println(f)
          }
          idx = idx + 1
        }

        println()
        println("*" * 40)
        println(f" \t\tCoverage Report: ")
        println("*" * 40)
        println()
        println("\t(Shape,Rot) Coverage Bins report")
        println()

        val shapeBin_seq = shape_bins.toSeq.sortBy(_._1)

        for ( (item, count) <- shapeBin_seq ) {
          println(f"\t\t$item\t:$count" + { if (count==0) " **" else "" } )
        }

        println(f"@${simTime()} ns Simulation Ending ......... ")
        simSuccess() // Simulation success after sending pieces

      }

      StreamMonitor(dut.io.piece_in, dut.clockDomain) { payload =>
        val expected_p = TetrominoesConfig.typeOffsetTable(payload.`type`.toEnum)(payload.rot.toInt)
        sentPieces.enqueue(
          pieceSim( payload.orign.x.toInt,
            payload.orign.y.toInt,
            payload.`type`.toEnum,
            payload.rot.toInt,
            simTime()
          )
        )

        for ((x, y) <- expected_p) {
          expectedBlocks.enqueue((x + payload.orign.x.toInt, y + payload.orign.y.toInt))
        }
      }

      StreamMonitor(dut.io.blocks_out, dut.clockDomain) { payload =>
        receivedBlocks.enqueue((payload.x.toInt, payload.y.toInt))
      }

      dut.clockDomain.waitSampling(10)

      println(f"@${simTime()} ns Simulation Starting ......... ")

    }


  }
}