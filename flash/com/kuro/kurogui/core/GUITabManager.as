package com.kuro.kurogui.core {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kurogui.events.GUIElementEvent;
  import flash.display.Stage;
  import flash.events.KeyboardEvent;
  import flash.ui.Keyboard;
  
  public class GUITabManager {
    
    private static var _tabsEnabled:Boolean = false; //True if enableTabs has been called
    
    private static var _elements:Array = []; //A list of elements that can be tabbed through
    private static var _current:int = -1; //The current tab index
    private static var _element:GUIElement; //The element with tab focus
    
    /**
     * Enable KuroGUI managed tab key presses.  Disables the standard Flash tab handler.
     * @param	stage The main stage object
     */
    public static function enableTabs( stage:Stage ):void {
      _tabsEnabled = true;
      stage.tabChildren = false;
      stage.tabEnabled = false;
      KuroExpress.addListener( stage, KeyboardEvent.KEY_DOWN, keyDown );
    }
    
    /**
     * Called when a key has been pressed while the main stage has focus.
     * @param	e The calling KeyboardEvent object
     */
    private static function keyDown( e:KeyboardEvent ):void {
      if ( !_tabsEnabled ) {
        return;
      }
      if ( e.keyCode == Keyboard.TAB ) {
        tabPressed();
      } else if ( e.keyCode == Keyboard.ENTER ) {
        enterPressed();
      }
    }
    
    /**
     * Register an element with the tab manager so that when the tab key is pressed enough times, the element gains focus.
     * @param	element The element to add to the tab cycle
     * @param	position The position to add the element at
     */
    internal static function registerElement( element:GUIElement, position:int = -1 ):void {
      if ( !_tabsEnabled ) {
        return;
      }
      if( _elements.indexOf( element ) < 0 ) {
        if ( position >= 0 && position < _elements.length - 1 ) {
          _elements.splice( position, 0, element );
        } else {
          _elements.push( element );
        }
        KuroExpress.addListener( element, GUIElementEvent.GAINED_FOCUS, elementGainedFocus, element );
      }
    }
    
    /**
     * Remove an element from the tab list
     * @param	element The element needing removal
     */
    internal static function unregisterElement( element:GUIElement ):void {
      if ( !_tabsEnabled ) {
        return;
      }
      var index:int = _elements.indexOf( element );
      if ( index >= 0 ) {
        _elements.splice( index, 1 );
        if ( _current >= index ) {
          _current--;
        }
        if ( _element == element ) {
          _element.unfocused();
        }
        KuroExpress.removeListener( element, GUIElementEvent.GAINED_FOCUS, elementGainedFocus );
      }
    }
    
    /**
     * Called from keyDown when the key pressed was determined to be the tab key.  Sets focus on the next element in the tab list.
     */
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
        _element.addEventListener( GUIElementEvent.LOST_FOCUS, elementLostFocus );
      }
    }
    
    /**
     * Called when an element gains focus through means other than tabbing (i.e. clicking)
     * @param	element The element that has focus
     */
    private static function elementGainedFocus( element:GUIElement ):void {
      if( _element != element ) {
        var index:int = _elements.indexOf( element );
        if ( index >= 0 ) {
          _current = index;
          _element = element;
          element.tabbed();
        }
      }
    }
    
    /**
     * Called when an element has lost focus through any means
     * @param	e
     */
    private static function elementLostFocus( e:GUIElementEvent ):void {
      _element.removeEventListener( GUIElementEvent.LOST_FOCUS, elementLostFocus );
      _element = null;
    }
    
    /**
     * Called from keyDown when the key pressed was determined to be the enter key.  Activate the currently focused element.
     */
    private static function enterPressed():void {
      if ( _element ) {
        _element.activated();
      }
    }
    
  }

}