package com.kuro.kuroexpress {
  import com.kuro.kuroexpress.util.IQueueLoadable;
  import flash.events.ErrorEvent;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ProgressEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
	/**
   * ...
   * @author David Talley
   */
  public class LoadQueue extends EventDispatcher {
    
    private var _max:uint;
    
    public var _queue:Array = [];
    public var _loading:Array = [];
    
    public function LoadQueue( max:uint ) {
      _max = max;
    }
    
    public function get max():uint {
      return _max;
    }
    
    public function set max( val:uint ):void {
      _max = val;
    }
    
    public function add( obj:IQueueLoadable ):void {
      if( !obj.loaded && _queue.indexOf( obj ) < 0 && _loading.indexOf( obj ) < 0 ) {
        _queue.push( obj );
        if ( _loading.length < _max ) {
          load();
        }
      }
    }
    
    public function load():void {
      while ( _loading.length < _max && _queue.length > 0 ) {
        var obj:IQueueLoadable = _queue.shift();
        obj.load();
        KuroExpress.addListener( obj, Event.COMPLETE, loaded, obj );
        KuroExpress.addFullListener( obj, ErrorEvent.ERROR, error, obj );
        _loading.push( obj );
      }
    }
    
    private function error( obj:IQueueLoadable, e:ErrorEvent ):void {
      KuroExpress.removeListener( obj, Event.COMPLETE, loaded );
      KuroExpress.removeListener( obj, ErrorEvent.ERROR, error );      
      KuroExpress.broadcast( "An object failed to load:\n" + e.text,
        { obj:this, label:"LoadQueue::error()" } );
    }
    
    private function loaded( obj:IQueueLoadable ):void {
      KuroExpress.removeListener( obj, Event.COMPLETE, loaded );
      KuroExpress.removeListener( obj, ErrorEvent.ERROR, error );
      var index:int = _loading.indexOf( obj );
      if ( index >= 0 ) {
        _loading.splice( index, 1 );
      }
      if ( _loading.length < _max ) {
        load();
      }
    }
    
    public function remove( obj:IQueueLoadable ):void {
      var index:int = _queue.indexOf( obj );
      if ( index >= 0 ) {
        _queue.splice( index, 1 );
        return;
      }
      index = _loading.indexOf( obj );
      if ( index >= 0 ) {
        _loading.splice( index, 1 );
        KuroExpress.removeListener( obj, Event.COMPLETE, loaded );
        KuroExpress.removeListener( obj, ErrorEvent.ERROR, error );
        obj.cancel();
      }
    }
    
    public function flush():void {
      _queue = [];
      var total:uint = _loading.length;
      for ( var i:int = 0; i < total; i++ ) {
        _loading[i].cancel();
        KuroExpress.removeListener( _loading[i], Event.COMPLETE, loaded );
        KuroExpress.removeListener( _loading[i], ErrorEvent.ERROR, error );
      }
      _loading = null;
    }
    
  }

}