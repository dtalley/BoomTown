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
    
    public static const BACKGROUND_READY:String = "background_ready";    
    public static const BACKGROUND_POPULATED:String = "background_populated";
    
  }

}