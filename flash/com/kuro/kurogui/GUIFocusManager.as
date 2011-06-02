package com.kuro.kurogui {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Stage;
  import flash.events.MouseEvent;
  
  internal class GUIFocusManager {
    
    private static var _focusEnabled:Boolean = false;
    
    private static var _elements:Array = [];    
    private static var _current:GUIElement;
    
    public static function enableFocus( stage:Stage ):void {
      _focusEnabled = true;
      stage.addEventListener( MouseEvent.MOUSE_DOWN, stageDown );
    }
    
    private static function stageDown( e:MouseEvent ):void {
      if ( _current ) {
        if ( !_current.hitTestPoint( e.stageX, e.stageY, true ) ) {
          _current.unfocused();
          _current = null;
        }
      }
    }
    
    public static function registerElement( element:GUIElement ):void {
      if ( !_focusEnabled ) {
        return;
      }
      if ( _elements.indexOf( element ) < 0 ) {
        _elements.push( element );
        KuroExpress.addListener( element, MouseEvent.CLICK, elementClicked, element );
      }      
    }
    
    private static function elementClicked( element:GUIElement ):void {
      if ( _current && !_current.isParentOf( element ) ) {
        _current.unfocused();
      }
      _current = element;
      _current.focused();
    }
    
  }

}