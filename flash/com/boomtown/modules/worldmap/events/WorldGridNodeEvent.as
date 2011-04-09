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
    
    public static function get NODE_CLICKED():String {
      return "node_clicked";
    }
    
    public static function get NODE_OVER():String {
      return "node_over";
    }
    
  }

}