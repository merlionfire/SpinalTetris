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
}