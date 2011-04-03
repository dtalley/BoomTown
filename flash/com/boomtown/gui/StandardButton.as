package com.boomtown.gui {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.PrecisionTextField;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextField;
	/**
   * ...
   * @author David Talley
   */
  public class StandardButton extends Sprite {
    
    private var _title:PrecisionTextField;
    private var _style:Object = {};
    private var _enabled:Boolean = true;
    
    public function StandardButton( title:String, style:Object = null ) {
      if( style ) {
        _style = style;
      }
      _title = new PrecisionTextField( { font:_style.font ? _style.font : "BorisBlackBloxx", size:_style.size ? _style.size : 14, color:_style.fontColor ? _style.fontColor : 0xFFFFFF } );
      _title.text = title;
      
      addEventListener( Event.ADDED_TO_STAGE, init );
    }
    
    private function init( e:Event ):void {
      removeEventListener( Event.ADDED_TO_STAGE, init );
      draw();
      
      if ( _style.width ) {
        _title.x = width / 2 - _title.width / 2;
      } else {
        _title.x = 5;
      }
      if ( _style.height ) {
        _title.y = height / 2 - _title.height / 2;
      } else {
        _title.y = 5;
      }
      addChild( _title );
      
      mouseChildren = false;
      addEventListener( MouseEvent.MOUSE_OVER, mouseOver );
      addEventListener( MouseEvent.MOUSE_OUT, mouseOut );
      addEventListener( MouseEvent.CLICK, mouseClick );
    }
    
    private function draw( over:Boolean = false ):void {
      graphics.clear();
      graphics.beginFill( over ? 0x000000 : ( _style.color ? _style.color : 0x0088FF ) );
      graphics.drawRoundRect( 0, 0, _style.width ? _style.width : ( _title.width + 10 ), _style.height ? _style.height : ( _title.height + 10 ), 5 );
      graphics.endFill();
    }
    
    private function mouseOver( e:MouseEvent ):void {
      draw(true);
    }
    
    private function mouseOut( e:MouseEvent ):void {
      draw();
    }
    
    private function mouseClick( e:MouseEvent ):void {
      if ( !_enabled ) {
        e.stopPropagation();
      }
    }
    
    public function enable():void {
      _enabled = true;
    }
    
    public function disable():void {
      _enabled = false;
    }
    
  }

}