package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.ILinkedObjectNode;
	
  public class LinkedList {
    
    protected var _first:ILinkedObjectNode;
    protected var _last:ILinkedObjectNode;
    protected var _size:uint = 0;
    
    public function LinkedList(){}
    
    public function add( obj:ILinkedObjectNode ):void {
      if ( obj.list == this ) {
        return;
      }
      if ( !_first ) {
        _first = obj;
        _last = obj;
      } else {
        _last.next = obj;
        obj.prev = _last;
        _last = obj;
      }
      _size++;
    }
    
    public function remove( obj:ILinkedObjectNode ):void {
      if ( obj.list != this ) {
        return;
      }
      if ( obj.prev && obj.next ) {
        obj.prev.next = obj.next;
        obj.next.prev = obj.prev;
      } else if ( obj == _first ) {
        _first = obj.next;
        obj.next.prev = null;
      } else if ( obj == _last ) {
        _last = obj.prev;
        obj.prev.next = null;
      }
      obj.next = null;
      obj.prev = null;
      _size--;
    }
    
    public function pop():ILinkedObjectNode {
      var node:ILinkedObjectNode = _last as ILinkedObjectNode;
      if ( node.prev ) {
        _last = node.prev;
      }
      if ( node == _first ) {
        _first = null;
        _last = null;
      }
      return node;
    }
    
    public function shift():ILinkedObjectNode {
      var node:ILinkedObjectNode = _first as ILinkedObjectNode;
      if ( node.next ) {
        _first = node.next;
      }
      if ( node == _last ) {
        _last = null;
        _first = null;
      }
      return node;
    }
    
    public function createIterator( type:uint = ListIterator.FORWARD ):ListIterator {
      return new ListIterator( this, type );
    }
    
    public function clear():void {
      _first = null;
      _last = null;
      _size = 0;
    }
    
    public function get first():IExpandedObjectNode {
      return _first;
    }
    public function get last():IExpandedObjectNode {
      return _last;
    }
    public function get size():uint {
      return _size;
    }
    
  }

}