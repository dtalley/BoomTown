package com.boomtown.modules.worldmap {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
	/**
   * ...
   * @author David Talley
   */
  public class WorldGridCache {
    
    private static var _key:BitmapData;
    private static var _data:BitmapData;
    
    public static function init():void {
      _key = KuroExpress.createBitmap("WorldMapKey").bitmapData;
      _data = new BitmapData( _key.width, _key.height, true, 0x00000000 );
    }
    
    public static function addNode( x:int, y:int ):void {
      y = _data.height - 1 - y;
      var color:uint = _data.getPixel32( x, y );
      color = color | 0x01000000;
      _data.setPixel32( x, y, color );
    }
    
    public static function removeNode( x:int, y:int ):void {
      y = _data.height - 1 - y;
      var color:uint = _data.getPixel32( x, y );
      color = color & 0xFEFFFFFF;
      _data.setPixel32( x, y, color );
    }
    
    public static function checkNode( x:int, y:int ):Boolean {
      y = _data.height - 1 - y;
      if ( x < 0 || y < 0 || x > _data.width - 1 || y > _data.height - 1 ) {
        return true;
      }
      var color:uint = _data.getPixel32( x, y ) & 0x01000000;
      return Boolean( color > 0 );
    }
    
    public static function getNode( x:int, y:int ):uint {
      y = _data.height - 1 - y;
      return _key.getPixel32( x, y );
    }
    
  }

}