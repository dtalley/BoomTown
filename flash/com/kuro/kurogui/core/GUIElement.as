package com.kuro.kurogui.core {
  import com.kuro.kurogui.events.GUIElementEvent;
  import com.kuro.kurogui.util.GUIDrawState;
  import flash.display.DisplayObject;
	import flash.display.Sprite;
  import flash.geom.Point;
  import flash.geom.Rectangle;
	
  public class GUIElement extends Sprite {
    
    private var _parent:GUIElement;
    private var _children:Array = [];
    
    private var _width:Number = 0;
    private var _height:Number = 0;
    
    private var _focusEnabled:Boolean = false;
    private var _tabEnabled:Boolean = false;
    
    private var _hasFocus:Boolean = false;
    private var _hasTab:Boolean = false;
    
    protected var _contentX:Number = 0;
    protected var _contentY:Number = 0;
    protected var _contentWidth:Number = 0;
    protected var _contentHeight:Number = 0;
    
    private var _enabled:Boolean = true;
    
    private var _drawState:GUIDrawState;
    
    public function GUIElement( lock:GUIElementLock ) {}
    
    public function disable():void {
      _enabled = false;
      _drawState = GUIDrawState.DISABLED;
      draw();
    }
    
    public function enable():void {
      _enabled = true;
      if ( _hasFocus ) {
        _drawState = GUIDrawState.FOCUSED;
      } else {
        _drawState = GUIDrawState.UNFOCUSED;
      }
      draw();
    }
    
    protected function enableFocus():void {
      if( !_focusEnabled ) {
        GUIFocusManager.registerElement( this );
        _focusEnabled = true;
      }
    }
    
    protected function disableFocus():void {
      if( _focusEnabled ) {
        GUIFocusManager.unregisterElement( this );
        _focusEnabled = false;
      }
    }
    
    protected function enableTab( position:int = -1 ):void {
      if( !_tabEnabled ) {
        GUITabManager.registerElement( this, position );
        _tabEnabled = true;
      }
    }
    
    protected function disableTab():void {
      if( _tabEnabled ) {
        GUITabManager.unregisterElement( this );
        _tabEnabled = false;
      }
    }
    
    public function focused():void {
      _hasFocus = true;    
      _drawState = GUIDrawState.FOCUSED;
      draw();      
      dispatchEvent( new GUIElementEvent( GUIElementEvent.GAINED_FOCUS ) );
    }
    
    public function tabbed():void {
      _hasTab = true;
      if ( !_hasFocus ) {
        _drawState = GUIDrawState.FOCUSED;
        _hasFocus = true;
        draw();
      }
    }
    
    public function unfocused():void {
      _hasFocus = false;
      _hasTab = false;      
      _drawState = GUIDrawState.UNFOCUSED;
      draw();      
      dispatchEvent( new GUIElementEvent( GUIElementEvent.LOST_FOCUS ) );
    }
    
    public function activated():void {
      draw( GUIDrawState.ACTIVATED );
    }
    
    public function isAncestorOf( element:GUIElement ):Boolean {
      var total:uint = _children.length;
      for ( var i:int = 0; i < total; i++ ) {
        if ( _children[i] == element ) {
          return true;
        } else if ( _children[i].isAncestorOf( element ) ) {
          return true;
        }
      }
      return false;
    }
    
    override public function addChild( child:DisplayObject ):DisplayObject {
      super.addChild( child );
      if ( child is GUIElement ) {
        var element:GUIElement = GUIElement( child );
        var index:int = _children.indexOf( element );
        if ( index >= 0 ) {
          _children.splice( index, 1 );
        }
        _children.push( element );
        element.setParent( this );
      }
      return child;
    }
    
    override public function removeChild( child:DisplayObject ):DisplayObject {
      if( super.contains( child ) ) {
        super.removeChild( child );
        if ( child is GUIElement ) {
          var element:GUIElement = GUIElement( child );
          releaseChild( element );
          element.removeParent( this );
        }
      }
      return child;
    }
    
    public function releaseChild( child:GUIElement ):GUIElement {
      var index:int = _children.indexOf( element );
      if ( index >= 0 ) {
        _children.splice( index, 1 );
      }
      return child;
    }
    
    public function setParent( parent:GUIElement ):void {
      if ( _parent ) {
        _parent.releaseChild( this );
      }
      if ( parent == this.parent ) {
        _parent = parent;
      }
    }
    
    public function removeParent( parent:GUIElement ):void {
      if ( _parent == parent ) {
        _parent = null;
      }
    }
    
    public function clean():void {
      var total:uint = _children.length;
      for ( var i:int = 0; i < total; i++ ) {
        _children[i].clean();
      }
      disableFocus();
      disableTab();
    }
    
    public function position( x:Number, y:Number ):void {
      if ( _parent ) {
        this.x = _parent.contentX + x;
        this.y = _parent.contentY + y;
      }
    }
    
    override public function set width( val:Number ):void {
      _width = val;
      draw();
    }
    
    override public function set height( val:Number ):void {
      _height = val;
      draw();
    }
    
    override public function get width():Number {
      return _width;
    }
    
    override public function get height():Number {
      return _height;
    }
    
    public function get stageX():Number {
      if( stage ) {
        return stage.globalToLocal(localToGlobal(new Point(0, 0)).x;
      }
      return 0;
    }
    
    public function get stageY():Number {
      if( stage ) {
        return stage.globalToLocal(localToGlobal(new Point(0, 0)).y;
      }
      return 0;
    }
    
    public function get parentX():Number {
      return x - _parent.content.x;
    }
    
    public function get parentY():Number {
      return y - _parent.content.y;
    }
    
    public function get content():Rectangle {
      return new Rectangle( _contentX, _contentY, _contentWidth, _contentHeight );
    }
    
    protected function draw():void {}
    
  }

}
class GUIElementLock{function GUIElementLock():void{}};