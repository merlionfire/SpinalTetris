package SOC.tetris_top.model


import spinal.core._
import spinal.core.sim._
import spinal.lib._
import scala.collection.mutable
import scala.util.Random

class kb_model {

}

// PS2 Interface Bundle
case class PS2Interface() extends Bundle with IMasterSlave {
  val clk = Bool()
  val data = Bool()

  override def asMaster(): Unit = {
    out(clk, data)
  }

  override def asSlave(): Unit = {
    in(clk, data)
  }
}

// PS2 Keyboard Scan Code definitions
object PS2KbScanCodes {
  val BREAK_CODE = 0xF0
  val EXTENDED_CODE = 0xE0

  // Common scan codes (Make codes)
  val scanCodeMap = Map(
    'a' -> 0x1C, 'b' -> 0x32, 'c' -> 0x21, 'd' -> 0x23, 'e' -> 0x24,
    'f' -> 0x2B, 'g' -> 0x34, 'h' -> 0x33, 'i' -> 0x43, 'j' -> 0x3B,
    'k' -> 0x42, 'l' -> 0x4B, 'm' -> 0x3A, 'n' -> 0x31, 'o' -> 0x44,
    'p' -> 0x4D, 'q' -> 0x15, 'r' -> 0x2D, 's' -> 0x1B, 't' -> 0x2C,
    'u' -> 0x3C, 'v' -> 0x2A, 'w' -> 0x1D, 'x' -> 0x22, 'y' -> 0x35,
    'z' -> 0x1A,
    '0' -> 0x45, '1' -> 0x16, '2' -> 0x1E, '3' -> 0x26, '4' -> 0x25,
    '5' -> 0x2E, '6' -> 0x36, '7' -> 0x3D, '8' -> 0x3E, '9' -> 0x46,
    ' ' -> 0x29, // Space
    '\n' -> 0x5A, // Enter
    '\t' -> 0x0D  // Tab
  )

  // Special keys
  val ESCAPE = 0x76
  val BACKSPACE = 0x66
  val LEFT_SHIFT = 0x12
  val RIGHT_SHIFT = 0x59
  val LEFT_CTRL = 0x14
  val LEFT_ALT = 0x11
  val CAPS_LOCK = 0x58

  // Extended keys (require E0 prefix)
  val ARROW_UP = 0x75
  val ARROW_DOWN = 0x72
  val ARROW_LEFT = 0x6B
  val ARROW_RIGHT = 0x74
  val INSERT = 0x70
  val DELETE = 0x71
  val HOME = 0x6C
  val END = 0x69
  val PAGE_UP = 0x7D
  val PAGE_DOWN = 0x7A
}
// PS2 Transaction types
sealed trait PS2Transaction
case class PS2HostToDevice(data: Int) extends PS2Transaction
case class PS2DeviceToHost(data: Int) extends PS2Transaction
case class PS2Acknowledge() extends PS2Transaction
case class PS2Resend() extends PS2Transaction

// PS2 Device Model (Keyboard simulation)
class PS2KbDeviceModel(ps2: PS2Interface, clockDomain: ClockDomain) {
  import PS2KbScanCodes._

  private val transactionQueue = mutable.Queue[PS2Transaction]()
  private var currentBitIndex = 0
  private var currentFrame = 0
  private var frameBits = Array[Boolean]()
  private var isTransmitting = false
  private var clockCounter = 0
  private val clockPeriod = 100 // microseconds (10kHz)
  private var inhibitMode = false

  // Statistics and monitoring
  private var totalFramesSent = 0
  private var totalFramesReceived = 0
  private var errorCount = 0

  def reset(): Unit = {
    transactionQueue.clear()
    currentBitIndex = 0
    currentFrame = 0
    isTransmitting = false
    clockCounter = 0
    inhibitMode = false
    ps2.clk #= true
    ps2.data #= true
    totalFramesSent = 0
    totalFramesReceived = 0
    errorCount = 0
  }

