package IPS.controller

import config.{BuildConfig, ElabProfiles, runSimConfig}
import org.scalatest.funsuite.AnyFunSuite
import spinal.core.Bool
import spinal.core.sim._
import utils.PathUtils

import scala.collection.mutable.ArrayBuffer

class ControllerTest extends AnyFunSuite {

  private val compiler: String = "vcs" // verilator"
  private val config: ControllerConfig = ControllerConfig(
	rowNum = 23,
	colNum = 12,
	levelFallInCycle = 200,
	lockDownInCycle = 100
  )
  private val runFolder: String = PathUtils.getRtlOutputPath(getClass, targetName = "sim").toString

  private lazy val compiled: SimCompiled[controller] = runSimConfig(runFolder, compiler)
	.compile {
	  implicit val buildConfig: BuildConfig = ElabProfiles.Debug
	  new controller(config)
	}

  private case class MotionInput(
								  drop: Boolean = false,
								  moveDown: Boolean = false,
								  moveLeft: Boolean = false,
								  moveRight: Boolean = false,
								  rotate: Boolean = false
								)

  private case class CheckResult(sequence: String, step: String, passed: Boolean, detail: String)

  private final class ScenarioSummary {
		private val results = ArrayBuffer[CheckResult]()

		def check(sequence: String, step: String, condition: Boolean, detail: String): Unit = {
			val status = if (condition) "PASS" else "FAIL"
			println(s"[INFO] @[${simTime()}] sequence=$sequence step=$step status=$status detail=$detail")
			results += CheckResult(sequence, step, condition, detail)
		}

		def printFinal(name: String): Unit = {
			println(s"[INFO] @[${simTime()}] ${"=" * 80}")
			println(s"[INFO] @[${simTime()}] $name final summary")
			results.groupBy(_.sequence).toSeq.sortBy(_._1).foreach { case (sequence, sequenceResults) =>
				val passed = sequenceResults.forall(_.passed)
				val status = if (passed) "PASS" else "FAIL"
				val failedSteps = sequenceResults.filterNot(_.passed).map(_.step).mkString(",")
				val detail = if (failedSteps.isEmpty) "all steps passed" else s"failed_steps=$failedSteps"
				println(s"[INFO] @[${simTime()}] sequence=$sequence status=$status checks=${sequenceResults.size} $detail")
			}
			println(s"[INFO] @[${simTime()}] ${"=" * 80}")
		}

		def failOnError(): Unit = {
			val failures = results.filterNot(_.passed)
			if (failures.nonEmpty) {
			simFailure(s"[ERROR] @[${simTime()}] ${failures.size} controller checks failed")
			}
		}
  }

  private def initialize(dut: controller): Unit = {
		dut.clockDomain.forkStimulus(10)
		SimTimeout(5000)
		dut.io.game_start #= false
		dut.io.move_left #= false
		dut.io.move_right #= false
		dut.io.move_down #= false
		dut.io.rotate #= false
		dut.io.drop #= false
		dut.io.screen_is_ready #= false
		dut.io.playfield_in_idle #= false
		dut.io.playfield_allow_action #= false
		dut.io.collision_status.valid #= false
		dut.io.collision_status.payload #= false
		dut.clockDomain.waitSampling(5)
		println(s"[INFO] @[${simTime()}] controller initialized")
  }

  private def pulseAndSample(dut: controller, signal: Bool): Unit = {
		signal #= true
		dut.clockDomain.waitSampling()
		signal #= false
  }

  private def waitUntil(dut: controller, maxCycles: Int, description: String)(condition: => Boolean): Boolean = {
		var cycles = 0
		while (!condition && cycles < maxCycles) {
			dut.clockDomain.waitSampling()
			cycles += 1
		}
		val passed = condition
		println(s"[INFO] @[${simTime()}] wait description=$description cycles=$cycles status=${if (passed) "PASS" else "FAIL"}")
		passed
  }

  private def driveCollision(dut: controller, isCollision: Boolean): Unit = {
		dut.io.collision_status.payload #= isCollision
		dut.io.collision_status.valid #= true
		dut.clockDomain.waitSampling()
		dut.io.collision_status.valid #= false
		dut.io.collision_status.payload #= false
  }

  private def startAndReachPlace(dut: controller): Boolean = {
		dut.io.screen_is_ready #= true
		pulseAndSample(dut, dut.io.game_start)
		waitUntil(dut, maxCycles = 8, description = "RANDOM_GEN asserts gen_piece_en") {
			dut.io.gen_piece_en.toBoolean
		} && waitUntil(dut, maxCycles = 4, description = "PLACE state becomes active") {
			dut.io.debug.controller_in_place.toBoolean
		}
  }

