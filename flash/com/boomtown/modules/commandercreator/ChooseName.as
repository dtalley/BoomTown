package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.kuro.kuroexpress.PrecisionTextField;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.GradientType;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  
  public class ChooseName extends CreatorScreen {
    
    public function ChooseName( commander:Commander ):void {      
      super( commander );
    }
    
    private var bgName:Sprite;
    private var ipName:PrecisionTextField;
    private var lbName:PrecisionTextField;
    
    override public function open():void {
      bgName = new Sprite();
      addChild( bgName );
      
      ipName = new PrecisionTextField( { font:"BorisBlackBloxx", size:30, color:0xFFFFFF } );
      ipName.applyInput( 200 );
      //ipName.applyGradient( GradientType.LINEAR, Math.PI / 2, [0xFFFFFF, 0x444444], [1, 1], [0x00, 0xFF], false );
      ipName.text = "TESTING";
      addChild( ipName );
      ipName.x = stage.stageWidth / 2 - ipName.width / 2;
      ipName.y = stage.stageHeight / 2 - ipName.height / 2;
      bgName.x = ipName.x;
      bgName.y = ipName.y;
    }
    
    override public function close():void {
      super.close();
    }
    
  }
  
}