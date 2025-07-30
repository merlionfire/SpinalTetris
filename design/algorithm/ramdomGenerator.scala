package algorithm

import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import scala.collection.mutable.ArrayBuffer

object Lfsr7BagVerilogSim {

  private var lfsr: Int = Integer.parseInt("101101",2) // Initial LFSR state
  private var generatedNumbers = ArrayBuffer.empty[Int]
  private var count: Int = 0

  def nextValue(): Option[Int] = {
    if (count == 7) {
      count = 0
      generatedNumbers.clear()
    }

    lfsr = (lfsr << 1 | ((lfsr >> 5) ^ (lfsr >> 3)) & 1) & 0x3F // LFSR update (6 bits)
    val nextNumber = lfsr % 7

    if (!generatedNumbers.contains(nextNumber)) {
      generatedNumbers += nextNumber
      count += 1
      Some(nextNumber)
    } else {
      None
    }
  }
}

class Lfsr7BagVerilogSimTest extends AnyFlatSpec with Matchers {

  "Lfsr7BagVerilogSim" should "generate all numbers from 0 to 6 exactly once per cycle" in {
    for (_ <- 1 to 10) { // Test multiple cycles
      var generated = Set.empty[Int]
      while (generated.size < 7) {
        Lfsr7BagVerilogSim.nextValue() match {
          case Some(value) => generated += value
          case None => // Number already generated, continue
        }
      }
      println(generated)
      generated shouldBe (0 to 6).toSet
    }
  }

  it should "generate different sequences over multiple cycles" in {
    val firstSequence = (1 to 7).flatMap(_ => Lfsr7BagVerilogSim.nextValue()).toSeq
    Lfsr7BagVerilogSim.nextValue() // Reset counter
    val secondSequence = (1 to 7).flatMap(_ => Lfsr7BagVerilogSim.nextValue()).toSeq
    firstSequence should not be secondSequence
  }

  it should "handle many iterations" in {
    val numIterations = 70000
    var generatedCount = Array.fill(7)(0)
    for(_ <- 1 to numIterations) {
      Lfsr7BagVerilogSim.nextValue() match {
        case Some(value) => generatedCount(value) += 1
        case None => // Number already generated, continue
      }
    }
    val expectedCount = numIterations / 7.0
    val chiSquared = generatedCount.map(c => math.pow(c - expectedCount, 2) / expectedCount).sum
    chiSquared should be < 20.0
    println(s"Chi-squared value: $chiSquared")
  }
}