  private def startAndReachFalling(dut: controller): Boolean = {
		val reachedPlace = startAndReachPlace(dut)
		driveCollision(dut, isCollision = false)
		reachedPlace && waitUntil(dut, maxCycles = 4, description = "PLACE exits after no-collision response") {
			!dut.io.debug.controller_in_place.toBoolean
		}
  }

	// No cycle is consumed inside setMotionInputs, so the caller can control when the motion input signals are sampled by the controller
	  private def setMotionInputs(dut: controller, input: MotionInput, value: Boolean): Unit = {
		dut.io.drop #= (input.drop && value)
		dut.io.move_down #= (input.moveDown && value)
		dut.io.move_left #= (input.moveLeft && value)
		dut.io.move_right #= (input.moveRight && value)
		dut.io.rotate #= (input.rotate && value)
  }

	// Stimulus a pulse for the requested motion input, then deassert it after one cycle to simulate a button press
  private def requestMotion(dut: controller, input: MotionInput): Unit = {
		setMotionInputs(dut, input, value = true) // enable all input signals for the requested motion
		dut.clockDomain.waitSampling()
		setMotionInputs(dut, input, value = false) //deassert inputs after one cycle to simulate a button press
  }

  private def anyMoveOut(dut: controller): Boolean = {
		dut.io.move_out.left.toBoolean ||
			dut.io.move_out.right.toBoolean ||
			dut.io.move_out.rotate.toBoolean ||
			dut.io.move_out.down.toBoolean
  }

  private def waitForPulse(dut: controller, signal: Bool, maxCycles: Int): Boolean = {
		var cycles = 0
		var observed = signal.toBoolean
		while (!observed && cycles < maxCycles) {
			dut.clockDomain.waitSampling()
			cycles += 1
			observed = signal.toBoolean
		}
		observed
  }

  private def acknowledgeMove(dut: controller): Unit = {
		dut.clockDomain.waitSampling()
		driveCollision(dut, isCollision = false)
		dut.clockDomain.waitSampling()
  }

  private def runSimpleMove(dut: controller, summary: ScenarioSummary, sequence: String, step: String, request: MotionInput, expectedPulse: Bool): Unit = {
		requestMotion(dut, request)
		val pulseObserved = waitForPulse(dut, expectedPulse, maxCycles = 4)
		summary.check(sequence, step, pulseObserved, "expected move_out pulse was observed")
		acknowledgeMove(dut)
  }

  private def checkStartupRestart(dut: controller, summary: ScenarioSummary): Unit = {
		summary.check("startup", "reach-place", startAndReachPlace(dut), "game_start and screen_is_ready reach PLACE")
		driveCollision(dut, isCollision = true)
		summary.check(
			"game-over",
			"place-collision-enters-end",
			waitUntil(dut, maxCycles = 4, description = "END state after PLACE collision") {
			dut.io.debug.controller_in_end.toBoolean
			},
			"PLACE collision moves controller to END"
		)

		dut.io.game_start #= true
		sleep(1)
		summary.check("restart", "soft-reset-pulse", dut.io.softReset.toBoolean, "softReset pulses while restarting from END")
		summary.check("restart", "game-restart-pulse", dut.io.game_restart.toBoolean, "game_restart pulses while restarting from END")
		dut.clockDomain.waitSampling()
		dut.io.game_start #= false

		summary.check(
			"restart",
			"new-piece-after-restart",
			waitUntil(dut, maxCycles = 8, description = "new piece after restart") {
			dut.io.gen_piece_en.toBoolean
			},
			"controller requests a new piece after restart"
		)
  }

  private def runSingleMotionSequence(dut: controller, summary: ScenarioSummary): Unit = {
		dut.io.playfield_allow_action #= true
		runSimpleMove(dut, summary, "single-motion-sequence", "move-left", MotionInput(moveLeft = true), dut.io.move_out.left)
		runSimpleMove(dut, summary, "single-motion-sequence", "move-right", MotionInput(moveRight = true), dut.io.move_out.right)
		runSimpleMove(dut, summary, "single-motion-sequence", "rotate", MotionInput(rotate = true), dut.io.move_out.rotate)

		requestMotion(dut, MotionInput(moveDown = true))
		summary.check(
			"single-motion-sequence",
			"move-down",
			waitForPulse(dut, dut.io.move_out.down, maxCycles = 4),
			"move_down request enters DOWN and asserts move_out.down"
		)
		driveCollision(dut, isCollision = false)
		dut.clockDomain.waitSampling()
		}

