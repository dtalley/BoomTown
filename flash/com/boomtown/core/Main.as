﻿package com.boomtown.core {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextField;
  import md.core.Module;
  import nl.demonsters.debugger.MonsterDebugger;
  
  
  public class Main extends MovieClip {
    
    private var _commander:Commander;
    
    public function Main():void {
      var debugger:MonsterDebugger = new MonsterDebugger(this);
      MonsterDebugger.enabled = true;
      addEventListener( Event.ADDED_TO_STAGE, init );
    }
    
    private function init( e:Event ):void {
      removeEventListener( Event.ADDED_TO_STAGE, init );
      var style:String = loaderInfo.parameters && loaderInfo.parameters.style_dir ? loaderInfo.parameters.style_dir + "/flash/" : "";
      if ( style ) {
        KuroExpress.setFullURL( style );
      }
      XMLManager.loadFile( style + "settings.xml", "settings", settingsLoaded );
    }
    
    private function settingsLoaded():void {
      ActionRequest.saveAddress( XMLManager.getFile("settings").magasi_url.toString() );
      loadFonts();
    }
    
    private function loadFonts():void {
      
      var loaderFonts:XMLList = XMLManager.getFile("settings").loader_fonts;
      var total:int = loaderFonts.font.length();
      var fonts:Array = [];
      for ( var i:int = 0; i < total; i++ ) {
        fonts.push( loaderFonts.font[i].toString() );
      }
      var fontLoader:Sprite = KuroExpress.loadFonts(fonts);
      fontLoader.addEventListener( Event.COMPLETE, fontsLoaded );
    }
    
    private function fontsLoaded( e:Event ):void {
      e.target.removeEventListener( Event.COMPLETE, fontsLoaded );
      
      _commander = new Commander();
      _commander.addEventListener( Event.COMPLETE, commanderReady );
      if ( loaderInfo.parameters.user_id ) {
        _commander.init( loaderInfo.parameters.user_id );
      } else {
        _commander.init( XMLManager.getFile( "settings" ).default_user.toString() );
      }
    }
    
    private function commanderReady( e:Event ):void {
      if ( _commander.complete ) {
        loadModule( "CommandBridge" );
      } else {
        loadModule( "CommanderCreator" );
      }
    }
    
    private var loadedModules:Object = {};
    private function loadModule( id:String ):void {
      if ( !loadedModules[id] ) {
        var moduleLoader:Sprite = KuroExpress.loadAssetsFile( "modules/" + id + ".swf" );
        KuroExpress.addListener( moduleLoader, Event.COMPLETE, moduleLoaded, moduleLoader, id );
      } else {
        openModule( id );
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
      }
      if ( !currentModule || currentModule.id != id ) {
        var newModule:Module = Module( KuroExpress.createAsset( id ) );
        if ( currentModule ) {
          KuroExpress.addListener( currentModule,=
          \]]]]]]]]y6777777777777777777utEvent.CLOSE, moduleClosed, currentModule, newModule );
        } else {
          addChild( newModule );
          newModule.open();
        }
        currentModule = newModule;
      }
    }
    
    private function moduleClosed( oldModule:Module, newModule:Module ):void {
      if( contains( oldModule ) ) {
        removeChild( oldModule );
      }
      addChild( newModule );
      newModule.open();
    }
    
  }
  
}