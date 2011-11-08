package com.boomtown.modules.battle {
  import com.boomtown.core.Commander;
  import com.boomtown.modules.battle.events.BattleGridEvent;
  import com.boomtown.modules.battle.grid.BattleGrid;
	import com.boomtown.modules.core.Module;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.events.MouseEvent;
  import flash.geom.Point;
	
  public class Battle extends Module {
    
    private var _grid:BattleGrid;
    private var _offset:Point;
    private var _clicks:Boolean = true;
    
    public function Battle() {
      _id = "Battle";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      prepareGrid();
    }
    
    private function prepareGrid():void {
      KuroExpress.broadcast( "Creating grid and beginning its pool population", 
        { obj:this, label:"Battle::start()" } );
      _grid = new BattleGrid();
      _grid.addEventListener( BattleGridEvent.READY, gridReady );
    }
    
    private function gridReady( e:BattleGridEvent ):void {
      KuroExpress.broadcast( "Grid has signaled that it is ready for population", 
        { obj:this, label:"Battle::gridReady()" } );
      _grid.removeEventListener( BattleGridEvent.READY, gridReady );
      
      populateGrid();
    }
    
    private function populateGrid():void {
      addChild( _grid );
      _grid.position( 10, 10 );
      _grid.visible = false;
      _grid.addEventListener( BattleGridEvent.POPULATED, gridPopulated );
      _grid.populateKey();
    }
    
    private function gridPopulated( e:BattleGridEvent ):void {
      KuroExpress.broadcast( "Grid has signaled that it is populated.",
        { obj:this, label:"Battle::gridPopulated()" } );
      _grid.removeEventListener( BattleGridEvent.POPULATED, gridPopulated );
      
      init();
    }
    
    private function init():void {      
      _grid.visible = true;
      
      stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
    }
    
    private function mouseDown( e:MouseEvent ):void {
      _offset = new Point( _grid.mouseX, _grid.mouseY );
      stage.addEventListener( MouseEvent.MOUSE_MOVE, checkNav );
      stage.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
    }
    
    private function checkNav( e:MouseEvent ):void {
      var distance:Number = Math.sqrt( Math.pow( _grid.mouseX - _offset.x, 2 ) + Math.pow( _grid.mouseY - _offset.y, 2 ) );
      if ( distance > 5 ) {
        enableNav();
        stage.removeEventListener( MouseEvent.MOUSE_MOVE, checkNav );
      }
    }
    
    private function enableNav():void {
      _clicks = false;
      stage.removeEventListener( MouseEvent.MOUSE_MOVE, checkNav );
      stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
    }
    
    private function mouseUp( e:MouseEvent ):void {
      if( !_clicks ) {
        _clicks = true;
        stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
        stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUp );
        TweenLite.delayedCall( .05, enableGrid );
      } else {
        stage.removeEventListener( MouseEvent.MOUSE_MOVE, checkNav );
      }
    }
    
    private function enableGrid():void {
      
    }
    
    private function mouseMove( e:MouseEvent ):void {
      TweenLite.to( _grid, .2, { x:mouseX - _offset.x, y:mouseY - _offset.y, onUpdate:updateGrid, onComplete:updateGrid } );
    }
    
    private function updateGrid():void {
      _grid.x = Math.round( _grid.x );
      _grid.y = Math.round( _grid.y );
      _grid.populate();
    }
    
    override public function close():void {      
      super.close();
    }
    
  }
}