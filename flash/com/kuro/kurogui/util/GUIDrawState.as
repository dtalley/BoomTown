package com.kuro.kurogui.util {
	
  public class GUIDrawState {
    
    public function GUIDrawState( lock:GUIDrawStateLock ) {}
    
    private static var _unfocused:GUIDrawState;
    public static function get UNFOCUSED():GUIDrawState {
      if ( !_unfocused ) {
        _unfocused = new GUIDrawState( new GUIDrawStateLock() );
      }
      return _unfocused;
    }
    private static var _focused:GUIDrawState;
    public static function get FOCUSED():GUIDrawState {
      if ( !_focused ) {
        _focused = new GUIDrawState( new GUIDrawStateLock() );
      }
      return _focused;
    }
    private static var _activated:GUIDrawState;
    public static function get ACTIVATED():GUIDrawState {
      if ( !_activated ) {
        _activated = new GUIDrawState( new GUIDrawStateLock() );
      }
      return _activated;
    }
    private static var _hovering:GUIDrawState;
    public static function get HOVERING():GUIDrawState {
      if ( !_hovering ) {
        _hovering = new GUIDrawState( new GUIDrawStateLock() );
      }
      return _hovering;
    }
    private static var _disabled:GUIDrawState;
    public static function get DISABLED():GUIDrawState {
      if ( !_disabled ) {
        _disabled = new GUIDrawState( new GUIDrawStateLock() );
      }
      return _disabled;
    }
  }

}
class GUIDrawStateLock{}