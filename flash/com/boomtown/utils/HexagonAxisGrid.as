package com.boomtown.utils {
  import flash.display.Sprite;
  import flash.geom.Point;
  
  public class HexagonAxisGrid {
    
    private static var _yalign:int = 90;
    private static var _xalign:int = _yalign - 60;
    
    public static function set yalign( val:int ):void {
      _yalign = val;
    }
    
    public static function set xalign( val:int ):void {
      _xalign = val;
    }
     
    public static function calculateSplit( size:Number ):Number {
      return Math.round( Math.sqrt( Math.pow( size, 2 ) - Math.pow( size / 2, 2 ) ) * 10000 ) / 10000;
    }
    
    public static function calculateSize( split:Number ):Number {
      return Math.round( Math.sqrt( 4 * Math.pow( split, 2 ) / 3 ) * 10000 ) / 10000;
    }
    
    public static function calculateX( width:Number, height:Number, x:Number, y:Number ):Number {
      var metrics:Object = Hexagon.getMetrics( width, height, _yalign - 90 );
      return ( Math.cos( metrics.angle2 * Math.PI / 180 ) * ( metrics.size2 * 2 * x ) ) + ( Math.cos( metrics.angle1 * Math.PI / 180 ) * ( metrics.size1 * 2 * y ) );
    }
    
    public static function calculateHexX( width:Number, height:Number, x:Number, y:Number ):Number {
      y *= -1;
      
      var metrics:Object = Hexagon.getMetrics( width, height, _yalign - 90 );
      var add:Number = 0;
      var dist:Number = Math.sqrt( Math.pow( x, 2 ) + Math.pow( y, 2 ) );
      if ( x < 0 && y > 0 ) {
        add = Math.PI / 2;
      } else if ( x < 0 && y < 0 ) {
        add = Math.PI;
      } else if ( x > 0 && y < 0 ) {
        add = 3 * Math.PI / 2;
      }
      var angle:Number = Math.atan( Math.abs( y ) / Math.abs( x ) ) + add;
      var sangle:Number = angle - _xalign;
      var length:Number = Math.cos( angle ) * dist;
      return Math.round( length / metrics.size2 * 10000 ) / 10000;
    }
    
    public static function calculateY( width:Number, height:Number, x:Number, y:Number ):Number {
      var metrics:Object = Hexagon.getMetrics( width, height, _yalign - 90 );
      return ( ( Math.sin( metrics.angle2 * Math.PI / 180 ) * ( metrics.size2 * 2 * x ) ) + ( Math.sin( metrics.angle1 * Math.PI / 180 ) * ( metrics.size1 * 2 * y ) ) ) * -1;
    }
    
    public static function calculateHexY( width:Number, height:Number, x:Number, y:Number ):Number {
      y *= -1;    
      
      var metrics:Object = Hexagon.getMetrics( width, height, _yalign - 90 );
      var add:Number = 0;
      var dist:Number = Math.sqrt( Math.pow( x, 2 ) + Math.pow( y, 2 ) );
      if ( x < 0 && y > 0 ) {
        add = Math.PI / 2;
      } else if ( x < 0 && y < 0 ) {
        add = Math.PI;
      } else if ( x > 0 && y < 0 ) {
        add = 3 * Math.PI / 2;
      }
      var angle:Number = Math.atan( Math.abs( y ) / Math.abs( x ) ) + add;
      var sangle:Number = _yalign - angle;
      var length:Number = Math.cos( angle ) * dist;
      return Math.round( length / metrics.size1 * 10000 ) / 10000;
    }
    
    public static function calculateDist( width:Number, height:Number, x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      x = calculateX( width, height, x, y );
      y = calculateY( width, height, x, y );
      centerX = calculateX( width, height, centerX, centerY );
      centerY = calculateY( width, height, centerX, centerY );
      return Math.sqrt( Math.pow( centerX - x, 2 ) + Math.pow( centerY - y, 2 ) );
    }
    
    public static function calculateHDist( x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      return Math.sqrt( Math.pow( centerX - x, 2 ) + Math.pow( centerY - y, 2 ) );
    }
    
    public static function calculateAngle( width:Number, height:Number, x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      x = calculateX( width, height, x, y );
      y = calculateY( width, height, x, y );
      centerX = calculateX( width, height, centerX, centerY );
      centerY = calculateY( width, height, centerX, centerY );
      var tAngle:Number = ( 180 / Math.PI ) * Math.atan2( ( 0 - y ) - ( 0 - centerY ), x - centerX );
      if ( tAngle < 0 ) {
        tAngle += 360;
      }
      if ( tAngle >= 360 ) {
        tAngle -= 360;
      }
      return Math.round( tAngle * 10000 ) / 10000;
    }
    
    public static function calculateHAngle( x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      var tAngle:Number = ( 180 / Math.PI ) * Math.atan2( ( 0 - y ) - ( 0 - centerY ), x - centerX );
      if ( tAngle < 0 ) {
        tAngle += 360;
      }
      if ( tAngle >= 360 ) {
        tAngle -= 360;
      }
      return Math.round( tAngle * 10000 ) / 10000;
    }
    
  }
  
}