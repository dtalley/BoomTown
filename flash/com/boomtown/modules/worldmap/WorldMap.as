package com.boomtown.modules.worldmap {
  import com.boomtown.core.Commander;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.events.OpenModuleEvent;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import com.boomtown.modules.core.Module;
  
  public class WorldMap extends Module {
    
    private var _background:Bitmap;
    
    public function WorldMap():void {
      _id = "WorldMap";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      _background = KuroExpress.createBitmap("WorldMapBackground");
      addChild( _background );
      TweenLite.from( _background, .3, { alpha:0 } );
    }
    
    override public function close():void {
      
      super.close();
    }
    
  }
  
}