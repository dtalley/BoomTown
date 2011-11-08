package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.IComparableObjectNode;
  import com.kuro.kuroexpress.util.ILinkedObjectNode;
	
  public class OrderedLinkedList extends LinkedList {
    
    public function OrderedLinkedList(){}
    
    override public function add( obj:IComparableObjectNode ):void {
      if ( obj.list == this ) {
        return;
      }
      
      if ( !_first ) {
        _first = obj;
        _last = obj;
      } else {
        var node:IComparableObjectNode = _first as IComparableObjectNode;
        if ( node.compare( obj ) > 0 ) {
          obj.next = _first;
          _first.prev = obj;
          _first = obj;
        } else if ( !node.next ) {
          node.next = obj;
          obj.prev = node;
          if ( node == _last ) {
            _last = obj;
          }
        } else {
          while ( (node.next as IComparableObjectNode).compare( obj ) <= 0 ) {
            node = node.next;
          }
          obj.next = node.next;
          (node.next as ILinkedObjectNode).prev = obj;
          node.next = obj;
          obj.prev = node;
        }
      }
      _size++;
    }
    
  }

}