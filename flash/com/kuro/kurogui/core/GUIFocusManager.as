package com.kuro.kurogui.core {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Stage;
  import flash.events.MouseEvent;
  
  public class GUIFocusManager {
    
    private static var _focusEnabled:Boolean = false; //True if enableFocus has been called
    
    private static var _elements:Array = []; //An array of GUIElements that need focus management
    private static var _focused:Array = []; //An array of currently focused elements
    
    /**
     * Enable KuroGUI managed focus.  Supercedes the standard Flash focus management.
     * @param	stage The main Stage object
     */
    public static function enableFocus( stage:Stage ):void {
      _focusEnabled = true;
      stage.addEventListener( MouseEvent.MOUSE_DOWN, stageDown );
    }
    
    /**
     * Called when the primary mouse button is pressed down anywhere on the stage
     * @param	e The calling MouseEvent
     */
    private static function stageDown( e:MouseEvent ):void {
      if ( _focused.length ) {
        var total:uint = _focused.length;
        for ( var i:int = 0; i < total; i++ ) {
          if ( !_focused[i].hitTestPoint( e.stageX, e.stageY, true ) ) {
            _focused[i].unfocused();
            _focused.splice( i, 1 );
            i--;
            total--;
          }
        }
      }
    }
    
    /**
     * Place focus on a given element
     * @param	element The element to focus on
     */
    public static function focus( element:GUIElement ):void {
      elementClicked( element, null );
    }
    
    /**
     * Register an element with this focus manager, so that when the user clicks on that element, it gains focus.
     * @param	element The element that we want to add to the focus list
     */
    internal static function registerElement( element:GUIElement ):void {
      if ( !_focusEnabled ) {
        return;
      }
      if ( _elements.indexOf( element ) < 0 ) {
        _elements.push( element );
        KuroExpress.addFullListener( element, MouseEvent.CLICK, elementClicked, element );
      }      
    }
    
    /**
     * Remove an element from the focus list
     * @param	element The element that needs removal
     */
    internal static function unregisterElement( element:GUIElement ):void {
      if ( !_focusEnabled ) {
        return;
      }
      var index:int = _elements.indexOf( element );
      if ( index >= 0 ) {
        var focusIndex:int = _focused.indexOf( element );
        if ( focusIndex >= 0 ) {
          _focused.splice( focusIndex, 1 );
        }
        _elements.splice( index, 1 );
        KuroExpress.removeListener( element, MouseEvent.MOUSE_DOWN, elementClicked );
      }
    }
    
    /**
     * Called when the user clicked on an element that is currently in the focus list
     * @param	element The element that was clicked on
     * @param e The calling MouseEvent
     */
    private static function elementClicked( element:GUIElement, e:MouseEvent ):void {
      var total:uint = _focused.length;
      for ( var i:int = 0; i < total; i++ ) {
        if ( !_focused[i].isAncestorOf( element ) ) {
          _focused[i].unfocused();
          _focused.splice( i, 1 );
          i--;
          total--;
        }
      }
      _focused.push( element );
      element.focused();
      if( e ) {
        e.stopImmediatePropagation();
      }
    }
    
  }

}