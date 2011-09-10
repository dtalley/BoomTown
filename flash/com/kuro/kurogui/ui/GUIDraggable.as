package com.kuro.kurogui.ui {
	import com.kuro.kurogui.core.GUIElement;
  import com.kuro.kurogui.ui.events.GUIDraggableEvent;
  import flash.display.DisplayObject;
  import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.geom.Point;
  import flash.geom.Rectangle;
	
  public class GUIDraggable extends GUIElement {
    
    private var _width:Number, _height:Number;
    private var _prev:Point, _prevMouse:Point, _position:Point;
    private var _content:Sprite, _hit:Sprite;
    private var _restrict:Rectangle;
    
    public function GUIDraggable( width:Number, height:Number, restrict:Rectangle = null ) {
      _width = width;
      _height = height;
      _restrict = restrict;
      _prev = new Point( x, y );
      init();
    }
    
    private function init():void {
      _content = new Sprite();
      addChildAt( _content, 0 );
      _hit = createHit();
      addChildAt( _hit, 1 );
      
      _hit.addEventListener( MouseEvent.MOUSE_DOWN, hitDown );
    }
    
    private function hitDown( e:MouseEvent ):void {
      stage.addEventListener( MouseEvent.MOUSE_UP, hitUp );
      stage.addEventListener( MouseEvent.MOUSE_MOVE, hitMove );
      _prevMouse = new Point( _hit.mouseX, _hit.mouseY );
      _position = new Point( x, y );
    }
    
    private function hitUp( e:MouseEvent ):void {
      stage.removeEventListener( MouseEvent.MOUSE_UP, hitUp );
      stage.removeEventListener( MouseEvent.MOUSE_MOVE, hitMove );
      dispatchEvent( new GUIDraggableEvent( GUIDraggableEvent.DROPPED ) );
    }
    
    private function hitMove( e:MouseEvent ):void {
      var delta:Point = new Point( ( _hit.mouseX - _prevMouse.x ) + ( ex - _position.x ), ( _hit.mouseY - _prevMouse.y ) + ( ey - _position.y ) );
      var target:Point = new Point( _position.x + delta.x, _position.y + delta.y );
      if ( _restrict ) {
        if ( target.x < _restrict.x ) {
          target.x = _restrict.x;
        } else if ( target.x + _content.width > _restrict.x + _restrict.width ) {
          target.x = _restrict.x + _restrict.width - _content.width;
        }
        if ( target.y < _restrict.y ) {
          target.y = _restrict.y;
        } else if ( target.y + _content.height > _restrict.y + _restrict.height ) {
          target.y = _restrict.y + _restrict.height - _content.height;
        }
      }
      move( target.x, target.y );
      dispatchEvent( new GUIDraggableEvent( GUIDraggableEvent.DRAGGED ) );
    }
    
    protected function move( tx:Number, ty:Number ):void {
      x = tx;
      y = ty;
    }
    
    protected function createHit():Sprite {
      var hit:Sprite = new Sprite();
      hit.graphics.beginFill( 0, 0 );
      hit.graphics.drawRect( 0, 0, _width, _height );
      hit.graphics.endFill();
      hit.buttonMode = true;
      hit.mouseChildren = false;
      return hit;
    }
    
    override public function addChild( child:DisplayObject ):DisplayObject {
      return _content.addChild( child );
    }
    
    override public function removeChild( child:DisplayObject ):DisplayObject {
      if ( _content.contains( child ) ) {
        _content.removeChild( child );
      }
      return child;
    }
    
    override public function set x( value:Number ):void {
      _prev.x = super.x;
      super.x = value;
    }
    
    override public function set y( value:Number ):void {
      _prev.y = super.y;
      super.y = value;
    }
    
    public function get px():Number {
      return _prev.x;
    }
    
    public function get py():Number {
      return _prev.y;
    }
    
    protected function get ex():Number {
      return x;
    }
    
    protected function get ey():Number {
      return y;
    }
    
  }

}