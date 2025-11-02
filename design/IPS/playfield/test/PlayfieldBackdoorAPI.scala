package IPS.playfield
import IPS.playfield.playfield
import spinal.core.sim._
import utils.BitPatternGenerators

trait PlayfieldBackdoorAPI {

  def backdoorWritePlayfieldRow(dut: playfield, row: Int, data: Int) = {
    println(s"[INFO] @${simTime()} Backdoor write playfield row[${row}] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')}")
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= true
    dut.io.playfield_backdoor.row #= row
    dut.io.playfield_backdoor.data #= data
  }


  def backdoorWriteWholePlayfield(dut: playfield, content: Seq[Int]) = {
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
    content.zipWithIndex.foreach { case (value, i) =>
      backdoorWritePlayfieldRow(dut, i, value)
    }
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
  }

  def backdoorWriteFlowRegion(dut: playfield, content: Seq[Int], row: Int) = {

    dut.clockDomain.waitSampling()
    dut.io.flow_backdoor.valid #= false
    dut.clockDomain.waitSampling()
    dut.io.flow_backdoor.valid #= true
    dut.io.flow_backdoor.row #= row
    content.zipWithIndex.foreach { case (data, i) =>
      dut.io.flow_backdoor.data(i) #= data
      println(s"[INFO] @${simTime()} Backdoor write flow regin[${i}] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')}")
    }
    dut.clockDomain.waitSampling()
    dut.io.flow_backdoor.valid #= false
    dut.io.flow_backdoor.row.randomize()
    for (i <- content.indices) {
      dut.io.flow_backdoor.data(i).randomize()
    }
  }

  def backdoorWriteCheckerRegion(dut: playfield, content: Seq[Int], row: Int) = {

    dut.clockDomain.waitSampling()
    dut.io.checker_backdoor.valid #= false
    dut.clockDomain.waitSampling()
    dut.io.checker_backdoor.valid #= true
    dut.io.checker_backdoor.row #= row
    content.zipWithIndex.foreach { case (data, i) =>
      dut.io.checker_backdoor.data(i) #= data
      println(s"[INFO] @${simTime()} Backdoor write checker regin[${i}] \t=\t0b${String.format("%10s", Integer.toBinaryString(data)).replace(' ', '0')}")
    }
    dut.clockDomain.waitSampling()
    dut.io.checker_backdoor.valid #= false
    dut.io.checker_backdoor.row.randomize()
    for (i <- content.indices) {
      dut.io.checker_backdoor.data(i).randomize()
    }
  }


  def backdoorWritePlayfieldWithPattern(dut: playfield, length: Int, width: Int, pattern: BitPatternGenerators.Pattern, ref : Seq[Int] = null ) = {

    BitPatternGenerators.generateSequence(length, width, pattern, ref ).sample match {
      case Some(seq) =>
        backdoorWriteWholePlayfield(dut, seq)
        seq
      case None => simFailure("[ERROR] No seq is created !!!"); Nil
    }

  }

  def backdoorWriteFlowWithPattern(dut: playfield, row: Int, width: Int, pattern: BitPatternGenerators.Pattern) = {

    BitPatternGenerators.generateSequence(4, width, pattern).sample match {
      case Some(seq) =>
        backdoorWriteFlowRegion(dut, seq, row)
        seq
      case None => simFailure("[ERROR] No seq is created !!!"); Nil
    }

  }

  def backdoorWriteCheckerWithPattern(dut: playfield, row: Int, width: Int, pattern: BitPatternGenerators.Pattern, ref: Seq[Int]) = {

    // create Seq[Int] having 4 item which is "width" bit-width
    BitPatternGenerators.generateSequence(n = 4, width, pattern, ref).sample match {
      case Some(seq) =>
        backdoorWriteCheckerRegion(dut, seq, row)
        seq
      case None => simFailure("[ERROR] No seq is created !!!"); Nil
    }

  }
}
