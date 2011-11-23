package com.boomtown.modules.battle.grid {
  import com.boomtown.game.Faction;
  import com.boomtown.modules.battle.events.BattleGridNodeEvent;
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.motionPaths.RectanglePath2D;
  import com.kuro.kuroexpress.assets.KuroAssets;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.util.IComparableObjectNode;
  import com.kuro.kuroexpress.util.IObjectNode;
  import com.kuro.kuroexpress.util.ITreeNode;
  import com.kuro.kuroexpress.util.TreeNode;
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
  internal class BattleGridNode extends TreeNode {
    
    private var _metrics:HexagonMetrics;
    
    private var _hx:int = 0;
    private var _hy:int = 0;
    private var _x:Number = 0;
    private var _y:Number = 0;
    
    private var _color:uint = 0;
    
    public function BattleGridNode() {
    }
    
    override public function compare( obj:IComparableObjectNode ):int {
      if ( !( obj is BattleGridNode ) ) {
        return -1;
      }
      var node:BattleGridNode = BattleGridNode( obj );
      if ( _y < node.y ) {
        return -1;
      } else if ( _y > node.y ) {
        return 1;
      }
      if ( _x < node.x ) {
        return -1;
      } else if ( _x > node.x ) {
        return 1;
      }
      return 0;
    }
    
    override public function copy( obj:ITreeNode ):void {
      if ( !( obj is BattleGridNode ) ) {
        throw new Error( "Cannot copy an object that is not a BattleGridNode" );
      }
      var node:BattleGridNode = BattleGridNode( obj );
      _metrics = node.metrics;
      _hx = node.hX;
      _hy = node.hY;
      refresh();
    }
    
    public function init( metrics:HexagonMetrics, x:int, y:int ):void {
      _metrics = metrics;
      _hx = x;
      _hy = y;
      refresh();
    }
    
    public function clear():void {
      
    }
    
    public function refresh():void {
      _x = HexagonAxisGrid.calculateX( _hx, _hy );
      _y = HexagonAxisGrid.calculateY( _hx, _hy );
    }
    
    public function set metrics( val:HexagonMetrics ):void {
      if( !_metrics || !_metrics.compare( val ) ) {
        _metrics = val;
        refresh();
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
    
    public function get x():Number {
      return _x;
    }
    
    public function get y():Number {
      return _y;
    }
    
  }

}