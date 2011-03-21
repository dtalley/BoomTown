package com.boomtown.core {
  import com.kuro.kuroexpress.KuroExpress;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import nl.demonsters.debugger.MonsterDebugger;
  
  
  public class Main extends MovieClip {
    
    public function Main():void {
      var debugger:MonsterDebugger = new MonsterDebugger(this);
      MonsterDebugger.enabled = true;
      addEventListener( Event.ADDED_TO_STAGE, init );      
      ActionRequest.saveAddress( "http://boomtowngame.com/facebook/index.php" );
    }
    
    private function init( e:Event ):void {
      removeEventListener( Event.ADDED_TO_STAGE, init );
    }
    
  }
  
}