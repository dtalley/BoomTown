package com.kuro.kuroexpress.util {	
  public class TreeNode extends OrderedListNode implements ITreeNode {    
    private var _left:ITreeNode;
    private var _right:ITreeNode;
    private var _level:uint;
    private var _next:IObjectNode;
    public function get left():ITreeNode {
      return _left;
    }
    public function set left( val:ITreeNode ):void {
      _left = val;
    }
    public function get right():ITreeNode {
      return _right;
    }
    public function set right( val:ITreeNode ):void {
      _right = val;
    }
    public function get level():uint {
      return _level;
    }
    public function set level( val:uint ):void {
      _level = val;
    }    
    public function copy( obj:ITreeNode ):void {
      
    }
  }
}