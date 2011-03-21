package com.kuro.kuroexpress {
  import com.hightouch.events.BitmapTextFieldEvent;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.text.AntiAliasType;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  import flash.ui.Keyboard;
  import flash.utils.Timer;
  
  /**
   * ...
   * @author ...
   */
  public class BitmapTextField extends Sprite {
    
    private var _hit:Sprite;
    private var _map:Bitmap;
    private var _stage:Bitmap;
    private var _field:TextField;
    private var _mask:Sprite;
    private var _clip:Sprite;
    private var _holder:Sprite;
    private var _cursor:Sprite;
    private var _cursorTimer:Timer;
    private var _input:Boolean = false;
    private var _cursorPosition:uint;
    
    private var _gradientActive:Boolean = false;
    private var _gradientType:String;
    private var _gradientAngle:Number;
    private var _gradientColors:Array;
    private var _gradientAlphas:Array;
    private var _gradientRatios:Array;
    
    private static var selectedInput:BitmapTextField;
    private static var tabReference:Array = [];
    private static var currentTab:uint = 0;
    
    private var _useBackground:Boolean = true;
    
    public function BitmapTextField( properties:Object ):void {
      _holder = new Sprite();
      _clip = new Sprite();
      _mask = new Sprite();
      _field = KuroExpress.createTextField( properties );
      _map = new Bitmap( new BitmapData( 10, 10, true, 0x00000000 ), "auto", true );
      _stage = new Bitmap( new BitmapData( 10, 10, true, 0x00000000 ), "auto", true );
      
      addChild( _map );
      //addChild( _holder );
      _holder.addChild( _clip );
      _holder.addChild( _mask );
      _mask.addChild( _field );
      _clip.mask = _mask;
    }
    
    public function applyFormatting( properties:Object ):void {
      KuroExpress.setTextFormat( _field, properties );
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
      draw();
    }
    
    public function disableMask():void {
      _clip.mask = null;
      _clip.visible = false;
      draw();
    }
    
    private function draw():void {
      _clip.graphics.clear();
      if ( _gradientActive ) {
        //_clip.mask = _mask;
        //_clip.visible = true;
        if( _useBackground ) {
          _clip.graphics.beginFill( uint( _field.defaultTextFormat.color ) );
          _clip.graphics.drawRect( 0, 0, _field.width, _field.height );
          _clip.graphics.endFill();
        }
        KuroExpress.beginGradientFill( _clip, _field.width, _field.height, _gradientType, _gradientAngle, _gradientColors, _gradientAlphas, _gradientRatios );
      } else {
        //_clip.mask = null;
        //_clip.visible = false;
        _clip.graphics.beginFill( uint( _field.defaultTextFormat.color ) );
      }
      _clip.graphics.drawRect( 0, 0, _field.width, _field.height );
      _clip.graphics.endFill();
      _stage.bitmapData = new BitmapData( _field.width, _field.height, true, 0x00000000 );
      _stage.bitmapData.draw( _holder, null, null, null, null, true );
      var rect:Rectangle = _stage.bitmapData.getColorBoundsRect( 0xFFFFFFFF, 0x00000000, false );
      if ( _input && rect.width > _hit.width ) {
        rect.width = _hit.width;
      }
      _map.bitmapData = new BitmapData( rect.width+1, rect.height+1, true, 0x00000000 );
      var matr:Matrix = new Matrix();
      matr.translate( 0 - rect.x, 0 - rect.y );
      _map.bitmapData.draw( _stage, matr, null, null, null, true );
      if ( _input ) {
        if ( _cursorPosition >= _field.text.length ) {
          _cursor.x = _map.width + _cursor.width;
          if ( _field.text.substr( -1 ) == " " ) {
            _cursor.x += _cursor.width * 3;
          }
        } else {
          rect = _field.getCharBoundaries(_cursorPosition);
          _cursor.x = rect.x - _cursor.width;
        }
      }
    }
    
    public function set text( val:String ):void {
      _field.text = val;
      _cursorPosition = val.length;
      draw();
    }
    
    public function get text():String {
      return _field.text;
    }
    
  }
  
}