package utils
import config._
import spinal.core._
import spinal.lib.Delay
import spinal.lib.soc.pinsec.{Pinsec, PinsecConfig}

object mis {
  def int2binString( a : Int ) = f"0b${String.format("%10s", Integer.toBinaryString(a)).replace(' ', '0')}"
}

object Counter2 {

  def apply( end : UInt, inc: Bool): Counter2 = {

    val start = cloneOf(end )
    start := U(0)
    val counter = new Counter2( start , end)
    when( inc ) {
      counter.increment()
    }
    counter
  }


  def apply ( start : UInt, end : UInt , inc : Bool )  ={

    val counter = new Counter2( start, end )
    when ( inc ) {
      counter.increment()
    }
    counter
  }

  def apply (  latch : Bool , start : UInt, size: UInt )  ={


    val end_reg = RegNextWhen( ( start + size - 1 ) , latch, U(0) )

    val inc_reg = RegNextWhen( True, latch, False )

    val counter = new Counter2( start, end_reg  )
    when ( latch ) { counter.load( start ) }

    when ( inc_reg ) {
      counter.increment()
    }

    inc_reg.clearWhen( counter.willOverflow )

    counter
  }

}

class Counter2(val start : UInt , val end : UInt) extends ImplicitArea[UInt] {

  val willIncrement = False.allowOverride
  val willClear = False.allowOverride



  def clear() : Unit = willClear := True
  def increment() : Unit = willIncrement := True
  def load(value: UInt): Unit = valueNext := value


  val valueNext = cloneOf(end)

  val value = RegNext(valueNext) init (start)

  val willOverflowIfInc = value === end
  val willOverflow = willOverflowIfInc && willIncrement


  when ( willOverflow) {
    valueNext := start
  } otherwise {
    valueNext := (value + U(willIncrement)).resized
  }

  when(willClear) {
    valueNext := start
  }

  willOverflowIfInc.allowPruning()
  willOverflow.allowPruning()
  override def implicitValue: UInt = this.value

  val isDone = RegNextWhen( willOverflow, False )
}

case class  Offset( ) extends  Bundle {
  val x = UInt( 2 bit)
  val y = UInt( 2 bit)
}

object Offset {
  def apply( x : Int, y : Int ) : Offset = {
    val ret = Offset()
    ret.x := x
    ret.y := y
    ret
  }

  implicit def tuple2Offset( tuple : ( Int, Int ) ) : Offset = {
    Offset(tuple._1, tuple._2)
  }
}


object Piece {
  def apply(a : Piece) : Piece = {
    val ret = cloneOf(a)
    ret.orign.x = a.orign.x
    ret.orign.y = a.orign.y
    ret.`type` = a.`type`
    ret.rot = a.rot
    ret
  }

}

case class Piece(colBitsWidth : Int, rowBitsWidth : Int) extends  Bundle {


  var orign = Block(colBitsWidth,rowBitsWidth )
  var `type` = TYPE()
  var rot = UInt(2 bits)

  /*
    def randomize() = {

      orign.x = Random.nextInt(11)
      orign.y = Random.nextInt(21)
      `type` =   TYPE.elements(Random.nextInt(TYPE.elements.size))
      rot = Random.nextInt(4)

    }
    */

}


case class Block( colBitsWidth : Int, rowBitsWidth : Int ) extends Bundle {

  var x = UInt( colBitsWidth bit )
  var y = UInt( rowBitsWidth bit )

  def +(z : Offset) = {
    //val ret = Block()
    val ret = cloneOf(this)
    ret.x := this.x + z.x
    ret.y := this.y + z.y
    ret
  }

  def ===( right : Block  ) : Bool =  {
    val ret = Bool()
    ret := ( this.x === right.x  )  && ( this.y === right.y )
    ret
  }
}

case class  hitStatus() extends Bundle {
  val is_occupied = Bool()
  val is_wall = Bool()
}

object SimUtils {
  def maskInt(bitWidth: Int) = (1 << bitWidth - 1)
}