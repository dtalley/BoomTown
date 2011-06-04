package com.boomtown.modules.worldmap {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
	/**
   * ...
   * @author David Talley
   */
  public class WorldGridNodeCache {
    
    private static var _data:BitmapData;
    
    public static function init():void {
      if ( !WorldGridCache.initialized ) {
        throw new Error( "WorldGridNodeCache cannot be initialized before WorldGridCache." );
      }
      _data = new BitmapData( WorldGridCache.width, WorldGridCache.height, true, 0x00000000 );
    }
    
    public static function storeNode( x:int, y:int, status:uint, faction:uint ):void {
      y = _data.height - 1 - y;
      var color:uint = _data.getPixel32( x, y );
      color = color | ( status << 30 );
      color = color | ( faction << 28 );
      _data.setPixel32( x, y, color );
    }
    
    public static function retrieveNode( x:int, y:int ):WorldGridNodeStore {
      y = _data.height - 1 - y;
      if ( x < 0 || y < 0 || x > _data.width - 1 || y > _data.height - 1 ) {
        return null;
      }
      var color:uint = _data.getPixel32( x, y );
      if( color > 0 ) {
        var status:uint = ( color & 0xC0000000 ) >> 30;
        var faction:uint = ( color & 0x30000000 ) >> 28;
        return new WorldGridNodeStore( status, faction );
      }
      return null;
    }
    
  }

}