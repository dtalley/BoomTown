package com.boomtown.utils {
	/**
   * ...
   * @author David Talley
   */
  public class BlockMetrics{

    private var _width:Number;
    private var _height:Number;
    
    public function BlockMetrics( width:Number, height:Number ) {
      _width = width;
      _height = height;      
    }
    
    public function compare( val:BlockMetrics ):Boolean {
      if ( val.width == _width && val.height == _height ) {
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
    
  }

}