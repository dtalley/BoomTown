package com.boomtown.modules.battle.grid {
  import com.kuro.kuroexpress.assets.KuroAssets;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.BitmapData;
  import flash.events.TimerEvent;
  import flash.geom.Point;
  import flash.utils.Timer;
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
    private static var _display:BitmapData;
    
    public static function init():BitmapData {
      _initialized = true;
      _key = generateKey();
      return _display;
    }
    
    private static function generateKey():BitmapData {
      var key:BitmapData = new BitmapData( 200, 200, true, 0x000000FF );
      _display = new BitmapData( 200, 200, false, 0xFF0000FF );
      return key;
    }
    
    private static var _points:Array;
    private static var _placed:uint = 0;
    private static var _total:uint = 200 * 200;
    public static function populateKey():void {
      var timer:Timer = new Timer(200);
      timer.addEventListener( TimerEvent.TIMER, stepAutomata );
      timer.start();
      
      _points = [];
      plantSeeds();
    }
    
    private static function plantSeeds():void {
      for ( var i:uint = 0; i < 5; i++ ) {
        var point:Point = new Point( Math.round( Math.random() * 199 ), Math.round( Math.random() * 199 ) );
        var type:uint = Math.round( Math.random() * 3 ) + 1;
        var color:uint = setType( setColor( 0, type ), type );
        _key.setPixel32( point.x, point.y, color );
        addPoints( point );
      }
    }
    
    private static function addPoints( point:Point ):void {
      _points.push( new Point( point.x + 1, point.y ) );
      _points.push( new Point( point.x, point.y + 1 ) );
      _points.push( new Point( point.x - 1, point.y ) );
      _points.push( new Point( point.x, point.y - 1 ) );
    }
    
    private static function stepAutomata( e:TimerEvent ):void {
      var total:uint = _points.length;
      var current:uint = 0;
      for ( var i:uint = 0; i < total; i++ ) {
        if ( current > 200 ) {
          return;
        }
        
        current++;
      }
    }
    
    private static function getType( color:uint ):uint {
      return ( color >> 26 ) & 0x7F;
    }
    
    private static function setType( color:uint, type:uint ):uint {
      color = color & 0x83FFFFFF;
      color = color | ( type << 26 );
      return color;
    }
    
    private static function setSeed( color:uint, seed:uint ):uint {
      
    }
    
    private static function setColor( color:uint, type:uint ):uint {
      color = color & 0xFF000000;
      if ( type == 0 ) {
        color = color | 0xFF;
      } else if ( type == 1 ) {
        color = color | 0xFFAA00;
      } else if ( type == 2 ) {
        color = color | 0xFF00;
      } else if ( type == 3 ) {
        color = color | 0x55FF22;
      } else {
        color = color | 0x777777;
      }
      return color;
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
      y = _key.height - 1 - y;
      if ( x < 0 || y < 0 || x > _key.width - 1 || y > _key.height - 1 ) {
        return 0;
      }
      return ( _key.getPixel32( x, y ) & 0x7FFFFFFF ) >> 26;
    }
    
    public static function nodeTree( x:int, y:int ):Boolean {
      y = _key.height - 1 - y;
      if ( x < 0 || y < 0 || x > _key.width - 1 || y > _key.height - 1 ) {
        return true;
      }
      var color:uint = _key.getPixel32( x, y ) & 0x02000000;
      return color > 0;
    }
    
    public static function addNode( x:int, y:int ):void {
      y = _key.height - 1 - y;
      var color:uint = _key.getPixel32( x, y );
      color = color | 0x80000000;
      _key.setPixel32( x, y, color );
    }
    
    public static function removeNode( x:int, y:int ):void {
      y = _key.height - 1 - y;
      var color:uint = _key.getPixel32( x, y );
      color = color & 0x7FFFFFFF;
      _key.setPixel32( x, y, color );
    }
    
    public static function checkNode( x:int, y:int ):Boolean {
      y = _key.height - 1 - y;
      if ( x < 0 || y < 0 || x > _key.width - 1 || y > _key.height - 1 ) {
        return true;
      }
      var color:uint = _key.getPixel32( x, y ) & 0x80000000;
      return color > 0;
    }
    
    public static function getNode( x:int, y:int ):uint {
      y = _key.height - 1 - y;
      return _key.getPixel32( x, y );
    }
    
  }

}