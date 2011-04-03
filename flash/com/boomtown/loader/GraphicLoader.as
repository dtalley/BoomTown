package com.boomtown.loader {
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.greensock.easing.Linear;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.SpreadMethod;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ProgressEvent;
  import flash.filters.GlowFilter;
  import flash.geom.Point;
  
  /**
   * ...
   * @author ...
   */
  public class GraphicLoader extends Sprite {
    
    private var _bg:Sprite;
    private var _bitHolder:Sprite;
    private var _bits:Array = [];
    private var _total:int = 0;
    private var _max:int = 37;
    private var _progress:Boolean = false;
    private var _complete:Boolean = false;
    private var _backwards:Boolean = false;
    private var _target:EventDispatcher;
    private var _speed:Number = .01;
    
    private var _hexWidth:Number;
    private var _hexHeight:Number;
    
    private var _style:Object;
    
    public function GraphicLoader( hexWidth:Number, hexHeight:Number, target:EventDispatcher = null, style:Object = null ):void {
      _hexWidth = hexWidth;
      _hexHeight = hexHeight;
      _target = target;
      _style = style ? style : {};
      KuroExpress.addListener( this, Event.ADDED_TO_STAGE, init );
    }
    
    private function init():void {
      KuroExpress.removeListener( this, Event.ADDED_TO_STAGE, init );
      if ( _target ) {
        _target.addEventListener( ProgressEvent.PROGRESS, targetProgress );
        _target.addEventListener( Event.COMPLETE, targetComplete );
      } else if ( _style.cycle ) {
        _total = _max;
        _speed = .05;
      }
      
      _bg = new Sprite();
      for ( var i:int = 0; i < 37; i++ ) {
        var bit:Sprite = new Sprite();
        bit.graphics.beginFill( _style.bitbg ? _style.bitbg : 0x444444 );
        Hexagon.drawHexagon( bit, _hexWidth-1, _hexHeight-1 );
        bit.graphics.endFill();
        var metrics:Object = Hexagon.getMetrics( _hexWidth, _hexHeight );
        var offset:Point = HexagonLevelGrid.offset( i, metrics.angle1, metrics.angle2, metrics.size1 * 2, metrics.size2 * 2 );
        _bg.addChild(bit);
        bit.x = offset.x;
        bit.y = offset.y;
        bit.filters = [new GlowFilter( _style.bgglow ? _style.bgglow : 0, .8, 5, 5, 2, 1, true )];
      }
      addChild( _bg );
      _bg.x = stage.stageWidth / 2;
      _bg.y = stage.stageHeight / 2;
      _bg.filters = [new GlowFilter( _style.bgglow ? _style.bgglow : 0, .7, 12, 12, 2, 1, true )];
      TweenLite.from( _bg, .3, { alpha:0, onComplete:_style.cycle?showProgress:null } );
      
      _bitHolder = new Sprite();
      addChild( _bitHolder );
      _bitHolder.filters = [new GlowFilter( _style.color ? _style.color : 0x0088FF, .6, 35, 35, 2 )];
      
      TweenLite.to( _bitHolder, .3, { alpha:_style.pulseAlpha?_style.pulseAlpha:.7, onComplete:toggleFillGlow, ease:Linear.easeNone } );
    }
    
    private function toggleFillGlow():void {
      if ( _bitHolder.alpha == 1 ) {
        TweenLite.to( _bitHolder, .3, { alpha:_style.pulseAlpha?_style.pulseAlpha:.7, onComplete:toggleFillGlow, ease:Linear.easeNone } );
      } else {
        TweenLite.to( _bitHolder, .3, { alpha:1, onComplete:toggleFillGlow, ease:Linear.easeNone } );
      }
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
      if ( length == _max && !_style.cycle ) {
        TweenLite.delayedCall( .3, complete );
        return;
      }
      if ( length < _total || _backwards ) {
        if ( _backwards ) {
          if ( length == 0 ) {
            _backwards = false;
            showProgress();
          } else {
            var rbit:Sprite = _bits.shift();
            TweenLite.to( rbit, .3, { alpha:0, onComplete:removeBit, onCompleteParams:[rbit] } );
            TweenLite.delayedCall( _speed, showProgress );
          }
        } else {
          var bit:Sprite = new Sprite();
          bit.graphics.beginFill( _style.borderColor ? _style.borderColor : 0, _style.borderAlpha ? _style.borderAlpha : 0 );
          Hexagon.drawHexagon( bit, _hexWidth, _hexHeight );
          bit.graphics.endFill();
          bit.graphics.beginFill( 0xFFFFFF );
          Hexagon.drawHexagon( bit, _hexWidth-1, _hexHeight-1 );
          bit.graphics.endFill();
          var metrics:Object = Hexagon.getMetrics( _hexWidth, _hexHeight );
          var offset:Point = HexagonLevelGrid.offset( _style.invert ? _max - _bits.length - 1 : _bits.length, metrics.angle1, metrics.angle2, metrics.size1 * 2, metrics.size2 * 2 );
          _bits.push(bit);
          _bitHolder.addChild(bit);
          bit.x = _bg.x + offset.x;
          bit.y = _bg.y + offset.y;
          bit.filters = [new GlowFilter( _style.color ? _style.color : 0x0088FF, .7, 5, 5, 2, 1, true )];
          TweenLite.from( bit, .3, { alpha:0 } );
          TweenLite.delayedCall( _speed, showProgress );
        }
      } else if ( !_style.cycle ) {
        _progress = false;
      } else if ( _style.cycle ) {
        _backwards = true;
        showProgress();
      }
    }
    
    private function removeBit( bit:Sprite ):void {
      _bitHolder.removeChild( bit );
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
      destroy();
    }
    
    public function destroy():void {
      TweenLite.to( this, .5, { alpha:0, onComplete:completeDestruction } );
    }
    
    private function completeDestruction():void {
      if ( parent ) {
        parent.removeChild( this );
      }
      dispatchEvent( new Event( Event.COMPLETE ) );
    }
    
    private function targetComplete( e:Event ):void {
      _complete = true;
      _target.removeEventListener( ProgressEvent.PROGRESS, targetProgress );
      _target.removeEventListener( Event.COMPLETE, targetComplete );
    }
    
  }
  
}