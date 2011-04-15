package com.boomtown.utils {
  import flash.geom.Point;
	/**
   * ...
   * @author David Talley
   */
  public class HexagonMetrics {
    
    private var _width:Number;
    private var _height:Number;
    private var _rotation:Number;
    private var _angle1:Number;
    private var _angle2:Number;
    private var _radians1:Number;
    private var _radians2:Number;
    private var _size1:Number;
    private var _size2:Number;
    
    public function HexagonMetrics( width:Number, height:Number, rotation:Number = 0 ) {
      _width = width;
      _height = height;
      _rotation = rotation;
      rotation *= Math.PI / 180;
      var p1:Point = new Point( 
        ( Math.cos( ( Math.PI / 2 ) ) * ( height / 2 ) ) + ( ( width / 4 ) ),
        ( ( Math.sin( ( Math.PI / 2 ) ) * ( height / 2 ) ) * -1 )
      );
      var p2:Point = new Point( 
        ( ( width / 2 ) ),
        0
      );
      var mp:Point = new Point( ( p1.x + p2.x ) / 2, ( p1.y + p2.y ) / 2 );
      var ret:Object = { };
      _angle1 = rotation * 180 / Math.PI + 90;
      _angle2 = _angle1 - ( 90 - ( Math.atan( mp.y * -1 / mp.x ) * 180 / Math.PI ) );
      _size1 = height / 2;
      _size2 = Math.sqrt( Math.pow( mp.x - 0, 2 ) + Math.pow( mp.y - 0, 2 ) );
      _radians1 = _angle1 * Math.PI / 180;
      _radians2 = _angle2 * Math.PI / 180;
    }
    
    public function compare( metrics:HexagonMetrics ):Boolean {
      if ( _width == metrics.width && _height == metrics.height && _rotation == metrics.rotation ) {
        return true;
      }
      return false;
    }
    
    public function get width():Number {
      return _width;
    }
    
    public function get height():Number {
      return _height;
    }
    
    public function get rotation():Number {
      return _rotation;
    }
    
    public function get angle1():Number {
      return _angle1;
    }
    
    public function get angle2():Number {
      return _angle2;
    }
    
    public function get radians1():Number {
      return _radians1;
    }
    
    public function get radians2():Number {
      return _radians2;
    }
    
    public function get size1():Number {
      return _size1;
    }
    
    public function get size2():Number {
      return _size2;
    }
    
  }

}