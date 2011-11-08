package com.boomtown.core {
	import com.kuro.kuroexpress.util.IObjectNode;
	
  public class QueuedMethod implements IObjectNode {
    
    private var _obj:Object;
    private var _method:Function;
    private var _args:Array;
    
    public function QueuedMethod( obj:Object, method:Function, args:Array ) {
      _obj = obj;
      _method = method;
      _args = args;
    }
    
    public function act():void {
      _method.apply( _obj, _args );
    }
    
    private var _next:IObjectNode;
    public function get next():IObjectNode {
      return _next;
    }
    public function set next( val:IObjectNode ):void {
      _next = val;
    }
    
  }

}