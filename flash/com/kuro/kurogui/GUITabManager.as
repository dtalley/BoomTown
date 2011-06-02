package com.kuro.kurogui {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Stage;
  import flash.events.KeyboardEvent;
  import flash.ui.Keyboard;
	
  public class GUITabManager {
    
    private static var _tabsEnabled:Boolean = false;
    
    private static var _elements:Array = [];
    private static var _current:int = -1;
    private static var _element:GUIElement;
    
    public static function enableTabs( stage:Stage ):void {
      _tabsEnabled = true;
      stage.tabChildren = false;
      stage.tabEnabled = false;
      KuroExpress.addListener( stage, KeyboardEvent.KEY_DOWN, keyDown );
    }
    
    private static function keyDown( e:KeyboardEvent ):void {
      if ( !_tabsEnabled ) {
        return;
      }
      if ( e.keyCode == Keyboard.TAB ) {
        tabPressed();
      }
    }
    
    /**
     * Register an element with the tab manager so that when the tab key is pressed enough times, the element gains focus.
     * @param	element The element to add to the tab cycle
     * @param	position The position to add the element at
     */
    public static function registerElement( element:GUIElement, position:int = -1 ):void {
      if ( !_tabsEnabled ) {
        return;
      }
      if ( position >= 0 && position < _elements.length - 1 ) {
        _elements.splice( position, 0, element );
      } else {
        _elements.push( element );
      }
    }
    
    public static function flushElements():void {
      if ( !_tabsEnabled ) {
        return;
      }
      _elements = [];
    }
    
    private static function tabPressed():void {
      if ( _elements.length > 0 ) {
        _current++;
        if ( _current >= _elements.length ) {
          _current = 0;
        }
        if( _element ) {
          _element.unfocused();
        }
        _element = _elements[_current];
        _element.tabbed();
      }
    }
    
  }

}