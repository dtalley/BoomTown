package com.boomtown.modules.battle.grid {
  import com.boomtown.modules.battle.events.BattleGridEvent;
  import com.boomtown.modules.battle.events.BattleGridNodeEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.LoadQueue;
  import com.kuro.kuroexpress.ObjectPool;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.filters.GlowFilter;
	/**
   * ...
   * @author David Talley
   */
  public class BattleGrid extends Sprite { 
    
    private var _width:Number = 72;
    private var _height:Number = 68;
    private var _rotation:Number = 90;
    
    private var _pool:ObjectPool;
    
    internal function setMetrics( width:Number, height:Number, rotation:Number ):void {
      _width = width;
      _height = height;
      _rotation = rotation;
      KuroExpress.broadcast( "Setting BattleGrid metrics.", 
        { obj:this, label:"BattleGrid::setMetrics()" } );
      populate();
    }
    
    public function BattleGrid() { 
      init();
    }
    
    private function init():void {
      resetMetrics();
      BattleGridCache.init();
      _pool = new ObjectPool( 100, BattleGridNode );
      _pool.addEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Beginning pool population", 
        { obj:this, label:"BattleGrid::init()" } );
    }
    
    private function poolReady( e:Event ):void {
      _pool.removeEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Pool has been populated", 
        { obj:this, label:"BattleGrid::poolReady()" } );
      dispatchEvent( new BattleGridEvent( BattleGridEvent.READY ) );
    }
    
    internal function resetMetrics():void {
      if ( 
        !HexagonAxisGrid.metrics || 
        HexagonAxisGrid.metrics.width != _width || 
        HexagonAxisGrid.metrics.height != _height || 
        HexagonAxisGrid.metrics.rotation != _rotation 
      ) {
        HexagonAxisGrid.metrics = new HexagonMetrics( _width, _height, _rotation );
      }
    }
    
    public function position( x:int, y:int ):void {
      this.x = 0 - HexagonAxisGrid.calculateX( x, y ) + ( stage.stageWidth / 2 );
      this.y = 0 - HexagonAxisGrid.calculateY( x, y ) + ( stage.stageWidth / 2 );
    }
    
    private var _prevSX:int = NaN;
    private var _prevSY:int = NaN;
    public function populate():void {
      var sX:int = Math.round( ( stage.stageWidth / 2 ) - this.x );
      var sY:int = Math.round( ( stage.stageHeight / 2 ) - this.y );
      var hX:int = HexagonAxisGrid.calculateHexX( sX, sY );
      var hY:int = HexagonAxisGrid.calculateHexY( sX, sY );
      if ( _prevSX == hX && _prevSY == hY ) {
        dispatchEvent( new BattleGridEvent( BattleGridEvent.POPULATED ) );
        return;
      }
      resetMetrics();
      _prevSX = hX;
      _prevSY = hY;
      var tLX:int = Math.floor( sX - ( stage.stageWidth / 2 ) - _width );
      var tLY:int = Math.floor( sY - ( stage.stageHeight / 2 ) - _height );
      var bRX:int = Math.ceil( sX + ( stage.stageWidth / 2 ) + _width );
      var bRY:int = Math.ceil( sY + ( stage.stageHeight / 2 ) + _height );
      var totalChildren:uint = numChildren;
      for ( var i:uint = 0; i < totalChildren; i++ ) {
        if ( getChildAt(i) is BattleGridNode ) {
          var node:BattleGridNode = BattleGridNode( getChildAt( i ) );
          node.x = HexagonAxisGrid.calculateX( node.hX, node.hY );
          node.y = HexagonAxisGrid.calculateY( node.hX, node.hY );
          if ( node.x < tLX || node.x > bRX || node.y < tLY || node.y > bRY ) {
            destroyNode( node );
            i--;
            totalChildren--;
          } else {
            node.metrics = HexagonAxisGrid.metrics;
          }
        }
      }
      createGrid( Math.round( hX ), 
                  Math.round( hY ), 
                  0, tLX, tLY, bRX, bRY );
    }
    
    private function createGrid( sx:int, sy:int, level:int, 
                                 tLX:int, tLY:int, 
                                 bRX:int, bRY:int ):void {
      var quadrant:int = 0;
      var created:int = 0;
      while ( quadrant < 4 ) {
        if ( level == 0 && ( quadrant == 1 || quadrant == 2 ) ) {
          quadrant++;
          continue;
        }
        var addx = ( quadrant == 0 || quadrant == 1 ) ? 1 : -1;
        var addy = ( quadrant == 0 || quadrant == 2 ) ? 1 : -1;
        var nsx:int = sx + addx * level;
        var nsy:int = sy + addy * level;
        var count:int = 0;
        var distance:int = 0;
        while ( count < 2 ) {
          if ( level == 0 && quadrant > 0 && distance == 0 && count == 0 ) {
            distance++;
            continue;
          }
          var cx:int = nsx;
          var cy:int = nsy;
          if ( count == 0 ) {
            cx = nsx;
            cy += addy * distance;
          } else if ( count == 1 ) {
            cx += addx * ( distance + 1 );
            cy = nsy;
          }
          var useX:int = HexagonAxisGrid.calculateX( cx, cy );
          var useY:int = HexagonAxisGrid.calculateY( cx, cy );
          if ( useX < tLX || useX > bRX || useY < tLY || useY > bRY ) {
            count++;
            distance = 0;
          } else {
            createNode( cx, cy );
            created++;
            distance++;
          }
        }
        quadrant++;
      }
      if ( created > 0 ) {
        createGrid( sx, sy, level + 1, tLX, tLY, bRX, bRY );
      } else {
        dispatchEvent( new BattleGridEvent( BattleGridEvent.POPULATED ) );
      }
    }
    
    private function createNode( x:int, y:int ):void {
      var newNode:BattleGridNode = null;
      if ( !BattleGridCache.checkNode( x, y ) ) {
        newNode = BattleGridNode( _pool.getObject() );
        BattleGridCache.addNode( x, y );
        newNode.init( HexagonAxisGrid.metrics, x, y );
        
        addChild( newNode );
        newNode.x = HexagonAxisGrid.calculateX( x, y );
        newNode.y = HexagonAxisGrid.calculateY( x, y );
        newNode.addEventListener( BattleGridNodeEvent.OVER, nodeOver );
        newNode.addEventListener( BattleGridNodeEvent.CLICKED, nodeClicked );
      }
    }
    
    
    
    private function destroyNode( node:BattleGridNode ):void {
      BattleGridCache.removeNode( node.hX, node.hY );
      _pool.returnObject( node );
      removeChild( node );
      node.clear();
      
      node.removeEventListener( BattleGridNodeEvent.OVER, nodeOver );
      node.removeEventListener( BattleGridNodeEvent.CLICKED, nodeClicked );
    }
    
    private function nodeOver( e:BattleGridNodeEvent ):void {
      addChild( BattleGridNode( e.target ) );
    }
    
    private function nodeClicked( e:BattleGridNodeEvent ):void {
      
    }
    
  }

}