		private def runAllowGatedSequence(dut: controller, summary: ScenarioSummary): Unit = {
		dut.io.playfield_allow_action #= false
		requestMotion(dut, MotionInput(moveLeft = true))
		dut.clockDomain.waitSampling(3)
		summary.check("allow-gated-sequence", "blocked-while-not-allowed", !anyMoveOut(dut), "pending move is held while playfield disallows action")
		dut.io.playfield_allow_action #= true
		summary.check(
			"allow-gated-sequence",
			"released-when-allowed",
			waitForPulse(dut, dut.io.move_out.left, maxCycles = 4),
			"held move_left request is issued after playfield_allow_action rises"
		)
		acknowledgeMove(dut)
  }

  private def runHardDropSequence(dut: controller, summary: ScenarioSummary): Unit = {
	requestMotion(dut, MotionInput(drop = true))
	summary.check(
	  "hard-drop-sequence",
	  "drop-asserts-down",
	  waitForPulse(dut, dut.io.move_out.down, maxCycles = 4),
	  "drop request enters DROP and asserts move_out.down"
	)
	driveCollision(dut, isCollision = true)
	summary.check(
	  "hard-drop-sequence",
	  "collision-enters-lockdown",
	  waitUntil(dut, maxCycles = 4, description = "LOCKDOWN after hard-drop collision") {
		dut.io.debug.controller_in_lockdown.toBoolean
	  },
	  "collision response during DROP moves controller to LOCKDOWN"
	)
  }

  private def runAutoLockSequence(dut: controller, summary: ScenarioSummary): Unit = {
	summary.check(
	  "auto-lock",
	  "timeout-requests-down-check",
	  waitForPulse(dut, dut.io.move_out.down, maxCycles = config.levelFallInCycle + 4),
	  "drop timeout enters LOCK and requests one down collision check"
	)
	driveCollision(dut, isCollision = true)
	summary.check(
	  "auto-lock",
	  "lockdown-after-collision",
	  waitUntil(dut, maxCycles = 4, description = "LOCKDOWN after automatic fall collision") {
		dut.io.debug.controller_in_lockdown.toBoolean
	  },
	  "collision in LOCK moves controller to LOCKDOWN"
	)
	summary.check(
	  "auto-lock",
	  "lock-pulse",
	  waitForPulse(dut, dut.io.lock, maxCycles = config.lockDownInCycle + 6),
	  "lock asserts after lockdown timeout"
	)

	dut.io.playfield_in_idle #= true
	summary.check(
	  "auto-lock",
	  "next-piece",
	  waitUntil(dut, maxCycles = config.lockDownInCycle + 8, description = "next RANDOM_GEN after clean/wait") {
		dut.io.gen_piece_en.toBoolean
	  },
	  "controller waits for playfield idle and requests next piece"
	)
  }

  test("startup, place collision, and game restart are self-checked") {
	compiled.doSimUntilVoid(seed = 42) { dut =>
	  val summary = new ScenarioSummary
	  initialize(dut)
	  checkStartupRestart(dut, summary)
	  summary.printFinal("startup/restart")
	  summary.failOnError()
	  simSuccess()
	}
  }

  test("external motion controls share one scenario-driven FSM test") {
	compiled.doSimUntilVoid(seed = 42) { dut =>
	  val summary = new ScenarioSummary
	  initialize(dut)
	  summary.check("setup", "reach-falling", startAndReachFalling(dut), "controller accepts first piece and reaches motion phase")
	  runSingleMotionSequence(dut, summary)
	  runAllowGatedSequence(dut, summary)
	  runHardDropSequence(dut, summary)
	  summary.printFinal("external motion controls")
	  summary.failOnError()
	  simSuccess()
	}
  }

  test("automatic fall timeout locks piece and requests the next one") {
	compiled.doSimUntilVoid(seed = 42) { dut =>
	  val summary = new ScenarioSummary
	  initialize(dut)
	  summary.check("setup", "reach-falling", startAndReachFalling(dut), "controller reaches FALLING without user motion")
	  runAutoLockSequence(dut, summary)
	  summary.printFinal("automatic fall lock")
	  summary.failOnError()
	  simSuccess()
	}
  }
}

