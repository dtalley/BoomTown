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
    
    public static const NODE_CLICKED:String = "node_clicked";    
    public static const NODE_OVER:String = "node_over";
    
  }

}