package com.kuro.kurogui.utils {
	
  public class GUIDrawState {
    
    public function GUIDrawState( lock:GUIDrawStateLock ) {}
    
    private static const _unfocused:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());
    public static function get UNFOCUSED():GUIDrawState {
      return _unfocused;
    }
    
    private static const _focused:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());
    public static function get FOCUSED():GUIDrawState {
      return _focused;
    }
    
    private static const _activated:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());
    public static function get ACTIVATED():GUIDrawState {
      return _activated;
    }
    
  }

}
class GUIDrawStateLock{function GUIDrawStateLock():void{}}