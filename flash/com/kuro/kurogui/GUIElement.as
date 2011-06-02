package com.kuro.kurogui {
	import flash.display.Sprite;
	
  public class GUIElement extends Sprite {
    
    private var _width:Number;
    private var _height:Number;
    
    private var _hasFocus:Boolean = false;
    private var _hasTab:Boolean = false;
    
    public function GUIElement() {
      GUIFocusManager.registerElement(this);
    }
    
    public function focused():void {
      _hasFocus = true;
    }
    
    public function tabbed():void {
      _hasFocus = true;
    }
    
    public function unfocused():void {
      _hasFocus = false;
    }
    
    public function set width( val:Number ):void {
      _width = val;
      draw();
    }
    
    public function set height( val:Number ):void {
      _height = val;
      draw();
    }
    
    public override function width():Number {
      return _width;
    }
    
    public override function height():Number {
      return _height;
    }
    
    protected function draw():void {
      
    }
    
  }

}