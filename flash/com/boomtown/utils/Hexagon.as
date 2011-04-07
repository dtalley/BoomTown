package com.boomtown.utils {
  import flash.display.Sprite;
  import flash.geom.Point;
  
  public class Hexagon {
    
    public static function drawHexagon( obj:Sprite, width:Number, height:Number, x:Number = 0, y:Number = 0, rotation:Number = 0 ):void {
      var sangle:Number = Math.atan( ( height / 2 ) / ( width / 4 ) );
      var mangle:Number = Math.PI - sangle * 2;
      var slength:Number = ( height / 2 ) / Math.sin( sangle );
      var tlength:Number = Math.sin( mangle / 2 ) * slength * 2;
      rotation *= Math.PI / 180;
      
      var p1:Point = new Point( 
        ( Math.cos( rotation + ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.cos( rotation ) * ( tlength / 2 ) ),
        ( ( Math.sin( rotation + ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.sin( rotation ) * ( tlength / 2 ) ) ) * -1
      );
      var p2:Point = new Point( 
        ( Math.cos( rotation + ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.cos( rotation ) * ( tlength / -2 ) ),
        ( ( Math.sin( rotation + ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.sin( rotation ) * ( tlength / -2 ) ) ) * -1
      );
      var p3:Point = new Point( 
        ( Math.cos( rotation + ( Math.PI ) ) * ( width / 2 ) ),
        ( ( Math.sin( rotation + ( Math.PI ) ) * ( width / 2 ) ) ) * -1
      );
      var p4:Point = new Point( 
        ( Math.cos( rotation + ( 3 * Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.cos( rotation ) * ( tlength / -2 ) ),
        ( ( Math.sin( rotation + ( 3 * Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.sin( rotation ) * ( tlength / -2 ) ) ) * -1
      );
      var p5:Point = new Point( 
        ( Math.cos( rotation + ( 3 * Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.cos( rotation ) * ( tlength / 2 ) ),
        ( ( Math.sin( rotation + ( 3 * Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.sin( rotation ) * ( tlength / 2 ) ) ) * -1
      );
      var p6:Point = new Point( 
        ( Math.cos( rotation ) * ( width / 2 ) ),
        ( ( Math.sin( rotation ) * ( width / 2 ) ) ) * -1
      );
      
      obj.graphics.moveTo( x + p1.x, y + p1.y );
      obj.graphics.lineTo( x + p2.x, y + p2.y );
      obj.graphics.lineTo( x + p3.x, y + p3.y );
      obj.graphics.lineTo( x + p4.x, y + p4.y );
      obj.graphics.lineTo( x + p5.x, y + p5.y );
      obj.graphics.lineTo( x + p6.x, y + p6.y );
    }
    
    public static function getMetrics( width:Number, height:Number, rotation:Number = 0 ):Object {
      rotation *= Math.PI / 180;
      var p1:Point = new Point( 
        ( Math.cos( ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( ( width / 4 ) ),
        ( ( Math.sin( ( Math.PI / 2 ) ) * ( height / 2 ) ) * -1 )
      );
      var p2:Point = new Point( 
        ( ( width / 2 ) ),
        0
      );
      var mp:Point = new Point( ( p1.x + p2.x ) / 2, ( p1.y + p2.y ) / 2 );
      var ret:Object = { };
      ret.angle1 = rotation * 180 / Math.PI + 90;
      ret.angle2 = ret.angle1 - ( 90 - ( Math.atan( mp.y * -1 / mp.x ) * 180 / Math.PI ) );
      ret.size1 = height / 2;
      ret.size2 = Math.sqrt( Math.pow( mp.x - 0, 2 ) + Math.pow( mp.y - 0, 2 ) );
      return ret;
    }
    
  }
  
}