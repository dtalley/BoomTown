package com.kuro.kurogui.ui.events {
	import flash.events.Event;
	
  public class GUIDraggableEvent extends Event {
    
    public function GUIDraggableEvent( type:String ) {      
      super( type );      
    }
    
    public static var DRAGGED:String = "guidraggableevent.dragged";
    public static var DROPPED:String = "guidraggableevent.dropped";
    
  }

}