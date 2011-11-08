package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.IObjectNode;
	
  public class Stack {
    
    private var _first:IObjectNode;
    private var _last:IObjectNode;
    private var _size:uint = 0;
    
    public function Stack() { }
    
    public function add( obj:IObjectNode ):void {
      if ( !_last ) {
        _first = obj;
        _last = obj;
      } else {
        obj.next = _last;
        _last = obj;
      }
      _size++;
    }
    
    public function pop():IObjectNode {
      if ( !_last ) {
        return null;
      } else {
        var node:IObjectNode = _last;
        if ( node.next ) {
          _last = node.next;
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
    
    public function get last():IObjectNode {
      return _last;
    }
    public function get size():uint {
      return _size;
    }
    
  }

}