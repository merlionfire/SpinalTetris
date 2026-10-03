package config

import spinal.core.ClockDomain.FixedFrequency
import spinal.core.sim.SimConfig
import spinal.core._
import spinal.sim.VCSFlags

import java.io.{File, PrintWriter}
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import scala.language.postfixOps
import scala.sys.process.Process

object  runSimConfig {
  private def shellQuote(value: String): String = "'" + value.replace("'", "'\"'\"'") + "'"

  private def resolveRealVcsBinary(): String = {
    sys.env.get("VCS_HOME")
      .map(home => new File(home, "bin/vcs"))
      .filter(_.canExecute)
      .map(_.getAbsolutePath)
      .getOrElse {
        val vcsFromPath = Process(Seq("bash", "-lc", "command -v vcs")).!!.trim
        if (vcsFromPath.isEmpty) {
          throw new IllegalStateException("Unable to locate the real `vcs` binary. Check VCS_HOME/PATH.")
        }
        vcsFromPath
      }
  }

  private def installVcsWrapper(runDir: String): Unit = {
    val wrapperDir = new File(runDir, ".vcs-wrapper")
    if (!wrapperDir.exists() && !wrapperDir.mkdirs()) {
      throw new IllegalStateException(s"Unable to create VCS wrapper directory: ${wrapperDir.getAbsolutePath}")
    }

    val realVcs = resolveRealVcsBinary()
    val wrapperFile = new File(wrapperDir, "vcs")
    val wrapperScript =
      s"""#!/usr/bin/env bash
         |set -euo pipefail
         |
         |real_vcs=${shellQuote(realVcs)}
         |args=()
         |skip_next=0
         |for arg in "$$@"; do
         |  if [[ $$skip_next -eq 1 ]]; then
         |    skip_next=0
         |    continue
         |  fi
         |  if [[ "$$arg" == "-load" ]]; then
         |    skip_next=1
         |    continue
         |  fi
         |  args+=("$$arg")
         |done
         |
         |exec "$$real_vcs" "$${args[@]}"
         |""".stripMargin

    Files.write(wrapperFile.toPath, wrapperScript.getBytes(StandardCharsets.UTF_8))
    wrapperFile.setExecutable(true)

    prependProcessPath(wrapperDir.getAbsolutePath)
  }

  private def prependProcessPath(pathPrefix: String): Unit = {
    val env = System.getenv()
    val unsafeClass = Class.forName("sun.misc.Unsafe")
    val theUnsafe = unsafeClass.getDeclaredField("theUnsafe")
    theUnsafe.setAccessible(true)
    val unsafe = theUnsafe.get(null)
    val objectFieldOffset = unsafeClass.getMethod("objectFieldOffset", classOf[java.lang.reflect.Field])
    val getObject = unsafeClass.getMethod("getObject", classOf[Object], java.lang.Long.TYPE)

    val field = env.getClass.getDeclaredField("m")
    val offset = objectFieldOffset.invoke(unsafe, field).asInstanceOf[Long]
    val backingMap = getObject.invoke(unsafe, env, java.lang.Long.valueOf(offset)).asInstanceOf[java.util.Map[String, String]]
    backingMap.put("PATH", pathPrefix + File.pathSeparator + Option(env.get("PATH")).getOrElse(""))
  }

  def apply(runDir: String, compiler: String = "verilator", fsdb : String = "") : spinal.core.sim.SpinalSimConfig = {

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
      SimConfig
        //.withWave
        .withConfig(buildConfig)
        .withTimeSpec( 1 ns, 100 ps)
        .withVerilator
        .addSimulatorFlag("-D" + "SIM")
        .workspacePath(runDir+"/verilator")

    } else if (compiler == "vcs" ) {
      val flags = VCSFlags(
        compileFlags = List(s"+define+SIM +define+FORMAL +define+VCS -debug_access+all -kdb "),
        elaborateFlags = List(s"-kdb "),
        runFlags = List("-no_save -l sim.log ")
      )
      val simConfig = SimConfig.withConfig(buildConfig).withTimeSpec( 1 ns, 100 ps)
        .workspacePath(runDir+"/vcs")
        .withVCS(flags)
        //.withFSDBWave.waveFilePrefix("verdi")
       // .withWaveDepth(99)

      if (fsdb.isEmpty) {
        simConfig.withFSDBWave.waveFilePrefix("verdi")
        // .withWaveDepth(99)

      }
      // Remove legacy VCS elaborate flags that are not needed for this setup.
      flags.elaborateFlags --= Seq(
        "-debug_acc+pp+dmptf",
        "-debug_region=+cell+encrypt",
        "+vcs+initreg+random",
        "+vpi"
      )
      flags.withElabFlags("-sverilog")


      // CCT : replace -debug_access+all by -debug_access+rw to decrease meory usage. 2024-06-10

//      flags.elaborateFlags.indices.foreach { i =>
//        if (flags.elaborateFlags(i).contains("-debug_access+all")) {
//          flags.elaborateFlags(i) = flags.elaborateFlags(i).replace("-debug_access+all", "-debug_access+rw")
//        }
//      }

      flags.elaborateFlags.indices.foreach { i =>
        if (flags.elaborateFlags(i).contains("novas.tab")) {
          flags.elaborateFlags(i) = flags.elaborateFlags(i).replace("novas.tab", "verdi.tab")
        }
      }

      //Hack to add "-top glbl" to elaborateFlags if "glbl.v" is present in _additionalRtlPath and "-top" is not already specified
      simConfig._vcsEnvSetup = () => {

        // CCT : this hack is to remove -load option from vcs command line, which is not compatible with some versions of VCS. The wrapper script will handle this.
        // But it does not work. So comment it and keep it here for further investigation. 2024-06-10
        //installVcsWrapper(runDir)

        lazy val rtlFullPath = s"${simConfig._workspacePath}/${simConfig._workspaceName}/rtl/"

        print(s"[Debug] simConfig._additionalRtlPath = ${simConfig._additionalRtlPath}\n")
        print(s"[Debug] flags.elaborateFlags = ${flags.elaborateFlags}\n")
        print(s"[Debug] simConfig._workspacePath = ${simConfig._workspacePath}\n")
        print(s"[Debug] simConfig._workspaceName = ${simConfig._workspaceName}\n")



        val hasGlbl = simConfig._additionalRtlPath.exists(path => new java.io.File(path).getName == "glbl.v")
        if (hasGlbl && !flags.elaborateFlags.contains("-top")) {
          flags.withElabFlags("-top glbl")
        }


        if ( fsdb.nonEmpty) {

          flags.withElabFlags(s"-top ${fsdb}")

          simConfig.withWaveDepth(1)

        }
      }



      simConfig
    } else {
      throw new IllegalArgumentException(
        s"Unsupported simulator compiler: '$compiler'. Only 'verilator' and 'vcs' are supported."
      )
    }
  }
}