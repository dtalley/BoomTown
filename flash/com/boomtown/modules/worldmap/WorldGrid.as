package com.boomtown.modules.worldmap {
  import com.boomtown.modules.worldmap.events.WorldGridEvent;
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
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
    
    private var _pool:ObjectPool;
    
    public function WorldGrid() { 
      init();
    }
    
    private function init():void {
      _pool = new ObjectPool( 100, WorldGridNode );
      _pool.addEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Beginning pool population", { obj:this, label:"WorldGrid::init()" } );
    }
    
    private function poolReady( e:Event ):void {
      _pool.removeEventListener( Event.COMPLETE, poolReady );
      dispatchEvent( new WorldGridEvent( WorldGridEvent.GRID_READY ) );
      KuroExpress.broadcast( "Pool has been populated", { obj:this, label:"WorldGrid::poolReady()" } );
    }
    
    public function populate( width:Number, height:Number ):void {
      var sX:int = Math.round( ( stage.stageWidth / 2 ) - this.x );
      var sY:int = Math.round( ( stage.stageHeight / 2 ) - this.y );
      var tLX:int = Math.floor( sX - ( stage.stageWidth / 2 ) - width );
      var tLY:int = Math.floor( sY - ( stage.stageHeight / 2 ) - height );
      var bRX:int = Math.ceil( sX + ( stage.stageWidth / 2 ) + width );
      var bRY:int = Math.ceil( sY + ( stage.stageHeight / 2 ) + height );
      
      var totalChildren:uint = numChildren;
      for ( var i:uint = 0; i < totalChildren; i++ ) {
        if ( getChildAt(i) is WorldGridNode ) {
          var node:WorldGridNode = WorldGridNode( getChildAt( i ) );
          node.x = HexagonAxisGrid.calculateX( width, height, node.hX, node.hY );
          node.y = HexagonAxisGrid.calculateY( width, height, node.hX, node.hY );
          if ( node.x < tLX || node.x > bRX || node.y < tLY || node.y > bRY ) {
            destroyHexagon( node );
            i--;
            totalChildren--;
          } else {
            node.setSize( width, height );
          }
        }
      }
      
      createGrid( width, height, Math.round( HexagonAxisGrid.calculateHexX( width, height, sX, sY ) ), Math.round( HexagonAxisGrid.calculateHexY( width, height, sX, sY ) ), 0, tLX, tLY, bRX, bRY );
    }
    
    private function createGrid( width:Number, height:Number, sx:int, sy:int, level:int, tLX:int, tLY:int, bRX:int, bRY:int ):void {
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
          var useX:int = Math.round( HexagonAxisGrid.calculateX( width, height, cx, cy ) );
          var useY:int = Math.round( HexagonAxisGrid.calculateY( width, height, cx, cy ) );
          if ( useX < tLX || useX > bRX || useY < tLY || useY > bRY ) {
            count++;
            distance = 0;
          } else {
            createHexagon( width, height, cx, cy );
            created++;
            distance++;
          }
        }
        quadrant++;
      }
      if ( created > 0 ) {
        createGrid( width, height, sx, sy, level + 1, tLX, tLY, bRX, bRY );
      } else { 
        dispatchEvent( new WorldGridEvent( WorldGridEvent.GRID_POPULATED ) );
      }
    }
    
    private function createHexagon( width:Number, height:Number, x:int, y:int ):void {
      var newNode:WorldGridNode = null;
      if ( !WorldGridCache.checkNode( x, y ) ) {
        newNode = WorldGridNode( _pool.getObject() );
        WorldGridCache.addNode( x, y );
        newNode.init( width, height, x, y );
        if ( newNode.type != WorldGridNode.INACTIVE ) {
          addChild( newNode );
          newNode.x = HexagonAxisGrid.calculateX( width, height, x, y );
          newNode.y = HexagonAxisGrid.calculateY( width, height, x, y );
        } else {
          _pool.returnObject( newNode );
        }
        if ( newNode.type == WorldGridNode.ACTIVE ) {
          newNode.addEventListener( WorldGridNodeEvent.NODE_OVER, nodeOver );
          newNode.addEventListener( WorldGridNodeEvent.NODE_CLICKED, nodeClicked );
        }
      }
    }
    
    private function destroyHexagon( node:WorldGridNode ):void {
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