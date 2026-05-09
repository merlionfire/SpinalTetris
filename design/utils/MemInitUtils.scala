package utils

import scala.io.Source
import scala.util.{Failure, Success, Try}

object MemInitUtils {
  private def stripInlineComment(line: String): String = {
    val commentStart = line.indexOf("//")
    val content = if (commentStart >= 0) line.substring(0, commentStart) else line
    content.trim
  }

  private def parseHexLine(
                            rawLine: String,
                            lineNum: Int,
                            maxValue: BigInt,
                            wordWidth: Int
                          ): Either[String, Option[BigInt]] = {
    val token = stripInlineComment(rawLine)

    if (token.isEmpty) {
      Right(None)
    } else {
      Try(BigInt(token, 16)) match {
        case Success(value) if value >= 0 && value <= maxValue =>
          Right(Some(value))
        case Success(value) =>
          Left(
            s"Line $lineNum: value 0x${value.toString(16)} exceeds wordWidth=$wordWidth bits: '$rawLine'"
          )
        case Failure(_) =>
          Left(s"Line $lineNum: invalid hex token '$token': '$rawLine'")
      }
    }
  }

  private def validateDefaultValue(defaultValue: BigInt, wordWidth: Int): Unit = {
    val maxValue = (BigInt(1) << wordWidth) - 1
    require(
      defaultValue >= 0 && defaultValue <= maxValue,
      s"defaultValue 0x${defaultValue.toString(16)} exceeds wordWidth=$wordWidth bits"
    )
  }

  def loadHexInitFile(
                       initFileName: String,
                       depth: Int,
                       wordWidth: Int,
                       defaultValue: BigInt
                     ): Vector[BigInt] = {
    require(depth >= 0, s"depth must be >= 0, got $depth")
    require(wordWidth > 0, s"wordWidth must be > 0, got $wordWidth")
    validateDefaultValue(defaultValue, wordWidth)

    if (initFileName.isEmpty) {
      Vector.fill(depth)(defaultValue)
    } else {
      val src = Source.fromFile(initFileName)
      val rawLines = try {
        src.getLines().zipWithIndex.map { case (line, idx) => (line, idx + 1) }.toVector
      } finally {
        src.close()
      }

      val maxValue = (BigInt(1) << wordWidth) - 1
      val parsed = rawLines.map { case (rawLine, lineNum) =>
        parseHexLine(rawLine, lineNum, maxValue, wordWidth)
      }

      val errors = parsed.collect { case Left(msg) => msg }
      require(
        errors.isEmpty,
        s"Init file '$initFileName' has ${errors.size} error(s):\n${errors.mkString("\n")}"
      )

      val data = parsed.collect { case Right(Some(value)) => value }
      require(
        data.length == depth,
        s"Init file '$initFileName': expected $depth data entries after stripping blanks/comments, got ${data.length}"
      )

      data
    }
  }
}