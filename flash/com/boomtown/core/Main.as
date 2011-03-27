package com.boomtown.core {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.MovieClip;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.external.ExternalInterface;
  import flash.text.TextField;
  import com.boomtown.modules.core.Module;
  import nl.demonsters.debugger.MonsterDebugger;
  
  public class Main extends MovieClip {
    
    private var _commander:Commander;
    
    public function Main():void {
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
      fontLoader.addEventListener( Event.COMPLETE, loaderFontsLoaded );
    }
    
    private function loaderFontsLoaded( e:Event ):void {
      if( e ) {
        e.target.removeEventListener( Event.COMPLETE, loaderFontsLoaded );
      }
      
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
          KuroExpress.addListener( currentModule, Event.CLOSE, moduleClosed, currentModule, newModule );
        } else {
          addChild( newModule );
          newModule.open( _commander );
        }
        currentModule = newModule;
      }
    }
    
    private function moduleClosed( oldModule:Module, newModule:Module ):void {
      if( contains( oldModule ) ) {
        removeChild( oldModule );
      }
      addChild( newModule );
      newModule.open(_commander);
    }
    
  }
  
}