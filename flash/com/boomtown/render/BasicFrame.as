package com.boomtown.render {
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.IBitmapDrawable;
  import flash.display.Sprite;
  import flash.geom.ColorTransform;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
	
  public class BasicFrame extends Sprite {
    
    private var _layers:Array;
    private var _width:uint;
    private var _height:uint;
    
    public function BasicFrame( width:Number, height:Number ) {
      _width = Math.ceil( width );
      _height = Math.ceil( height );
      _layers = [];
      _layers.push( new Bitmap( new BitmapData( _width, _height, false, 0xFFFFFFFF ) ) );
      addChild( Bitmap( _layers[0] ) );
    }
    
    public function clearColor( color:uint ):void {
      var data:BitmapData = Bitmap( _layers[0] ).bitmapData;
      data.fillRect( data.rect, color );
      var totalLayers:uint = _layers.length;
      for ( var i:uint = 1; i < totalLayers; i++ ) {
        data = Bitmap( _layers[0] ).bitmapData;
        data.fillRect( data.rect, 0 );
      }
    }
    
    public function resize( width:Number, height:Number ):void {
      _width = Math.ceil( width );
      _height = Math.ceil( height );
      var totalLayers:uint = _layers.length;
      for ( var i:uint = 0; i < totalLayers; i++ ) {
        Bitmap( _layers[i] ).bitmapData = new BitmapData( _width, _height, i == 0 ? false : true, 0 );
      }
    }
    
    public function draw( layer:uint, source:IBitmapDrawable, matrix:Matrix = null, transform:ColorTransform = null, blend:String = null, clip:Rectangle = null, smoothing:Boolean = false ) {
      if ( _layers.length <= layer ) {
        var totalLayers:uint = _layers.length;
        for ( var i:uint = totalLayers; i < layer + 1 - totalLayers; i++ ) {
          _layers[i] = new Bitmap( new BitmapData( _width, _height, true, 0 ) );
        }
      }
      var drawLayer:BitmapData = Bitmap( _layers[layer] ).bitmapData; 
      drawLayer.draw( source, matrix, transform, blend, clip, smoothing );
    }
    
  }

}