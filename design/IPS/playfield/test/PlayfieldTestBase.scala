package IPS.playfield

import spinal.core.SpinalEnumElement
import spinal.core.sim._


trait PlayfieldTestBase {

  def initDUT( dut : playfield ) = {
    println(s"[INFO] @${simTime()} initDut is called .......")
    dut.clockDomain.waitSampling()
    dut.io.playfield_backdoor.valid #= false
    dut.io.fsm_reset #= false
    dut.io.read #= false
    dut.io.move_in.down #= false
    dut.io.move_in.left #= false
    dut.io.move_in.right #= false
    dut.io.move_in.rotate #= false
    dut.io.lock #= false

    dut.io.piece_in.valid #= false
    dut.io.piece_in.payload.randomize()
    dut.io.start_collision_check #= false

  }


  def readWholePlayfield(dut: playfield) = {
    dut.clockDomain.waitSamplingWhere(dut.io.motion_is_allowed.toBoolean)
    println(s"[INFO] @${simTime()} Start to front-door read whole playfield .......")
    dut.io.read #= true
    dut.clockDomain.waitSampling()
    dut.io.read #= false

  }


  def startCollisonCheck(dut: playfield) = {
    println(s"[INFO] @${simTime()} initiate collision check .......")
    dut.clockDomain.waitSampling()
    dut.io.start_collision_check #= true
    dut.clockDomain.waitSampling()
    dut.io.start_collision_check #= false

  }

  def issuePlacePiece(dut : playfield, pieceType :  SpinalEnumElement[config.TYPE.type]  ) = {
    dut.clockDomain.waitSamplingWhere( dut.io.fsm_is_idle.toBoolean )
    dut.io.piece_in.valid #= true
    dut.io.piece_in.payload #= pieceType
    dut.clockDomain.waitSampling()
    dut.io.piece_in.valid #= false
    dut.io.piece_in.payload.randomize()
  }

  def lockPiece(dut : playfield) = {
    dut.clockDomain.waitSamplingWhere(dut.io.motion_is_allowed.toBoolean)
    dut.io.lock #= true
    dut.clockDomain.waitSampling()
    dut.io.lock #= false
  }


  def forceFsmToIdle (dut : playfield ) = {
    dut.io.fsm_reset #= true
    dut.clockDomain.waitSampling(1)
    dut.io.fsm_reset #= false
  }


}
