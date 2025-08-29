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
      SimConfig.withWave.withConfig(buildConfig).withTimeSpec( 1 ns, 100 ps)
        .withVerilator
        .addSimulatorFlag("-D" + "SIM")
        .workspacePath(runDir+"/verilator")

    } else if (compiler == "vcs" ) {
      val flags = VCSFlags(
        compileFlags = List("-verilog +v2k -ntb +define+SIM -assert failonly "), /* Useless, skip this step in dev publish */
        //elaborateFlags = List("-V -lca +define+VCS_NO_INTEGER_RACE -debug_access+nomemcbk -no_optimize "), /* Useless, skip this step in dev publish */
        elaborateFlags = List("-V"), /* Useless, skip this step in dev publish */
        // +vcs+flush+all :  Increases the frequency of dumping both the compilation and simulation log files.
        // +vcs+flush+all :  Increases the frequency of dumping all log files, VCD files, and all files opened by the $fopen  system function.
        runFlags = List("-l sim.log +vcs+flush+log +vcs+flush+all -debug_pp +stacktrace -error=all")
      )
      SimConfig.withConfig(buildConfig).withTimeSpec( 1 ns, 100 ps)
        .workspacePath(runDir+"/vcs")
        .withVCS(flags)
        .withFSDBWave.waveFilePrefix("verdi")
    } else {
      throw new IllegalArgumentException(
        s"Unsupported simulator compiler: '$compiler'. Only 'verilator' and 'vcs' are supported."
      )
    }
  }
}