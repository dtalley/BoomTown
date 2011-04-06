package com.boomtown.utils {
  import flash.display.Sprite;
  import flash.geom.Point;
  
  public class HexagonAxisGrid {
    
    private static var yAlign:int = 90;
    private static var xAlign:int = yAlign - 60;
     
    public static function calculateSplit( size:Number ):Number {
      return Math.sqrt( Math.pow( size, 2 ) - Math.pow( size / 2, 2 ) );
    }
    
    public static function calculateX( size:Number, x:Number, y:Number, angleOffset:int = 0 ):Number {
      var split:Number = HexGrid.calculateSplit( size );
      var xAngle:Number = ( Math.PI / 180 ) * ( xAlign + angleOffset );
      var xDist:Number = ( split * 2 ) * x;
      var firstX:Number = Math.cos( xAngle ) * xDist;
      var firstY:Number = Math.sin( xAngle ) * xDist;
      
      var yAngle:Number = ( Math.PI / 180 ) * ( yAlign + angleOffset );
      var yDist:Number = ( split * 2 ) * y;
      
      var newX:Number = firstX + ( Math.cos( yAngle ) * yDist );      
      return newX;
    }
    
    public static function calculateHexX( size:Number, x:Number, y:Number ):Number {
      var split:Number = HexGrid.calculateSplit( size );
      y *= -1;
      var yAngle:Number = ( Math.PI / 180 ) * yAlign;
      var slope:Number = ( Math.cos( yAngle ) / Math.sin( yAngle ) ) * -1;
      var yDist:Number = ( slope * x - y ) / Math.sqrt( Math.pow( slope, 2 ) + Math.pow( -1, 2 ) ) / ( split * 2 );
      var firstX:Number = x - ( Math.cos( yAngle ) * yDist );
      
      var xAngle:Number = ( Math.PI / 180 ) * xAlign;
      var newX:Number = firstX / ( Math.cos( xAngle ) * ( split * 2 ) );
      return newX;
    }
    
    public static function calculateY( size:Number, x:Number, y:Number, angleOffset:int = 0 ):Number {
      var split:Number = HexGrid.calculateSplit( size );
      var xAngle:Number = ( Math.PI / 180 ) * ( xAlign + angleOffset );
      var xDist:Number = ( split * 2 ) * x;
      var firstX:Number = Math.cos( xAngle ) * xDist;
      var firstY:Number = Math.sin( xAngle ) * xDist;
      
      var yAngle:Number = ( Math.PI / 180 ) * ( yAlign + angleOffset );
      var yDist:Number = ( split * 2 ) * y;
      
      var newY:Number = 0 - ( firstY + ( Math.sin( yAngle ) * yDist ) );      
      return newY;
    }
    
    public static function calculateHexY( size:Number, x:Number, y:Number ):Number {
      var split:Number = HexGrid.calculateSplit( size );
      y *= -1;      
      var yAngle:Number = ( Math.PI / 180 ) * yAlign;
      var ySlope:Number = Math.sin( yAngle ) / Math.cos( yAngle );
      var yInt:Number = y - ( ySlope * x );
      
      var xAngle:Number = ( Math.PI / 180 ) * xAlign;
      var xSlope:Number = Math.sin( xAngle ) / Math.cos( xAngle );
      
      var newX:Number = 0;
      newX = ( 0 - yInt ) / ( ySlope - xSlope );
      var newY:Number = xSlope * newX;
      
      var yDist:Number = Math.sqrt( Math.pow( newY - y, 2 ) + Math.pow( newX - x, 2 ) );
      if ( y < newY ) {
        yDist *= -1;
      }
      
      return yDist / ( split * 2 );
    }
    
    public static function calculateDist( size:Number, x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      x = HexGrid.calculateX( size, x, y );
      y = HexGrid.calculateY( size, x, y );
      centerX = HexGrid.calculateX( size, centerX, centerY );
      centerY = HexGrid.calculateY( size, centerX, centerY );
      return Math.sqrt( Math.pow( centerX - x, 2 ) + Math.pow( centerY - y, 2 ) );
    }
    
    public static function calculateHDist( x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      return Math.sqrt( Math.pow( centerX - x, 2 ) + Math.pow( centerY - y, 2 ) );
    }
    
    public static function calculateAngle( size:Number, x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      x = HexGrid.calculateX( size, x, y );
      y = HexGrid.calculateY( size, x, y );
      centerX = HexGrid.calculateX( size, centerX, centerY );
      centerY = HexGrid.calculateY( size, centerX, centerY );
      var tAngle:Number = ( 180 / Math.PI ) * Math.atan2( ( 0 - y ) - ( 0 - centerY ), x - centerX );
      if ( tAngle < 0 ) {
        tAngle += 360;
      }
      if ( tAngle >= 360 ) {
        tAngle -= 360;
      }
      return tAngle;
    }
    
    public static function calculateHAngle( x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      var tAngle:Number = ( 180 / Math.PI ) * Math.atan2( ( 0 - y ) - ( 0 - centerY ), x - centerX );
      if ( tAngle < 0 ) {
        tAngle += 360;
      }
      if ( tAngle >= 360 ) {
        tAngle -= 360;
      }
      return tAngle;
    }u7888888888hnjmhbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb4r55555555555555555555555555555555555555,-0l566666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666wqs
    
  }
  
}