package com.boomtown.modules.commandercreator.events {
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class CreatorScreenEvent extends Event {
    
    public function CreatorScreenEvent( type:String ) {
      super( type );
    }
    
    public static function get SCREEN_SAVED():String {
      return "screen_saved";
    }
    
    public static function get SAVE_COMMANDER():String {
      return "save_commander";
    }
    
  }

}