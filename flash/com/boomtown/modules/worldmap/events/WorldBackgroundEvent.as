package com.boomtown.modules.worldmap.events {
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class WorldBackgroundEvent extends Event {
    
    public function WorldBackgroundEvent( type:String ) {
      super( type );
    }
    
    public static function get BACKGROUND_READY():String {
      return "background_ready";
    }
    
    public static function get BACKGROUND_POPULATED():String {
      return "background_populated";
    }
    
  }

}