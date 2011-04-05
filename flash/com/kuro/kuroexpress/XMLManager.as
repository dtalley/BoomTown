package com.kuro.kuroexpress {
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  
  public class XMLManager {
    
    private static var _xml:Object = {};
    
    public static function loadFile( file:String, id:String, onComplete:Function = null, onCompleteParams:Array = null ):void {
      var request:URLRequest = new URLRequest( file );
      var loader:URLLoader = new URLLoader();
      KuroExpress.addListener( loader, Event.COMPLETE, fileLoaded, loader, id, onComplete, onCompleteParams );
      loader.load( request );
    }
    
    private static function fileLoaded( loader:URLLoader, id:String, onComplete:Function, onCompleteParams:Array ):void {
      KuroExpress.removeListener( loader, Event.COMPLETE, fileLoaded );
      var xml:XML = new XML( loader.data );
      _xml[id] = xml;
      if ( onComplete != null ) {
        onComplete.apply( {}, onCompleteParams );
      }
    }
    
    public static function addFile( id:String, content:Object ):void {
      _xml[id] = content;
    }
    
    public static function purgeFile( id:String ):Boolean {
      if( _xml[id] ) {
        _xml[id] = null;
        return true;
      }
      return false;
    }
    
    public static function getFile( id:String ):Object {
      if ( _xml[id] ) {
        return _xml[id];
      }
      return null;
    }
    
  }
  
}