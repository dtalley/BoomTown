package com.kuro.kurogui.events {
	import flash.events.Event;
	
  public class GUIElementEvent extends Event {
    
    public function GUIElementEvent( type:String ) {
      super( type );      
    }
    
    public static const LOST_FOCUS:String = "lost_focus";
    public static const GAINED_FOCUS:String = "gained_focus";
    
  }

}