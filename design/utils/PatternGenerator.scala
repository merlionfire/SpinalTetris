package utils

import org.scalacheck._
import org.scalacheck.Gen._

object BitPatternGenerators {
  /**
   * Generate a random integer with a maximum of m bits.
   * @param m The number of bits (must be < 31 to fit in a standard Int).
   * @return A Gen that produces an integer.
   */
  def hexWithBits(m: Int): Gen[Int] = {
    // The choose function directly creates a generator for an integer in the desired range.
    choose(0, (1 << m) - 1)
  }

  /**
   * A generator that always produces zero.
   * @param m The number of bits (unused, kept for API consistency).
   * @return A Gen that produces the integer 0.
   */
  def allZeros(m: Int): Gen[Int] = {
    const(0)
  }

  /**
   * A generator that produces an integer with the lower m bits set to 1.
   * @param m The number of bits to set to 1.
   * @return A Gen that produces the integer representation of all ones.
   */
  def allOnes(m: Int): Gen[Int] = {
    // Calculate the integer value for m bits set to 1.
    const((1 << m) - 1)
  }

  /**
   * A generator for an integer with a fixed number of randomly positioned bits set to 1.
   * @param m The bit-width of the integer.
   * @param count The number of bits to set to 1.
   * @return A Gen that produces the integer with the specified pattern.
   */
  def fixedOnes(m: Int, count: Int): Gen[Int] = {
    // Pick 'count' unique positions from 0 to m-1 and construct the integer.
    Gen.pick(count, 0 until m).map { positions =>
      positions.foldLeft(0)((value, pos) => value | (1 << pos))
    }
  }

  // --- Pattern Selector and Dispatcher ---

  sealed trait Pattern
  case object AllZeros extends Pattern
  case object AllOnes extends Pattern
  case class FixedOnes(count: Int) extends Pattern
  case object Random extends Pattern

  /**
   * Selects a generator based on the specified pattern.
   * @param m The bit-width for the generator.
   * @param pattern The pattern to generate.
   * @return A Gen[Int] that produces integers according to the pattern.
   */
  def generatePattern(m: Int, pattern: Pattern): Gen[Int] = pattern match {
    case AllZeros           => allZeros(m)
    case AllOnes            => allOnes(m)
    case FixedOnes(count)   => fixedOnes(m, count)
    case Random             => hexWithBits(m)
  }

  /**
   * Generates a sequence of integers based on a given pattern.
   * @param n The length of the sequence to generate.
   * @param m The bit-width for each integer in the sequence.
   * @param pattern The pattern to use for generation.
   * @return A Gen that produces a sequence of integers.
   */
  def generateSequence(n: Int, m: Int, pattern: Pattern): Gen[Seq[Int]] = {
    Gen.listOfN(n, generatePattern(m, pattern))
  }
}

import org.scalacheck.Prop.forAll
import org.scalacheck.Properties

/**
 * A test suite for the BitPatternGenerators object using ScalaCheck.
 * The test defines properties to verify the behavior of each generator function.
 */
object BitPatternGeneratorsTest extends Properties("BitPatternGenerators") {

  // A generator for valid bit-widths (m), which must be < 31 for Int.
  private val validMGen: Gen[Int] = Gen.choose(1, 30)

  // A generator for valid counts (c) of set bits, which must be less than or equal to m.
  // Note: This generator produces a tuple (m, c) where 1 <= c <= m <= 30.
  private val validMCGen: Gen[(Int, Int)] = validMGen.flatMap { m =>
    Gen.choose(1, m).map(c => (m, c))
  }

  // Define properties for each generator function.

  /**
   * Property for hexWithBits(m):
   * Tests that the generated number 'n' is non-negative and is less than $2^m$.
   */

  property("hexWithBits should produce a random integer within the 0 to (2^m)-1 range") = forAll(validMGen) { m =>
    val maxVal = (1 << m) - 1
    BitPatternGenerators.hexWithBits(m).sample match {
      case Some(n) => n >= 0 && n <= maxVal
      case None    => false // Should never happen for a valid 'm'
    }
  }

  // --------------------------------------------------------------------------------

  /**
   * Property for allZeros(m):
   * Tests that the generator always produces the integer 0.
   */
  property("allZeros should always produce 0") = forAll(validMGen) { m =>
    BitPatternGenerators.allZeros(m).sample.contains(0)
  }

  // --------------------------------------------------------------------------------

  /**
   * Property for allOnes(m):
   * Tests that the generator always produces the value $2^m - 1$, and that all its
   * lower 'm' bits are set.
   */
  property("allOnes should always produce the value (2^m) - 1") = forAll(validMGen) { m =>
    val expected = (1 << m) - 1
    BitPatternGenerators.allOnes(m).sample.contains(expected)
  }

  // --------------------------------------------------------------------------------

  /**
   * Property for fixedOnes(m, count):
   * Tests two things:
   * 1. The generated integer 'n' is within the range [0, 2^m - 1].
   * 2. The number of set bits (population count) in 'n' is exactly 'count'.
   */
  property("fixedOnes should produce an integer with 'count' bits set in the lower 'm' bits") = forAll(validMCGen) { case (m, count) =>
    val maxVal = (1 << m) - 1
    BitPatternGenerators.fixedOnes(m, count).sample match {
      case Some(n) =>
        // 1. Check range: number must be less than 2^m
        val rangeCheck = n >= 0 && n <= maxVal

        // 2. Check population count: number of set bits must equal 'count'
        // 'Integer.bitCount' is used to count the number of set bits.
        val bitCountCheck = Integer.bitCount(n) == count

        rangeCheck && bitCountCheck
      case None    => false
    }
  }

  // --------------------------------------------------------------------------------

  /**
   * Property for generatePattern(m, pattern):
   * Tests the dispatch logic by checking that the Random pattern uses hexWithBits
   * (already tested for range).
   * Note: We don't need to re-test AllZeros/AllOnes/FixedOnes as the dispatch simply
   * calls the functions we've already verified. This test focuses on the `match` logic.
   */
  property("generatePattern with Random should use hexWithBits(m)") = forAll(validMGen) { m =>
    val maxVal = (1 << m) - 1
    BitPatternGenerators.generatePattern(m, BitPatternGenerators.Random).sample match {
      case Some(n) => n >= 0 && n <= maxVal
      case None    => false
    }
  }

  // --------------------------------------------------------------------------------

  /**
   * Property for generateSequence(n, m, pattern):
   * Tests that the generated sequence has length 'n' and that each element respects
   * the properties of the AllZeros pattern (i.e., each element is 0).
   */
  property("generateSequence should produce a sequence of length 'n' with the correct pattern") = forAll(
    Gen.choose(1, 10), // sequence length 'n'
    validMGen         // bit-width 'm'
  ) { (n, m) =>
    val pattern = BitPatternGenerators.AllZeros
    BitPatternGenerators.generateSequence(n, m, pattern).sample match {
      case Some(seq) =>
        // 1. Check length
        val lengthCheck = seq.length == n

        // 2. Check pattern property (for AllZeros, all elements must be 0)
        val patternCheck = seq.forall(_ == 0)

        lengthCheck && patternCheck
      case None => false
    }
  }
}