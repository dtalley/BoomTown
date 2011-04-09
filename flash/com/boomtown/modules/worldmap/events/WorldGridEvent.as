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
    
    public static function get GRID_READY():String {
      return "grid_ready";
    }
    
    public static function get GRID_POPULATED():String {
      return "grid_populated";
    }
    
  }

}