package com.boomtown.render {
  import flash.geom.Point;
	
  public class BasicCamera {
    
    private var _width:Number;
    private var _height:Number;
    private var _x:Number;
    private var _y:Number;
    private var _px:Number;
    private var _py:Number;
    private var _tl:Point;
    private var _br:Point;
    
    public function BasicCamera() {
      _width = _height = _x = _y = 0;
      _tl = new Point( 0, 0 );
      _br = new Point( 0, 0 );
    }
    
    private function generateBounds():void {
      _tl = new Point( _x - ( _width / 2 ), _y - ( _height / 2 ) );
      _br = new Point( _x + ( _width / 2 ), _y + ( _height / 2 ) );
    }
    
    public function set width( val:Number ):void {
      _width = val;
      generateBounds();
    }
    public function set height( val:Number ):void {
      _height = val;
      generateBounds();
    }
    public function set x( val:Number ):void {
      _px = _x;
      _x = val;
      generateBounds();
    }
    public function set y( val:Number ):void {
      _py = _y;
      _y = val;
      generateBounds();
    }
    
    public function get dx():Number {
      return _x - _px;
    }
    public function get dy():Number {
      return _y - _py;
    }
    
    public function get tl():Point {
      return _tl;
    }
    public function get br():Point {
      return _br;
    }
    
    public function localize( point:Point ):Point {
      return new Point( point.x - _tl.x, point.y - _tl.y );
    }
    
    public function globalize( point:Point ):Point {
      return new Point( point.x + _tl.x, point.y + _tl.y );
    }
    
    public function focus( x:Number, y:Number ):void {
      _x = x;
      _y = y;
      generateBounds();
    }
    
    public function resize( width:Number, height:Number ):void {
      _width = width;
      _height = height;
      generateBounds();
    }
    
  }

}