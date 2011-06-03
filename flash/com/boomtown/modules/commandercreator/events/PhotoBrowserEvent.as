package com.boomtown.modules.commandercreator.events {
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class PhotoBrowserEvent extends Event {
    
    private var _photo:String;
    
    public function PhotoBrowserEvent( type:String, photo:String ) {
      super(type);
      _photo = photo;
    }
    
    public function get photo():String {
      return _photo;
    }
    
    public static const PHOTO_CLICKED:String = "photo_clicked";
    
  }

}