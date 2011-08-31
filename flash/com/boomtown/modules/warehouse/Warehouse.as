package com.boomtown.modules.warehouse {
  import com.boomtown.core.Commander;
	import com.boomtown.modules.core.Module;
  import com.kuro.kurogui.core.GUIElement;
  import com.kuro.kurogui.ui.GUIDraggable;
  import flash.display.Sprite;
  import flash.geom.Rectangle;
	
  public class Warehouse extends Module {
    
    public function Warehouse() {
      _id = "Warehouse";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      var draggable:GUIDraggable = new GUIDraggable( 200, 100, new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );
      var content:Sprite = new Sprite();
      content.graphics.beginFill( 0xFF0000 );
      content.graphics.drawRect( 0, 0, 200, 100 );
      content.graphics.endFill();
      draggable.addChild( content );
      addChild( draggable );
      draggable.x = 100;
      draggable.y = 100;
    }
    
  }
}