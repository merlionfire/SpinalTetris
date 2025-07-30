package config

import spinal.core.ClockDomain.FixedFrequency
import spinal.core.sim.{SimConfig, SpinalSimConfig}
import spinal.core.{IntToBuilder, SpinalConfig, blackboxAll, blackboxAllWhatsYouCan}
import spinal.sim.VCSFlags

import scala.language.postfixOps

object  runSimConfig {
  def apply(runDir: String, compiler: String = "verilator") : SpinalSimConfig = {

    val buildConfig = SpinalConfig(
      targetDirectory = "rtl",
      verbose = true,
      nameWhenByFile = false,
      enumPrefixEnable = false,
      anonymSignalPrefix = "temp",
      mergeAsyncProcess = true,
      defaultClockDomainFrequency = FixedFrequency(100 MHz)
    )/* .addStandardMemBlackboxing(blackboxAllWhatsYouCan) */

    if ( compiler == "verilator" ) {
      SimConfig.withWave.withConfig(buildConfig).withTimeSpec( 1 ns, 10 ps)
        .withVerilator
        .workspacePath(runDir+"/verilator")

    } else if (compiler == "vcs" ) {
      val flags = VCSFlags(
        compileFlags = List("-verilog +v2k -ntb"), /* Useless, skip this step in dev publish */
        elaborateFlags = List("-V"), /* Useless, skip this step in dev publish */
        runFlags = List("-l sim.log")
      )
      SimConfig.withConfig(buildConfig).withTimeSpec( 1 ns, 10 ps)
        .workspacePath(runDir+"/vcs")
        .withVCS(flags).
        withFSDBWave.waveFilePrefix("verdi")
    } else {
      throw new IllegalArgumentException(
        s"Unsupported simulator compiler: '$compiler'. Only 'verilator' and 'vcs' are supported."
      )
    }
  }
}