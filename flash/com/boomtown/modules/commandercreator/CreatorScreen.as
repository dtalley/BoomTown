package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.boomtown.modules.commandercreator.events.CreatorScreenEvent;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.StatusEvent;
  import flash.text.TextField;
  
  public class CreatorScreen extends Sprite {
    
    protected var _commander:Commander;
    protected var _closing:Boolean = false;
    protected var _saved:Boolean = false;
    
    public function CreatorScreen( commander:Commander ):void {
      _commander = commander;
    }
    
    public function open():void {
      
    }
    
    public function close():void {
      _closing = true;
    }
    
    public function verify():Boolean {
      return true;
    }
    
    public function save():void {
      _saved = true;
      dispatchEvent( new CreatorScreenEvent( CreatorScreenEvent.SCREEN_SAVED ) );
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
    
    public function get saved():Boolean {
      return _saved;
    }
    
  }
  
}