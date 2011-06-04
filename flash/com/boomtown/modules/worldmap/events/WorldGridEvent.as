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
    
    public static const READY:String = "world_grid_ready";    
    public static const POPULATED:String = "world_grid_populated";
    public static const CLICK_REQUESTED:String = "world_grid_click_requested";
    
  }

}