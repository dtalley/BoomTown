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
    
    public static function calculateX( size:Number, split:Number, x:Number, y:Number, angleOffset:int = 0 ):Number {
      var xAngle:Number = ( Math.PI / 180 ) * ( _xalign + angleOffset );
      var xDist:Number = ( split * 2 ) * x;
      var firstX:Number = Math.cos( xAngle ) * xDist;
      var firstY:Number = Math.sin( xAngle ) * xDist;
      
      var yAngle:Number = ( Math.PI / 180 ) * ( _yalign + angleOffset );
      var yDist:Number = ( split * 2 ) * y;
      
      var newX:Number = firstX + ( Math.cos( yAngle ) * yDist );      
      return Math.round( newX * 10000 ) / 10000;
    }
    
    public static function calculateHexX( width:Number, height:Number, x:Number, y:Number ):Number {
      y *= -1;
      
      var metrics:Number = Hexagon.getMetrics( size * 2, split * 2, _yalign - 90 );
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
      
      
      /*var yAngle:Number = ( Math.PI / 180 ) * _yalign;
      var slope:Number = ( Math.cos( yAngle ) / Math.sin( yAngle ) ) * -1;
      var yDist:Number = ( slope * x - y ) / Math.sqrt( Math.pow( slope, 2 ) + Math.pow( -1, 2 ) ) / ( split * 2 );
      var firstX:Number = x - ( Math.cos( yAngle ) * yDist );
      
      var xAngle:Number = ( Math.PI / 180 ) * _xalign;
      var newX:Number = firstX / ( Math.cos( xAngle ) * ( split * 2 ) );
      return Math.round( newX * 10000 ) / 10000;*/
    }
    
    public static function calculateY( size:Number, split:Number, x:Number, y:Number, angleOffset:int = 0 ):Number {
      var xAngle:Number = ( Math.PI / 180 ) * ( _xalign + angleOffset );
      var xDist:Number = ( split * 2 ) * x;
      var firstX:Number = Math.cos( xAngle ) * xDist;
      var firstY:Number = Math.sin( xAngle ) * xDist;
      
      var yAngle:Number = ( Math.PI / 180 ) * ( _yalign + angleOffset );
      var yDist:Number = ( split * 2 ) * y;
      
      var newY:Number = 0 - ( firstY + ( Math.sin( yAngle ) * yDist ) );      
      return Math.round( newY * 10000 ) / 10000;
    }
    
    public static function calculateHexY( size:Number, split:Number, x:Number, y:Number ):Number {
      y *= -1;      
      var yAngle:Number = ( Math.PI / 180 ) * _yalign;
      var ySlope:Number = Math.sin( yAngle ) / Math.cos( yAngle );
      var yInt:Number = y - ( ySlope * x );
      
      var xAngle:Number = ( Math.PI / 180 ) * _xalign;
      var xSlope:Number = Math.sin( xAngle ) / Math.cos( xAngle );
      
      var newX:Number = 0;
      newX = ( 0 - yInt ) / ( ySlope - xSlope );
      var newY:Number = xSlope * newX;
      
      var yDist:Number = Math.sqrt( Math.pow( newY - y, 2 ) + Math.pow( newX - x, 2 ) );
      if ( y < newY ) {
        yDist *= -1;
      }
      
      return Math.round( yDist / ( split * 2 ) * 10000 ) / 10000;
    }
    
    public static function calculateDist( size:Number, split:Number, x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      x = calculateX( size, split, x, y );
      y = calculateY( size, split, x, y );
      centerX = calculateX( size, split, centerX, centerY );
      centerY = calculateY( size, split, centerX, centerY );
      return Math.sqrt( Math.pow( centerX - x, 2 ) + Math.pow( centerY - y, 2 ) );
    }
    
    public static function calculateHDist( x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      return Math.sqrt( Math.pow( centerX - x, 2 ) + Math.pow( centerY - y, 2 ) );
    }
    
    public static function calculateAngle( size:Number, split:Number, x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      x = calculateX( size, split, x, y );
      y = calculateY( size, split, x, y );
      centerX = calculateX( size, split, centerX, centerY );
      centerY = calculateY( size, split, centerX, centerY );
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