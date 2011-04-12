package com.boomtown.utils {
  import flash.display.Sprite;
  import flash.geom.Point;
  
  public class HexagonAxisGrid {
    
    private static var _metrics:Object;
    private static var _xslope:Number, _yslope:Number;
    
    public static function setMetrics( width:Number, height:Number, rotation:Number ):void {
      _metrics = Hexagon.getMetrics( width, height, rotation );
      _xslope = Math.sin( _metrics.angle2 * Math.PI / 180 ) / Math.cos( _metrics.angle2 * Math.PI / 180 );
      _yslope = Math.sin( _metrics.angle1 * Math.PI / 180 ) / Math.cos( _metrics.angle1 * Math.PI / 180 );
    }
    
    public static function calculateX( x:Number, y:Number ):Number {
      return ( Math.cos( _metrics.angle2 * Math.PI / 180 ) * ( _metrics.size2 * 2 * x ) ) + 
             ( Math.cos( _metrics.angle1 * Math.PI / 180 ) * ( _metrics.size1 * 2 * y ) );
    }
    
    public static function calculateHexX( x:Number, y:Number ):Number {
      y *= -1;
      
      var yAngle:Number = ( Math.PI / 180 ) * _metrics.angle1;
      var slope:Number = ( Math.cos( yAngle ) / Math.sin( yAngle ) ) * -1;
      var yDist:Number = ( slope * x - y ) / Math.sqrt( Math.pow( slope, 2 ) + Math.pow( -1, 2 ) ) / ( _metrics.size2 * 2 );
      var firstX:Number = x - ( Math.cos( yAngle ) * yDist );
      
      var xAngle:Number = ( Math.PI / 180 ) * _metrics.angle2;
      var newX:Number = firstX / ( Math.cos( xAngle ) * ( _metrics.size2 * 2 ) );
      return Math.round( newX );
    }
    
    public static function calculateY( x:Number, y:Number ):Number {
      return ( ( Math.sin( _metrics.angle2 * Math.PI / 180 ) * ( _metrics.size2 * 2 * x ) ) + 
               ( Math.sin( _metrics.angle1 * Math.PI / 180 ) * ( _metrics.size1 * 2 * y ) ) ) * -1;
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
      if ( y < newY ) {
        yDist *= -1;
      }
      
      return Math.round( yDist / ( _metrics.size1 * 2 ) );
    }
    
  }
  
}