package utils

// File: TestPatterns.scala
import scala.collection.mutable.ArrayBuffer

object TestPatterns {

  /**
   * Test action definition
   * @param pattern The bit pattern generator to use
   * @param count Number of times to execute this pattern
   * @param description Optional description for reporting
   */
  case class TestPatternSingle(
                         pattern: BitPatternGenerators.Pattern,
                         count: Int,
                         description: String = ""
                       ) {
    def getDescription: String = {
      if (description.nonEmpty) description
      else pattern match {
        case BitPatternGenerators.AllZeros => "All Zeros"
        case BitPatternGenerators.AllOnes => "All Ones"
        case BitPatternGenerators.FixedOnes(n) => s"Fixed $n Ones"
        case BitPatternGenerators.Random => "Random"
      }
    }
  }

  case class TestPatternPair(
                         p0: BitPatternGenerators.Pattern,
                         p1: BitPatternGenerators.Pattern,
                         count: Int,
                         description: String = ""
                       ) {
    def getDescription: String = {
      if (description.nonEmpty) description
      else  Seq( (p0, "p0"), (p1, "p1" ) ).map { a =>  s"${a._2} : " +
        ( a._1  match {
            case BitPatternGenerators.AllZeros => "All Zeros"
            case BitPatternGenerators.AllOnes => "All Ones"
            case BitPatternGenerators.FixedOnes(n) => s"Fixed $n Ones"
            case BitPatternGenerators.Random => "Random"
          }
        )
      }.mkString
    }
  }

  case class TestPiecePatternPair(
                              p0: BitPatternGenerators.Pattern,
                              p1: PiecePatternGenerators.Pattern,
                              count: Int,
                              description: String = ""
                            ) {
    def getDescription: String = {
      if (description.nonEmpty) description
      else  Seq( (p0, "p0"), (p1, "p1" ) ).map { a =>  s"${a._2} : " +
        ( a._1  match {
          case BitPatternGenerators.AllZeros => "All Zeros"
          case BitPatternGenerators.AllOnes => "All Ones"
          case BitPatternGenerators.FixedOnes(n) => s"Fixed $n Ones"
          case BitPatternGenerators.Random => "Random"
        }
          )
      }.mkString
    }
  }



  case class TestMotionPatternGroup(
      p0: BitPatternGenerators.Pattern,
      p1: PiecePatternGenerators.Pattern,
      p2: Seq[MotionPatternGenerators.Pattern],
      description: String = ""
  ) {
    def getMotionsDescription: String = p2.map {
      case MotionPatternGenerators.Left(step) => s"← ${step}"
      case MotionPatternGenerators.Right(step) => s"→ ${step}"
      case MotionPatternGenerators.Rotate(step) => s"↓ ${step}"
      case MotionPatternGenerators.Down(step) => s"↺ ${step}"
      case MotionPatternGenerators.Drop => s"↓↓↓"
      case MotionPatternGenerators.Random => s"Randomized motions"
    }.mkString(", ")
  }

  object ReadoutScenarios {

    // ----------- Test patterns -----------------

    // p0 : pattern for playfield region
    // p1 : pattern for flow region
    // count : test counts
    def basic : Seq[TestPatternPair] = Seq (
      /* test case : game start scenario */
      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.AllZeros,
        1,
        "Verify game start scenario where all zeros of playfield and flow region"
      ),
      /* test case : corner case for test only */
      TestPatternPair(
        BitPatternGenerators.AllOnes,
        BitPatternGenerators.AllZeros,
        1,
        "Verify that playfield is all-occupied and flow region is empty"
      ),

      /* test case : corner case for test only */
      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.AllOnes,
        1,
        "Verify that playfield is empty and flow region is all-occuppied"
      ),

