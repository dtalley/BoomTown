package com.boomtown.modules.worldmap {
  import com.boomtown.core.Commander;
  import com.boomtown.core.HexGridBackground;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.events.OpenModuleEvent;
  import com.boomtown.gui.StandardButton;
  import com.boomtown.loader.GraphicLoader;
  import com.boomtown.modules.commandercreator.events.CreatorScreenEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.GradientType;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.text.TextField;
  import com.boomtown.modules.core.Module;
  import flash.utils.getQualifiedClassName;
  
  public class WorldMap extends Module {
    
    
    public function WorldMap():void {
      _id = "WorldMap";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      
    }
    
    override public function close():void {
      
      super.close();
    }
    
  }
  
}