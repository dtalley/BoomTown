package md.commandercreator {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.text.TextField;
  import md.core.Module;
  
  public class CommanderCreator extends Module {
    
    public function CommanderCreator():void {
      _id = "CommanderCreator";
    }
    
    override public function open():void {
      var text:TextField = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:28, color:0xFFFFFF } );
      text.text = "TESTING MODULES";
      addChild( text );
      text.x = stage.stageWidth / 2 - text.width / 2;
      text.y = stage.stageHeight / 2 - text.height / 2;
    }
    
  }
  
}