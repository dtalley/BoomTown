package com.kuro.kuroexpress {
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ProgressEvent;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
	/**
   * ...
   * @author David Talley
   */
  public class ObjectPool extends EventDispatcher {
    
    private var _object:Class;
    
    public var _count:int;
    public var _used:int;
    
    private var _createTimer:Timer;
    
    public var _available:Array = new Array();
    
    public function ObjectPool( count:uint, object:Class ) {
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
      if ( _available.length < _count ) {
        _available.push( new _object() );
        var event:ProgressEvent = new ProgressEvent( ProgressEvent.PROGRESS, false, false, _available.length, _count );
        dispatchEvent( event );
      } else {
        _createTimer.stop();
        _createTimer.removeEventListener( TimerEvent.TIMER, createObject );
        dispatchEvent( new Event( Event.COMPLETE ) );
      }
    }
    
    public function getObject():Object {
      _used++;
      if ( _available.length == 0 ) {
        _available.push( new _object() );
      }
      return _available.shift();
    }
    
    public function returnObject( obj:Object ):void {
      if ( !( obj is _object ) ) {
        throw new Error( "That is not the correct type of object for this pool." );
      }
      if ( _available.indexOf( obj ) >= 0 ) {
        throw new Error( "That object is already in the pool." );
      }
      _available.unshift( obj );
      _used--;
    }
    
    public function get used():int {
      return _used;
    }
    
  }

}