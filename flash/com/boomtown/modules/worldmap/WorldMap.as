package com.boomtown.modules.worldmap {
  import com.boomtown.core.Commander;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.events.OpenModuleEvent;
  import com.boomtown.modules.worldmap.background.WorldBackground;
  import com.boomtown.modules.worldmap.events.WorldBackgroundEvent;
  import com.boomtown.modules.worldmap.events.WorldGridEvent;
  import com.boomtown.modules.worldmap.grid.WorldGrid;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import com.boomtown.modules.core.Module;
  import flash.events.TimerEvent;
  import flash.geom.Point;
  import flash.utils.Timer;
  
  public class WorldMap extends Module {
    
    private var _background:Sprite;
    private var _land:WorldBackground;
    private var _grid:WorldGrid;
    private var _offset:Point;
    
    private var _clicks:Boolean = true;
    
    public function WorldMap():void {
      _id = "WorldMap";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      _background = new Sprite();
      _background.graphics.beginFill( 0xFFFFFF );
      _background.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
      _background.graphics.endFill();
      addChild( _background );
      TweenLite.from( _background, .3, { alpha:0 } );
      
      prepareGrid();
    }
    
    private function prepareGrid():void {
      KuroExpress.broadcast( "Creating grid and beginning its pool population", 
        { obj:this, label:"WorldMap::start()" } );
      _grid = new WorldGrid();
      _grid.addEventListener( WorldGridEvent.READY, gridReady );
    }
    
    private function gridReady( e:WorldGridEvent ):void {
      KuroExpress.broadcast( "Grid has signaled that it is ready for population", 
        { obj:this, label:"WorldMap::gridReady()" } );
      _grid.removeEventListener( WorldGridEvent.READY, gridReady );
      
      prepareBackground();
    }
    
    private function prepareBackground():void {
      _land = new WorldBackground();
      _land.addEventListener( WorldBackgroundEvent.READY, backgroundReady );
    }
    
    private function backgroundReady( e:WorldBackgroundEvent ):void {
      KuroExpress.broadcast( "Background has signaled that it is ready for population", 
        { obj:this, label:"WorldMap::backgroundReady()" } );
      _land.removeEventListener( WorldBackgroundEvent.READY, backgroundReady );
      
      populateGrid();
    }
    
    private function populateGrid():void {
      addChild( _grid );
      _grid.position( 10, 10 );
      _grid.visible = false;
      _grid.addEventListener( WorldGridEvent.POPULATED, gridPopulated );
      _grid.populate();
    }
    
    private function gridPopulated( e:WorldGridEvent ):void {
      KuroExpress.broadcast( "Grid has signaled that it is populated.",
        { obj:this, label:"WorldMap::gridPopulated()" } );
      _grid.removeEventListener( WorldGridEvent.POPULATED, gridPopulated );
      
      populateBackground();
    }
    
    private function populateBackground():void {
      addChild( _land );
      _land.position( _grid.x, _grid.y );
      _land.visible = false;
      _land.addEventListener( WorldBackgroundEvent.POPULATED, backgroundPopulated );
      _land.populate();
    }
    
    private function backgroundPopulated( e:WorldBackgroundEvent ):void {
      KuroExpress.broadcast( "Background has signaled that it is populated", 
        { obj:this, label:"WorldMap::backgroundPopulated()" } );
      _land.removeEventListener( WorldBackgroundEvent.POPULATED, backgroundPopulated );
      
      init();
    }
    
    private function init():void {      
      _grid.visible = true;
      _land.visible = true;
      
      addChild( _land );
      addChild( _grid );
      
      TweenLite.from( _land, .4, { alpha:1 } );
      TweenLite.from( _grid, .4, { alpha:1, delay:.4 } );
      
      _grid.addEventListener( WorldGridEvent.CLICK_REQUESTED, clickRequested );
      stage.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );
    }
    
    private function mouseDown( e:MouseEvent ):void {
      _offset = new Point( _grid.mouseX, _grid.mouseY );
      var timer:Timer = new Timer(30,1);
      timer.addEventListener( TimerEvent.TIMER_COMPLETE, enableNav );
      KuroExpress.addListener( stage, MouseEvent.MOUSE_UP, interceptNav, timer );
      timer.start();
    }
    
    private function interceptNav( timer:Timer ):void {
      timer.removeEventListener( TimerEvent.TIMER_COMPLETE, enableNav );
    }
    
    private function enableNav( e:TimerEvent ):void {
      _clicks = false;
      KuroExpress.removeListener( stage, MouseEvent.MOUSE_UP, interceptNav );
      stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
      stage.addEventListener( MouseEvent.MOUSE_UP, mouseUp );
    }
    
    private function mouseUp( e:MouseEvent ):void {
      _clicks = true;
      stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
      stage.removeEventListener( MouseEvent.MOUSE_UP, mouseUp );
    }
    
    private function mouseMove( e:MouseEvent ):void {
      TweenLite.to( _grid, .2, { x:mouseX - _offset.x, y:mouseY - _offset.y, onUpdate:updateGrid, onComplete:updateGrid } );
    }
    
    private function clickRequested( e:WorldGridEvent ):void {
      KuroExpress.broadcast( "A click was requested", 
        { obj:this, label:"WorldMap::clickRequested()" } );
      if ( _clicks ) {
        _grid.confirmClick();
      } else {
        _grid.cancelClick();
      }
    }
    
    private function updateGrid():void {
      _grid.x = Math.round( _grid.x );
      _grid.y = Math.round( _grid.y );
      _land.x = Math.round( _grid.x );
      _land.y = Math.round( _grid.y );
      _grid.populate();
      _land.populate();      
    }
    
    override public function close():void {      
      super.close();
    }
    
  }
  
}