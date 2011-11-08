package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.IExpandedObjectNode;
  
  public class ListIterator {
    
    private var _list:LinkedList;
    private var _type:uint;
    private var _current:IExpandedObjectNode;
    
    public function ListIterator( list:LinkedList, type:uint = ListIterator.FORWARD ) {
      _type = type;
      _list = list;
      if ( _type == ListIterator.FORWARD ) {
        _current = list.first;
      } else {
        _current = list.last;
      }
    }
    
    public function getNext():IExpandedObjectNode {
      switch( _type ) {
        case ListIterator.FORWARD:
          return getNextForward();
          break;
        default:
          return getNextReverse();
          break;
      }
    }
    
    private function getNextForward():IExpandedObjectNode {
      var node:IExpandedObjectNode = _current;
      if( node ) {
        _current = node.next;
      }
      return node;
    }
    
    private function getNextReverse():IExpandedObjectNode {
      var node:IExpandedObjectNode = _current;
      if( node ) {
        _current = node.prev;
      }
      return node;
    }
    
    public static const FORWARD:uint = 0;
    public static const REVERSE:uint = 1;
    
  }

}