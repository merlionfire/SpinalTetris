package IPS.keyboard

import spinal.core._
import spinal.lib._
import spinal.lib.fsm.{State, StateFsm, StateMachine}
import IPS.ps2._
import spinal.lib.fsm.StateMachine
import utils.PathUtils

import scala.collection.mutable

/**
 * A Scala object containing all known PS/2 keyboard scan codes.
 *
 * This list is based on the reference: http://www.technoblogy.com/show?4QEL
 * Single-byte scan codes represent the 'make' code (when the key is pressed).
 * The 'break' code is typically the make code with the most significant bit set (e.g., 0x1A -> 0xFA).
 *
 * Multi-byte scan codes are noted with comments. A single 'val' cannot represent
 * a multi-byte sequence, so the first byte of the sequence is listed for convenience.
 */
object PS2ScanCodes {

  // --- Escape and Function Keys ---
  val KEY_ESC = 0x76
  val KEY_F1 = 0x05
  val KEY_F2 = 0x06
  val KEY_F3 = 0x04
  val KEY_F4 = 0x0C
  val KEY_F5 = 0x03
  val KEY_F6 = 0x0B
  val KEY_F7 = 0x83
  val KEY_F8 = 0x0A
  val KEY_F9 = 0x01
  val KEY_F10 = 0x09
  val KEY_F11 = 0x78
  val KEY_F12 = 0x07

  // --- Top Row: Numbers and Symbols ---
  val KEY_GRAVE_ACCENT_TILDE = 0x0E
  val KEY_1 = 0x16
  val KEY_2 = 0x1E
  val KEY_3 = 0x26
  val KEY_4 = 0x25
  val KEY_5 = 0x2E
  val KEY_6 = 0x36
  val KEY_7 = 0x3D
  val KEY_8 = 0x3E
  val KEY_9 = 0x46
  val KEY_0 = 0x45
  val KEY_HYPHEN_MINUS = 0x4E
  val KEY_EQUAL = 0x55
  val KEY_BACKSPACE = 0x66

  // --- QWERTY Row ---
  val KEY_TAB = 0x0D
  val KEY_Q = 0x15
  val KEY_W = 0x1D
  val KEY_E = 0x24
  val KEY_R = 0x2D
  val KEY_T = 0x2C
  val KEY_Y = 0x35
  val KEY_U = 0x3C
  val KEY_I = 0x43
  val KEY_O = 0x44
  val KEY_P = 0x4D
  val KEY_LEFT_BRACKET = 0x54
  val KEY_RIGHT_BRACKET = 0x5B
  val KEY_ENTER = 0x5A

  // --- ASDF Row ---
  val KEY_CAPS_LOCK = 0x58
  val KEY_A = 0x1C
  val KEY_S = 0x1B
  val KEY_D = 0x23
  val KEY_F = 0x2B
  val KEY_G = 0x34
  val KEY_H = 0x33
  val KEY_J = 0x3B
  val KEY_K = 0x42
  val KEY_L = 0x4B
  val KEY_SEMICOLON = 0x4C
  val KEY_SINGLE_QUOTE = 0x52
  val KEY_BACKSLASH = 0x5D

  // --- ZXCV Row ---
  val KEY_LSHIFT = 0x12
  val KEY_Z = 0x1A
  val KEY_X = 0x22
  val KEY_C = 0x21
  val KEY_V = 0x2A
  val KEY_B = 0x32
  val KEY_N = 0x31
  val KEY_M = 0x3A
  val KEY_COMMA = 0x41
  val KEY_PERIOD = 0x49
  val KEY_FORWARD_SLASH = 0x4A
  val KEY_RSHIFT = 0x59

  // --- Bottom Row: Modifiers and Space Bar ---
  val KEY_LCTRL = 0x14
  val KEY_LWIN = 0xE0 // Multi-byte scan code: E0 1F
  val KEY_LALT = 0x11
  val KEY_SPACE = 0x29
  val KEY_RALT = 0xE0 // Multi-byte scan code: E0 11
  val KEY_RWIN = 0xE0 // Multi-byte scan code: E0 27
  val KEY_MENU = 0xE0 // Multi-byte scan code: E0 2F
  val KEY_RCTRL = 0xE0 // Multi-byte scan code: E0 14

  // --- Navigation and Editing Keys ---
  val KEY_INSERT = 0xE0 // Multi-byte scan code: E0 70
  val KEY_HOME = 0xE0 // Multi-byte scan code: E0 6C
  val KEY_PAGE_UP = 0xE0 // Multi-byte scan code: E0 7D
  val KEY_DELETE = 0xE0 // Multi-byte scan code: E0 71
  val KEY_END = 0xE0 // Multi-byte scan code: E0 69
  val KEY_PAGE_DOWN = 0xE0 // Multi-byte scan code: E0 7A

  // --- Arrow Keys ---
  val KEY_UP_ARROW = 0xE0 // Multi-byte scan code: E0 75
  val KEY_LEFT_ARROW = 0xE0 // Multi-byte scan code: E0 6B
  val KEY_DOWN_ARROW = 0xE0 // Multi-byte scan code: E0 72
  val KEY_RIGHT_ARROW = 0xE0 // Multi-byte scan code: E0 74

