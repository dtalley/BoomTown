package com.boomtown.render {
	
  public class BasicRenderer extends  {
    
    private var _renderables:Array;
    
    public function BasicRenderer() {
      _renderables = [];
    }
    
    public function add( obj:IRenderable ):Boolean {
      if ( _renderables.indexOf( obj ) < 0 ) {
        _renderables.push( obj );
        return true;
      }
      return false;
    }
    
    public function remove( obj:IRenderable ):Boolean {
      var index:int = _renderables.indexOf( obj );
      if ( index >= 0 ) {
        _renderables.splice( index, 1 );
        return true;
      }
      return false;
    }
    
    public function render( _camera:BasicCamera, _frame:BasicFrame ):void {
      
    }
    
  }

}