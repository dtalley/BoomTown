package com.magasi.events {
  
  public class MagasiErrorEvent extends MagasiMessageEvent {
    
    private var _file:String;
    private var _line:String;
    private var _func:String;
    private var _object:String;
    
    public function MagasiErrorEvent( type:String, code:String, title:String, body:String, file:String = "", line:String = "", func:String = "", object:String = "" ):void {
      super( type, code, title, body );
      _file = file;
      _line = line;
      _func = func;
      _object = object;
    }
    
    public function get file():String {
      return _file;
    }
    
    public function get line():String {
      return _line;
    }
    
    public function get func():String {
      return _func;
    }
    
    public function get object():String {
      return _object;
    }
    
    public static function get SYSTEM_ERROR():String { return "ms_system_error" }
    public static function get APPLICATION_ERROR():String { return "ms_application_error" }
    public static function get USER_ERROR():String { return "ms_user_error" }
    public static function get AUTHENTICATION_ERROR():String { return "ms_authentication_error" }
    public static function get MAINTENANCE_ERROR():String { return "ms_maintenance_error" }
    public static function get NOTFOUND_ERROR():String { return "ms_notfound_error" }
    
  }
  
}