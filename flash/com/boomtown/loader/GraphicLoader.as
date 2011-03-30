package com.boomtown.loader {
  import com.boomtown.utils.HexagonLevelGrid;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ProgressEvent;
  import flash.geom.Point;
  
  /**
   * ...
   * @author ...
   */
  public class GraphicLoader extends Sprite {
    
    private var _bg:Bitmap;
    private var _bitHolder:Sprite;
    private var _bits:Array = [];
    private var _total:int = 0;
    private var _max:int = 37;
    private var _progress:Boolean = false;
    private var _complete:Boolean = false;
    private var _cycle:Boolean = false;
    private var _invert:Boolean = false;
    private var _target:EventDispatcher;
    
    private var _speed:Number = .3;
    
    public function GraphicLoader( target:EventDispatcher = null, cycle:Boolean = false, invert:Boolean = false ):void {
      KuroExpress.addListener( this, Event.ADDED_TO_STAGE, init, target, cycle, invert );
    }
    
    private function init( target:EventDispatcher, cycle:Boolean, invert:Boolean ):void {
      _cycle = cycle;
      _invert = invert;
      KuroExpress.removeListener( this, Event.ADDED_TO_STAGE, init );
      if ( target ) {
        _target = target;
        _target.addEventListener( ProgressEvent.PROGRESS, targetProgress );
        _target.addEventListener( Event.COMPLETE, targetComplete );
      } else if ( _cycle ) {
        _total = _max;
        _speed = .05;
        TweenLite.delayedCall( _speed, showProgress );
      }
      
      _bg = KuroExpress.createBitmap("LoaderBackground");
      addChild( _bg );
      _bg.x = Math.ceil( stage.stageWidth / 2 - _bg.width / 2 );
      _bg.y = Math.ceil( stage.stageHeight / 2 - _bg.height / 2 );
      
      _bitHolder = new Sprite();
      addChild( _bitHolder );
    }
    
    private function targetProgress( e:ProgressEvent ):void {
      var percent:Number = e.bytesLoaded / e.bytesTotal;
      _total = Math.floor( _max * percent );
      if ( !_progress ) {
        _progress = true;
        TweenLite.delayedCall( _speed, showProgress );
      }
    }
    
    private function showProgress():void {
      var length:uint = _bits.length;
      if ( length == _max ) {
        if ( _cycle ) {
          TweenLite.delayedCall( .3, cycle );
          return;
        } else {
          TweenLite.delayedCall( .3, complete );
          return;
        }
      }
      if ( _bits.length < _total ) {
        var bit:Bitmap = KuroExpress.createBitmap("LoaderBit");
        var offset:Point = HexagonLevelGrid.calculateOffset( _invert ? _max - _bits.length - 1 : _bits.length, 90, 26.56, 8, 9 );
        _bits.push(bit);
        _bitHolder.addChild(bit);
        bit.x = Math.ceil( _bg.x + ( _bg.width / 2 ) ) + offset.x - Math.ceil( bit.width/2 );
        bit.y = Math.ceil( _bg.y + ( _bg.height / 2 ) ) + offset.y - Math.ceil( bit.height/2 );
        TweenLite.from( bit, .3, { alpha:0 } );
        TweenLite.delayedCall( _speed, showProgress );
      } else {
        _progress = false;
      }
    }
    
    private function cycle():void {
      var length:uint = _bits.length;
      for ( var i:int = 0; i < length; i++ ) {
        _bitHolder.removeChildAt(0);
      }
      _bits = [];
      TweenLite.delayedCall( _speed, showProgress );
    }
    
    private function complete():void {
      dispatchEvent( new Event( Event.COMPLETE ) );
      destroy();
    }
    
    private function destroy():void {
      
    }
    
    private function targetComplete( e:Event ):void {
      _complete = true;
      _target.removeEventListener( ProgressEvent.PROGRESS, targetProgress );
      _target.removeEventListener( Event.COMPLETE, targetComplete );
    }
    
  }
  
}