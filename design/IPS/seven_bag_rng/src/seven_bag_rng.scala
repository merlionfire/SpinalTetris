package IPS.seven_bag_rng

import spinal.core._
import spinal.lib._
import spinal.lib.fsm.{State, StateMachine}
import utils.PathUtils


class seven_bag_rng extends Component {

  val io = new Bundle {
    val enable = in Bool() // New enable signal
    val shape = master Flow( UInt(3 bits) )
  }

  val lfsr = Reg(UInt(6 bits)) init 0x2D // 0b101101
  val generatedNumbers = Vec(Reg(U(0, 3 bits)), 7)
  val count = Reg(UInt(3 bits)) init 0
  val existed = Reg(Bool())
  val shift = Bool()

  //lfsr := Mux(io.enable, (lfsr(4 downto 0) ## (lfsr(5) ^ lfsr(3))).resized, lfsr) // LFSR update only when enable is high


  when( shift) {
    lfsr := (lfsr(4 downto 0) ## (lfsr(5) ^ lfsr(3))).resized.asUInt
  }

  val nextNumber = lfsr(2 downto 0)


  val invalid = RegNext( nextNumber === 7 )

  existed := False
  for (i <- 0 to 6) {
    when(count > i && nextNumber === generatedNumbers(i)) {
      existed := True
    }
  }

  io.shape.payload := nextNumber

  val fsm = new StateMachine {

    shift := False
    io.shape.valid := False

    val IDLE = makeInstantEntry()
    IDLE.whenIsActive{
      when ( io.enable ) {
        goto(CHECK)
      }
    }

    val CHECK : State = new State {
      whenIsActive {
        when(existed || invalid ) {
          goto(SHIFT)
        } otherwise {
          goto(OUTPUT)
        }
      }
    }

    val OUTPUT : State = new State {
      whenIsActive {
        io.shape.valid := True
        generatedNumbers(count) := nextNumber
        count := count + 1
        shift := True
        goto(DONE)
      }
    }

    val DONE : State = new State {

      whenIsActive {
        when(count === 7) {
          count := 0
          for (i <- 0 to 6) {
            generatedNumbers(i) := 0
          }
        }
        goto(IDLE)
      }

    }

    val SHIFT : State = new State {

      whenIsActive {
        shift := True
        goto(ELEMENT)
      }
    }

    val ELEMENT : State = new State {
      whenIsActive {
        goto(CHECK)
      }
    }

  }

}

object sevenBagRngMain{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new seven_bag_rng()
    )
  }
}