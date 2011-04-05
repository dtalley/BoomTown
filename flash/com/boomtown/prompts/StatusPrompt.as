package com.boomtown.prompts {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.PrecisionTextField;
	/**
   * ...
   * @author David Talley
   */
  public class StatusPrompt extends Prompt {
    
    private var _status:PrecisionTextField;
    
    public function StatusPrompt() {
      _status = new PrecisionTextField( { font:"BorisBlackBloxx", size:24, color:0xFFFFFF } );
      addChild( _status );
    }
    
    public function setStatus( text:String ):void {
      _status.text = text;
      draw();
    }
    
    private function draw():void {
      graphics.clear();
      graphics.beginFill( 0x000000 );
      graphics.drawRoundRect( 0, 0, _status.width + 20, _status.height + 20, 10 );
      graphics.endFill();
      
      _status.x = 10;
      _status.y = 10;
    }
    
  }

}