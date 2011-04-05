package com.boomtown.prompts {
  import com.boomtown.events.PromptEvent;
  import com.boomtown.gui.StandardButton;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.PrecisionTextField;
  import flash.events.MouseEvent;
  import flash.text.TextFormatAlign;
	/**
   * ...
   * @author David Talley
   */
  public class ChoicePrompt extends Prompt {
    
    private var _text:PrecisionTextField;
    private var _accept:StandardButton;
    private var _cancel:StandardButton;
    
    public function ChoicePrompt( text:String, acceptText:String, cancelText:String ) {
      _text = new PrecisionTextField( { font:"BorisBlackBloxx", size:18, color:0xFFFFFF, width:380, wordWrap:true, align:TextFormatAlign.CENTER } );
      _text.text = text;
      addChild( _text );
      
      _accept = new StandardButton( acceptText );
      addChild( _accept );
      
      _cancel = new StandardButton( cancelText );
      addChild( _cancel );
      
      _accept.addEventListener( MouseEvent.CLICK, acceptClicked );
      _cancel.addEventListener( MouseEvent.CLICK, cancelClicked );
      
      draw();
    }
    
    private function acceptClicked( e:MouseEvent ):void {
      _accept.removeEventListener( MouseEvent.CLICK, acceptClicked );
      _cancel.removeEventListener( MouseEvent.CLICK, cancelClicked );
      dispatchEvent( new PromptEvent( PromptEvent.PROMPT_ACCEPTED, this ) );
    }
    
    private function cancelClicked( e:MouseEvent ):void {
      _accept.removeEventListener( MouseEvent.CLICK, acceptClicked );
      _cancel.removeEventListener( MouseEvent.CLICK, cancelClicked );
      dispatchEvent( new PromptEvent( PromptEvent.PROMPT_CANCELED, this ) );
    }
    
    private function draw():void {
      graphics.clear();
      graphics.beginFill( 0x222222 );
      graphics.drawRoundRect( 0, 0, _text.width + 40, _text.height + 10 + _accept.height + 40, 10 );
      graphics.endFill();
      
      _text.x = 20;
      _text.y = 20;
      _accept.x = _text.x + _text.width / 2 - ( _accept.width + 10 + _cancel.width ) / 2;
      _accept.y = _text.y + _text.height + 10;
      _cancel.x = _accept.x + _accept.width + 10;
      _cancel.y = _accept.y;
    }
    
  }

}