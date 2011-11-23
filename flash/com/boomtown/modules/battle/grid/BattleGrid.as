package com.boomtown.modules.battle.grid {
  import com.boomtown.modules.battle.events.BattleGridEvent;
  import com.boomtown.modules.battle.events.BattleGridNodeEvent;
  import com.boomtown.render.BasicCamera;
  import com.boomtown.render.BasicFrame;
  import com.boomtown.render.IRenderable;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.LoadQueue;
  import com.kuro.kuroexpress.ObjectPool;
  import com.kuro.kuroexpress.struct.AnderssonTree;
  import com.kuro.kuroexpress.struct.TreeIterator;
  import com.kuro.kuroexpress.util.IObjectNode;
  import com.kuro.kuroexpress.util.ITreeNode;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.filters.GlowFilter;
  import flash.geom.Matrix;
  import flash.geom.Point;
	/**
   * ...
   * @author David Talley
   */
  public class BattleGrid extends EventDispatcher implements IRenderable { 
    
    private var _width:Number = 24;
    private var _height:Number = 50;
    private var _rotation:Number = 90;
    
    private var _pool:ObjectPool;
    
    private var _tree:AnderssonTree;
    private var _nodes:Array = [];
    
    internal function setMetrics( width:Number, height:Number, rotation:Number ):void {
      _width = width;
      _height = height;
      _rotation = rotation;
      KuroExpress.broadcast( "Setting BattleGrid metrics.", 
        { obj:this, label:"BattleGrid::setMetrics()" } );
    }
    
    public function BattleGrid() { 
      init();      
    }
    
    private function init():void {
      _tree = new AnderssonTree();
      _nodes = [];
      
      resetMetrics();
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
      return;
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
    
    public function positionCamera( camera:BasicCamera, x:int, y:int ):void {
      camera.x = HexagonAxisGrid.calculateX( x, y );
      camera.y = HexagonAxisGrid.calculateY( x, y );
    }
    
    public function populateKey():void {
      KuroExpress.broadcast( "Populating battle grid key.", 
        { obj:this, label:"BattleGrid::populateKey()" } );
      BattleGridCache.dispatcher.addEventListener( Event.COMPLETE, continuePopulation );
      BattleGridCache.populateKey();
    }
    
    private function continuePopulation( e:Event ):void {
      KuroExpress.broadcast( "Key has been populated.", 
        { obj:this, label:"BattleGrid::continuePopulation()" } );
      BattleGridCache.dispatcher.removeEventListener( Event.COMPLETE, continuePopulation );
      dispatchEvent( new BattleGridEvent( BattleGridEvent.POPULATED ) );
    }
    
    public function render( frame:BasicFrame, camera:BasicCamera ):void {
      populate( camera );
      var obj:BattleGridNode;
      var iterator:TreeIterator = _tree.createIterator();
      var circle:Sprite = new Sprite();
      circle.graphics.beginFill( 0xFF0000 );
      circle.graphics.drawCircle( 5, 5, 5 );
      circle.graphics.endFill();
      var matr:Matrix = new Matrix();
      /*var total:uint = _nodes.length;
      for ( var i:uint = 0; i < total; i++ ) {
        matr.identity();
        var obj:BattleGridNode = BattleGridNode( _nodes[i] );
        var local:Point = camera.localize( new Point( obj.x, obj.y ) );
        matr.translate( local.x, local.y );
        frame.draw( 0, circle, matr );
      }*/
      while ( obj = iterator.getNext() as BattleGridNode ) {
        matr.identity();
        var local:Point = camera.localize( new Point( obj.x, obj.y ) );
        matr.translate( local.x, local.y );
        frame.draw( 0, circle, matr );
      }
    }
    
    private var _prevSX:int = NaN;
    private var _prevSY:int = NaN;
    public function populate( camera:BasicCamera ):void {      
      var sX:int = camera.x;
      var sY:int = camera.y;
      var hX:int = HexagonAxisGrid.calculateHexX( sX, sY );
      var hY:int = HexagonAxisGrid.calculateHexY( sX, sY );
      if ( _prevSX == hX && _prevSY == hY ) {
        dispatchEvent( new BattleGridEvent( BattleGridEvent.POPULATED ) );
        return;
      }
      resetMetrics();
      _prevSX = hX;
      _prevSY = hY;
      var tLX:int = camera.tl.x - HexagonAxisGrid.metrics.width * 2;
      var tLY:int = camera.tl.y - HexagonAxisGrid.metrics.height * 2;
      var bRX:int = camera.br.x + HexagonAxisGrid.metrics.width * 2;
      var bRY:int = camera.br.y + HexagonAxisGrid.metrics.height * 2;
      /*var total:uint = _nodes.length;
      for ( var i:uint = 0; i < total; i++ ) {
        var node:BattleGridNode = BattleGridNode( _nodes[i] );
        if ( node.x < tLX || node.x > bRX || node.y < tLY || node.y > bRY ) {
          destroyNode( node );
          i--;
          total--;
        } else {
          node.metrics = HexagonAxisGrid.metrics;
        }
      }*/
      var iterator:TreeIterator = _tree.createIterator();
      var removals:Array = [];
      var totalRemovals:uint = 0;
      var node:BattleGridNode;
      while ( node = iterator.getNext() as BattleGridNode ) {
        if ( node.x < tLX || node.x > bRX || node.y < tLY || node.y > bRY ) {
          removals.push( node );
          totalRemovals++;
        } else {
          node.metrics = HexagonAxisGrid.metrics;
        }
      }
      while ( totalRemovals > 0 ) {
        destroyNode( removals.shift() );
        totalRemovals--;
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
        
        _tree.add( newNode );
        //_nodes.push( newNode );
      }
    }
    
    private function destroyNode( node:BattleGridNode ):void {
      BattleGridCache.removeNode( node.hX, node.hY );
      _pool.returnObject( node as IObjectNode );
      _tree.rem( node );
      /*if ( _nodes.indexOf( node ) >= 0 ) {
        _nodes.splice( _nodes.indexOf( node ), 1 );
      }*/
      node.clear();
    }
    
  }

}