package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.boomtown.core.HexGridBackground;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.events.OpenModuleEvent;
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
    
    private var _order:Array = ["ChooseFaction", "ChooseCommandCenter", "ChooseName"];
    
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
      _next.alpha = _prev.alpha = _confirm.alpha = 0;
      KuroExpress.addListener( _next, MouseEvent.CLICK, nextClicked );
      KuroExpress.addListener( _prev, MouseEvent.CLICK, prevClicked );
      KuroExpress.addListener( _confirm, MouseEvent.CLICK, confirmClicked );
      
      switchScreen( _order[0], false );
    }
    
    private function chooseName( oride:Boolean = false ):void {
      loadScreen( "ChooseName" );
      toggleButtons( "ChooseName" );
      _end = true;
    }
    
    private function chooseFaction( oride:Boolean = false ):void {
      if ( _commander.faction && !oride ) {
        switchScreen( _order[_order.indexOf("ChooseFaction") + 1] );
      }
      loadScreen( "ChooseFaction" );
      toggleButtons( "ChooseFaction" );
    }
    
    private function chooseCommandCenter( oride:Boolean = false ):void {
      if ( _commander.commandCenter && !oride ) {
        switchScreen( _order[_order.indexOf("ChooseCommandCenter") + 1] );
      }
      loadScreen( "ChooseCommandCenter" );
      toggleButtons( "ChooseCommandCenter" );
    }
    
    private function toggleButtons( id:String ):void {
      if( _order.indexOf(id) == 0 ) {
        disablePrevious();
      } else {
        enablePrevious();
      }
      if( _order.indexOf(id) == _order.length-1 ) {
        disableNext();
      } else {
        enableNext();
      }
      if( _order.indexOf(id) >= _order.length - 2 ) {
        disableConfirm();
      } else {
        enableConfirm();
      }
    }
    
    private function nextClicked():void {
      if ( _screen ) {
        if ( !_screen.verify() ) {
          return;
        }
        var screen:String = getQualifiedClassName( _screen );
        screen = screen.substr( screen.lastIndexOf("::") + 2 );
        if ( _order.indexOf(screen) == _order.length - 1 ) {
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
        var target:String = _order[_order.indexOf(screen) - 1];
        switchScreen(target);
      }
    }
    
    private function confirmClicked():void {
      if ( _screen ) {
        if ( !_screen.verify() ) {
          return;
        }
        switchScreen(_order[_order.length - 1]);
      }
    }
    
    private function switchScreen( id:String, oride:Boolean = true ):void {
      switch( id ) {
        case "ChooseName":
          chooseName(oride);
          break;
        case "ChooseFaction":
          chooseFaction(oride);
          break;
        case "ChooseCommandCenter":
          chooseCommandCenter(oride);
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
    
    private function disableButtons():void {
      _next.disable();
      _prev.disable();
      _confirm.disable();
    }
    
    private function enableButton( btn:StandardButton ):void {
      btn.enable();
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
          KuroExpress.removeListener( _screen, CreatorScreenEvent.SAVE_COMMANDER, saveCommander );
          var old:CreatorScreen = _screen;
          _screen = null;
          KuroExpress.addListener( old, Event.CLOSE, loadScreen, id, old );
          old.close();
        }
        return;
      }
      var screenClass:Class = KuroExpress.getAsset("com.boomtown.modules.commandercreator." + id);
      _screen = new screenClass(_commander);
      KuroExpress.addListener( _screen, CreatorScreenEvent.SAVE_COMMANDER, saveCommander );
      addChild( _screen );
      _screen.open();
    }
    
    private function saveCommander():void {
      KuroExpress.broadcast( "Screen has requested that the commander be saved.", 
        { obj:this, label:"CommanderCreator::saveCommander()" } );
      if ( !_screen.verify() ) {
        return;
      }
      disableButtons();
      if ( !_screen.saved ) {
        KuroExpress.broadcast( "Screen needs to save information first.", 
          { obj:this, label:"CommanderCreator::saveCommander()" } );
        KuroExpress.addListener( _screen, CreatorScreenEvent.SCREEN_SAVED, saveCommander );
        _screen.save();
        return;
      }
      KuroExpress.broadcast( "Screen is saved, so now we can save the commander information.", 
        { obj:this, label:"CommanderCreator::saveCommander()" } );
      KuroExpress.removeListener( _screen, CreatorScreenEvent.SCREEN_SAVED, saveCommander );
      KuroExpress.removeListener( _screen, CreatorScreenEvent.SAVE_COMMANDER, saveCommander );
      
      if ( !_commander.verify() ) {
        return;
      }
      _commander.addEventListener( CommanderEvent.COMMANDER_SAVED, commanderSaved );    
      _commander.save();
    }
    
    private function commanderSaved( e:CommanderEvent ):void {
      KuroExpress.broadcast( "Commander indicated that info is saved.", 
        { obj:this, label:"CommanderCreator::commanderSaved()" } );
      _commander.removeEventListener( CommanderEvent.COMMANDER_SAVED, commanderSaved );      
      _commander.addEventListener( Event.COMPLETE, commanderReady );
      _commander.init(null);
    }
    
    private function commanderReady( e:Event ):void {
      _commander.removeEventListener( Event.COMPLETE, commanderReady );
      dispatchEvent( new OpenModuleEvent( OpenModuleEvent.OPEN_MODULE, "WorldMap" ) );
    }
    
    override public function close():void {
      KuroExpress.removeListener( _next, MouseEvent.CLICK, nextClicked );
      KuroExpress.removeListener( _prev, MouseEvent.CLICK, prevClicked );
      KuroExpress.removeListener( _confirm, MouseEvent.CLICK, confirmClicked );
      super.close();
    }
    
  }
  
}