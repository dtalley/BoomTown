package com.boomtown.core {
  import com.kuro.kuroexpress.struct.LinkedList;
  import com.kuro.kuroexpress.util.IComparableObjectNode;
  import com.kuro.kuroexpress.util.OrderedListNode;
	
  public class DrivenObject extends OrderedListNode {
    
    private var _listener:Object;
    private var _priority:Number;
    
    public function DrivenObject( listener:Object, priority:Number ) {
      _listener = listener;
      _priority = priority;
    }
    
    public function get listener():Object {
      return _listener;
    }
    
    public function get priority():Number {
      return _priority;
    }
    
    override public function compare( obj:IComparableObjectNode ):int {
      var comp:DrivenObject = obj as DrivenObject;
      if ( comp.listener == _listener ) {
        return 0;
      }
      return comp.priority < _priority ? 1 : -1;
    }
    
  }

}