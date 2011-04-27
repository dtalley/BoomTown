package com.boomtown.modules.worldmap {
  import com.boomtown.utils.BlockMetrics;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.net.URLRequest;
  import flash.text.TextField;
	/**
   * ...
   * @author David Talley
   */
  internal class WorldBackgroundNode extends Sprite {
    
    private var _metrics:BlockMetrics;
    private var _bx:int, _by:int;
    private var _map:Bitmap;
    
    public function WorldBackgroundNode() {
      
    }
    
    public function init( metrics:BlockMetrics, x:int, y:int ):void {
      _metrics = metrics;
      _bx = x;
      _by = y;
      
      if( _map && contains( _map ) ) {
        removeChild( _map );
        _map = null;
      }
      
      var loader:Loader = new Loader();
      loader.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
      loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imageError );
      loader.load( new URLRequest( "map/images/" + _bx + "." + _by + ".jpg" ) );
      
      draw();
    }
    
    private function imageError( e:IOErrorEvent ):void {
      e.target.removeEventListener( Event.COMPLETE, imageLoaded );
      e.target.removeEventListener( IOErrorEvent.IO_ERROR, imageError );
    }
    
    private function imageLoaded( e:Event ):void {
      e.target.removeEventListener( Event.COMPLETE, imageLoaded );
      e.target.removeEventListener( IOErrorEvent.IO_ERROR, imageError );
      _map = e.target.loader.content;
      addChild( _map );
    }
    
    private function draw():void {
      graphics.clear();
      var fill:Bitmap = KuroExpress.createBitmap("WorldBackgroundGrid");
      graphics.beginBitmapFill( fill.bitmapData );
      graphics.drawRect( 0, 0, _metrics.width, _metrics.height );
      graphics.endFill();
    }
    
    public function clear():void {
      graphics.clear();
      if( _map && contains( _map ) ) {
        removeChild( _map );
        _map = null;
      }
    }
    
    public function set metrics( val:BlockMetrics ):void {
      if( !_metrics || !_metrics.compare( val ) ) {
        _metrics = val;
        draw();
      }
    }
    
    public function get bX():int {
      return _bx;
    }
    
    public function get bY():int {
      return _by;
    }
    
  }

}