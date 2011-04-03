package com.boomtown.modules.commandercreator.events {
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class PhotoEditorEvent extends Event {
    
    public function PhotoEditorEvent( type:String ) {
      super(type);
    }
    
    public static function get PHOTO_NOT_LOADED():String {
      return "photo_not_loaded";
    }
    
  }

}