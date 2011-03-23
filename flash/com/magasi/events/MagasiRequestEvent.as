package com.magasi.events {
  import flash.events.Event;
  
  public class MagasiRequestEvent extends Event {
    
    private var _data:XML;
    
    public function MagasiRequestEvent( type:String, data:XML ):void {
      super( type );
      _data = data;
    }
    
    public function get data():XML {
      return _data;
    }
    
    public static function get MAGASI_REQUEST():String { return "magasi_request"; }
    
  }
  
}