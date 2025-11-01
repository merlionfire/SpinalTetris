package utils

import config.TYPE.newElement
import config._
import config.TetrominoesConfig._
import org.scalacheck._
import org.scalacheck.Gen._
import spinal.core.{SpinalEnumElement, SpinalEnumEncoding}
import utils.PiecePatternGenerators.Pattern
import utils.mis.int2binString

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

  /**
   * A generator for an integer with no 1 bit overlapping with input ref.
   * @param m The bit-width of the integer.
   * @param ref Integer as reference which has no-overlap with created integer.
   * @return A Gen that produces the integer with the specified pattern.
   */
  def noCollisionBits(
                          m: Int,
                          ref: Int,
                        ): Gen[Int] = {

    val ret =  ( ~ ref )  &  (  ( 1 << m ) -  1 )
    // for debug
    //println(s"[noCollisionBit] m = $m, ref = ${int2binString(ref)}, ret = ${int2binString(ret)} "  )
    const(  ret  )
  }

  /**
   * Generates an Int which has exactly 'count' bits set that overlap (collide) with the 'ref' value.
   * The total bit width 'm' is primarily used for context but is less critical here.
   *
   * @param m The total bit width (ignored in this specific implementation, but kept for signature)
   * @param ref The reference value to collide with.
   * @param count The required number of overlapping (colliding) bits.
   * @return A Gen[Int] that always produces a value with 'count' bits colliding with 'ref'.
   */
  def fixedCollisionOnes(
                          m: Int,
                          ref: Int,
                          count : Int
                        ): Gen[Int] = {
    // 1. Validation Checks
    require(m > 0, s"bitWidth must be positive, got $m")
    val refBitCount = Integer.bitCount(ref)
    require(count >= 0, "count must be non-negative")
    require(count <= refBitCount, s"count($count) must be less than or equal to the number of set bits in ref ($refBitCount)")

    // 2. Identify the Bit Positions that MUST be set (the 'candidates')
    // Get the indices of all bits that are set in 'ref'.
    val candidatePositions: Seq[Int] = (0 until m).filter { pos =>
      (ref & (1 << pos)) != 0
    }

    // 3. Select the 'count' subset of positions for collision
    // Use Gen.pick to randomly select exactly 'count' indices from the candidates.
    val selectedPositionsGen: Gen[Seq[Int]] = Gen.pick(count, candidatePositions)

    // 4. Transform the selected positions into the final Int value
    selectedPositionsGen.map { positions =>
      // Combine the selected positions using the OR operator
      positions.foldLeft(0) { (value, pos) =>
        value | (1 << pos)
      }
    }
  }




  // --- Pattern Selector and Dispatcher ---

  sealed trait Pattern
  case object AllZeros extends Pattern
  case object AllOnes extends Pattern
  case class FixedOnes(count: Int) extends Pattern
  case object Random extends Pattern
  case object NoCollision extends Pattern
  case class FixCollisionOnes( count : Int ) extends Pattern
  case object Hold extends Pattern
  case object Custom extends Pattern  // New pattern
  //case class Composite(segments: Seq[(Int, Pattern)]) extends Pattern

  /**
   * Selects a generator based on the specified pattern.
   * @param m The bit-width for the generator.
   * @param pattern The pattern to generate.
   * @param ref The reference integer for patterns of NoCollision and FixCollisionOnes(count).
   * @return A Gen[Int] that produces integers according to the pattern.
   */
  def generatePattern(m: Int, pattern: Pattern, ref : Int = 0 ): Gen[Int] = pattern match {
    case AllZeros           => allZeros(m)
    case AllOnes            => allOnes(m)
    case FixedOnes(count)   => fixedOnes(m, count)
    case Random             => hexWithBits(m)
    case NoCollision        => noCollisionBits(m,ref)
    case FixCollisionOnes(count) => fixedCollisionOnes(m, ref, count)
    case Custom             => Gen.const(ref)
    //case class Composite(segments: Seq[(Int, Pattern)])
  }

  /**
   * Generates a sequence of integers based on a given pattern.
   * @param n The length of the sequence to generate.
   * @param m The bit-width for each integer in the sequence.
   * @param pattern The pattern to use for generation.
   * @return A Gen that produces a sequence of integers.
   */
  def generateSequence(n: Int, m: Int, pattern: Pattern, ref : Seq[Int] = null ): Gen[Seq[Int]] = {

    // Custom pattern validation
    if (pattern == Custom) {
      require(ref != null, "Custom pattern requires a non-null reference sequence")
    }

    if (ref == null) {
      Gen.listOfN(n, generatePattern(m, pattern))
    } else {

      // 1. Validation Check: Ensure the requested length 'n' matches the reference sequence length.
      require(n == ref.length, s"Requested sequence length (n=$n) must match reference length (${ref.length})")

      // 2. Map the reference sequence to a sequence of generators.
      // For each 'refItem' in the 'ref' sequence, create a tailored Gen[Int].
      val individualGenerators: Seq[Gen[Int]] = ref.map { refItem =>
        // Pass the specific refItem to the pattern generator
        generatePattern(m, pattern, refItem)
      }

      // 3. Combine the sequence of generators into a single Gen[Seq[Int]].
      // Gen.sequence takes a Seq[Gen[A]] and returns a Gen[Seq[A]].
      Gen.sequence[Seq[Int], Int](individualGenerators).map(_.toSeq)
      // .map(_.toSeq) is often necessary for older ScalaCheck versions when used with .asJava
    }

  }




}