  // Convert data byte to PS2 frame (11 bits: start, 8 data, parity, stop)
  private def createFrame(data: Int): Array[Boolean] = {
    val frame = Array.ofDim[Boolean](11)
    frame(0) = false // Start bit

    // Data bits (LSB first)
    for (i <- 0 until 8) {
      frame(i + 1) = ((data >> i) & 1) == 1
    }

    // Odd parity bit ensure that the total number of 1s in the data byte (including the parity bit) is always odd.

    frame(9) = ! frame.slice(1, 9).reduce(_ ^ _)
    frame(10) = true // Stop bit
    frame
  }

  // Calculate parity for received frame
  private def checkParity(frame: Array[Boolean]): Boolean = {
    val dataAndParity = frame.slice(1, 10)
    val parityCount = dataAndParity.count(identity)
    (parityCount % 2) == 1 // Odd parity
  }

  // Queue a scan code to be sent
  def queueScanCode(scanCode: Int): Unit = {
    transactionQueue.enqueue(PS2DeviceToHost(scanCode))
  }

  // Queue multiple scan codes
  def queueScanCodes(scanCodes: Seq[Int]): Unit = {
    scanCodes.foreach(code => transactionQueue.enqueue(PS2DeviceToHost(code)))
  }

  // Send a key press (make code)
  def sendKeyPress(key: Char): Unit = {
    scanCodeMap.get(key.toLower) match {
      case Some(scanCode) => queueScanCode(scanCode)
      case None => println(s"Warning: No scan code defined for key '$key'")
    }
  }

  // Send a key release (break code)
  def sendKeyRelease(key: Char): Unit = {
    scanCodeMap.get(key.toLower) match {
      case Some(scanCode) =>
        queueScanCode(BREAK_CODE)
        queueScanCode(scanCode)
      case None => println(s"Warning: No scan code defined for key '$key'")
    }
  }

  // Send extended key press
  def sendExtendedKeyPress(keyCode: Int): Unit = {
    queueScanCode(EXTENDED_CODE)
    queueScanCode(keyCode)
  }

  // Send extended key release
  def sendExtendedKeyRelease(keyCode: Int): Unit = {
    queueScanCode(EXTENDED_CODE)
    queueScanCode(BREAK_CODE)
    queueScanCode(keyCode)
  }

  // Type a string (with proper press/release sequence)
  def typeString(text: String, delay: Int = 1000): Unit = {
    for (char <- text) {
      sendKeyPress(char)
      wait(delay)
      sendKeyRelease(char)
      wait(delay)
    }
  }

  // Send special key combinations
  def sendCtrlAltDel(): Unit = {
    queueScanCode(LEFT_CTRL)
    queueScanCode(LEFT_ALT)
    queueScanCode(DELETE)
    wait(10000)
    queueScanCode(BREAK_CODE)
    queueScanCode(DELETE)
    queueScanCode(BREAK_CODE)
    queueScanCode(LEFT_ALT)
    queueScanCode(BREAK_CODE)
    queueScanCode(LEFT_CTRL)
  }

  // Enter inhibit mode (host pulls clock low)
  def enterInhibitMode(): Unit = {
    inhibitMode = true
    ps2.clk #= false
  }

  // Exit inhibit mode
  def exitInhibitMode(): Unit = {
    inhibitMode = false
    ps2.clk #= true
  }

  // Main simulation process
  def startSimulation(): Unit = {
    fork {
      reset()

      while (true) {
        if (!inhibitMode) {
          // Check if we need to start a new transmission
          if (!isTransmitting && transactionQueue.nonEmpty) {
            val transaction = transactionQueue.dequeue()
            transaction match {
              case PS2DeviceToHost(data) =>
                startTransmission(data)
              case PS2Acknowledge() =>
                startTransmission(0xFA) // ACK
              case PS2Resend() =>
                startTransmission(0xFE) // Resend
              case _ =>
            }
          }

          // Handle ongoing transmission
          if (isTransmitting) {
            handleTransmission()
          }

          // Monitor host-to-device communication
          monitorHostCommunication()
        }

        wait(clockPeriod)
      }
    }
  }

  private def startTransmission(data: Int): Unit = {
    frameBits = createFrame(data)
    currentBitIndex = 0
    isTransmitting = true
    clockCounter = 0
    println(s"PS2: Starting transmission of 0x${data.toHexString}")
  }

