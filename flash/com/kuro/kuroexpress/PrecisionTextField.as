package com.kuro.kuroexpress {
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.FocusEvent;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.TextEvent;
  import flash.events.TimerEvent;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.text.AntiAliasType;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  import flash.text.TextLineMetrics;
  import flash.ui.Keyboard;
  import flash.utils.Timer;
  
  /**
   * ...
   * @author ...
   */
  public class PrecisionTextField extends Sprite {
    
    private var _field:TextField;
    private var _backup:TextField;
    private var _clip:Sprite;
    private var _holder:Sprite;
    private var _mask:Sprite;
    private var _stage:Bitmap;
    private var _rect:Rectangle;
    private var _input:Boolean;
    
    private var _gradientActive:Boolean = false;
    private var _gradientType:String;
    private var _gradientAngle:Number;
    private var _gradientColors:Array;
    private var _gradientAlphas:Array;
    private var _gradientRatios:Array;
    private var _useBackground:Boolean = true;
    
    private var _updateTimer:Timer;
    private var _oldText:String;
    
    public function PrecisionTextField( properties:Object ):void {
      _holder = new Sprite();
      _clip = new Sprite();
      _mask = new Sprite();
      _field = KuroExpress.createTextField( properties );
      _backup = KuroExpress.createTextField( properties );
      _stage = new Bitmap( new BitmapData( 10, 10, true, 0x00000000 ), "auto", true );
      
      addChild( _holder );
      _holder.addChild( _clip );
      _holder.addChild( _mask );
      _mask.addChild( _field );
      _clip.mask = _mask;
      
      _field.addEventListener( Event.CHANGE, fieldChanged );
    }
    
    private function fieldChanged( e:Event ):void {
      draw();
    }
    
    public function applyInput( width:Number ):void {
      KuroExpress.setTextFormat( _field, { type:TextFieldType.INPUT, autoSize:TextFieldAutoSize.NONE, selectable:true } );
      KuroExpress.setTextFormat( _backup, { type:TextFieldType.INPUT, autoSize:TextFieldAutoSize.NONE, selectable:true } );
      _field.width = width;
      _backup.width = width;
      _input = true;
      draw();
      
      _updateTimer = new Timer( 50 );
      _field.addEventListener( FocusEvent.FOCUS_IN, inputFocused );
    }
    
    private function inputFocused( e:Event ):void {
      e.target.addEventListener( FocusEvent.FOCUS_OUT, inputUnfocused );
      _updateTimer.addEventListener( TimerEvent.TIMER, inputChange );
      _updateTimer.start();
    }
    
    private function inputUnfocused( e:Event ):void {
      e.target.removeEventListener( FocusEvent.FOCUS_OUT, inputUnfocused );
      _updateTimer.removeEventListener( TimerEvent.TIMER, inputChange );
      _updateTimer.stop();
      _updateTimer.reset();
    }
    
    private function inputChange( e:Event ):void {
      draw();
    }
    
    public function applyFormatting( properties:Object ):void {
      KuroExpress.setTextFormat( _field, properties );
      KuroExpress.setTextFormat( _backup, properties );
      draw();
    }
    
    public function applyGradient( type:String, angle:Number, colors:Array, alphas:Array, ratios:Array, keepBackground:Boolean = true ):void {
      _gradientActive = true;
      _gradientType = type;
      _gradientAngle = angle;
      _gradientColors = colors;
      _gradientAlphas = alphas;
      _gradientRatios = ratios;
      if ( !keepBackground ) {
        _useBackground = false;
      }
      draw();
    }
    
    public function disableGradient():void {
      _gradientActive = false;
      if ( _backup ) {
        removeChild( _backup );
        _backup = null;
      }
      draw();
    }
    
    public function disableMask():void {
      _clip.mask = null;
      _clip.visible = false;
      draw();
    }
    
    private function draw():void {
      if( _input ) {
        _backup.selectable = false;
        _backup.setSelection( _field.selectionBeginIndex, _field.selectionEndIndex );
        if ( _backup.text.length < _field.text.length ) {
          for ( var i:int = 0; i < _field.text.length - _backup.text.length; i++ ) {
            _backup.appendText("X");
          }
        }
      }
      _stage.bitmapData = new BitmapData( _field.width, _field.height, true, 0x00000000 );
      var selectable:Boolean = _field.selectable;
      _field.selectable = false;
      _stage.bitmapData.draw( _input ? _backup : _field, null, null, null, null, true );
      _field.selectable = selectable;
      _rect = _stage.bitmapData.getColorBoundsRect( 0xFFFFFFFF, 0x00000000, false );
      _clip.graphics.clear();
      if ( _gradientActive ) {
        _clip.mask = _mask;
        _clip.visible = true;
        if( _useBackground ) {
          _clip.graphics.beginFill( uint( _field.defaultTextFormat.color ) );
          _clip.graphics.drawRect( 0, 0, _field.width, _field.height );
          _clip.graphics.endFill();
        }
        KuroExpress.beginGradientFill( _clip, _rect.width, _rect.height, _gradientType, _gradientAngle, _gradientColors, _gradientAlphas, _gradientRatios, _rect.x, _rect.y );
      } else {
        _clip.mask = null;
        _clip.visible = false;
        _clip.graphics.beginFill( uint( _field.defaultTextFormat.color ) );
      }
      _clip.graphics.drawRect( 0, 0, _rect.width, _rect.height );
      _clip.graphics.endFill();
      _holder.x = 0 - _rect.x;
      _holder.y = 0 - _rect.y;
      if ( !_oldText || _oldText != _field.text ) {
        dispatchEvent( new Event( Event.CHANGE ) );
        _oldText = _field.text;
      }
    }
    
    public function set text( val:String ):void {
      _field.text = val;
      draw();
    }
    
    public function get text():String {
      return _field.text;
    }
    
    override public function get width():Number {
      if ( _input ) {
        return _field.width;
      }
      return _rect.width;
    }
    
    override public function get height():Number {
      return _rect.height;
    }
    
  }
  
}