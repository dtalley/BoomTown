package com.boomtown.events {
  import flash.events.Event;
  
  public class CommanderEvent extends Event {
    
    public function CommanderEvent( type:String ):void {
      super(type);
    }
    
    public static function get TOKEN_REFRESHED():String {
      return "token_refreshed";
    }
    
    public static function get COMMANDER_SAVED():String {
      return "commander_saved";
    }
    
  }
  
}