  // --- Numeric Keypad Keys ---
  val KEY_NUM_LOCK = 0x77
  val KEY_KEYPAD_SLASH = 0xE0 // Multi-byte scan code: E0 4A
  val KEY_KEYPAD_ASTERISK = 0x7C
  val KEY_KEYPAD_MINUS = 0x7B
  val KEY_KEYPAD_PLUS = 0x79
  val KEY_KEYPAD_ENTER = 0xE0 // Multi-byte scan code: E0 5A
  val KEY_KEYPAD_1 = 0x69
  val KEY_KEYPAD_2 = 0x72
  val KEY_KEYPAD_3 = 0x7A
  val KEY_KEYPAD_4 = 0x6C
  val KEY_KEYPAD_5 = 0x75
  val KEY_KEYPAD_6 = 0x7D
  val KEY_KEYPAD_7 = 0x6B
  val KEY_KEYPAD_8 = 0x73
  val KEY_KEYPAD_9 = 0x74
  val KEY_KEYPAD_0 = 0x70
  val KEY_KEYPAD_PERIOD = 0x71

  // --- Miscellaneous Keys ---
  val KEY_PRINT_SCREEN = 0xE0 // Multi-byte scan code: E0 12
  val KEY_SCROLL_LOCK = 0x7E
  val KEY_PAUSE = 0xE1 // Multi-byte scan code: E1 14 77 E1 F0 14 C1
  val KEY_BREAK = 0xF0
}


case  class KdPs2Config( )  {
  import PS2ScanCodes._
  val keyMap = mutable.LinkedHashMap[String, Int](
    "start" -> KEY_W,
    "down" -> KEY_S,
    "left" -> KEY_A,
    "right" -> KEY_D,
    "rotate" ->  KEY_SPACE ,
    "drop" -> KEY_ENTER
  )

  def keysValidNum =  keyMap.size // exclude break
}

class kd_ps2 ( config : KdPs2Config ) extends Component  {

  import config._

  val io = new Bundle {
    val ps2_clk = inout(Analog(Bool()))
    val ps2_data = inout(Analog(Bool()))
    val rd_data = master Flow UInt (8 bit)
    val keys_valid = out Bits(keysValidNum bit )
  }

  noIoPrefix()
  import PS2ScanCodes._

  // ====================================================
  //          Instantiate Sub
  // ====================================================

  val ps2_inst = new ps2_host_rxtx()

  import ps2_inst.io._

  // ====================================================
  //          Connection
  // ====================================================

  io.ps2_clk <> ps2.clk
  io.ps2_data <> ps2.data

  io.rd_data.valid := ps2.rddata_valid
  io.rd_data.payload := ps2.rd_data

  ps2.wr_stb := False
  ps2.wr_data := 0


  // ====================================================
  //          FSM
  // ====================================================
  val is_key_received = Bool()
  var is_key_2nd_recevied = Bool()

  val break_tick = ps2.rddata_valid && (ps2.rd_data === KEY_BREAK)

  val rx_fsm = new StateMachine {

    val IDLE = makeInstantEntry()
    IDLE.onEntry {
    }
    IDLE.whenIsActive {

      when ( is_key_received ) {
        goto ( WAIT_BREAK )
      }
    }

    val WAIT_BREAK : State = new State {
      whenIsActive {
        when ( break_tick ) {
          goto(WAIT_LAST)
        }
      }

    }

    val WAIT_LAST : State = new State {
      whenIsActive {
        when ( is_key_2nd_recevied ) {
           goto(IDLE)
        }
      }
    }

    val DEFAULT : State = new State {
      whenIsActive {
        goto(IDLE)
      }
    }

  }

  //********* Control ********************//

  val is_fsm_in_idle = rx_fsm.isActive(rx_fsm.IDLE)
  val is_fsm_exit_wait_last = rx_fsm.isExiting(rx_fsm.WAIT_LAST )

  val keys_area = keyMap.toList.zipWithIndex.map {  case  ( ( action, keyCode), i ) =>
    new Area {
      val tick = ps2.rddata_valid && (ps2.rd_data === keyCode)
      val valid = RegNextWhen(  tick, is_fsm_in_idle  , False)
      valid.clearWhen(is_fsm_exit_wait_last  )
      val tick_2nd = tick & valid
      io.keys_valid(i) := valid
    }  .setName(action)
  }

  is_key_received := keys_area.map(_.tick).orR
  is_key_2nd_recevied := keys_area.map(_.tick_2nd).orR


}


object kdPs2Main{
  def main(args: Array[String]) {
    SpinalConfig(
      targetDirectory = PathUtils.getRtlOutputPath(getClass).toString,
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true,
      mergeSyncProcess = true,
      inlineConditionalExpression = true,
        inlineRom = true
    ).generateVerilog(
      gen = new kd_ps2(KdPs2Config())
    ).mergeRTLSource()
  }
}