package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.events.Event;
  import flash.text.TextField;
  import com.boomtown.modules.core.Module;
  
  public class CommanderCreator extends Module {
        
    private var _screen:CreatorScreen;
    
    public function CommanderCreator():void {
      _id = "CommanderCreator";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      chooseName();
    }
    
    private function chooseName():void {
      if ( _commander.name ) {
        chooseFaction();
      }
      if ( _screen ) {
        _screen.close();
        KuroExpress.addListener( _screen, Event.CLOSE, chooseName );
        _screen = null;
      }
      _screen = new ChooseName( _commander );
      addChild( _screen );
      _screen.open();
    }
    
    private function chooseFaction():void {
      if ( _commander.faction ) {
        chooseCommandCenter();
      }
    }
    
    private function chooseCommandCenter():void {
      if ( _commander.commandCenter ) {
        confirmCommander();
      }
    }
    
    private function confirmCommander():void {
      
    }
    
    override public function close():void {
      super.close();
    }
    
  }
  
}