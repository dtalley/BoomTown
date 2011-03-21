package com.magasi.events {
  import flash.events.Event;
  
  public class MagasiMessageEvent extends Event {
    
    protected var _code:String;
    protected var _title:String;
    protected var _body:String;
    
    public function MagasiMessageEvent( type:String, code:String, title:String, body:String ):void {
      super( type );
      _code = code;
      _title = title;
      _body = body;
    }
    
    public function get code():String {
      return _code;
    }
    
    public function get title():String {
      return _title;
    }
    
    public function get body():String {
      return _body;
    }
    
    public static function get USER_MESSAGE():String { return "ms_user_message" }
    
  }
  
}