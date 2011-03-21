package com.magasi.util {
  import com.kuro.kuroexpress.KuroExpress;
  import com.magasi.events.MagasiActionEvent;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.events.MagasiMessageEvent;
  import com.magasi.events.MagasiRequestEvent;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLRequestMethod;
  import flash.net.URLVariables;
  
  public class ActionRequest {
    
    private static var _address:String;
  
    public static function saveAddress( url:String ):void {
      _address = url;
    }
    
    public static function sendRequest( extension:String, action:String, params:Object = null ):Sprite {
      KuroExpress.broadcast( {}, "ActionRequest::sendRequest(): Sending request to " + extension + " for action " + action );
      
      var request:URLRequest = new URLRequest( _address );
      var uvars:URLVariables = new URLVariables();
      if( params ) {
        for ( var key:String in params ) {
          uvars[key] = params[key];
        }
      }
      uvars.extension = extension;
      uvars.action = action;
      request.method = URLRequestMethod.POST;
      request.data = uvars;
      
      var dispatcher:Sprite = new Sprite();
      var loader:URLLoader = new URLLoader();
      KuroExpress.addListener( loader, Event.COMPLETE, requestLoaded, loader, extension, action, dispatcher );
      loader.addEventListener( IOErrorEvent.IO_ERROR, requestError );
      loader.load( request );
      
      return dispatcher;
      
    }
    
    private static function requestError( e:IOErrorEvent ):void {
      KuroExpress.broadcast( {}, "ActionRequest::requestError(): An error occurred in processing the request.", 0xFF0000 );
    }
    
    private static function requestLoaded( loader:URLLoader, extension:String, action:String, dispatcher:Sprite ):void {      
      if ( !KuroExpress.removeListener( loader, Event.COMPLETE, requestLoaded ) ) {
        KuroExpress.broadcast( {}, "ActionRequest::requestLoaded(): Unable to remove request listener.", 0xFF0000 );
      }
      
      try {
        var response:XML = new XML( loader.data );
      } catch ( e:Error ) { KuroExpress.broadcast( {}, "ActionRequest::requestLoaded(): XML document was malformed.", 0xFF0000 ) }
      
      KuroExpress.broadcast( {}, "ActionRequest::requestLoaded(): Response from extension " + extension + " for action " + action + " was properly returned.", 0x00FF00 );
      
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
        var message:XML = response.message[i];
        var code:int = int( message.code.toString() );
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
              message.title.toString(), 
              message.body.toString(), 
              message.file.toString(), 
              message.line.toString(), 
              message["function"].toString(), 
              message["class"].toString() 
            );
            break;
          case USER_MESSAGE:
            evt = new MagasiMessageEvent(
              types[code],
              String(code),
              message.title.toString(),
              message.body.toString()
            );
            break;
        }
        if ( evt != null ) {
          dispatcher.dispatchEvent( evt );
        }
      }
      
      /**
       * Parse through all of the actions returned from Magasi and dispatch events
       * populated with their information.
       */
      var totalActions:int = response.actions.action.length();
      for ( i = 0; i < totalActions; i++ ) {
        var action:XML = response.actions.action[i];
        var act:MagasiActionEvent = new MagasiActionEvent( 
          MagasiActionEvent.MAGASI_ACTION,
          action.extension.toString(),
          action.action.toString(),
          action.title.toString(),
          action.name.toString(),
          action.message.toString(),
          Boolean( action.success.toString() ) 
        );
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