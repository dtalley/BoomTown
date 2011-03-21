package com.kuro.kuroexpress {
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.geom.Matrix;
  import flash.geom.Rectangle;
  import flash.text.AntiAliasType;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFieldType;
  import flash.text.TextFormat;
  
  /**
   * ...
   * @author ...
   */
  public class BitmapTextInput extends Sprite {
    
    private var _map:Bitmap;
    private var _stage:Bitmap;
    private var _field:TextField;
    private var _mask:Sprite;
    private var _clip:Sprite;
    private var _holder:Sprite;
    private var _cursor:Sprite;
    
    private var _gradientActive:Boolean = false;
    private var _gradientType:String;
    private var _gradientAngle:Number;
    private var _gradientColors:Array;
    private var _gradientAlphas:Array;
    private var _gradientRatios:Array;
    
    public function BitmapTextInput( properties:Object ):void {
      _holder = new Sprite();
      _clip = new Sprite();
      _mask = new Sprite();
      _field = KuroExpress.createTextField( properties );
      KuroExpress.setTextFormat( { type:TextFieldType.INPUT, autoSize:TextFieldAutoSize.NONE } );
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
    
    public function applyGradient( type:String, angle:Number, colors:Array, alphas:Array, ratios:Array ):void {
      _gradientActive = true;
      _gradientType = type;
      _gradientAngle = angle;
      _gradientColors = colors;
      _gradientAlphas = alphas;
      _gradientRatios = ratios;
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
        _clip.graphics.beginFill( uint( _field.defaultTextFormat.color ) );
        _clip.graphics.drawRect( 0, 0, _field.width, _field.height );
        _clip.graphics.endFill();
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
      _map.bitmapData = new BitmapData( rect.width+1, rect.height+1, true, 0x00000000 );
      var matr:Matrix = new Matrix();
      matr.translate( 0 - rect.x, 0 - rect.y );
      _map.bitmapData.draw( _stage, matr, null, null, null, true );
    }
    
    public function set text( val:String ):void {
      _field.text = val;
      draw();
    }
    
    public function get text():String {
      return _field.text;
    }
    
  }
  
}