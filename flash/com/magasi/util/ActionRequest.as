package com.magasi.util {
  import com.adobe.crypto.SHA256;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.PostGenerator;
  import com.magasi.events.MagasiActionEvent;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.events.MagasiMessageEvent;
  import com.magasi.events.MagasiRequestEvent;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLVariables;
  
  public class ActionRequest {
    
    private static var _address:String;
  
    public static function saveAddress( url:String ):void {
      _address = url;
    }
    
    public static function sendRequest( params:Object = null ):Sprite {
      KuroExpress.broadcast( "Sending request.",
        { label:"ActionRequest::sendRequest()" } );
      
        
      var request:URLRequest = PostGenerator.getRequest( _address, params );
      
      var dispatcher:Sprite = new Sprite();
      var loader:URLLoader = new URLLoader();
      loader.dataFormat = URLLoaderDataFormat.BINARY;
      KuroExpress.addListener( loader, Event.COMPLETE, requestLoaded, loader, dispatcher );
      KuroExpress.addListener( loader, IOErrorEvent.IO_ERROR, requestError, loader );
      loader.load( request );
      
      return dispatcher;
      
    }
    
    private static function requestError( loader:URLLoader ):void {
      KuroExpress.removeListener( loader, Event.COMPLETE, requestLoaded );
      KuroExpress.removeListener( loader, IOErrorEvent.IO_ERROR, requestError );
      KuroExpress.broadcast( "An error occurred in processing the request.", 
        { label:"ActionRequest::requestError()", color:0xFF0000 } );
    }
    
    private static function requestLoaded( loader:URLLoader, dispatcher:Sprite ):void {      
      KuroExpress.removeListener( loader, Event.COMPLETE, requestLoaded );
      KuroExpress.removeListener( loader, IOErrorEvent.IO_ERROR, requestError );
      
      try {
        var response:XML = new XML( loader.data );
      } catch ( e:Error ) { 
        KuroExpress.broadcast( "XML document was malformed.\n\n" + loader.data, 
          { label:"ActionRequest::requestLoaded()", color:0xFF0000 } );
        return;
      }
      
      KuroExpress.broadcast( "Response from Magasi was properly returned.", 
        { label:"ActionRequest::requestLoaded()", color:0x00FF00 } );
      
      /**
       * Parse through all of the messages returned from Magasi and dispatch errors
       * populated with their information.
       */
      var totalMessages:int = response.message.length();
      var types:Array = [];
      if ( totalMessages > 0 ) {
        types[SYSTEM_ERROR] = MagasiErrorEvent.SYSTEM_ERROR;
        types[APPLICATION_ERROR] = MagasiErrorEvent.APPLICATION_ERROR;
        types[USER_ERROR] = MagasiErrorEvent.USER_ERROR;
        types[USER_MESSAGE] = MagasiMessageEvent.USER_MESSAGE;
        types[AUTHENTICATION_ERROR] = MagasiErrorEvent.AUTHENTICATION_ERROR;
        types[MAINTENANCE_ERROR] = MagasiErrorEvent.MAINTENANCE_ERROR;
        types[NOTFOUND_ERROR] = MagasiErrorEvent.NOTFOUND_ERROR;
      }
      for ( var i:int = 0; i < totalMessages; i++ ) {
        var messagexml:XML = response.message[i];
        var code:int = int( messagexml.code.toString() );
        var evt:MagasiMessageEvent = null;
        switch( code ) {
          case SYSTEM_ERROR:
          case APPLICATION_ERROR:
          case USER_ERROR:
          case AUTHENTICATION_ERROR:
          case MAINTENANCE_ERROR:
          case NOTFOUND_ERROR:
            evt = new MagasiErrorEvent( 
              types[code],
              String(code), 
              messagexml.title.toString(), 
              messagexml.body.toString(), 
              messagexml.file.toString(), 
              messagexml.line.toString(), 
              messagexml["function"].toString(), 
              messagexml["class"].toString() 
            );
            break;
          case USER_MESSAGE:
            evt = new MagasiMessageEvent(
              types[code],
              String(code),
              messagexml.title.toString(),
              messagexml.body.toString()
            );
            break;
        }
        if ( evt != null ) {
          KuroExpress.broadcast( "An error was encountered.\n\n" + evt.title + "\n" + evt.body, 
            { label:"ActionRequest::requestLoaded()", color:0xFF0000 } );
          dispatcher.dispatchEvent( evt );
        }
      }
      
      /**
       * Parse through all of the actions returned from Magasi and dispatch events
       * populated with their information.
       */
      var totalActions:int = response.actions.action.length();
      for ( i = 0; i < totalActions; i++ ) {
        var actionxml:XML = response.actions.action[i];
        var act:MagasiActionEvent = new MagasiActionEvent( 
          MagasiActionEvent.MAGASI_ACTION,
          actionxml.extension.toString(),
          actionxml.action.toString(),
          actionxml.title.toString(),
          actionxml.name.toString(),
          actionxml.message.toString(),
          Boolean( actionxml.success.toString() ),
          actionxml.extra
        );
        KuroExpress.broadcast( "An action was encountered, " + act.extension + "::" + act.action,
          { label:"ActionRequest::requestLoaded()" } );
        dispatcher.dispatchEvent( act );
      }
      
      /**
       * Dispatch the final data event containing the entirety of the response from Magasi
       */
      var req:MagasiRequestEvent = new MagasiRequestEvent( 
        MagasiRequestEvent.MAGASI_REQUEST, 
        response
      );
      dispatcher.dispatchEvent( req );
      
    }
    
    public static function get SYSTEM_ERROR():int { return 0; }
    public static function get APPLICATION_ERROR():int { return 1; }
    public static function get USER_ERROR():int { return 2; }
    public static function get USER_MESSAGE():int { return 3; }
    public static function get AUTHENTICATION_ERROR():int { return 4; }
    public static function get MAINTENANCE_ERROR():int { return 5; }
    public static function get NOTFOUND_ERROR():int { return 6; }
    
  }
  
}