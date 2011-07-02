package com.boomtown.modules.worldmap.background {
  import com.boomtown.utils.BlockMetrics;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.util.IQueueLoadable;
  import com.kuro.kuroexpress.XMLManager;
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
  internal class WorldBackgroundNode extends Sprite implements IQueueLoadable {
    
    private var _metrics:BlockMetrics;
    private var _bx:int, _by:int;
    private var _map:Bitmap;
    
    private var _loader:Loader;
    private var _loaded:Boolean = false;
    
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
      
      draw();
    }
    
    public function load():void {
      _loader = new Loader();
      _loader.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
      _loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imageError );
      _loader.load( new URLRequest( XMLManager.getFile("settings").site_path + "styles/boomtown/flash/map/images/" + _bx + "." + _by + ".jpg" ) );
    }
    
    public function cancel():void {
      if ( _loader ) {
        try {
          _loader.close();
        } catch( e:Error ) {}
        cleanLoader();
      }
    }
    
    public function get loaded():Boolean {
      return _loaded;
    }
    
    private function cleanLoader():void {
      if ( _loader ) {
        _loader.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded );
        _loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, imageError );
        _loader = null;
      }
    }
    
    private function imageError( e:IOErrorEvent ):void {
      cleanLoader();
      _loaded = true;
      dispatchEvent( new Event( Event.COMPLETE ) );
    }
    
    private function imageLoaded( e:Event ):void {
      _map = e.target.loader.content;
      cleanLoader();
      addChild( _map );
      _loaded = true;
      dispatchEvent( new Event( Event.COMPLETE ) );
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
      _loaded = false;
      if ( _loader ) {
        cancel();
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