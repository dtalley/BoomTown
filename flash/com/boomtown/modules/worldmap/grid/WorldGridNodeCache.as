package com.boomtown.modules.worldmap.grid {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
	/**
   * A class that caches information about WorldGridNode objects and their loaded information
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
   * 01-02  = UINT, the numeric ID of the status of the node, locked, open, or disputed
   * 03-04  = UINT, the numeric ID of the faction that owns the node
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