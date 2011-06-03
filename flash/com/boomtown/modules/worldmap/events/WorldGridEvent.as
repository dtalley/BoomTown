package com.boomtown.modules.worldmap.events {
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class WorldGridEvent extends Event {
    
    public function WorldGridEvent( type:String ) {
      super( type );
    }
    
    public static const GRID_READY:String = "grid_ready";    
    public static const GRID_POPULATED:String = "grid_populated";
    
  }

}