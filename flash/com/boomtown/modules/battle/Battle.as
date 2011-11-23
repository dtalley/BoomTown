package com.boomtown.modules.battle {
  import com.boomtown.game.Commander;
  import com.boomtown.core.GameDriver;
  import com.boomtown.core.ITickedObject;
  import com.boomtown.core.IAnimatedObject;
  import com.boomtown.modules.battle.events.BattleGridEvent;
  import com.boomtown.modules.battle.grid.BattleGrid;
	import com.boomtown.modules.core.Module;
  import com.boomtown.render.BasicCamera;
  import com.boomtown.render.BasicFrame;
  import com.boomtown.render.BasicRenderer;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.events.MouseEvent;
  import flash.geom.Point;
	
  public class Battle extends Module implements ITickedObject, IAnimatedObject {
    
    private var _grid:BattleGrid;
    private var _offset:Point;
    private var _start:Point;
    private var _clicks:Boolean = true;
    
    private var _renderer:BasicRenderer;
    private var _camera:BasicCamera;
    private var _frame:BasicFrame;
    
    public function Battle() {
      _id = "Battle";
    }
    
    override public function open( commander:Commander, driver:GameDriver ):void {
      super.open( commander, driver );
      start();
    }
    
    private function start():void {
      _renderer = new BasicRenderer();
      _camera = new BasicCamera();
      _camera.resize( stage.stageWidth, stage.stageHeight );
      _camera.focus( stage.stageWidth / 2, stage.stageHeight / 2 );
      _frame = new BasicFrame( _camera.width, _camera.height );
      addChild( _frame );
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
      _grid.positionCamera( _camera, 10, 10 );
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
      _driver.addTickedObject( this, 0 );
      _driver.addAnimatedObject( this, 0 );
      _renderer.add( _grid );
      _renderer.start();
      stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
    }
    
    public function onTick( rate:Number ):void {
      
    }
    
    public function onFrame( offset:Number ):void {
      _frame.clearColor( 0xFFFFFF );
      _renderer.render( _frame, _camera );
    }
    
    private function mouseDown( e:MouseEvent ):void {
      _offset = new Point( mouseX, mouseY );
      stage.addEventListener( MouseEvent.MOUSE_MOVE, checkNav );
      stage.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
    }
    
    private function checkNav( e:MouseEvent ):void {
      var distance:Number = Math.sqrt( Math.pow( mouseX - _offset.x, 2 ) + Math.pow( mouseY - _offset.y, 2 ) );
      if ( distance > 5 ) {
        enableNav();
        stage.removeEventListener( MouseEvent.MOUSE_MOVE, checkNav );
      }
    }
    
    private function enableNav():void {
      _clicks = false;
      _start = new Point( _camera.x, _camera.y );
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
      _camera.tx = _start.x - ( mouseX - _offset.x );
      _camera.ty = _start.y - ( mouseY - _offset.y );
      TweenLite.to( _camera, .2, { x:_camera.tx, y:_camera.ty, onUpdate:updateGrid, onComplete:updateGrid } );
    }
    
    private function updateGrid():void {
      _camera.x = Math.round( _camera.x );
      _camera.y = Math.round( _camera.y );
    }
    
    override public function close():void {      
      super.close();
    }
    
  }
}