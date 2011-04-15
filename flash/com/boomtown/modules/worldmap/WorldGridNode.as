package com.boomtown.modules.worldmap {
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import flash.display.Sprite;
  import flash.geom.Point;
	/**
   * ...
   * @author David Talley
   */
  internal class WorldGridNode extends Sprite {
    
    private var _metrics:HexagonMetrics;
    
    private var _hx:int = 0;
    private var _hy:int = 0;
    
    private var _type:uint = 0;
    
    public function WorldGridNode() {
      
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
      draw();
    }
    
    private function draw( stuff:Boolean = false ):void {
      graphics.clear();
      graphics.beginFill( 0xAAAAAA );
      Hexagon.drawHexagon( this, _metrics.width - 2, _metrics.height - 2, 0, 0, _metrics.rotation );
      graphics.endFill();
      graphics.beginFill( 0xFFFFFF );
      Hexagon.drawHexagon( this, _metrics.width - 6, _metrics.height - 6, 0, 0, _metrics.rotation );
      graphics.endFill();
      
      var metrics:HexagonMetrics = Hexagon.getMetrics( 12, 8, 0 );
      for ( var i:int = 0; i < 37; i++ ) {
        graphics.beginFill( 0x444444, .5 );
        var offset:Point = HexagonLevelGrid.offset( i, metrics );
        Hexagon.drawHexagon( this, 11, 7, offset.x, offset.y );
        graphics.endFill();
      }
    }
    
    public function clear():void {
      graphics.clear();
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