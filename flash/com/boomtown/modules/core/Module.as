package com.boomtown.modules.core {
  import com.boomtown.core.GameDriver;
  import com.boomtown.game.Commander;
  import flash.display.MovieClip;
  import flash.events.Event;
  
  public class Module extends MovieClip {
    
    protected var _driver:GameDriver;
    
    protected var _commander:Commander;
    protected var _closing:Boolean = false;
    protected var _id:String = "module";
    
    public function Module():void {}
    
    public function open( commander:Commander, driver:GameDriver ):void {
      _commander = commander;
      _driver = driver;
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
    
    public function get id():String {
      return _id;
    }
    
    public function get closing():Boolean {
      return _closing;
    }
    
  }
  
}