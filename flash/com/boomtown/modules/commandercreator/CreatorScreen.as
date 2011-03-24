package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  
  public class CreatorScreen extends Sprite {
    
    protected var _commander:Commander;
    protected var _closing:Boolean = false;
    
    public function CreatorScreen( commander:Commander ):void {
      _commander = commander;
    }
    
    public function open():void {
      
    }
    
    public function close():void {
      _closing = true;
    }
    
    protected function closed():void {
      var totalChildren:int = numChildren;
      for ( var i:int = 0; i < totalChildren; i++ ) {
        removeChildAt( 0 );
      }
      dispatchEvent( new Event( Event.CLOSE ) );
    }
    
    public function get closing():Boolean {
      return _closing;
    }
    
  }
  
}