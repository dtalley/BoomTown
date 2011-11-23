package com.boomtown.render {
  import flash.geom.Point;
	
  public class BasicCamera {
    
    private var _width:Number;
    private var _height:Number;
    private var _x:Number;
    private var _y:Number;
    private var _px:Number;
    private var _py:Number;
    private var _tx:Number;
    private var _ty:Number;
    private var _tl:Point;
    private var _br:Point;
    
    public function BasicCamera() {
      _width = _height = _x = _y = 0;
      _tl = new Point( 0, 0 );
      _br = new Point( 0, 0 );
    }
    
    private function generateBounds():void {
      _tl = new Point( Math.floor( _x - ( _width / 2 ) ), Math.floor( _y - ( _height / 2 ) ) );
      _br = new Point( Math.ceil( _x + ( _width / 2 ) ), Math.ceil( _y + ( _height / 2 ) ) );
    }
    
    public function set width( val:Number ):void {
      _width = Math.ceil( val );
      generateBounds();
    }
    public function set height( val:Number ):void {
      _height = Math.ceil( val );
      generateBounds();
    }
    public function set x( val:Number ):void {
      _px = _x;
      _x = Math.round( val );
      generateBounds();
    }
    public function set y( val:Number ):void {
      _py = _y;
      _y = Math.round( val );
      generateBounds();
    }
    
    public function set tx( val:Number ):void {
      _tx = val;
    }
    
    public function set ty( val:Number ):void {
      _ty = val;
    }
    
    public function get width():Number {
      return _width;
    }
    
    public function get height():Number {
      return _height;
    }
    
    public function get x():Number {
      return _x;
    }
    
    public function get y():Number {
      return _y;
    }
    
    public function get dx():Number {
      return _x - _px;
    }
    public function get dy():Number {
      return _y - _py;
    }
    
    public function get tx():Number {
      return _tx;
    }
    
    public function get ty():Number {
      return _ty;
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
      _x = Math.round( x );
      _y = Math.round( y );
      _tx = _x;
      _ty = _y;
      generateBounds();
    }
    
    public function resize( width:Number, height:Number ):void {
      _width = Math.ceil( width );
      _height = Math.ceil( height );
      generateBounds();
    }
    
  }

}