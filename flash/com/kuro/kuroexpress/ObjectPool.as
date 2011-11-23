package com.kuro.kuroexpress {
  import com.kuro.kuroexpress.struct.Queue;
  import com.kuro.kuroexpress.util.IObjectNode;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ProgressEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
	
  public class ObjectPool extends EventDispatcher {
    
    private var _object:Class;
    
    public var _count:int;
    public var _used:int;
    
    private var _createTimer:Timer;
    
    private var _queue:Queue;
    
    public function ObjectPool( count:uint, object:Class ) {
      _queue = new Queue();
      
      _object = object;
      _count = count;
      _used = 0;
      
      _createTimer = new Timer( 1 );
      _createTimer.addEventListener( TimerEvent.TIMER, createObject );
      _createTimer.start();
    }
    
    /**
     * Called on each _createTimer interval, creates a new object and adds it to the pool
     * @param	e
     */
    private function createObject( e:TimerEvent ):void {
      if ( _queue.size < _count ) {
        var node:IObjectNode = IObjectNode( new _object() );
        _queue.add( node );
        if( _createTimer.running ) {
          var event:ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS, false, false, _queue.size, _count );
          dispatchEvent( event );
        }
      } else {
        if( _createTimer.running ) {
          _createTimer.stop();
          _createTimer.removeEventListener( TimerEvent.TIMER, createObject );
          dispatchEvent( new Event( Event.COMPLETE ) );
        }
      }
    }
    
    public function getObject():IObjectNode {
      var node:IObjectNode = _queue.shift();
      if ( !node ) {
        _count++;
        createObject( null );
        node = _queue.shift();
      }
      _used++;
      return node;
    }
    
    public function returnObject( obj:IObjectNode ):void {
      _queue.add( obj );
      _used--;
    }
    
    public function get used():int {
      return _used;
    }
    
  }

}