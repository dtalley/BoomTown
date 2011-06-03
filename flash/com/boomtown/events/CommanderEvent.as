package com.boomtown.events {
  import flash.events.Event;
  
  public class CommanderEvent extends Event {
    
    public function CommanderEvent( type:String ):void {
      super(type);
    }
    
    public static const TOKEN_REFRESHED:String = "token_refreshed";    
    public static const COMMANDER_SAVED:String = "commander_saved";
    
  }
  
}