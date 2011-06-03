package com.kuro.kurogui.core {
  import com.kuro.kurogui.events.GUIElementEvent;
  import com.kuro.kurogui.utils.GUIDrawState;
  import flash.display.DisplayObject;
	import flash.display.Sprite;
  import flash.geom.Point;
	
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
    
    public function GUIElement( lock:GUIElementLock ) {}
    
    public function enableFocus():void {
      if( !_focusEnabled ) {
        GUIFocusManager.registerElement( this );
        _focusEnabled = true;
      }
    }
    
    public function disableFocus():void {
      if( _focusEnabled ) {
        GUIFocusManager.unregisterElement( this );
        _focusEnabled = false;
      }
    }
    
    public function enableTab( position:int = -1 ):void {
      if( !_tabEnabled ) {
        GUITabManager.registerElement( this, position );
        _tabEnabled = true;
      }
    }
    
    public function disableTab():void {
      if( _tabEnabled ) {
        GUITabManager.unregisterElement( this );
        _tabEnabled = false;
      }
    }
    
    public function focused():void {
      _hasFocus = true;      
      draw( GUIDrawState.FOCUSED );      
      dispatchEvent( new GUIElementEvent( GUIElementEvent.GAINED_FOCUS ) );
    }
    
    public function tabbed():void {
      _hasTab = true;
      if ( !_hasFocus ) {
        _hasFocus = true;
        draw( GUIDrawState.FOCUSED );
      }
    }
    
    public function unfocused():void {
      _hasFocus = false;
      _hasTab = false;      
      draw( GUIDrawState.UNFOCUSED );      
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
    
    public function set width( val:Number ):void {
      _width = val;
      draw();
    }
    
    public function set height( val:Number ):void {
      _height = val;
      draw();
    }
    
    public override function get width():Number {
      return _width;
    }
    
    public override function get height():Number {
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
      
    }
    
    public function get parentY():Number {
      
    }
    
    public function get contentX():Number {
      return _contentX;
    }
    
    public function get contentY():Number {
      return _contentY;
    }
    
    protected function draw( state:GUIDrawState = null ):void {}
    
  }

}
class GUIElementLock{function GUIElementLock():void{}};