package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.ITreeNode;
  
  public class TreeIterator {
    
    private var _tree:BinaryTree;
    private var _type:uint;
    private var _stack:Stack;
    
    public function TreeIterator( tree:BinaryTree, type:uint = TreeIterator.IN_ORDER ) {
      _type = type;
      _tree = tree;
      _stack = new Stack();
    }
    
    public function getNext():ITreeNode {
      switch( _type ) {
        case TreeIterator.IN_ORDER:
          return getNextInOrder();
          break;
        case TreeIterator.PRE_ORDER:
          return getNextPreOrder();
          break;
        default:
          return getNextPostOrder();
          break;
      }
    }
    
    private function getNextInOrder():ITreeNode {
      if ( _stack.size == 0 ) {
        return getInOrder( _tree.root );
      } else {
        var node:ITreeNode = ITreeNode( _stack.pop() );
        if ( node.right && node.right.level > 0 ) {
          return getInOrder( node.right );
        }
        return ITreeNode( _stack.last );
      }
    }    
    private function getInOrder( root:ITreeNode ):ITreeNode {
      _stack.add( root );
      var node:ITreeNode = root;
      while ( node.left && node.left.level > 0 ) {
        _stack.add( node );
        node = node.left;
      }
      return root;
    }
    
    private function getNextPreOrder():ITreeNode {
      if ( _stack.size == 0 ) {
        return getPreOrder( _tree.root );
      } else {
        return getPreOrder( ITreeNode( _stack.pop() ) );
      }
    }
    private function getPreOrder( root:ITreeNode ):ITreeNode {
      if( root.right && root.right.level > 0 ) {
        _stack.add( root.right );
      }
      if( root.left && root.left.level > 0 ) {
        _stack.add( root.left );
      }
      return root;
    }
    
    private function getNextPostOrder():ITreeNode {
      return null;
    }
    private function getPostOrder( root:ITreeNode ):ITreeNode {
      if ( root.left && root.left.level > 0 ) {
        
      } else if ( root.right && root.right.level > 0 ) {
        
      }
      _stack.add( root );
      return null;
    }
    
    public static const IN_ORDER:uint = 0;
    public static const PRE_ORDER:uint = 1;
    public static const POST_ORDER:uint = 2;
    
  }

}