package com.magasi.events {
  import flash.events.Event;
  
  public class MagasiActionEvent extends Event {
    
    private var _extension:String;
    private var _action:String;
    private var _title:String;
    private var _name:String;
    private var _body:String;
    private var _success:Boolean;
    private var _extra:XMLList;
    
    public function MagasiActionEvent( type:String, extension:String, action:String, title:String, name:String, body:String, success:Boolean, extra:XMLList = null ):void {
      super( type );
      _extension = extension;
      _action = action;
      _title = title;
      _name = name;
      _body = body;
      _success = success;
      _extra = extra;
    }
    
    public function get extension():String {
      return _extension;
    }
    
    public function get action():String {
      return _action;
    }
    
    public function get title():String {
      return _title;
    }
    
    public function get name():String {
      return _name;
    }
    
    public function get body():String {
      return _body;
    }
    
    public function get success():Boolean {
      return _success;
    }
    
    public function get extra():XMLList {
      return _extra;
    }
    
    public static const MAGASI_ACTION:String = "magasi_action";
    
  }
  
}