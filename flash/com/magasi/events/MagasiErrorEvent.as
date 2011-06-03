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
    
    public static const SYSTEM_ERROR:String = "ms_system_error";
    public static const APPLICATION_ERROR:String = "ms_application_error";
    public static const USER_ERROR:String = "ms_user_error";
    public static const AUTHENTICATION_ERROR:String = "ms_authentication_error";
    public static const MAINTENANCE_ERROR:String = "ms_maintenance_error";
    public static const NOTFOUND_ERROR:String = "ms_notfound_error";
    
  }
  
}