  private def handleTransmission(): Unit = {
    clockCounter += 1

    // Generate clock edges (falling edge first)
    if (clockCounter % 2 == 1) {
      // Falling edge - set data
      ps2.clk #= false
      ps2.data #= frameBits(currentBitIndex)
    } else {
      // Rising edge - advance bit
      ps2.clk #= true
      currentBitIndex += 1

      if (currentBitIndex >= frameBits.length) {
        // Transmission complete
        isTransmitting = false
        totalFramesSent += 1
        ps2.data #= true // Release data line
        println(s"PS2: Transmission complete. Total frames sent: $totalFramesSent")
      }
    }
  }

  private def monitorHostCommunication(): Unit = {
    // This would monitor for host-to-device communication
    // Implementation depends on your specific needs
    // You might want to detect when host pulls clock low for request-to-send
  }

  // Utility methods for testing
  def getStatistics(): (Int, Int, Int) = {
    (totalFramesSent, totalFramesReceived, errorCount)
  }

  def isIdle(): Boolean = {
    !isTransmitting && transactionQueue.isEmpty
  }

  def waitForIdle(timeout: Int = 100000): Unit = {
    var timeoutCounter = 0
    while (!isIdle() && timeoutCounter < timeout) {
      wait(clockPeriod)
      timeoutCounter += clockPeriod
    }
    if (timeoutCounter >= timeout) {
      throw new RuntimeException("Timeout waiting for PS2 to become idle")
    }
  }

  // Test pattern generators
  def generateRandomKeyPresses(count: Int, delay: Int = 5000): Unit = {
    val keys = "abcdefghijklmnopqrstuvwxyz0123456789"
    val random = new Random()

    for (_ <- 0 until count) {
      val key = keys(random.nextInt(keys.length))
      sendKeyPress(key)
      wait(delay)
      sendKeyRelease(key)
      wait(delay)
    }
  }

  def generateTypingBurst(text: String): Unit = {
    for (char <- text) {
      sendKeyPress(char)
      wait(500) // Quick press
      sendKeyRelease(char)
      wait(200) // Short gap between keys
    }
  }

  // Error injection for testing
  def injectParityError(): Unit = {
    // This would modify the next transmission to have wrong parity
    // Implementation would require modifying the createFrame method
  }

  def injectClockGlitch(): Unit = {
    fork {
      ps2.clk #= false
      wait(50) // Short glitch
      ps2.clk #= true
    }
  }
}

// Complete PS2 Test Environment
class PS2KbTestEnvironment(ps2: PS2Interface, clockDomain: ClockDomain, isSlave : Boolean = true  ) {
  val deviceModel = if ( isSlave ) new PS2KbDeviceModel(ps2, clockDomain) else null
  //val hostModel = new PS2HostModel(ps2, clockDomain)

  def initialize(): Unit = {
    deviceModel.startSimulation()
    //hostModel.startListening()
  }

  // High-level test methods
  def testBasicKeyPress(key: Char): Boolean = {
    deviceModel.sendKeyPress(key)
    deviceModel.waitForIdle()

    val received = hostModel.waitForBytes(1, 10000)
    val expectedScanCode = PS2ScanCodes.scanCodeMap.getOrElse(key.toLower, -1)

    received.headOption.contains(expectedScanCode)
  }

  def testKeySequence(keys: String): Boolean = {
    var success = true
    for (key <- keys) {
      if (!testBasicKeyPress(key)) {
        success = false
        println(s"Failed to send key: $key")
      }
    }
    success
  }

  def testFullKeyPressRelease(key: Char): Boolean = {
    deviceModel.sendKeyPress(key)
    deviceModel.sendKeyRelease(key)
    deviceModel.waitForIdle()

    val received = hostModel.waitForBytes(2, 10000)
    val expectedScanCode = PS2ScanCodes.scanCodeMap.getOrElse(key.toLower, -1)

    received.length == 2 &&
      received(0) == expectedScanCode &&
      received(1) == PS2ScanCodes.BREAK_CODE
  }
}