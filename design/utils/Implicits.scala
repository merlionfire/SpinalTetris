package utils

import spinal.lib.graphic.{Rgb, RgbConfig}
import spinal.core._

object Implicits {

  implicit class ConnectableBundles( val bundles :( Bundle, Bundle)) extends AnyVal {

    def connectByName(l: List[String]) = {
      val source_io = bundles._1
      val target_io = bundles._2
      target_io.elements
        .filter { element => l.contains(element._1) }
        .foreach { case (name, data) => data := source_io.find(name) }
    }
  }

}




object  RgbPrefs {

  implicit class RgbWrapper( x : Rgb ) {
    def <=( y : Int ) = {
      x.b := y & 0x00f
      x.g := ( y >> 4 ) & 0x00f
      x.r := ( y >> 8 ) & 0x00f
    }

    def <=( y : Bits ) = {
      x.b := y(3 downto 0).asUInt
      x.g := y( 7 downto 4 ).asUInt
      x.r := y( 11 downto 8 ).asUInt
    }


    def +( y : Int ) = {
      val ret = Rgb(x.c)

      ret.b := x.b + ( y & 0x00f )
      ret.g := x.g + ( ( y >> 4 ) & 0x00f )
      ret.r := x.r + ( ( y >> 8 ) & 0x00f )
      ret
    }

    def -( y : Int ) = {
      val ret = Rgb(x.c)

      ret.b := x.b - ( y & 0x00f )
      ret.g := x.g - ( ( y >> 4 ) & 0x00f )
      ret.r := x.r - ( ( y >> 8 ) & 0x00f )
      ret
    }
  }
}