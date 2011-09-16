package com.boomtown.modules.battle.grid {
  import com.boomtown.core.Faction;
  import com.boomtown.modules.battle.events.BattleGridNodeEvent;
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.motionPaths.RectanglePath2D;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.util.IQueueLoadable;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.events.MagasiRequestEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
	/**
   * ...
   * @author David Talley
   */
  internal class BattleGridNode extends Sprite {
    
    private var _metrics:HexagonMetrics;
    
    private var _hx:int = 0;
    private var _hy:int = 0;
    
    private var _hit:Sprite;
    
    public function BattleGridNode() {
      _hit = new Sprite();
    }
    
    public function init( metrics:HexagonMetrics, x:int, y:int ):void {
      _metrics = metrics;
      _hx = x;
      _hy = y;
      
      draw();
    }
    
    private function nodeOver( e:MouseEvent ):void {
      dispatchEvent( new BattleGridNodeEvent( BattleGridNodeEvent.OVER ) );
      draw( true );
    }
    
    private function nodeOut( e:MouseEvent ):void {
      draw();
    }
    
    private function nodeClick( e:MouseEvent ):void {
      dispatchEvent( new BattleGridNodeEvent( BattleGridNodeEvent.CLICKED ) );
    }
    
    private function draw( over:Boolean = false ):void {
      graphics.clear();
      graphics.beginFill( over ? 0x8888FF : 0xAAAAAA );
      Hexagon.drawHexagon( this, _metrics.width - ( over ? -10 : 2 ), _metrics.height - ( over ? -10 : 2 ), 0, 0, _metrics.rotation );
      graphics.endFill();
      graphics.beginFill( over ? 0x222222 : 0x444444 );
      Hexagon.drawHexagon( this, _metrics.width - 6, _metrics.height - 6, 0, 0, _metrics.rotation );
      graphics.endFill();
    }
    
    public function clear():void {
      graphics.clear();      
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
    
  }

}