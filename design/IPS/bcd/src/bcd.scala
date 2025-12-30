package IPS.bcd

import spinal.core._
import spinal.lib._
import spinal.lib.fsm._
import utils.PathUtils

// Component implementing Double Dabble Algorithm (Binary to BCD conversion)
class bcd(binaryWidth: Int) extends Component {


  // Import configuration parameters for simplified access
  // Calculate number of BCD digits needed: ceil(log10(2^binaryWidth))
  val bcdDigits = Math.ceil(binaryWidth * Math.log10(2)).toInt
  val bcdWidth = bcdDigits * 4  // Each BCD digit needs 4 bits


  val io = new Bundle {
    // Input: Binary data as a Flow stream
    val data_in_bin = slave(Flow(UInt( binaryWidth bits)))

    // Output: BCD data as a Flow stream
    val data_out_dec = master(Flow(Bits(bcdWidth bits)))
  }

  noIoPrefix()

  // Internal registers for the algorithm
  val shiftRegister = Reg(Bits( ( bcdWidth + binaryWidth ) bits)) init(0)
  val shiftCounter = Reg( UInt(log2Up( binaryWidth + 1) bits)) init(0)
  val isProcessing = Reg(Bool()) init(False)


  // State machine for Double Dabble algorithm
  val fsm = new StateMachine {
    // IDLE: Wait for new input data

    val IDLE: State = new State with EntryPoint {
      whenIsActive {
        when(io.data_in_bin.valid) {
          // Load binary input into lower bits of shift register
          shiftRegister := io.data_in_bin.payload.asBits.resized
          shiftCounter := 0
          isProcessing := True
          goto(ADD3_CHECK)
        }
      }
    }

    // ADD3_CHECK: Check each BCD digit, add 3 if >= 5
    val ADD3_CHECK: State = new State {
      whenIsActive {
        // Process each BCD digit from MSB to LSB

        val updatedRegister = Bits( ( bcdWidth + binaryWidth ) bits)
        updatedRegister := shiftRegister

        // Iterate through each BCD digit position
        for (i <- 0 until bcdDigits) {
          val digitStartBit = binaryWidth + i * 4
          val digit = shiftRegister(digitStartBit + 3 downto digitStartBit).asUInt

          // If digit >= 5, add 3 (Shift-and-Add-3 algorithm rule)
          when(digit >= 5) {
            updatedRegister(digitStartBit + 3 downto digitStartBit) := (digit + 3).asBits
          }
        }
        shiftRegister := updatedRegister
        goto(SHIFT)
      }
    }

    // SHIFT: Left shift the entire register by 1 bit
    val SHIFT: State = new State {
      whenIsActive {
        shiftRegister := (shiftRegister |<< 1)
        shiftCounter := shiftCounter + 1

        // Check if all bits have been shifted
        when(shiftCounter === ( binaryWidth - 1 ) ) {
          goto(DONE)
        } otherwise {
          goto(ADD3_CHECK)
        }
      }
    }

    // DONE: Output the BCD result
    val DONE: State = new State {
      whenIsActive {
        isProcessing := False
        goto(IDLE)
      }
    }
  }

  // Output logic
  io.data_out_dec.valid := fsm.isActive(fsm.DONE)

  // Extract BCD digits from upper bits of shift register
  io.data_out_dec.payload := shiftRegister( ( bcdWidth + binaryWidth - 1 ) downto binaryWidth )


}

object bcdMain{

  def main(args: Array[String]) {

    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true
    ).generateVerilog(
      gen = new bcd(10)
    )
  }
}
