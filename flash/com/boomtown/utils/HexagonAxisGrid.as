package com.boomtown.utils {
  import flash.display.Sprite;
  import flash.geom.Point;
  
  public class HexagonAxisGrid {
    
    private static var _metrics:HexagonMetrics;
    
    public static function calculateX( x:Number, y:Number ):Number {
      return ( Math.cos( _metrics.radians2 ) * ( _metrics.size2 * 2 * x ) ) + 
             ( Math.cos( _metrics.radians1 ) * ( _metrics.size1 * 2 * y ) );
    }
    
    public static function calculateHexX( x:Number, y:Number ):Number {
      y *= -1; 
      
      var yAngle:Number = _metrics.radians2;
      var ySlope:Number = Math.sin( yAngle ) / Math.cos( yAngle );
      var yInt:Number = y - ( ySlope * x );
      
      var xAngle:Number = _metrics.radians1;
      var xSlope:Number = Math.sin( xAngle ) / Math.cos( xAngle );
      
      var newX:Number = 0;
      newX = ( 0 - yInt ) / ( ySlope - xSlope );
      var newY:Number = xSlope * newX;
      
      var yDist:Number = Math.sqrt( Math.pow( newY - y, 2 ) + Math.pow( newX - x, 2 ) );
      if ( y < newY ) {
        yDist *= -1;
      }
      
      return Math.round( yDist / ( _metrics.size2 * 2 ) );
    }
    
    public static function calculateY( x:Number, y:Number ):Number {
      return ( ( Math.sin( _metrics.radians2 ) * ( _metrics.size2 * 2 * x ) ) + 
               ( Math.sin( _metrics.radians1 ) * ( _metrics.size1 * 2 * y ) ) ) * -1;
    }
    
    public static function calculateHexY( x:Number, y:Number ):Number {
      y *= -1; 
      
      var yAngle:Number = ( Math.PI / 180 ) * _metrics.angle1;
      var ySlope:Number = Math.sin( yAngle ) / Math.cos( yAngle );
      var yInt:Number = y - ( ySlope * x );
      
      var xAngle:Number = ( Math.PI / 180 ) * _metrics.angle2;
      var xSlope:Number = Math.sin( xAngle ) / Math.cos( xAngle );
      
      var newX:Number = 0;
      newX = ( 0 - yInt ) / ( ySlope - xSlope );
      var newY:Number = xSlope * newX;
      
      var yDist:Number = Math.sqrt( Math.pow( newY - y, 2 ) + Math.pow( newX - x, 2 ) );
      if ( Math.round( y ) < Math.round( newY ) ) {
        yDist *= -1;
      }
      
      return Math.round( yDist / ( _metrics.size1 * 2 ) );
    }
    
    public static function set metrics( val:HexagonMetrics ):void {
      _metrics = val;
    }
    
    public static function get metrics():HexagonMetrics {
      return _metrics;
    }
    
  }
  
}