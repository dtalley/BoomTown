package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.IObjectNode;
	
  public class Queue {
    
    private var _first:IObjectNode;
    private var _last:IObjectNode;
    private var _size:uint = 0;
    
    public function Queue() { }
    
    public function add( obj:IObjectNode ):void {
      if ( !_first ) {
        _first = obj;
        _last = obj;
      } else {
        _last.next = obj;
        _last = obj;
      }
      _size++;
    }
    
    public function shift():IObjectNode {
      if ( !_first ) {
        return null;
      } else {
        var node:IObjectNode = _first;
        if ( node.next ) {
          _first = node.next;
        } else {
          _last = null;
          _first = null;
        }
        _size--;
        node.next = null;
        return node;
      }
    }
    
    public function clear():void {
      _first = null;
      _last = null;
      _size = 0;
    }
    
    public function get first():IObjectNode {
      return _first;
    }
    public function get size():uint {
      return _size;
    }
    
  }

}