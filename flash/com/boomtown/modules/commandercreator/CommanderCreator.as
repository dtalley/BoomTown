package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.boomtown.core.HexGridBackground;
  import com.boomtown.gui.StandardButton;
  import com.boomtown.loader.GraphicLoader;
  import com.boomtown.modules.commandercreator.events.CreatorScreenEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.GradientType;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.text.TextField;
  import com.boomtown.modules.core.Module;
  import flash.utils.getQualifiedClassName;
  
  public class CommanderCreator extends Module {
    
    private var _screen:CreatorScreen;
    private var _next:StandardButton;
    private var _prev:StandardButton;
    private var _confirm:StandardButton;
    
    private var _end:Boolean = false;
    
    private var _order:Array = ["ChooseName", "ChooseFaction", "ChooseCommandCenter", "ConfirmCommander"];
    
    public function CommanderCreator():void {
      _id = "CommanderCreator";
    }
    
    override public function open( commander:Commander ):void {
      super.open( commander );
      start();
    }
    
    private function start():void {
      _next = new StandardButton( "Next" );
      _prev = new StandardButton( "Previous" );
      _confirm = new StandardButton( "Confirm" );
      KuroExpress.addListener( _next, MouseEvent.CLICK, nextClicked );
      KuroExpress.addListener( _prev, MouseEvent.CLICK, prevClicked );
      KuroExpress.addListener( _confirm, MouseEvent.CLICK, confirmClicked );
      
      chooseName();
    }
    
    private function chooseName( oride:Boolean = false ):void {
      if ( _commander.name && !oride ) {
        chooseFaction();
      }
      loadScreen( "ChooseName" );
      disablePrevious();
      enableNext();
      enableConfirm();
    }
    
    private function chooseFaction( oride:Boolean = false ):void {
      if ( _commander.faction && !oride ) {
        chooseCommandCenter();
      }
      loadScreen( "ChooseFaction" );
      enablePrevious();
      enableNext();
      enableConfirm();
    }
    
    private function chooseCommandCenter( oride:Boolean = false ):void {
      if ( _commander.commandCenter && !oride ) {
        confirmCommander();
      }
      loadScreen( "ChooseCommandCenter" );
      enablePrevious();
      enableNext();
      enableConfirm();
    }
    
    private function confirmCommander():void {
      loadScreen( "ConfirmCommander" );
      enablePrevious();
      disableNext();
      disableConfirm();
      _end = true;
    }
    
    private function nextClicked():void {
      if ( _screen ) {
        var screen:String = getQualifiedClassName( _screen );
        screen = screen.substr( screen.lastIndexOf("::") + 2 );
        if ( _order.indexOf(screen) == _order.length - 1 ) {
          return;
        }
        if ( !_screen.verify() ) {
          return;
        }
        var target:String = _order[_order.indexOf(screen) + 1];
        switchScreen(target);
      }
    }
    
    private function prevClicked():void {
      if ( _screen ) {
        var screen:String = getQualifiedClassName( _screen );
        screen = screen.substr( screen.lastIndexOf("::") + 2 );
        if ( _order.indexOf(screen) == 0 ) {
          return;
        }
        if ( !_screen.verify() ) {
          return;
        }
        var target:String = _order[_order.indexOf(screen) - 1];
        switchScreen(target);
      }
    }
    
    private function confirmClicked():void {
      
    }
    
    private function switchScreen( id:String ):void {
      switch( id ) {
        case "ChooseName":
          chooseName(true);
          break;
        case "ChooseFaction":
          chooseFaction(true);
          break;
        case "ChooseCommandCenter":
          chooseCommandCenter(true);
          break;
        case "ConfirmCommander":
          confirmCommander();
      }
    }
    
    private function enablePrevious():void {
      if ( !contains( _prev ) ) {
        addChild( _prev );
        _prev.x = 50;
        _prev.y = stage.stageHeight - _prev.height - 10;
      }
      enableButton( _prev );
    }
    
    private function disablePrevious():void {
      disableButton( _prev );
    }
    
    private function enableNext():void {
      if ( !contains( _next ) ) {
        addChild( _next );
        _next.x = stage.stageWidth - _next.width - 50;
        _next.y = stage.stageHeight - _next.height - 10;
      }
      enableButton( _next );
    }
    
    private function disableNext():void {
      disableButton( _next );
    }
    
    private function enableConfirm():void {
      if( _end ) {
        if ( !contains( _confirm ) ) {
          addChild( _confirm );
          _confirm.x = stage.stageWidth - _next.width - 50 - _confirm.width - 20;
          _confirm.y = stage.stageHeight - _confirm.height - 10;
        }
      }
      enableButton( _confirm );
    }
    
    private function disableConfirm():void {
      disableButton( _confirm );
    }
    
    private function enableButton( btn:StandardButton ):void {
      btn.enable();
      btn.alpha = 0;
      TweenLite.to( btn, .3, { alpha:1 } );
    }
    
    private function disableButton( btn:StandardButton ):void {
      btn.disable();
      TweenLite.to( btn, .3, { alpha:0 } );
    }
    
    private function loadScreen( id:String, screen:CreatorScreen = null ):void {
      if ( screen ) {
        KuroExpress.removeListener( screen, Event.CLOSE, loadScreen );
        removeChild( screen );
      }
      if ( _screen ) {
        if ( !_screen.saved ) {
          KuroExpress.addListener( _screen, CreatorScreenEvent.SCREEN_SAVED, loadScreen, id );
          _screen.save();
        } else {
          KuroExpress.removeListener( _screen, CreatorScreenEvent.SCREEN_SAVED, loadScreen );
          var old:CreatorScreen = _screen;
          _screen = null;
          KuroExpress.addListener( old, Event.CLOSE, loadScreen, id, old );
          old.close();
        }
        return;
      }
      var screenClass:Class = KuroExpress.getAsset("com.boomtown.modules.commandercreator." + id);
      _screen = new screenClass(_commander);
      addChild( _screen );
      _screen.open();
    }
    
    override public function close():void {
      KuroExpress.removeListener( _next, MouseEvent.CLICK, nextClicked );
      KuroExpress.removeListener( _prev, MouseEvent.CLICK, prevClicked );
      KuroExpress.removeListener( _confirm, MouseEvent.CLICK, confirmClicked );
      super.close();
    }
    
  }
  
}