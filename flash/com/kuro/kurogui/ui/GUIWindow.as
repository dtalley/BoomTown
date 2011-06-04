package com.kuro.kurogui.ui {
	import com.kuro.kurogui.core.GUIElement;
  import com.kuro.kurogui.events.GUIElementEvent;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  
  public class GUIWindow extends GUIElement {
    
    public function GUIWindow() {
      enableFocus();
    }
    
    private var _current:Point;
    private var _offset:Point;
    private var _restriction:Rectangle;
    protected function startDrag( restriction:Rectangle = null ):void {
      _restriction = restriction;
      _offset = new Point( mouseX, mouseY );
      _current = new Point( x, y );
      stage.addEventListener( MouseEvent.MOUSE_MOVE, windowMouseMove );
      stage.addEventListener( MouseEvent.MOUSE_UP, windowMouseUp );
    }
    
    private function windowMouseMove( e:MouseEvent ):void {
      var xd:Number = mouseX - _offset.x;
      var yd:Number = mouseY - _offset.y;
      _current.x += xd;
      _current.y += yd;
      
      if ( _restriction ) {
        if ( _current.x < _restriction.x ) {
          _current.x = _restriction.x;
        } else if ( _current.x + width > _restriction.x + _restriction.width ) {
          _current.x = ( _restriction.x + _restriction.width ) - width;
        }
        if ( _current.y < _restriction.y ) {
          _current.y = _restriction.y;
        } else if ( _current.y + height > _restriction.y + _restriction.height ) {
          _current.y = ( _restriction.y + _restriction.height ) - height;
        }
      }
      
      positionWindow( _current.x, _current.y );
      dispatchEvent( new GUIElementEvent( GUIElementEvent.MOVED ) );
    }
    
    protected function positionWindow( x:Number, y:Number ):void {
      this.x = x;
      this.y = y;
    }
    
    private function windowMouseUp( e:MouseEvent ):void {
      stage.removeEventListener( MouseEvent.MOUSE_MOVE, windowMouseMove );
      stage.removeEventListener( MouseEvent.MOUSE_UP, windowMouseUp );
      dispatchEvent( new GUIElementEvent( GUIElementEvent.DROPPED ) );
    }
    
  }

}