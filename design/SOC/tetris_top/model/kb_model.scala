package SOC.tetris_top.model


import SOC.tetris_top.tetris_top
import spinal.core._
import spinal.core.sim._
import spinal.lib._

import scala.collection.mutable
import scala.util.Random


// PS2 Interface Bundle
case class PS2Interface( clk : Bool, data : Bool ) extends Bundle with IMasterSlave {

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
  val scanCodeMapRev = scanCodeMap.map(_.swap)

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

// Define the states for our state machine using the Scala 2 pattern.
// A sealed trait can only be extended in the same file, giving us
// similar safety to an enum.
sealed trait State
object State {
  case object Idle extends State
  case object ExpectingBreakCode extends State
  case object ExpectingExtendedCode extends State
  case object ExpectingExtendedBreakCode extends State
}


// PS2 Device Model (Keyboard simulation)
class PS2KbDeviceModel(ps2: PS2Interface, clockDomain: ClockDomain) {
  import PS2KbScanCodes._

  // working_clk = 10us
  // ps2 clock = 80us
  // half_duty_cycles = 4
  // full_duty = 60us - 100 us => 16.7KHz - 10 HZ
  // 60su < T < 100 us
  private val clockFreqInMHz = 50
  def usToCycles( duty : Int ) = clockFreqInMHz * duty
  private val ps2ClockPeriod = 50000 // 50us = 20kHz (PS2 spec: 10-16.7kHz)
  // 50MHz ->   80 (us)  / ( 1 / 50 ( MHz) ) = 80 x 50 = 4000
  private val full_duty_cylces = usToCycles(80) // 4000
  private val half_duty_cylces = full_duty_cylces / 2

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

  // Convert data byte to PS2 packet (11 bits: start, 8 data, parity, stop)
  private def createPacket(data: Int): Array[Boolean] = {
    val packet = Array.ofDim[Boolean](11)
    packet(0) = false // Start bit

    // Data bits (LSB first)
    for (i <- 0 until 8) {
      packet(i + 1) = ((data >> i) & 1) == 1
    }
    // Odd parity bit ensure that the total number of 1s in the data byte (including the parity bit) is always odd.
    packet(9) = ! packet.slice(1, 9).reduce(_ ^ _)
    packet(10) = true // Stop bit
    packet
  }

  // Calculate parity for received packet is odd
  private def checkParity(packet: Int): Boolean = {
    Integer.bitCount(packet) % 2 == 1
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
      //clockDomain.waitSampling(delay)
      sleep(  delay us )
      sendKeyRelease(char)
      //clockDomain.waitSampling(delay)
      sleep(  delay us )

    }
  }

  // Send special key combinations
  def sendCtrlAltDel(): Unit = {
    queueScanCode(LEFT_CTRL)
    queueScanCode(LEFT_ALT)
    queueScanCode(DELETE)
    clockDomain.waitSampling(1000)
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

  def delay() = {

    //println( "simTime : " + simTime() + "[PS2 DEV] Start to wait for while ... ")
    clockDomain.waitSampling(200)
    //println( "simTime : " + simTime() + "[PS2 DEV] I wake up now ... ")
  }

  // Main simulation process. It corresponds to UVM run_phase() task
  def run(): Unit = {
    fork {

      println(s"[PS2 DEV] run() is called now ...")
      reset()
      println(s"[PS2 DEV] reset() is done !!! ")
      while (true) {
        if (!inhibitMode) {
          // Check if we need to start a new transmission
          //println(s"[PS2 DEV] Checking if some data are to be transmitted !!! ")
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
         // monitorHostCommunication()
        }
        //println(s"[PS2 DEV] Sleep for a while  !!! ")
        clockDomain.waitSampling(200)
        //println(s"[PS2 DEV] I am wake up !!! ")
      }
    }
  }

  private def startTransmission(data: Int): Unit = {
    frameBits = createPacket(data)
    currentBitIndex = 0
    isTransmitting = true
    clockCounter = 0
    println(s"PS2: Starting transmission of 0x${data.toHexString}")
  }

  // Driver interface
  private def handleTransmission(): Unit = {
    //clockCounter += 1

    clockDomain.waitSampling()
    println("simTime : " + simTime() + s"[PS2 DEV] handleTransmission() is entered ! ")
    for ( data <- frameBits ) {
      //println("simTime : " + simTime() + s"[PS2 DEV] clk <- true, data <- ${data.toString}  ")
      ps2.clk #= true
      ps2.data #= data
      //println("simTime : " + simTime() + s"[PS2 DEV] wait for ${half_duty_cylces} cycles ")
      clockDomain.waitSampling(half_duty_cylces)
      ps2.clk #= false
      //println("simTime : " + simTime() + s"[PS2 DEV] clk <- false, data <- NO Change ")
      //println("simTime : " + simTime() + s"[PS2 DEV] wait for ${half_duty_cylces} cycles ")
      clockDomain.waitSampling(half_duty_cylces)
    }
    ps2.clk #= true
    ps2.data #= true
    isTransmitting = false
    println(s"PS2: Transmission complete.")
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

  def waitForIdle(timeout: Int = 100): Unit = {
    var timeoutCounter = 0
    while (!isIdle() && timeoutCounter < timeout) {
      clockDomain.waitSampling(full_duty_cylces)
      timeoutCounter += 1
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
      clockDomain.waitSampling(delay)
      sendKeyRelease(key)
      clockDomain.waitSampling(delay)
    }
  }

  def generateTypingBurst(text: String): Unit = {
    for (char <- text) {
      sendKeyPress(char)
      clockDomain.waitSampling(200)
      sendKeyRelease(char)
      clockDomain.waitSampling(200) // Short gap between keys
    }
  }

  // Error injection for testing
  def injectParityError(): Unit = {
    // This would modify the next transmission to have wrong parity
    // Implementation would require modifying the createPacket method
  }

  def injectClockGlitch(): Unit = {
    fork {
      ps2.clk #= false
      wait(50) // Short glitch
      ps2.clk #= true
    }
  }
}

object PS2Monitor{
  def apply(ps2: PS2Interface, clockDomain: ClockDomain)(callback : (Int) => Unit) = {
    new PS2Monitor(ps2, clockDomain).addCallback(callback)
  }
}

class PS2Monitor(ps2: PS2Interface, clockDomain: ClockDomain){
  import PS2KbScanCodes._
  val callbacks = mutable.ArrayBuffer[(Int) => Unit]()

  var bitCount = 0
  var charData = 0
  val packet = Array.fill(10)(false)

  val  packetQueue = mutable.Queue[Int]()
  val  observedCharQueue = mutable.Queue[Char]()
  // Calculate parity for received packet is odd
  private def checkParity(packet: Array[Boolean]): Boolean = {
    packet.slice(1, 10).reduce(_ ^ _)
  }


  private def listBoolean2Int( packet : Array[Boolean] ) : Int = {
    packet.map(if (_) 1 else 0).reduce((a, b) => (a << 1) | b)
  }

  def addCallback(callback : (Int) => Unit): this.type = {
    callbacks += callback
    this
  }

  def isStart = bitCount == 0
  def isPacket = 1 to 8 contains( bitCount )
  def isParity = bitCount == 9
  def isStop = bitCount == 10

  def getKeyInChar = observedCharQueue.dequeue()


  def run(): Unit = {
    // Import the states from the companion object.
    import State._
    var currentState: State = Idle // Start in the Idle state
    var heldKey: Option[Char] = None

    var ps2ClockPreviousValue = true

    println("[PS2 MON] Keyboard Monitor started. Waiting for scan codes...")
    
    clockDomain.onRisingEdges {
      //println( "simTime : " + simTime() + "[PS2 MON] Clock rising edge is triggered ...")
      val ps2ClockCurrentValue = ps2.clk.toBoolean

      if (   !ps2ClockCurrentValue  && ps2ClockPreviousValue  ) {
        // negative edge of ps2.clk is observed
        //println( "simTime : " + simTime() + "[PS2 MON] negative edge of PS2 CLK is observed ...")
        //println( "simTime : " + simTime() + s"[PS2 MON] bitCount = ${bitCount} ")

        if (isStart) {
          if ( ! ps2.data.toBoolean) {
            println("[INF] PS2 : Start Bit is observed !!")
            packet(0) = false
            bitCount += 1
          }
        } else if (isPacket) {
          packet(bitCount) = ps2.data.toBoolean
          bitCount += 1
        } else if (isParity) {

          charData = listBoolean2Int(packet.slice(1, 9).reverse)
          println(f"[INF] PS2 : data 0x$charData%x is observed !!")
          packet(bitCount) = ps2.data.toBoolean
          if (!checkParity(packet)) {
            println(s"[ERR] PS2 : parity is NOT expected !!")
          }
          bitCount += 1
        } else if (isStop) {
          if (ps2.data.toBoolean) {
            println("[INF] PS2 : Stop Bit is observed !!")
          } else {
            println("[ERR] PS2 : Stop Bit is NOT observed !!")
          }
          bitCount = 0
          callbacks.foreach(_(charData))
          packetQueue.enqueue(charData)

        }

      }
      ps2ClockPreviousValue = ps2ClockCurrentValue
    }


    println("[PS2 MON] Initiate fork to process received bytes.")

    fork {
      while (true) {
        // .take() blocks and waits until an item is available in the queue.
        //println("simTime : " + simTime() + "[PS2 MON] I am checking if packetQueue has data...")


        if ( packetQueue.nonEmpty ) {
          val code = packetQueue.dequeue()
          println("simTime : " + simTime() + f"[PS2 MON] Get 0x${code}%x from packetQueue ...")
          // The core logic is a state machine implemented with a match expression.
          (currentState, code) match {
            // --- State: Idle ---
            case (Idle, 0xF0) => currentState = ExpectingBreakCode // Break code prefix
            case (Idle, 0xE0) => currentState = ExpectingExtendedCode // Extended key prefix
            case (Idle, makeCode) =>
              scanCodeMapRev.get(makeCode) match {
                case Some(key) =>
                  if (heldKey.contains(key)) {
                    println(s"[HOLD] Key: $key")
                  } else {
                    println(s"[PRESS] Key: $key")
                    heldKey = Some(key)
                  }
                case None =>
                  println(f"[INFO] Unknown make code: 0x$code%02X")
              }

            // --- State: Expecting a Break Code ---
            case (ExpectingBreakCode, breakCode) =>
              scanCodeMapRev.get(breakCode) match {
                case Some(key) =>
                  println(s"[RELEASE] Key: $key")
                  heldKey = None
                  observedCharQueue.enqueue(key)

                case None =>
                  println(f"[INFO] Unknown break code after F0: 0x$breakCode%02X")
              }
              currentState = Idle // Return to Idle state

            // --- State: Expecting an Extended Key ---
            case (ExpectingExtendedCode, 0xF0) => currentState = ExpectingExtendedBreakCode // Release of an extended key

            case (ExpectingExtendedCode, makeCode) =>
              scanCodeMapRev.get(makeCode) match {
                case Some(key) =>
                  println(s"[PRESS] Extended Key: $key")
                  heldKey = Some(key)
                case None =>
                  println(f"[INFO] Unknown extended make code: 0x$makeCode%02X")
              }
              currentState = Idle

            // --- State: Expecting an Extended Break Code ---
            case (ExpectingExtendedBreakCode, breakCode) =>
              scanCodeMapRev.get(breakCode) match {
                case Some(key) =>
                  println(s"[RELEASE] Extended Key: $key")
                  heldKey = None
                case None =>
                  println(f"[INFO] Unknown extended break code: 0x$breakCode%02X")
              }
              currentState = Idle

            case (state, unmatchedCode) =>
              println(f"[WARN] Unhandled combination! State: $state, Code: 0x$unmatchedCode%02X")
              currentState = Idle // Reset on error
          }
        }

        //clockDomain.waitSampling(2000)
        sleep(2 us)

      }

    } // end of fork
    println("[PS2 MON] Exit run().")
  } // end of run()

}

// Complete PS2 Test Environment
//class PS2KbTestEnvironment(val ps2: PS2Interface, val clockDomain: ClockDomain, isSlave : Boolean = true  ) {
class PS2KbTestEnvironment(val ps2: PS2Interface, clockDomain: ClockDomain, isSlave : Boolean = true  ) {

  val deviceModel = if ( isSlave ) new PS2KbDeviceModel(ps2, clockDomain) else null
  val ps2Monitor = PS2Monitor( ps2, clockDomain ){ _ => }

  // It corresponds to UVM_ENV run_phase
  def sendKeys( text : String, dutyInUs: Int = 20000 ) = {


    //deviceModel.typeString(text,  deviceModel.usToCycles(dutyInUs) )
    deviceModel.typeString(text,  dutyInUs )

    deviceModel.waitForIdle()
    val receivedString = ps2Monitor.observedCharQueue.dequeueAll( _ => true ). mkString
    println(s"[PS2 ENV] Received String = ${receivedString}")

  }

  def run(): Unit = {

    println("simTime : " + simTime() + s"[PS2 ENV] device and monitor have run now ..... ")
    clockDomain.waitSampling(10)
    println("simTime : " + simTime() + s"[PS2 ENV] Start to transfer strings")
    deviceModel.run()
    ps2Monitor.run()

    clockDomain.waitSampling(10)
    println("simTime : " + simTime() + s"[PS2 ENV] run() is exit")
  }




//  def testFullKeyPressRelease(key: Char): Boolean = {
//    deviceModel.sendKeyPress(key)
//    deviceModel.sendKeyRelease(key)
//    deviceModel.waitForIdle()
//
//    //val received = hostModel.waitForBytes(2, 10000)
//    val expectedScanCode = scanCodeMap.getOrElse(key.toLower, -1)
//
//    received.length == 2 &&
//      received(0) == expectedScanCode &&
//      received(1) == PS2ScanCodes.BREAK_CODE
//  }
}