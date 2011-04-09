package com.boomtown.modules.worldmap {
  import com.boomtown.core.Commander;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.events.OpenModuleEvent;
  import com.boomtown.modules.worldmap.events.WorldGridEvent;
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
  import flash.utils.Timer;
  
  public class WorldMap extends Module {
    
    private var _grid:WorldGrid;
    
    public function WorldMap():void {
      _id = "WorldMap";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
       _grid = new WorldGrid();
       _grid.addEventListener( WorldGridEvent.GRID_READY, gridReady );
       KuroExpress.broadcast( "Creating grid and beginning its pool population", { obj:this, label:"WorldMap::start()" } );
    }
    
    private function gridReady( e:WorldGridEvent ):void {
      KuroExpress.broadcast( "Grid has signaled that it is ready for population", { obj:this, label:"WorldMap::gridReady()" } );
      _grid.removeEventListener( WorldGridEvent.GRID_READY, gridReady );
    }
    
    override public function close():void {
      
      super.close();
    }
    
  }
  
}