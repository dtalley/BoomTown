package com.kuro.kurogui.events {
	import flash.events.Event;
  import flash.events.MouseEvent;
	
  public class GUIElementEvent extends Event {
    
    public function GUIElementEvent( type:String ) {
      super( type, true, true );
    }
    
    public static const LOST_FOCUS:String = "gui_element_lost_focus";
    public static const GAINED_FOCUS:String = "gui_element_gained_focus";
    public static const MOVED:String = "gui_element_moved";
    public static const DROPPED:String = "gui_element_dropped";
    public static const ENTERED:String = "gui_element_entered";
    public static const LEFT:String = "gui_element_left";
    
  }

}