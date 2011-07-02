package com.boomtown.modules.worldmap.grid {
  import com.boomtown.modules.worldmap.events.WorldGridEvent;
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
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
  public class WorldGrid extends Sprite { 
    
    private var _width:Number = 72;
    private var _height:Number = 78;
    private var _rotation:Number = 90;
    
    private var _queue:LoadQueue;
    private var _pool:ObjectPool;
    
    private var _potential:WorldGridNode;
    private var _clicked:WorldGridNode;
    
    private var _menu:WorldGridNodeMenu;
    
    internal function setMetrics( width:Number, height:Number, rotation:Number ):void {
      _width = width;
      _height = height;
      _rotation = rotation;
      KuroExpress.broadcast( "Setting WorldGrid metrics.", 
        { obj:this, label:"WorldGrid::setMetrics()" } );
      populate();
    }
    
    public function WorldGrid() { 
      init();
    }
    
    private function init():void {
      resetMetrics();
      WorldGridCache.init();
      WorldGridNodeCache.init();
      _queue = new LoadQueue(20,true);
      _pool = new ObjectPool( 100, WorldGridNode );
      _pool.addEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Beginning pool population", 
        { obj:this, label:"WorldGrid::init()" } );
    }
    
    private function poolReady( e:Event ):void {
      _pool.removeEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Pool has been populated", 
        { obj:this, label:"WorldGrid::poolReady()" } );
      dispatchEvent( new WorldGridEvent( WorldGridEvent.READY ) );
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
    
    internal function startLoading():void {
      var total:uint = numChildren;
      for ( var i:int = 0; i < total; i++ ) {
        if ( getChildAt(i) is WorldGridNode ) {
          _queue.add( WorldGridNode( getChildAt(i) ) );
        }
      }
    }
    
    internal function stopLoading():void {
      _queue.flush();
    }
    
    private var _prevSX:int = NaN;
    private var _prevSY:int = NaN;
    public function populate():void {
      var sX:int = Math.round( ( stage.stageWidth / 2 ) - this.x );
      var sY:int = Math.round( ( stage.stageHeight / 2 ) - this.y );
      var hX:int = HexagonAxisGrid.calculateHexX( sX, sY );
      var hY:int = HexagonAxisGrid.calculateHexY( sX, sY );
      if ( _prevSX == hX && _prevSY == hY ) {
        dispatchEvent( new WorldGridEvent( WorldGridEvent.POPULATED ) );
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
        if ( getChildAt(i) is WorldGridNode ) {
          var node:WorldGridNode = WorldGridNode( getChildAt( i ) );
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
        dispatchEvent( new WorldGridEvent( WorldGridEvent.POPULATED ) );
        if ( !_queue.loading ) {
          _queue.load();
        }
      }
    }
    
    private function createNode( x:int, y:int ):void {
      var newNode:WorldGridNode = null;
      if ( !WorldGridCache.checkNode( x, y ) ) {
        newNode = WorldGridNode( _pool.getObject() );
        WorldGridCache.addNode( x, y );
        newNode.init( HexagonAxisGrid.metrics, x, y );
        if ( newNode.type == WorldGridNodeType.ACTIVE ) {
          addChild( newNode );
          newNode.x = HexagonAxisGrid.calculateX( x, y );
          newNode.y = HexagonAxisGrid.calculateY( x, y );
          newNode.addEventListener( WorldGridNodeEvent.OVER, nodeOver );
          newNode.addEventListener( WorldGridNodeEvent.CLICKED, nodeClicked );
          _queue.add( newNode );
        } else {
          _pool.returnObject( newNode );
        }
      }
    }
    
    
    
    private function destroyNode( node:WorldGridNode ):void {
      WorldGridCache.removeNode( node.hX, node.hY );
      _pool.returnObject( node );
      _queue.remove( node );
      removeChild( node );
      node.clear();
      if ( node.type == WorldGridNodeType.ACTIVE ) {
        node.removeEventListener( WorldGridNodeEvent.OVER, nodeOver );
        node.removeEventListener( WorldGridNodeEvent.CLICKED, nodeClicked );
      }
    }
    
    private function nodeOver( e:WorldGridNodeEvent ):void {
      addChild( WorldGridNode( e.target ) );
      if ( _menu ) {
        addChild( _menu );
      }
      if ( _clicked ) {
        addChild( _clicked );
      }
    }
    
    private function nodeClicked( e:WorldGridNodeEvent ):void {
      if ( _menu ) {
        closeMenu();
      }      
      _potential = WorldGridNode( e.target );
      dispatchEvent( new WorldGridEvent( WorldGridEvent.CLICK_REQUESTED ) );
    }
    
    public function cancelClick():void {
      _potential = null;
    }
    
    public function confirmClick():void {
      if ( _clicked ) {
        _clicked.deselect();
      }
      _clicked = _potential;
      _potential = null;
      _clicked.select();
      addChild( _clicked );      
      createMenu();
    }
    
    private function createMenu():void {
      _menu = new WorldGridNodeMenu( _clicked );
      addChildAt( _menu, getChildIndex( _clicked ) );
      _menu.x = _clicked.x;
      _menu.y = _clicked.y;
      _menu.filters = [new GlowFilter( 0, .6, 10, 10, 2, 1 )];
      KuroExpress.addListener( _menu, Event.CLOSE, menuClosed, _menu );
    }
    
    private function closeMenu():void {
      if( _menu ) {
        _menu.close();
      }
    }
    
    private function menuClosed( menu:WorldGridNodeMenu ):void {
      removeChild( menu );
      KuroExpress.removeListener( menu, Event.CLOSE, menuClosed );
      if ( menu == _menu ) {
        _menu = null;
        if ( _clicked ) {
          _clicked.deselect();
        }
        _clicked = null;
        _potential = null;
      }
    }
    
  }

}