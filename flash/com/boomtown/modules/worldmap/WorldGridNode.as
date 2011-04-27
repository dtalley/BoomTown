package com.boomtown.modules.worldmap {
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
	/**
   * ...
   * @author David Talley
   */
  internal class WorldGridNode extends Sprite {
    
    private var _metrics:HexagonMetrics;
    
    private var _hx:int = 0;
    private var _hy:int = 0;
    
    private var _type:uint = 0;
    
    private var _details:Sprite;
    private var _map:Bitmap;
    
    public function WorldGridNode() {
      _details = new Sprite();
    }
    
    public function init( metrics:HexagonMetrics, x:int, y:int ):void {
      _metrics = metrics;
      _hx = x;
      _hy = y;
      
      var info:uint = WorldGridCache.getNode( x, y );
      if ( ( info & 0x00FFFFFF ) < 0xFFFFFF ) {
        _type = ACTIVE;
      } else {
        _type = INACTIVE;
      }
      
      generateDetails();      
      draw();
    }
    
    private function generateDetails():void {
      if ( _map ) {
        removeChild( _map );
      }
      _map = new Bitmap( new BitmapData( _metrics.width * 2, _metrics.height * 2, true, 0x00000000 ) );
      addChild( _map );
      var metrics:HexagonMetrics = new HexagonMetrics( 12, 8, 0 );
      _details.graphics.clear();
      for ( var i:int = 0; i < 37; i++ ) {
        _details.graphics.beginFill( 0x444444, 1 );
        var offset:Point = HexagonLevelGrid.offset( i, metrics );
        Hexagon.drawHexagon( _details, 11, 7, offset.x, offset.y );
        _details.graphics.endFill();
      }
      var matr:Matrix = new Matrix();
      matr.translate( _metrics.width, _metrics.height );
      _map.bitmapData.draw( _details, matr );
      _map.x = 0 - _metrics.width;
      _map.y = 0 - _metrics.height;
      _details.graphics.clear();
    }
    
    private function draw():void {
      graphics.clear();
      graphics.beginFill( 0xAAAAAA );
      Hexagon.drawHexagon( this, _metrics.width - 2, _metrics.height - 2, 0, 0, _metrics.rotation );
      graphics.endFill();
      graphics.beginFill( 0xFFFFFF );
      Hexagon.drawHexagon( this, _metrics.width - 6, _metrics.height - 6, 0, 0, _metrics.rotation );
      graphics.endFill();
    }
    
    public function clear():void {
      graphics.clear();
      removeChild( _map );
      _map = null;
      _type = UNDEFINED;
    }
    
    public function set metrics( val:HexagonMetrics ):void {
      if( !_metrics || !_metrics.compare( val ) ) {
        _metrics = val;
        draw();
      }
    }
    
    public function get metrics():HexagonMetrics {
      return _metrics;
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