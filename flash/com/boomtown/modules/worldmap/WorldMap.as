package com.boomtown.modules.worldmap {
  import com.boomtown.core.Commander;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.events.OpenModuleEvent;
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
    
    private var _grid:Sprite;
    private var _key:Bitmap;
    
    public function WorldMap():void {
      _id = "WorldMap";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      _key = KuroExpress.createBitmap("WorldMapKey");
      _grid = new Sprite();
      addChild( _grid );
      _grid.x = 300;//Math.floor( stage.stageWidth / 2 );
      _grid.y = Math.floor( stage.stageHeight - 100 );
      
      var draw:Timer = new Timer(10);
      draw.addEventListener( TimerEvent.TIMER, drawMap );
      draw.start();
    }
    
    private var current:uint = 0;
    private var total:uint = 0;
    private function drawMap( e:TimerEvent ):void {
      var metrics:Object = Hexagon.getMetrics( 12, 8, 0 );
      HexagonAxisGrid.yalign = metrics.angle1;
      HexagonAxisGrid.xalign = metrics.angle2;
      for ( var i:int = 0; i < 10; i++ ) {
        var col:uint = current % _key.width;
        var row:uint = _key.height - Math.floor( current / _key.height );
        if( row > 0 ) {
          var tx:Number = HexagonAxisGrid.calculateX( 6, 4, col, row, 0 );
          var ty:Number = HexagonAxisGrid.calculateY( 6, 4, col, row, 0 );
          var pixel:uint = _key.bitmapData.getPixel( col, _key.height - row );
          if( pixel < 0xFFFFFF ) {
            _grid.graphics.beginFill( 0xFFFFFF );
            total++;
          } else {
            _grid.graphics.beginFill( 0xFF0000 );
          }
          Hexagon.drawHexagon( _grid, 12, 8, tx, ty, 0 );
          _grid.graphics.endFill();
          current++;
        } else {
          trace( total + " total open territories out of " + current + " total spaces." );
          Timer( e.target ).stop();
          Timer( e.target ).removeEventListener( TimerEvent.TIMER, drawMap );
          return;
        }
      }
    }
    
    override public function close():void {
      
      super.close();
    }
    
  }
  
}