package com.boomtown.modules.worldmap {
  import com.boomtown.modules.worldmap.events.WorldGridEvent;
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.ObjectPool;
  import flash.display.Sprite;
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  internal class WorldGrid extends Sprite { 
    
    private var _width:Number = 72;
    private var _height:Number = 78;
    private var _rotation:Number = 90;
    
    private var _pool:ObjectPool;
    
    public function setMetrics( width:Number, height:Number, rotation:Number ):void {
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
      graphics.beginFill( 0xFF0000 );
      graphics.drawRect( 0 - 3000, 0 - 3000, 6000, 6000 );
      graphics.drawRect( 0 - 3000, 0 - 3000, 3000, 3000 );
      graphics.endFill();
      WorldGridCache.init();
      _pool = new ObjectPool( 100, WorldGridNode );
      _pool.addEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Beginning pool population", 
        { obj:this, label:"WorldGrid::init()" } );
    }
    
    private function poolReady( e:Event ):void {
      _pool.removeEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Pool has been populated", 
        { obj:this, label:"WorldGrid::poolReady()" } );
      dispatchEvent( new WorldGridEvent( WorldGridEvent.GRID_READY ) );
    }
    
    public function resetMetrics():void {
      if ( 
        !HexagonAxisGrid.metrics || 
        HexagonAxisGrid.metrics.width != _width || 
        HexagonAxisGrid.metrics.height != _height || 
        HexagonAxisGrid.metrics.rotation != _rotation 
      ) {
        HexagonAxisGrid.metrics = Hexagon.getMetrics( _width, _height, _rotation );
      }
    }
    
    public function position( x:int, y:int ):void {
      resetMetrics();
      
      this.x = 0 - HexagonAxisGrid.calculateX( x, y ) + ( stage.stageWidth / 2 );
      this.y = 0 - HexagonAxisGrid.calculateY( x, y ) + ( stage.stageWidth / 2 );
    }
    
    public function populate():void {
      resetMetrics();
      
      var sX:int = Math.round( ( stage.stageWidth / 2 ) - this.x );
      var sY:int = Math.round( ( stage.stageHeight / 2 ) - this.y );
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
      
      createGrid( Math.round( HexagonAxisGrid.calculateHexX( sX, sY ) ), 
                  Math.round( HexagonAxisGrid.calculateHexY( sX, sY ) ), 
                  0, tLX, tLY, bRX, bRY );
    }
    
    private function createGrid( sx:int, sy:int, level:int, 
                                 tLX:int, tLY:int, 
                                 bRX:int, bRY:int ):void {
      var quadrant:int = 0;
      var created:int = 0;
      while ( quadrant < 4 ) {
        var addx = ( quadrant == 0 || quadrant == 1 ) ? 1 : -1;
        var addy = ( quadrant == 0 || quadrant == 2 ) ? 1 : -1;
        var nsx:int = sx + addx * level;
        var nsy:int = sy + addy * level;
        var count:int = 0;
        var distance:int = 0;
        while ( count < 2 ) {
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
        dispatchEvent( new WorldGridEvent( WorldGridEvent.GRID_POPULATED ) );
      }
    }
    
    private function createNode( x:int, y:int ):void {
      var newNode:WorldGridNode = null;
      if ( !WorldGridCache.checkNode( x, y ) ) {
        newNode = WorldGridNode( _pool.getObject() );
        WorldGridCache.addNode( x, y );
        newNode.init( HexagonAxisGrid.metrics, x, y );
        if ( newNode.type != WorldGridNode.INACTIVE ) {
          addChild( newNode );
          newNode.x = HexagonAxisGrid.calculateX( x, y );
          newNode.y = HexagonAxisGrid.calculateY( x, y );
        } else {
          _pool.returnObject( newNode );
        }
        if ( newNode.type == WorldGridNode.ACTIVE ) {
          newNode.addEventListener( WorldGridNodeEvent.NODE_OVER, nodeOver );
          newNode.addEventListener( WorldGridNodeEvent.NODE_CLICKED, nodeClicked );
        }
      }
    }
    
    private function destroyNode( node:WorldGridNode ):void {
      WorldGridCache.removeNode( node.hX, node.hY );
      _pool.returnObject( node );
      removeChild( node );
      if ( node.type == WorldGridNode.ACTIVE ) {
        node.removeEventListener( WorldGridNodeEvent.NODE_OVER, nodeOver );
        node.removeEventListener( WorldGridNodeEvent.NODE_CLICKED, nodeClicked );
      }
    }
    
    private function nodeOver( e:WorldGridNodeEvent ):void {
      
    }
    
    private function nodeClicked( e:WorldGridNodeEvent ):void {
      
    }
    
  }

}