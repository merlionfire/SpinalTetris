/*

ThisBuild / version := "1.0"

ThisBuild / scalaVersion := "2.13.14"

ThisBuild / organization := "org.example"

// I clone 1.22.2 and made changes on VCSBackend to use one-step sim in place of 2-step sim
// Then publish to local rep. Therefor, switch spinalHDL version to dev which is local release.
val spinalVersion = "1.12.2"
val scalatestVersion = "3.2.14"

val spinalCore = "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion
val spinalLib = "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion
val spinalIdslPlugin = compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion)
val spinalSim = "com.github.spinalhdl" %% "spinalhdl-sim" % spinalVersion // For simulation
val scalaTest = "org.scalatest" %% "scalatest" % scalatestVersion
val swing = "org.scala-lang.modules" %% "scala-swing" % "3.0.0"
lazy val projectname = (project in file("."))
  .settings(
    name := "SpinalTetris",
    Compile / scalaSource := baseDirectory.value / "design" ,
    libraryDependencies ++= Seq(spinalCore, spinalLib, spinalIdslPlugin, spinalSim, scalaTest,swing)
  )



fork := true
*/

import sbt.Keys._
import sbt._
import java.io.File // Needed for `File` and `Path`

ThisBuild / version := "1.0"

ThisBuild / scalaVersion := "2.12.18" // Make sure this matches your local SpinalHDL publish

ThisBuild / organization := "org.example"

val spinalVersion = "dev" // This version string must match what you published locally
val scalatestVersion = "3.2.14"

val spinalCore = "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion
val spinalLib = "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion
val spinalIdslPlugin = compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion)
val spinalSim = "com.github.spinalhdl" %% "spinalhdl-sim" % spinalVersion // For simulation
val scalaTest = "org.scalatest" %% "scalatest" % scalatestVersion
val swing = "org.scala-lang.modules" %% "scala-swing" % "3.0.0"
val scalaCheck = "org.scalacheck" %% "scalacheck" % "1.19.0"

lazy val projectname = (project in file("."))
  .settings(
    name := "SpinalTetris",
    Compile / scalaSource := baseDirectory.value / "design" ,
    libraryDependencies ++= Seq(spinalCore, spinalLib, spinalIdslPlugin, spinalSim, scalaTest,swing, scalaCheck  )

    //Compile / scalacOptions += "-Xplugin:" + (update.value.allFiles.filter(_.getName.contains("spinalhdl-idsl-plugin")).headOption.getOrElse(throw new Exception("SpinalHDL IDSL plugin not found"))).toString,
    //Compile / scalacOptions += "-Xplugin-require:spinalhdl-idsl-plugin"
  )

fork := true