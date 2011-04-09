package com.boomtown.modules.worldmap {
  import flash.display.Sprite;
	/**
   * ...
   * @author David Talley
   */
  internal class WorldGridNode extends Sprite {
    
    private var _width:Number;
    private var _height:Number;
    
    private var _hx:int;
    private var _hy:int;
    
    private var _type:uint;
    
    public function WorldGridNode() {
      
    }
    
    public function init( width:Number, height:Number, x:int, y:int ):void {
      _width = width;
      _height = height;
      _hx = x;
      _hy = y;
      
      draw();
    }
    
    private function draw():void {
      
    }
    
    public function setSize( width:Number, height:Number ):void {
      _width = width;
      _height = height;
      draw();
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
    
    public static function get ACTIVE():uint {
      return 1;
    }
    
    public static function get INACTIVE():uint {
      return 2;
    }
    
  }

}