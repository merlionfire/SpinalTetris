package config

sealed trait BuildFeature
case object DebugSignals extends BuildFeature
case object Assertions   extends BuildFeature
case object Coverage     extends BuildFeature
case object Formal       extends BuildFeature
case object Simulation   extends BuildFeature

case class BuildConfig(
                        features : Set[BuildFeature] = Set()
                      ) {
  def has(f: BuildFeature): Boolean =
    features.contains(f)
}


object ElabProfiles {

  val Release = BuildConfig(
    Set()
  )

  val Debug = BuildConfig(
    Set(DebugSignals, Assertions)
  )

  val DV = BuildConfig(
    Set(Assertions, Coverage)
  )

  val Sim = BuildConfig(
    Set(Simulation, DebugSignals, Assertions)
  )

}