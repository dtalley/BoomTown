package com.kuro.kuroexpress.util {
  import com.kuro.kuroexpress.struct.LinkedList;
	
  public class ListNode implements ILinkedObjectNode {
    
    private var _next:IObjectNode;
    private var _prev:ILinkedObjectNode;
    private var _list:LinkedList;
    
    public function get next():IObjectNode {
      return _next;
    }
    public function set next( val:IObjectNode ):void {
      _next = val;
    }   
    public function get prev():ILinkedObjectNode {
      return _prev;
    }
    public function set prev( val:ILinkedObjectNode ):void {
      _prev = val;
    }   
    public function get list():LinkedList {
      return _list;
    }
    public function set list( val:LinkedList ):void {
      _list = val;
    }   
    
  }

}