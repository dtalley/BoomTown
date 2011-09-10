package com.boomtown.modules.battle.grid {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
	/**
   * A class that tracks information on the titles of a BattleGrid
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
   * 02-06  = UINT, terrain code for that particular tile, 0-31
   * 07     = Boolean, true if a forest is present on the tile, false otherwise
   */
  public class BattleGridCache {
    
    private static var _initialized:Boolean;
    private static var _key:BitmapData;
    private static var _data:BitmapData;
    
    public static function init():void {
      _initialized = true;
      _key = KuroExpress.createBitmap("BattleMapKey").bitmapData;
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
     * Get the terrain type of the node at the specified location
     * @param	x The X value of the node
     * @param	y The Y value of the node
     * @return The terrain code, 0-31
     */
    public static function nodeTerrain( x:int, y:int ):uint {
      y = _data.height - 1 - y;
      if ( x < 0 || y < 0 || x > _data.width - 1 || y > _data.height - 1 ) {
        return 0;
      }
      return ( _data.getPixel32( x, y ) & 0x7FFFFFFF ) >> 26;
    }
    
    public static function nodeTree( x:int, y:int ):Boolean {
      y = _data.height - 1 - y;
      if ( x < 0 || y < 0 || x > _data.width - 1 || y > _data.height - 1 ) {
        return true;
      }
      var color:uint = _data.getPixel32( x, y ) & 0x02000000;
      return color > 0;
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
      return color > 0;
    }
    
    public static function getNode( x:int, y:int ):uint {
      y = _data.height - 1 - y;
      return _key.getPixel32( x, y );
    }
    
  }

}