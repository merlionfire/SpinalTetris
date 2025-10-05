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
  case class TestAction(
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

  /**
   * Predefined test scenarios
   */
  object Scenarios {

    // Basic verification: zeros, ones, random
    def basic: Seq[TestAction] = Seq(
      TestAction(BitPatternGenerators.AllZeros, 1, "Verify all zeros"),
      TestAction(BitPatternGenerators.AllOnes, 1, "Verify all ones"),
      TestAction(BitPatternGenerators.Random, 5, "Random patterns")
    )

    // Corner cases
    def pieceCases: Seq[TestAction] = Seq(
      TestAction(BitPatternGenerators.AllZeros, 1),
      TestAction(BitPatternGenerators.AllOnes, 1),
      TestAction(BitPatternGenerators.FixedOnes(1), 3, "Single bit set"),
      TestAction(BitPatternGenerators.FixedOnes(2), 3, "2 bit ones"),
      TestAction(BitPatternGenerators.FixedOnes(3), 3, "3 bit ones"),
      TestAction(BitPatternGenerators.FixedOnes(4), 3, "4 bit ones"),
      TestAction(BitPatternGenerators.Random, 20)
    )

    // Stress test with random patterns
    def stress: Seq[TestAction] = Seq(
      TestAction(BitPatternGenerators.Random, 100, "Stress test")
    )


    // Custom builder
    def custom(actions: TestAction*): Seq[TestAction] = actions.toSeq
  }
}