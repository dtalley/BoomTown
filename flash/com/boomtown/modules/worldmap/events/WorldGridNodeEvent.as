package com.boomtown.modules.worldmap.events {
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class WorldGridNodeEvent extends Event {
    
    public function WorldGridNodeEvent( type:String ) {
      super( type );
    }
    
    public static const CLICKED:String = "world_grid_node_clicked";    
    public static const OVER:String = "world_grid_node_over";
    
  }

}