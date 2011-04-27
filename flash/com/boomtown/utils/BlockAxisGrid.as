package com.boomtown.utils {
  import flash.display.Sprite;
  import flash.geom.Point;
  
  public class BlockAxisGrid {
    
    private static var _metrics:BlockMetrics;
    
    public static function calculateX( bx:Number, by:Number ):Number {
      return bx * _metrics.width;
    }
    
    public static function calculateBlockX( x:Number, y:Number ):Number {
      return Math.floor( x / _metrics.width );
    }
    
    public static function calculateY( bx:Number, by:Number ):Number {
      return by * _metrics.height;
    }
    
    public static function calculateBlockY( x:Number, y:Number ):Number {
      return Math.floor( y / _metrics.height );
    }
    
    public static function set metrics( val:BlockMetrics ):void {
      _metrics = val;
    }
    
    public static function get metrics():BlockMetrics {
      return _metrics;
    }
    
  }
  
}