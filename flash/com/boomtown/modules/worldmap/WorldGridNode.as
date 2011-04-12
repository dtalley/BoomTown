package com.boomtown.modules.worldmap {
  import com.boomtown.utils.Hexagon;
  import flash.display.Sprite;
	/**
   * ...
   * @author David Talley
   */
  internal class WorldGridNode extends Sprite {
    
    private var _width:Number = 0;
    private var _height:Number = 0;
    
    private var _hx:int = 0;
    private var _hy:int = 0;
    
    private var _type:uint = 0;
    
    public function WorldGridNode() {
      
    }
    
    public function init( width:Number, height:Number, x:int, y:int ):void {
      _width = width;
      _height = height;
      _hx = x;
      _hy = y;
      
      var info:uint = WorldGridCache.getNode( x, y );
      if ( ( info >> 8 ) == 0x000000 ) {
        trace( "active" );
        _type = ACTIVE;
        draw();
      } else {
        trace( "inactive" );
        _type = ACTIVE;
        draw(true);
      }
    }
    
    private function draw( stuff:Boolean = false ):void {
      graphics.clear();
      graphics.beginFill( stuff ? 0xFFFFFF : 0x000000 );
      Hexagon.drawHexagon( this, _width - 2, _height - 2 );
      graphics.endFill();
    }
    
    public function setSize( width:Number, height:Number ):void {
      _width = width;
      _height = height;
      draw();
    }
    
    public function clear():void {
      graphics.clear();
      _type = UNDEFINED;
    }
    
    public function get hX():Number {
      return _hx;
    }
    
    public function get hY():Number {
      return _hy;
    }
    
    public function get type():uint {
      return _type;
    }
    
    public static function get UNDEFINED():uint {
      return 0;
    }
    
    public static function get ACTIVE():uint {
      return 1;
    }
    
    public static function get INACTIVE():uint {
      return 2;
    }
    
  }

}