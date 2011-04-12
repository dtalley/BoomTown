package com.boomtown.modules.worldmap {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
	/**
   * ...
   * @author David Talley
   */
  public class WorldGridCache {
    
    private static var _key:BitmapData;
    
    public static function init():void {
      _key = KuroExpress.createBitmap("WorldMapKey").bitmapData;
    }
    
    public static function addNode( x:int, y:int ):void {
      var color:uint = _key.getPixel32( x, y );
      color = color | 0x01000000;
      _key.setPixel32( x, y, color );
    }
    
    public static function removeNode( x:int, y:int ):void {
      var color:uint = _key.getPixel32( x, y );
      color = color & 0xFEFFFFFF;
      _key.setPixel32( x, y, color );
    }
    
    public static function checkNode( x:int, y:int ):Boolean {
      var color:uint = _key.getPixel32( x, y ) & 0x01000000;
      return color > 0;
    }
    
    public static function getNode( x:int, y:int ):uint {
      return _key.getPixel32( x, y );
    }
    
  }

}