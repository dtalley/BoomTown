package com.kuro.kuroexpress.util {
	
  public class ObjectNode implements IObjectNode {
    
    private var _next:IObjectNode;
    
    public function get next():IObjectNode {
      return _next;
    }
    public function set next( val:IObjectNode ):void {
      _next = val;
    }   
    
  }

}