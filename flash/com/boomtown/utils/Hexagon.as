package com.boomtown.utils {
  import flash.display.Sprite;
  import flash.geom.Point;
  
  public class Hexagon {
    
    public static function drawHexagon( obj:Sprite, width:Number, height:Number, rotation:Number = 0 ):void {
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
      
      obj.graphics.moveTo( p1.x, p1.y );
      obj.graphics.lineTo( p2.x, p2.y );
      obj.graphics.lineTo( p3.x, p3.y );
      obj.graphics.lineTo( p4.x, p4.y );
      obj.graphics.lineTo( p5.x, p5.y );
      obj.graphics.lineTo( p6.x, p6.y );
    }
    
    public static function getMetrics( width:Number, height:Number, rotation:Number = 0 ):Object {
      var sangle:Number = Math.atan( ( height / 2 ) / ( width / 4 ) );
      var mangle:Number = Math.PI - sangle * 2;
      var slength:Number = ( height / 2 ) / Math.sin( sangle );
      var tlength:Number = Math.sin( mangle / 2 ) * slength * 2;
      rotation *= Math.PI / 180;
      var ret:Object = { };
      var p1:Point = new Point( 
        ( Math.cos( rotation + ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.cos( rotation ) * ( tlength / 2 ) ),
        ( ( Math.sin( rotation + ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( Math.sin( rotation ) * ( tlength / 2 ) ) ) * -1
      );
      var p2:Point = new Point( 
        ( Math.cos( rotation ) * ( width / 2 ) ),
        ( ( Math.sin( rotation ) * ( width / 2 ) ) ) * -1
      );
      var mp:Point = new Point( ( p1.x + p2.x ) / 2, ( p1.y + p2.y ) / 2 );
      var mlength:Number = Math.sqrt( Math.pow( p2.x - mp.x, 2 ) + Math.pow( p2.y - mp.y, 2 ) );
      var mheight:Number = Math.sin( sangle ) * mlength;
      var hlength:Number = Math.sqrt( Math.pow( mp.x, 2 ) + Math.pow( mp.y, 2 ) );
      var angle2:Number = Math.asin( mheight / hlength );
      ret.angle1 = rotation + 90;
      ret.angle2 = angle2 * 180 / Math.PI;
      ret.size1 = height / 2;
      ret.size2 = hlength;
      return ret;
    }
    
  }
  
}