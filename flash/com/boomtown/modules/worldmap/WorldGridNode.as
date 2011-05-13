package com.boomtown.modules.worldmap {
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.motionPaths.RectanglePath2D;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
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
    
    private var _hit:Sprite;
    private var _details:Sprite;
    private var _map:Bitmap;
    
    public function WorldGridNode() {
      _hit = new Sprite();
      _details = new Sprite();
      _details.mouseChildren = false;
      _details.mouseEnabled = false;
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
      if ( !_map || ( _map.width != _metrics.width && _map.height != _metrics.height ) ) {
        _map = new Bitmap( new BitmapData( _metrics.width, _metrics.height, true, 0x00000000 ) );
      } else {
        _map.bitmapData.fillRect( new Rectangle( 0, 0, _map.width, _map.height ), 0x00000000 );
      }
      var metrics:HexagonMetrics = new HexagonMetrics( 12, 8, 0 );
      _details.graphics.clear();
      for ( var i:int = 0; i < 37; i++ ) {
        _details.graphics.beginFill( 0x444444, 1 );
        var offset:Point = HexagonLevelGrid.offset( i, metrics );
        Hexagon.drawHexagon( _details, 11, 7, offset.x, offset.y );
        _details.graphics.endFill();
      }
      var matr:Matrix = new Matrix();
      matr.translate( _metrics.width / 2, _metrics.height / 2 );
      _map.bitmapData.draw( _details, matr );
      _map.x = 0 - _metrics.width / 2;
      _map.y = 0 - _metrics.height / 2;
      _details.graphics.clear();
      _details.addChild( _map );
      addChild( _details );
      
      addChild( _hit );
      _hit.graphics.beginFill( 0, 0 );
      Hexagon.drawHexagon( _hit, _metrics.width - 2, _metrics.height - 2, 0, 0, _metrics.rotation );
      _hit.graphics.endFill();
      _hit.buttonMode = true;
      _hit.addEventListener( MouseEvent.MOUSE_OVER, nodeOver );
      _hit.addEventListener( MouseEvent.MOUSE_OUT, nodeOut );
      _hit.addEventListener( MouseEvent.CLICK, nodeClick );
    }
    
    private function nodeOver( e:MouseEvent ):void {
      dispatchEvent( new WorldGridNodeEvent( WorldGridNodeEvent.NODE_OVER ) );
      draw( true );
    }
    
    private function nodeOut( e:MouseEvent ):void {
      draw();
    }
    
    private function nodeClick( e:MouseEvent ):void {
      dispatchEvent( new WorldGridNodeEvent( WorldGridNodeEvent.NODE_CLICKED ) );
    }
    
    private function draw( over:Boolean = false ):void {
      graphics.clear();
      graphics.beginFill( over ? 0x8888FF : 0xAAAAAA );
      Hexagon.drawHexagon( this, _metrics.width - ( over ? -10 : 2 ), _metrics.height - ( over ? -10 : 2 ), 0, 0, _metrics.rotation );
      graphics.endFill();
      graphics.beginFill( over ? 0xDDDDDD : 0xFFFFFF );
      Hexagon.drawHexagon( this, _metrics.width - 6, _metrics.height - 6, 0, 0, _metrics.rotation );
      graphics.endFill();
    }
    
    public function clear():void {
      graphics.clear();
      _details.removeChild( _map );
      _map = null;
      _type = UNDEFINED;
      
      _hit.graphics.clear();
      _hit.removeEventListener( MouseEvent.MOUSE_OVER, nodeOver );
      _hit.removeEventListener( MouseEvent.MOUSE_OUT, nodeOut );
      _hit.removeEventListener( MouseEvent.CLICK, nodeClick );
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