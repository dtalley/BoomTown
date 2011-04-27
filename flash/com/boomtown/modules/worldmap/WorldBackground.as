package com.boomtown.modules.worldmap {
  import com.boomtown.modules.worldmap.events.WorldBackgroundEvent;
  import com.boomtown.modules.worldmap.events.WorldGridEvent;
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
  import com.boomtown.utils.BlockAxisGrid;
  import com.boomtown.utils.BlockMetrics;
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
  internal class WorldBackground extends Sprite { 
    
    private var _width:Number = 200;
    private var _height:Number = 200;
    
    private var _pool:ObjectPool;
    
    public function setMetrics( width:Number, height:Number ):void {
      _width = width;
      _height = height;
      KuroExpress.broadcast( "Setting WorldBackground metrics.", 
        { obj:this, label:"WorldBackground::setMetrics()" } );
      populate();
    }
    
    public function WorldBackground() {
      init();
    }
    
    private function init():void {
      WorldBackgroundCache.init( 25, 25 );
      _pool = new ObjectPool( 100, WorldBackgroundNode );
      _pool.addEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Beginning pool population", 
        { obj:this, label:"WorldBackground::init()" } );
    }
    
    private function poolReady( e:Event ):void {
      _pool.removeEventListener( Event.COMPLETE, poolReady );
      KuroExpress.broadcast( "Pool has been populated", 
        { obj:this, label:"WorldBackground::poolReady()" } );
      dispatchEvent( new WorldBackgroundEvent( WorldBackgroundEvent.BACKGROUND_READY ) );
    }
    
    public function resetMetrics():void {
      if ( 
        !BlockAxisGrid.metrics || 
        BlockAxisGrid.metrics.width != _width || 
        BlockAxisGrid.metrics.height != _height
      ) {
        BlockAxisGrid.metrics = new BlockMetrics( _width, _height );
      }
    }
    
    public function position( x:int, y:int ):void {      
      this.x = x;
      this.y = y;
    }
    
    public function populate():void {
      resetMetrics();
      
      var sX:int = Math.round( ( stage.stageWidth / 2 ) - this.x );
      var sY:int = Math.round( ( stage.stageHeight / 2 ) - this.y );
      var tLX:int = Math.floor( sX - ( stage.stageWidth / 2 ) - _width * 2 );
      var tLY:int = Math.floor( sY - ( stage.stageHeight / 2 ) - _height * 2 );
      var bRX:int = Math.ceil( sX + ( stage.stageWidth / 2 ) + _width * 2 );
      var bRY:int = Math.ceil( sY + ( stage.stageHeight / 2 ) + _height * 2 );
      
      var totalChildren:uint = numChildren;
      for ( var i:uint = 0; i < totalChildren; i++ ) {
        if ( getChildAt(i) is WorldBackgroundNode ) {
          var node:WorldBackgroundNode = WorldBackgroundNode( getChildAt( i ) );
          node.x = BlockAxisGrid.calculateX( node.bX, node.bY );
          node.y = BlockAxisGrid.calculateY( node.bX, node.bY );
          if ( node.x < tLX || node.x > bRX || node.y < tLY || node.y > bRY ) {
            destroyNode( node );
            i--;
            totalChildren--;
          } else {
            node.metrics = BlockAxisGrid.metrics;
          }
        }
      }
      
      createGrid( Math.round( BlockAxisGrid.calculateBlockX( sX, sY ) ), 
                  Math.round( BlockAxisGrid.calculateBlockY( sX, sY ) ), 
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
          var useX:int = BlockAxisGrid.calculateX( cx, cy );
          var useY:int = BlockAxisGrid.calculateY( cx, cy );
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
        dispatchEvent( new WorldBackgroundEvent( WorldBackgroundEvent.BACKGROUND_POPULATED ) );
      }
    }
    
    private function createNode( x:int, y:int ):void {
      var newNode:WorldBackgroundNode = null;
      if ( !WorldBackgroundCache.checkNode( x, y ) ) {
        newNode = WorldBackgroundNode( _pool.getObject() );
        WorldBackgroundCache.addNode( x, y );
        newNode.init( BlockAxisGrid.metrics, x, y );
        addChild( newNode );
        newNode.x = BlockAxisGrid.calculateX( x, y );
        newNode.y = BlockAxisGrid.calculateY( x, y );
      }
    }
    
    private function destroyNode( node:WorldBackgroundNode ):void {
      WorldBackgroundCache.removeNode( node.bX, node.bY );
      _pool.returnObject( node );
      removeChild( node );
      node.clear();
    }
    
  }

}