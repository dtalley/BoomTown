package com.boomtown.modules.worldmap.grid {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
	/**
   * A class that tracks information on the placement and validity of WorldGridNode objects.
   * 
   * @author David Talley
   * 
   * @usage
   * The bits are as follows,
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
   * 01     = Boolean, true if the position has been checked by the grid constructor, false otherwise
   * 02-32  = UINT, the unix timestamp value of when the node at the specified position should be reloaded
   */
  public class WorldGridCache {
    
    private static var _initialized:Boolean;
    private static var _key:BitmapData;
    private static var _data:BitmapData;
    
    public static function init():void {
      _initialized = true;
      _key = KuroExpress.createBitmap("WorldMapKey").bitmapData;
      _data = new BitmapData( _key.width, _key.height, true, 0x00000000 );
    }
    
    public static function get width():Number {
      return _key.width;
    }
    
    public static function get height():Number {
      return _key.height;
    }
    
    public static function get initialized():Boolean {
      return _initialized;
    }
    
    /**
     * Set the timestamp value for when the node in this position should be reloaded
     * @param	x The X value of the node
     * @param	y The Y value of the node
     * @param	time The unix timestamp value of when the node at the specified position should be reloaded
     */
    public static function nodeLoaded( x:int, y:int, time:uint ):void {
      y = _data.height - 1 - y;
      var color:uint = _data.getPixel32( x, y );
      color = color | time;
      _data.setPixel32( x, y, color );
    }
    
    /**
     * Get the unix timestamp value for when the node at the specified position should be reloaded
     * @param	x The X value of the node
     * @param	y The Y value of the node
     * @return The unix timestamp value
     */
    public static function nodeExpires( x:int, y:int ):uint {
      y = _data.height - 1 - y;
      if ( x < 0 || y < 0 || x > _data.width - 1 || y > _data.height - 1 ) {
        return 0;
      }
      return _data.getPixel32( x, y ) & 0x7FFFFFFF;
    }
    
    public static function addNode( x:int, y:int ):void {
      y = _data.height - 1 - y;
      var color:uint = _data.getPixel32( x, y );
      color = color | 0x80000000;
      _data.setPixel32( x, y, color );
    }
    
    public static function removeNode( x:int, y:int ):void {
      y = _data.height - 1 - y;
      var color:uint = _data.getPixel32( x, y );
      color = color & 0x7FFFFFFF;
      _data.setPixel32( x, y, color );
    }
    
    public static function checkNode( x:int, y:int ):Boolean {
      y = _data.height - 1 - y;
      if ( x < 0 || y < 0 || x > _data.width - 1 || y > _data.height - 1 ) {
        return true;
      }
      var color:uint = _data.getPixel32( x, y ) & 0x80000000;
      return Boolean( color > 0 );
    }
    
    public static function getNode( x:int, y:int ):uint {
      y = _data.height - 1 - y;
      return _key.getPixel32( x, y );
    }
    
  }

}