package com.kuro.kurogui.util {
	
  public class GUIDrawState {
    
    public function GUIDrawState( lock:GUIDrawStateLock ) {}
    
    public static const UNFOCUSED:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());    
    public static const FOCUSED:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());
    public static const ACTIVATED:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());
    public static const HOVERING:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());
    public static const DISABLED:GUIDrawState = new GUIDrawState(new GUIDrawStateLock());
    
  }

}
class GUIDrawStateLock{function GUIDrawStateLock():void{}}