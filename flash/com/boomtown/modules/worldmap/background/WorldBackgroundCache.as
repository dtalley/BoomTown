package com.boomtown.modules.worldmap.background {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
	
  /**
   * @author David Talley
   * 
   * @usage
   * A class that allows the tracking of WorldBackgroundNode objects.  Stores 4 BitmapData objects
   * that serve as a coordinate plane for storing data on each Node position.  The bits are as follows,
   * starting from the most significant bit:
   * 
   * 01 02 03 04
   * 05 06 07 08
   * 09 10 11 12
   * 13 14 15 16
   * 17 18 19 20
   * 21 22 23 24
   * 25 26 27 28
   * 29 30 31 32
   * 
   * 08 - Boolean, true if the position has been checked by the grid constructor, false otherwise
   */
  public class WorldBackgroundCache {
    
    private static var _data1:BitmapData;
    private static var _data2:BitmapData;
    private static var _data3:BitmapData;
    private static var _data4:BitmapData;
    
    public static function init( qwidth:Number, qheight:Number ):void {
      _data1 = new BitmapData( qwidth, qheight, true, 0x00000000 );
      _data2 = new BitmapData( qwidth, qheight, true, 0x00000000 );
      _data3 = new BitmapData( qwidth, qheight, true, 0x00000000 );
      _data4 = new BitmapData( qwidth, qheight, true, 0x00000000 );
    }
    
    public static function addNode( x:int, y:int ):void {
      var quad:BitmapData = getDataQuadrant( x, y );
      x = Math.abs( x );
      y = Math.abs( y );
      
      var color:uint = quad.getPixel32( x, y );
      color = color | 0x01000000;
      quad.setPixel32( x, y, color );
    }
    
    public static function removeNode( x:int, y:int ):void {
      var quad:BitmapData = getDataQuadrant( x, y );
      x = Math.abs( x );
      y = Math.abs( y );
      
      var color:uint = quad.getPixel32( x, y );
      color = color & 0xFEFFFFFF;
      quad.setPixel32( x, y, color );
    }
    
    public static function checkNode( x:int, y:int ):Boolean {
      var quad:BitmapData = getDataQuadrant( x, y );
      x = Math.abs( x );
      y = Math.abs( y );
      
      if ( x > quad.width - 1 || y > quad.height - 1 ) {
        return true;
      }
      var color:uint = quad.getPixel32( x, y ) & 0x01000000;
      return Boolean( color > 0 );
    }
    
    private static function getDataQuadrant( x:int, y:int ):BitmapData {
      if ( x >= 0 && y >= 0 ) {
        return _data1;
      } else if ( x < 0 && y >= 0 ) {
        return _data2;
      } else if ( x < 0 && y < 0 ) {
        return _data3;
      } else {
        return _data4;
      }
    }
    
  }

}