package com.boomtown.prompts {
  import com.boomtown.events.PromptEvent;
  import com.boomtown.gui.StandardButton;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.PrecisionTextField;
  import flash.events.MouseEvent;
	/**
   * ...
   * @author David Talley
   */
  public class SimplePrompt extends Prompt {
    
    private var _text:PrecisionTextField;
    private var _button:StandardButton;
    
    public function SimplePrompt( text:String, buttonText:String ) {
      _text = new PrecisionTextField( { font:"BorisBlackBloxx", size:18, color:0xFFFFFF } );
      addChild( _text );
      _text.text = text;
      
      _button = new StandardButton( buttonText );
      addChild( _button );
      
      _button.addEventListener( MouseEvent.CLICK, buttonClicked );
      
      draw();
    }
    
    private function buttonClicked( e:MouseEvent ):void {
      _button.removeEventListener( MouseEvent.CLICK, buttonClicked );
      dispatchEvent( new PromptEvent( PromptEvent.PROMPT_ACCEPTED, this ) );
    }
    
    private function draw():void {
      graphics.clear();
      graphics.beginFill( 0x222222 );
      graphics.drawRoundRect( 0, 0, _text.width + 20, _text.height + 10 + _button.height + 20, 10 );
      graphics.endFill();
      
      _text.x = 10;
      _text.y = 10;
      _button.x = _text.x + _text.width / 2 - _button.width / 2;
      _button.y = _text.y + _text.height + 10;
    }
    
  }

}