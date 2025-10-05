package utils

import scala.collection.mutable
import scala.collection.mutable.ArrayBuffer
import scala.collection.immutable.Seq

// Base trait for scoreboard functionality
trait Scoreboard[T] {
  def addExpected(data: T): Unit
  def addActual(data: T, time : String ): Unit
  def compare(): Boolean
  def report(): String
  def clear(): Unit
  def isEmpty: Boolean

}

// Concrete implementation for sequence comparison
class SequenceScoreboard[T](
                             name: String = "Scoreboard",
                             verbose: Boolean = true
                           ) extends Scoreboard[T] {

  val expectedData = ArrayBuffer[T]()
  val actualData = ArrayBuffer[T] ()
  private val mismatches = ArrayBuffer[(Int, T, T  )]() // (index, expected, actual)
  private var actionCounter = 0

  def formatData(data: T): String = data.toString

  override def addExpected(data: T): Unit = {
    expectedData += data
    actionCounter += 1
    if (verbose) {
      println(s"[$name] Action $actionCounter: Added ${formatData(data)} as expected values")
      println(s"[$name] Total expected so far: ${expectedData.size}")
    }

  }

  override def addActual(data: T, time : String = ""): Unit = {
    actualData += data
    if (verbose) println(s"[$name] Added actual data: ${formatData(data)} ${time} ")
  }

  override def compare(): Boolean = {
    mismatches.clear()

    if (expectedData.size != actualData.size) {
      println(s"[ERROR] Size mismatch: expected ${expectedData.size}, got ${actualData.size}")
      return false
    }

    var allMatch = true
    expectedData.zip(actualData).zipWithIndex.foreach {
      case ((exp, act), idx) =>
        if (exp != act) {
          allMatch = false
          mismatches += ((idx, exp, act))
        }
    }

    allMatch
  }


  def formatMismatch(idx: Int, exp: T, act: T): String = ""

  override def report(): String = {
    val builder = new StringBuilder()
    builder.append(s"\n${"="*70}\n")
    builder.append(s"\t\t\t\t$name Report\n")
    builder.append(s"${"="*70}\n")
    builder.append(f"Total Actions Executed: $actionCounter\n")
    builder.append(f"Expected Values: ${expectedData.size}\n")
    builder.append(f"Actual Values:   ${actualData.size}\n")

    if (mismatches.isEmpty) {
      builder.append(s"\n✓ ALL CHECKS PASSED!\n")
    } else {
      builder.append(f"\n✗ FOUND ${mismatches.size} MISMATCH(ES):\n\n")

      // Show first 10 mismatches in detail
      mismatches.take(10).foreach { case (idx, exp, act) =>
        // Calls the concrete implementation provided by the child class
        builder.append(formatMismatch(idx, exp, act))
      }

      if (mismatches.size > 10) {
        builder.append(f"\n  ... and ${mismatches.size - 10} more mismatches\n")
      }
    }

    builder.append(s"${"="*70}\n")
    builder.toString()
  }

  override def clear(): Unit = {
    expectedData.clear()
    actualData.clear()
    mismatches.clear()
    actionCounter = 0
  }

  override def isEmpty: Boolean = expectedData.isEmpty && actualData.isEmpty

  def getMismatchCount: Int = mismatches.size

  def getFirstMismatch: Option[(Int, T, T)] = mismatches.headOption
}


class PlayFieldScoreboard(
                             name: String = "PlayFieldScoreboard",
                             size : Int = 10,
                             verbose: Boolean = true
                           ) extends SequenceScoreboard[Int](name, verbose) {

  override def addExpected(data: Int ): Unit = {
    super.addExpected(data)
  }

  override def addActual(data: Int, time : String = "" ): Unit = {
    super.addActual(data, time)
  }

  override def formatMismatch(idx: Int, exp: Int, act: Int): String = {
    // Using the f-interpolator, which works correctly because exp and act are Int.
    f"  Index [$idx%5d]: Expected=0x$exp%02X, Actual=0x$act%02X\n"
  }

  override def formatData(data: Int): String =  f"0x$data%03X"

}


// Scoreboard with automatic checking
trait AutoCheckScoreboard[T] extends Scoreboard[T] {
  def autoCheck: Boolean = {
    val result = compare()
    println(report())
    result
  }
}


// Combined scoreboard with statistics
class StatisticalScoreboard[T](
                                name: String = "StatScoreboard",
                                verbose: Boolean = true
                              ) extends SequenceScoreboard[T](name, verbose)
  with AutoCheckScoreboard[T] {

  private var totalChecks = 0
  private var passedChecks = 0

  override def compare(): Boolean = {
    totalChecks += 1
    val result = super.compare()
    if (result) passedChecks += 1
    result
  }

  override def report(): String = {
    val baseReport = super.report()
    val passRate = if (totalChecks > 0) {
      (passedChecks.toDouble / totalChecks * 100).formatted("%.2f")
    } else "N/A"

    s"$baseReport\nStatistics: $passedChecks/$totalChecks passed ($passRate%)\n"
  }

  def resetStats(): Unit = {
    totalChecks = 0
    passedChecks = 0
  }
}