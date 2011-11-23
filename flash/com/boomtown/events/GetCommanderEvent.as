package com.boomtown.events 
{
  import com.boomtown.game.Commander;
	import flash.events.Event;
	
  public class GetCommanderEvent extends Event {
    
    private var _commander:Commander;
    
    public function GetCommanderEvent() {
      super( GET_COMMANDER, true );
    }
    
    public function set commander( val:Commander ):void {
      _commander = val;
    }
    
    public function get commander():Commander {
      return _commander;
    }
    
    public static const GET_COMMANDER:String = "GetCommanderEvent.GET_COMMANDER";
    
  }

}