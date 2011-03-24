package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  
  public class ChooseFaction extends CreatorScreen {
    
    public function ChooseFaction( commander:Commander ):void {      
      super( commander );
    }
    
    override public function open():void {
      
    }
    
    override public function close():void {
      super.close();
    }
    
  }
  
}