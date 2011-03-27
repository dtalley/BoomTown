package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.kuro.kuroexpress.PrecisionTextField;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.GradientType;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  
  public class ChooseName extends CreatorScreen {
    
    public function ChooseName( commander:Commander ):void {     
      super( commander );
    }
    
    override public function open():void {
      
    }
    
    override public function close():void {
      super.close();
    }
    
  }
  
}