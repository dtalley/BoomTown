package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  import com.boomtown.modules.core.Module;
  
  public class CommanderCreator extends Module {
    
    private var _background:Sprite;
    private var _screen:CreatorScreen;
    
    public function CommanderCreator():void {
      _id = "CommanderCreator";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      
      _background = new Sprite();
      
      addChild( _background );
      TweenLite.from( _background, .5, { alpha:0 } );
      
      chooseName();
    }
    
    private function chooseName():void {
      if ( _commander.name ) {
        chooseFaction();
      }
      loadScreen( "ChooseName" );
    }
    
    private function chooseFaction():void {
      if ( _commander.faction ) {
        chooseCommandCenter();
      }
      loadScreen( "ChooseFaction" );
    }
    
    private function chooseCommandCenter():void {
      if ( _commander.commandCenter ) {
        confirmCommander();
      }
      loadScreen( "ChooseCommandCenter" );
    }
    
    private function confirmCommander():void {
      loadScreen( "ConfirmCommander" );
    }
    
    private function loadScreen( id:String, screen:CreatorScreen = null ):void {
      if ( screen ) {
        KuroExpress.removeListener( screen, Event.CLOSE, loadScreen );
      }
      if ( _screen ) {
        KuroExpress.addListener( _screen, Event.CLOSE, loadScreen, id, _screen );
        _screen.close();
        _screen = null;
      }
      var screenClass:Class = KuroExpress.getAsset("com.boomtown.modules.commandercreator." + id);
      _screen = new screenClass(_commander);
      addChild( _screen );
      _screen.open();
    }
    
    override public function close():void {
      super.close();
    }
    
  }
  
}