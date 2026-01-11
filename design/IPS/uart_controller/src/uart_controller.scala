package IPS.uart_controller

import spinal.core._
import spinal.lib._
import spinal.lib.com.uart._
import utils.PathUtils

class uart_controller(systemClockFrequency: HertzNumber = 50 MHz) extends Component {

    val io = new Bundle {

      // UART interface using Uart() bundle
      val uart = master(Uart())
      // Reset signal for control outputs
      val controlReset = in Bool()
      // Game control signals
      val game_start = out Bool()
      val move_left = out Bool()
      val move_right = out Bool()
      val move_down = out Bool()
      val rotate = out Bool()
      val drop = out Bool()

    }

    // UART Configuration with initialization for 19200 baud rate
    val uartCtrlConfig = UartCtrlGenerics(
      dataWidthMax = 8,
      clockDividerWidth = 20,
      preSamplingSize = 1,
      samplingSize = 5,
      postSamplingSize = 2
    )

    val uartCtrlInitConfig = UartCtrlInitConfig(
      baudrate = 19200,
      dataLength = 7,  // 8 bits (0-7 means 8 bits)
      parity = UartParityType.NONE,
      stop = UartStopType.ONE
    )

     // Instantiate UART controller
    val uartCtrl = new UartCtrl(uartCtrlConfig)

    // Connect UART bundle
    io.uart <> uartCtrl.io.uart

    // Configure UART with calculated clock divider
//    val clockDivider = (systemClockFrequency.toBigDecimal / 19200).setScale(0, BigDecimal.RoundingMode.HALF_UP).toInt
    //uartCtrl.io.config.setClockDivider := clockDivider
    uartCtrl.io.config.setClockDivider( baudrate = uartCtrlInitConfig.baudrate Hz, clkFrequency = systemClockFrequency )
    uartCtrl.io.config.frame.dataLength := uartCtrlInitConfig.dataLength
    uartCtrl.io.config.frame.parity := uartCtrlInitConfig.parity
    uartCtrl.io.config.frame.stop := uartCtrlInitConfig.stop
    uartCtrl.io.writeBreak := False


    // Default: not writing to UART
    uartCtrl.io.write.valid := False
    uartCtrl.io.write.payload := 0

    // ASCII key codes
    val ASCII_w = 0x77
    val ASCII_a = 0x61
    val ASCII_d = 0x64
    val ASCII_s = 0x73
    val ASCII_space = 0x20
    val ASCII_enter = 0x0D

    // Control signal registers (pulse for one cycle on key press)
    val game_start_reg = Reg(Bool()) init(False)
    val move_left_reg = Reg(Bool()) init(False)
    val move_right_reg = Reg(Bool()) init(False)
    val move_down_reg = Reg(Bool()) init(False)
    val rotate_reg = Reg(Bool()) init(False)
    val drop_reg = Reg(Bool()) init(False)

    // Handle control reset and default clear
    when(io.controlReset) {
      game_start_reg := False
      move_left_reg := False
      move_right_reg := False
      move_down_reg := False
      rotate_reg := False
      drop_reg := False
    } otherwise {
//      // Default: clear all control signals (one-cycle pulse)
//      game_start_reg := False
//      move_left_reg := False
//      move_right_reg := False
//      move_down_reg := False
//      rotate_reg := False
//      drop_reg := False

      // Read from UART and decode keys
      when(uartCtrl.io.read.valid) {
        switch(uartCtrl.io.read.payload) {
          is(ASCII_w) {
            game_start_reg := True
          }
          is(ASCII_a) {
            move_left_reg := True
          }
          is(ASCII_d) {
            move_right_reg := True
          }
          is(ASCII_s) {
            move_down_reg := True
          }
          is(ASCII_space) {
            rotate_reg := True
          }
          is(ASCII_enter) {
            drop_reg := True
          }
        }
      }
    }

    // Always ready to read
    uartCtrl.io.read.ready := True

    // Connect output signals
    io.game_start := game_start_reg
    io.move_left := move_left_reg
    io.move_right := move_right_reg
    io.move_down := move_down_reg
    io.rotate := rotate_reg
    io.drop := drop_reg
}

object uartControllerMain{
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
      gen = new uart_controller ()
    ).mergeRTLSource()
  }
}