object PiecePatternGenerators {

  sealed trait Pattern
  case class I(rot: Int) extends Pattern
  case class J(rot: Int) extends Pattern
  case class L(rot: Int) extends Pattern
  case class O(rot: Int) extends Pattern
  case class S(rot: Int) extends Pattern
  case class T(rot: Int) extends Pattern
  case class Z(rot: Int) extends Pattern
  case object PieceRandom extends Pattern

  // Returns (TYPE, rotation) tuple
  def generatePiecePattern(pattern: Pattern): Gen[(SpinalEnumElement[TYPE.type], Int)] = pattern match {
    case I(rot) => const((TYPE.I, rot))
    case J(rot) => const((TYPE.J, rot))
    case L(rot) => const((TYPE.L, rot))
    case O(rot) => const((TYPE.O, rot))
    case S(rot) => const((TYPE.S, rot))
    case T(rot) => const((TYPE.T, rot))
    case Z(rot) => const((TYPE.Z, rot))
    case PieceRandom =>
      for {
//        typeElement <- oneOf(TYPE.elements)
        typeElement <- frequency(
          10 -> TYPE.I,
          15 -> TYPE.J,
          15 -> TYPE.L,
          5  -> TYPE.O,  // Less common
          12 -> TYPE.S,
          15 -> TYPE.T,
          12 -> TYPE.Z
        )
        rotationMap = binaryTypeOffsetTable(typeElement)
        rotation <- oneOf(rotationMap.keys.toSeq)
      } yield (typeElement, rotation)
  }

  // Helper to get binary data from tuple
  def getBinaryData(typeAndRot: (SpinalEnumElement[TYPE.type], Int)): Seq[Int] = {
    val (pieceType, rotation) = typeAndRot
    binaryTypeOffsetTable(pieceType)(rotation)
  }


}

//object MotionPatternGenerators {
//
//  sealed trait Pattern
//  case object Left extends Pattern
//  case object Right extends Pattern
//  case object Rotate extends Pattern
//  case object Down extends Pattern
//  case object Drop extends Pattern
//  case object Random extends Pattern
//
//  // Default weights for Random pattern
//  private val defaultWeights: Map[Pattern, Int] = Map(
//    Left -> 10,
//    Right -> 10,
//    Rotate -> 10,
//    Down -> 10,
//    Drop -> 1
//  )
//
//  def generatePattern(
//     pattern: Pattern,
//     customWeights: Option[Map[Pattern, Int]] = None
//  ): Gen[Pattern] = pattern match {
//    case Left => const(Left)
//    case Right => const(Right)
//    case Rotate => const(Rotate)
//    case Down => const(Down)
//    case Drop =>  const( Drop )
//    case Random =>
//      // Use custom weights if provided, otherwise fall back to default
//      val weights = customWeights.getOrElse(defaultWeights)
//      // Convert Map to frequency format (Seq of (weight, pattern))
//      val weightPair = weights.toSeq.map { case (p, w) => (w, const(p)) }
//      frequency[Pattern]( weightPair : _* )
//  }
//}

object MotionPatternGenerators {

  sealed trait Pattern
  case class Left(step : Int) extends Pattern
  case class Right(step : Int) extends Pattern
  case class Rotate(step : Int) extends Pattern
  case class Down(step : Int) extends Pattern
  case object Drop  extends Pattern
  case object Random extends Pattern

  def generatePatternByType(
                             patternType: String,
                             stepRange: (Int, Int) = (1, 10),
                             customWeights: Option[Map[String, Int]] = None
                           ): Gen[Pattern] = patternType.toLowerCase match {
    case "left" =>
      Gen.choose(stepRange._1, stepRange._2).map(Left(_))

    case "right" =>
      Gen.choose(stepRange._1, stepRange._2).map(Right(_))

    case "rotate" =>
      Gen.choose(1, 4).map(Rotate(_))

    case "down" =>
      Gen.choose(stepRange._1, stepRange._2).map(Down(_))

    case "drop" =>
      Gen.const(Drop)

    case "random" =>
      val defaultTypeWeights = Map(
        "left" -> 10,
        "right" -> 10,
        "rotate" -> 10,
        "down" -> 10,
        "drop" -> 1
      )

      val weights = customWeights.getOrElse(defaultTypeWeights)

      val weightPairs = weights.toSeq.map { case (pType, weight) =>
        (weight, generatePatternByType(pType, stepRange, None))
      }

      Gen.frequency(weightPairs: _*)

    case _ =>
      throw new IllegalArgumentException(s"Unknown pattern type: $patternType")
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