package com.boomtown.modules.workshop {
  import com.boomtown.core.Commander;
	import com.boomtown.modules.core.Module;
  import com.kuro.kurogui.core.GUIElement;
  import com.kuro.kurogui.ui.GUIDraggable;
  import flash.display.Sprite;
  import flash.geom.Rectangle;
	
  public class Workshop extends Module {
    
    public function Workshop() {
      _id = "Workshop";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      
    }
    
  }
}