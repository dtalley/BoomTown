package com.kuro.kuroexpress.util {
  import com.kuro.kuroexpress.struct.LinkedList;
	
  public class ListNode implements ILinkedObjectNode {
    
    private var _next:IObjectNode;
    private var _prev:IObjectNode;
    private var _list:LinkedList;
    
    public function get next():IObjectNode {
      return _next;
    }
    public function set next( val:IObjectNode ):void {
      _next = val;
    }   
    public function get prev():IObjectNode {
      return _prev;
    }
    public function set prev( val:IObjectNode ):void {
      _prev = val;
    }   
    public function get list():IObjectNode {
      return _list;
    }
    public function set list( val:IObjectNode ):void {
      _list = val;
    }   
    
  }

}