package com.boomtown.core {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.struct.AnderssonTree;
  import com.kuro.kuroexpress.struct.LinkedList;
  import com.kuro.kuroexpress.struct.ListIterator;
  import com.kuro.kuroexpress.struct.OrderedLinkedList;
  import com.kuro.kuroexpress.struct.Queue;
  import flash.display.DisplayObject;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.utils.getTimer;
  
  public class GameDriver {
    
    private var TICKS_PER_SECOND:uint = 30;
    private var TICK_RATE:Number = 1.0 / Number(TICKS_PER_SECOND);
    private var TICK_RATE_MS:Number = TICK_RATE * 1000.0;
    private var MAX_TICKS_PER_FRAME:uint = 5;
    
    private var _running:Boolean = false;
    private var _advancing:Boolean = false;
    private var _listener:EventDispatcher;
    private var _platformTime:uint = 0;    
    private var _virtualTime:Number = 0;
    private var _timeScale:Number = 1;
    
    private var _tickedObjects:OrderedLinkedList;
    private var _animatedObjects:OrderedLinkedList;
    private var _queuedMethods:Queue;
    
    public function GameDriver( lis:EventDispatcher ) {      
      _listener = lis;
      _tickedObjects = new OrderedLinkedList();
      _animatedObjects = new OrderedLinkedList();
      _queuedMethods = new Queue();
    }
    
    public function start():void {
      _listener.addEventListener( Event.ENTER_FRAME, onFrame );
      _running = true;
    }
    
    public function stop():void {
      _listener.removeEventListener( Event.ENTER_FRAME, onFrame );
      _running = false;
    }
    
    public function get running():Boolean {
      return _running;
    }
    
    public function addTickedObject( obj:Object, priority:Number ):void {
      addObject( obj, priority, _tickedObjects );
    }
    public function removeTickedObject( obj:Object ):void {
      removeObject( obj, _tickedObjects );
    }
    
    public function addAnimatedObject( obj:Object, priority:Number ):void {
      addObject( obj, priority, _animatedObjects );
    }
    public function removeAnimatedObject( obj:Object ):void {
      removeObject( obj, _animatedObjects );
    }
    
    private function addObject( obj:Object, priority:uint, list:OrderedLinkedList ):void {
      if ( _advancing ) {
        delayedCall( this, addObject, [obj, priority, list] );
        return;
      }
      var obj:DrivenObject = new DrivenObject( obj, priority );
      list.add( obj );
      if ( !_running ) {
        start();
      }
    }
    
    public function delayedCall( obj:Object, method:Function, args:Array ):void {
      _queuedMethods.add( new QueuedMethod( obj, method, args ) );
    }
    
    private function removeObject( obj:Object, list:LinkedList ):void {
      var iterator:ListIterator = list.createIterator();
      while ( var obj:DrivenObject = ( iterator.getNext() as DrivenObject ) ) {
        if ( obj.listener == obj ) {
          list.remove( obj );
          return;
        }
      }
    }
    
    private var currentTime:int;
    private var lastTime:int = -1;
    
    private function onFrame( e:Event ):void {
      _platformTime = currentTime = getTimer();
      if ( lastTime < 0 ) {
        lastTime = currentTime;
      }
      advance( Number( currentTime - lastTime ) * _timeScale );
    }
    
    private var elapsed:Number = 0;
    private function advance( delta:Number, safety:Boolean = true ):void {
      var tickCount:uint = 0;
      while ( elapsed > TICK_RATE_MS && tickCount < MAX_TICKS_PER_FRAME ) {
        processQueues();
        
        _advancing = true;
        var iterator:ListIterator = _tickedObjects.createIterator();
        while ( var obj:DrivenObject = ( iterator.getNext() as DrivenObject ) ) {
          (obj.listener as ITickedObject).onTick(TICK_RATE);
        }
        _advancing = false;
        
        _virtualTime += TICK_RATE_MS;
        elapsed -= TICK_RATE_MS;
        tickCount++;
      }
      if ( tickCount >= MAX_TICKS_PER_FRAME ) {
        KuroExpress.broadcast( "Too many ticks to process in a timely manner.  Dropping " + elapsed.toFixed + "ms.", {
          obj: this,
          label: "TimeManager::advance()",
          person: "David Talley",
          color: 0xFF0000
        });
      }
      if ( elapsed < 0 ) {
        elapsed = 0;
      } else if ( elapsed > 300 ) {
        elapsed = 300;
      }
      
      _advancing = true;
      var iterator:ListIterator = _tickedObjects.createIterator();
      while ( var obj:DrivenObject = ( iterator.getNext() as DrivenObject ) ) {
        (obj.listener as IAnimatedObject).onFrame(elapsed/TICK_RATE_MS);
      }
      _advancing = false;
      
      if ( _tickedObjects.size == 0 && _animatedObjects.size == 0 && _queuedMethods.size == 0 ) {
        stop();
      }
    }
    
    private function processQueues():void {
      var queue:Queue = _queuedMethods;
      if ( queue.size > 0 ) {
        _queuedMethods = new Queue();
        while ( var method:QueuedMethod = (queue.shift() as QueuedMethod) ) {
          method.act();
        }
        queue.clear();
      }
    }
    
    public function get scale():Number {
      return _timeScale;
    }
    public function set scale( val:Number ):void {
      _timeScale = val;
    }
    
  }

}