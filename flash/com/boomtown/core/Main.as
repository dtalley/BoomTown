﻿package com.boomtown.core {
  import com.boomtown.events.OpenModuleEvent;
  import com.boomtown.events.PromptEvent;
  import com.boomtown.loader.GraphicLoader;
  import com.boomtown.prompts.PromptManager;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.external.ExternalInterface;
  import flash.text.TextField;
  import com.boomtown.modules.core.Module;
  import nl.demonsters.debugger.MonsterDebugger;
  
  public class Main extends Sprite {
    
    private var _background:HexGridBackground;
    private var _commander:Commander;
    
    private var _loader:GraphicLoader;
    
    public function Main():void {      
      addEventListener( Event.ADDED_TO_STAGE, init );
    }
    
    private function init( e:Event ):void {
      removeEventListener( Event.ADDED_TO_STAGE, init );
      
      _background = new HexGridBackground( 0x222222, 12, 8 );
      addChild( _background );
      TweenLite.from( _background, .5, { alpha:0 } );
      
      var style:String = loaderInfo.parameters && loaderInfo.parameters.style_dir ? loaderInfo.parameters.style_dir + "/flash/" : "";
      if ( style ) {
        KuroExpress.setFullURL( style );
      }
      XMLManager.loadFile( style + "settings.xml", "settings", settingsLoaded );
    }
    
    private function settingsLoaded():void {
      if ( int( XMLManager.getFile("settings").debug.toString() ) == 1 ) {
        var debugger:MonsterDebugger = new MonsterDebugger(this);
        MonsterDebugger.enabled = true;
      }
      ActionRequest.saveAddress( XMLManager.getFile("settings").magasi_url.toString() );
      loadFonts();
    }
    
    private function loadFonts():void {      
      var loaderFonts:XMLList = XMLManager.getFile("settings").loader_fonts;
      var total:int = loaderFonts.font.length();
      if ( total == 0 ) {
        loaderFontsLoaded(null);
      }
      var fonts:Array = [];
      for ( var i:int = 0; i < total; i++ ) {
        fonts.push( loaderFonts.font[i].toString() );
      }
      var fontLoader:Sprite = KuroExpress.loadFonts(fonts);
      _loader = new GraphicLoader( 12, 8, null, { cycle:true, invert:true, color:0x98bfff } );
      addChild( _loader );
      KuroExpress.addListener( fontLoader, Event.COMPLETE, loaderFontsLoaded, fontLoader );
    }
    
    private function loaderFontsLoaded( loader:Sprite ):void {
      KuroExpress.removeListener( loader, Event.COMPLETE, loaderFontsLoaded );
      
      var allFonts:XMLList = XMLManager.getFile("settings").all_fonts;
      var total:int = allFonts.font.length();
      if ( total == 0 ) {
        allFontsLoaded(null);
      }
      var fonts:Array = [];
      for ( var i:int = 0; i < total; i++ ) {
        fonts.push( allFonts.font[i].toString() );
      }
      var fontLoader:Sprite = KuroExpress.loadFonts(fonts);
      fontLoader.addEventListener( Event.COMPLETE, allFontsLoaded );
    }
    
    private function allFontsLoaded( e:Event ):void {
      if( e ) {
        e.target.removeEventListener( Event.COMPLETE, allFontsLoaded );
      }
      
      _loader.addEventListener( Event.COMPLETE, loaderDestroyed );
      _loader.destroy();
    }
    
    private function loaderDestroyed( e:Event ):void {
      _loader.removeEventListener( Event.COMPLETE, loaderDestroyed );      
      loadCommander();
    }
    
    private function loadCommander():void {
      _commander = new Commander( loaderInfo.parameters.token );
      _commander.addEventListener( Event.COMPLETE, commanderReady );
      if ( loaderInfo.parameters.user_id ) {
        _commander.init( loaderInfo.parameters.user_id );
      } else {
        _commander.init( XMLManager.getFile( "settings" ).default_user.toString() );
      }
    }
    
    private function commanderReady( e:Event ):void {
      begin();
    }
    
    private function begin():void {
      PromptManager.dispatcher.addEventListener( PromptEvent.PROMPT_ISSUED, promptIssued );
      PromptManager.dispatcher.addEventListener( PromptEvent.CLOSE_PROMPT, closePrompt );
      if ( _commander.complete ) {
        loadModule( "WorldMap" );
      } else {
        loadModule( "CommanderCreator" );
      }
    }
    
    private var _prompts:uint = 0;
    private var _promptBackground:HexGridBackground;
    
    private function promptIssued( e:PromptEvent ):void {
      if ( !_promptBackground ) {
        _promptBackground = new HexGridBackground( 0x111111, 12, 8 );
        _promptBackground.alpha = .9;
        addChild( _promptBackground );
      }
      addChild( e.prompt );
      e.prompt.x = stage.stageWidth / 2 - e.prompt.width / 2;
      e.prompt.y = stage.stageHeight / 2 - e.prompt.height / 2;
      _prompts++;
    }
    
    private function closePrompt( e:PromptEvent ):void {
      if ( contains( e.prompt ) ) {
        removeChild( e.prompt );
        _prompts--;
        if ( _prompts == 0 && contains( _promptBackground ) ) {
          removeChild( _promptBackground );
        }
      }
    }
    
    private function loadModule( id:String ):void {
      var moduleLoader:Sprite = KuroExpress.loadAssetsFile( "modules/" + id + ".swf" );
      if( moduleLoader ) {
        KuroExpress.addListener( moduleLoader, Event.COMPLETE, moduleLoaded, moduleLoader, id );
      } else {
        openModule(id);
      }
    }
    
    private function moduleLoaded( loader:Sprite, id:String ):void {
      KuroExpress.removeListener( loader, Event.COMPLETE, moduleLoaded );
      openModule( id );
    }
    
    private var currentModule:Module;
    private function openModule( id:String ):void {
      if ( !this.loaderInfo.applicationDomain.hasDefinition( id ) ) {
        throw new Error( "Module \"" + id + "\" is not loaded or does not exist." );
        return;
      }
      if ( !currentModule || currentModule.id != id ) {
        var newModule:Module = Module( KuroExpress.createAsset( id ) );
        if ( currentModule ) {
          KuroExpress.addListener( currentModule, Event.CLOSE, moduleClosed, currentModule, newModule );
          currentModule.removeEventListener( OpenModuleEvent.OPEN_MODULE, moduleRequested );
          currentModule.close();
        } else {
          addChild( newModule );
          newModule.open( _commander );
        }
        currentModule = newModule;
        currentModule.addEventListener( OpenModuleEvent.OPEN_MODULE, moduleRequested );
      }
    }
    
    private function moduleRequested( e:OpenModuleEvent ):void {
      loadModule( e.module );
    }
    
    private function moduleClosed( oldModule:Module, newModule:Module ):void {
      KuroExpress.removeListener( oldModule, Event.CLOSE, moduleClosed );
      if( contains( oldModule ) ) {
        removeChild( oldModule );
      }
      addChild( newModule );
      newModule.open(_commander);
    }
    
  }
  
}