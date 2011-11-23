package com.boomtown.render {
	
  public class BasicRenderer {
    
    private var _renderables:Array;
    private var _total:uint = 0;
    private var i:uint;
    
    private var _rendering:Boolean = false;
    
    public function BasicRenderer() {
      _renderables = [];
    }
    
    public function add( obj:IRenderable ):Boolean {
      if ( _renderables.indexOf( obj ) < 0 ) {
        _renderables.push( obj );
        _total++;
        return true;
      }
      return false;
    }
    
    public function remove( obj:IRenderable ):Boolean {
      var index:int = _renderables.indexOf( obj );
      if ( index >= 0 ) {
        _renderables.splice( index, 1 );
        _total--;
        return true;
      }
      return false;
    }
    
    public function render( frame:BasicFrame, camera:BasicCamera ):void {
      if ( !_rendering ) {
        return;
      }
      for ( i = 0; i < _total; i++ ) {
        IRenderable(_renderables[i]).render( frame, camera );
      }
    }
    
    public function start():void {
      _rendering = true;
    }
    
    public function stop():void {
      _rendering = false;
    }
    
  }

}