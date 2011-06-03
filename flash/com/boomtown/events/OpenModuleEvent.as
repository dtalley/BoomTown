package com.boomtown.events {
  import flash.events.Event;
  
  public class OpenModuleEvent extends Event {
    
    private var _module:String;
    
    public function OpenModuleEvent( type:String, module:String ):void {
      super(type);
      _module = module;
    }
    
    public function get module():String {
      return _module;
    }
    
    public static const OPEN_MODULE:String = "open_module";
    
  }
  
}