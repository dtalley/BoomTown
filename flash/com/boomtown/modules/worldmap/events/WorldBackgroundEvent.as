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
    
    public static const READY:String = "world_background_ready";    
    public static const POPULATED:String = "world_background_populated";
    
  }

}