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
    
    public static const SCREEN_SAVED:String = "screen_saved";    
    public static const SAVE_COMMANDER:String = "save_commander";
    
  }

}