      /* test case : corner case for test only */
      TestPatternPair(
        BitPatternGenerators.AllOnes,
        BitPatternGenerators.AllOnes,
        1,
        "Verify that playfield and flow region are all-occuppied"
      ),

    )

    def playfieldPatternOnly : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.FixedOnes(4),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(5),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(8),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      ),


      TestPatternPair(
        BitPatternGenerators.FixedOnes(9),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      )

    )

    def flowPatternOnly : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(1),
        5,
        "Verify flow only with playfield empty"
      ),

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(2),
        5,
        "Verify flow only with playfield empty"
      ),

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(3),
        5,
        "Verify flow only with playfield empty"
      ),

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(4),
        5,
        "Verify flow only with playfield empty"
      ),


    )


    def usecase : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.FixedOnes(1),
        BitPatternGenerators.FixedOnes(1),
        5,
        "Verify normal case where playfield and flow region is occupied by some blocks"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(4),
        BitPatternGenerators.FixedOnes(2),
        5,
        "Verify normal case where playfield and flow region is occupied by some blocks"
      ),

    )

    def random : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.Random,
        BitPatternGenerators.Random,
        20,
        "Verify random cases for both playfield and flow region"
      ),

    )

  }

  object CollisionCheckScenarios {

    // ----------- Test patterns -----------------

    // p0 : pattern for playfield region
    // p1 : pattern for flow region
    // count : test counts
    def basic : Seq[TestPatternPair] = Seq (
      /* test case : game start scenario */
      TestPatternPair(
        p0 = BitPatternGenerators.AllZeros,
        p1 = BitPatternGenerators.AllZeros,
        count = 1,
        "Verify collision check scenario where all zeros of playfield and checker region"
      ),

      /* test case : corner case for test only */
      TestPatternPair(
        BitPatternGenerators.AllOnes,
        BitPatternGenerators.AllZeros,
        1,
        "Verify that playfield is all-occupied and checker region is empty"
      ),

      /* test case : corner case for test only */
      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.AllOnes,
        1,
        "Verify that playfield is empty and checker region is all-occuppied"
      ),

      /* test case : corner case for test only */
      TestPatternPair(
        BitPatternGenerators.AllOnes,
        BitPatternGenerators.AllOnes,
        1,
        "Verify that both of playfield and checker region are all-occuppied"
      ),

    )

    def playfieldPatternOnly : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.FixedOnes(4),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(5),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(8),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      ),


      TestPatternPair(
        BitPatternGenerators.FixedOnes(9),
        BitPatternGenerators.AllZeros,
        5,
        "Verify playfield only with flow empty"
      )

    )


    def CheckerPatternOnly : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(1),
        5,
        "Verify checker only with playfield empty"
      ),

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(2),
        5,
        "Verify checker only with playfield empty"
      ),

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(3),
        5,
        "Verify checker only with playfield empty"
      ),

      TestPatternPair(
        BitPatternGenerators.AllZeros,
        BitPatternGenerators.FixedOnes(4),
        5,
        "Verify flow only with playfield empty"
      ),

    )

    def noCollison : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.FixedOnes(9),
        BitPatternGenerators.NoCollision,
        5,
        "Verify no collision scenario"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(8),
        BitPatternGenerators.NoCollision,
        5,
        "Verify no collision scenario"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(7),
        BitPatternGenerators.NoCollision,
        5,
        "Verify no collision scenario"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(4),
        BitPatternGenerators.NoCollision,
        5,
        "Verify no collision scenario"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(1),
        BitPatternGenerators.NoCollision,
        5,
        "Verify no collision scenario"
      )

    )

    def fixedCollison( count : Int )  : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.FixedOnes(9),
        BitPatternGenerators.FixCollisionOnes(count),
        5,
        "Verify no collision scenario"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(8),
        BitPatternGenerators.FixCollisionOnes(count),
        5,
        "Verify no collision scenario"
      ),

    )



    def usecase : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.FixedOnes(1),
        BitPatternGenerators.FixedOnes(1),
        5,
        "Verify normal case where playfield and flow region is occupied by some blocks"
      ),

      TestPatternPair(
        BitPatternGenerators.FixedOnes(4),
        BitPatternGenerators.FixedOnes(2),
        5,
        "Verify normal case where playfield and flow region is occupied by some blocks"
      ),

    )

    def random : Seq[TestPatternPair] = Seq (

      TestPatternPair(
        BitPatternGenerators.Random,
        BitPatternGenerators.Random,
        20,
        "Verify random cases for both playfield and flow region"
      ),

    )




  }

  object PlaceScenarios {
    // ----------- Test patterns -----------------

    // p0 : pattern for playfield region
    // p1 : pattern for piece region
    // count : test counts
    import PiecePatternGenerators._


    def basic(playfieldPattern : BitPatternGenerators.Pattern, count : Int = 1  ) : Seq[TestPiecePatternPair] = {
      // 1. Create a list of the constructor functions.
      // In Scala, case class companion objects are functions.
      val constructors: List[Int => Pattern] = List(I, J, L, O, S, T, Z)

      // 2. Use a for-comprehension to generate all combinations.
      val patternList: List[Pattern] = for {
        constructor <- constructors // For each constructor in the list...
        //rotation <- 0 to 3          // ...and for each rotation from 0 to 3...
        rotation <- 0 to 0          // ...and for each rotation from 0 to 3...
      } yield constructor(rotation)   // ...create a new Pattern instance.

      patternList.map { pattern => TestPiecePatternPair(
          p0 = playfieldPattern,
          p1 = pattern,
          count = count,
          "Verify place several new Pieces at beginning of game where playfield with specific-pattern"
        )

      }

    }

    def single( piecePattern : Pattern , playfieldPattern : BitPatternGenerators.Pattern, count : Int = 1  ) : Seq[TestPiecePatternPair] = {
      Seq (
        TestPiecePatternPair(
          p0 = playfieldPattern,
          p1 = piecePattern,
          count = count,
          "Verify place new Piece at beginning of game where playfield with specific-pattern"
        )
      )
    }



  }

  object MotionScenarios {

    import MotionPatternGenerators._

    def generatePattern(p: String, step: Int = 0): Pattern = {

      p match {
        case "left" => Left(step)
        case "right" => Right(step)
        case "rotate" => Rotate(step)
        case "down" => Down(step)
        case "drop" => Drop
        case "Random" => Random
      }
    }


    def m1 ( )  : Seq[Pattern]  = List (
      Left(3),
      Right(6),
      Rotate(2),
      Left(3),
      Down(2),
      Rotate(3),
      Drop
    )

    def m2 ( )  : Seq[Pattern]  = List (
      Down(2),
      Rotate(3),
      Right(6),
      Left(3),
      Rotate(1),
      Right(6),
      Rotate(2),
      Down(2),
      Left(3),
      Drop
    )


    def m3 ( )  : Seq[Pattern] = List(
      Rotate(1),
      Down(2),
      Left(6),
      Down(3),
      Rotate(4),
      Right(2),
      Rotate(2),
      Down(2),
      Drop
    )


    def m4 ()  : Seq[Pattern] = List(
      Rotate(5),
      Left(2),
      Rotate(1),
      Down(3),
      Left(1),
      Rotate(2),
      Right(1),
      Rotate(3),
      Down(2),
      Rotate(4),
      Drop
    )


    def m5 ()  : Seq[Pattern] = List(
      Drop
    )

    def m6 ()  : Seq[Pattern] =  List(
      Left(5),
      Rotate(3),
      Right(8),
      Rotate(3),
      Left(4),
      Drop
    )

    def ms1 ()  : Seq[Pattern] =  List(
      Left(3),
      Right(6),
      Rotate(2),
      Down(2),
      Rotate(3),
      Drop
    )

    def ms2 ()  : Seq[Pattern] = List(
      Left(5),
      Rotate(3),
      Right(8),
      Rotate(3),
      Left(4),
      Drop
    )



    def uc1( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.AllZeros,
        p1 = piecePattern,
        p2 = List(
          Left(3),
          Right(6),
          Rotate(2),
          Left(3),
          Down(2),
          Rotate(3),
          Drop
        ),
        description = "Usecase 1"
      )

    }

    def uc2( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.AllZeros,
        p1 = piecePattern,
        p2 = List(
          Down(2),
          Rotate(3),
          Right(6),
          Left(3),
          Rotate(1),
          Right(6),
          Rotate(2),
          Down(2),
          Left(3),
          Drop
        ),
        description = "Usecase 2"
      )

    }

    def uc3( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.AllZeros,
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Down(2),
          Left(6),
          Down(3),
          Rotate(4),
          Right(2),
          Rotate(2),
          Down(2),
          Drop
        ),
        description = "Usecase 3"
      )

    }

    def uc4( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.AllZeros,
        p1 = piecePattern,
        p2 = List(
          Rotate(5),
          Left(2),
          Rotate(1),
          Down(3),
          Left(1),
          Rotate(2),
          Right(1),
          Rotate(3),
          Down(2),
          Rotate(4),
          Drop
        ),
        description = "Usecase 4"
      )

    }

    def uc5( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.AllZeros,
        p1 = piecePattern,
        p2 = List(
          Drop
        ),
        description = "Usecase 5"
      )

    }

    def uc6( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.AllZeros,
        p1 = piecePattern,
        p2 = List(
          Left(5),
          Rotate(3),
          Right(8),
          Rotate(3),
          Left(4),
          Drop
        ),
        description = "Usecase 6"
      )

    }

    def ucs1( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(1),
        p1 = piecePattern,
        p2 = List(
          Left(3),
          Right(6),
          Rotate(2),
          Down(2),
          Rotate(3),
          Drop
        ),
        description = "Custom Playfield test 1"
      )

    }

    def ucs2( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(1),
        p1 = piecePattern,
        p2 = List(
            Left(5),
            Rotate(3),
            Right(8),
            Rotate(3),
            Left(4),
            Drop
        ),
        description = "Custom Playfield test 2"
      )

    }

    def ucs3( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(1),
        p1 = piecePattern,
        p2 = List(
           Drop
        ),
        description = "Custom Playfield test 3"
      )

    }


    def ucs4( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if (playfieldHold) BitPatternGenerators.Hold else BitPatternGenerators.Custom(2),
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs5( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(2),
        p1 = piecePattern,
        p2 = List(
          Right(3),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs6( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(2),
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Left(1),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs7( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(2),
        p1 = piecePattern,
        p2 = List(
          Left(5),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs8( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(2),
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Right(6),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs9( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(2),
        p1 = piecePattern,
        p2 = List(
          Rotate(2),
          Right(2),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs10( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(2),
        p1 = piecePattern,
        p2 = List(
          Rotate(3),
          Left(1),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs20( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false, left_step : Int  )  : TestMotionPatternGroup = {


      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(1),
        p1 = piecePattern,
        p2 = List(
          left_step  match {
            case n if n >0 => Left(n)
            case n if n==0 => Down(1)
            case n => Right(-n)
          } ,
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs31( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(3),
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Left(1),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs32( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(3),
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs41( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(4),
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Left(1),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }

    def ucs42( piecePattern : PiecePatternGenerators.Pattern, playfieldHold : Boolean = false )  : TestMotionPatternGroup = {
      TestMotionPatternGroup(
        p0 = if ( playfieldHold ) BitPatternGenerators.Hold else BitPatternGenerators.Custom(4),
        p1 = piecePattern,
        p2 = List(
          Rotate(1),
          Drop
        ),
        description = "Custom Playfield test 4"
      )

    }


  }

  /**
   * Predefined test scenarios
   */
  object Scenarios {

    // Basic verification: zeros, ones, random
    def basic: Seq[TestPatternSingle] = Seq(
      TestPatternSingle(BitPatternGenerators.AllZeros, 1, "Verify all zeros"),
      TestPatternSingle(BitPatternGenerators.AllOnes, 1, "Verify all ones"),
      TestPatternSingle(BitPatternGenerators.Random, 5, "Random patterns")
    )



    // Corner cases
    def pieceCases: Seq[TestPatternSingle] = Seq(
      TestPatternSingle(BitPatternGenerators.AllZeros, 1),
      TestPatternSingle(BitPatternGenerators.AllOnes, 1),
      TestPatternSingle(BitPatternGenerators.FixedOnes(1), 3, "Single bit set"),
      TestPatternSingle(BitPatternGenerators.FixedOnes(2), 3, "2 bit ones"),
      TestPatternSingle(BitPatternGenerators.FixedOnes(3), 3, "3 bit ones"),
      TestPatternSingle(BitPatternGenerators.FixedOnes(4), 3, "4 bit ones"),
      TestPatternSingle(BitPatternGenerators.Random, 20)
    )

    // Stress test with random patterns
    def stress: Seq[TestPatternSingle] = Seq(
      TestPatternSingle(BitPatternGenerators.Random, 100, "Stress test")
    )


    // Custom builder
    def custom(actions: TestPatternSingle*): Seq[TestPatternSingle] = actions.toSeq
  }

} // TestPatterns end