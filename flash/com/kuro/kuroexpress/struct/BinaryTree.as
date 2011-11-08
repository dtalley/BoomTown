package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.ITreeNode;
	
  public class BinaryTree {
    
    protected var _root:ITreeNode;
    
    public function BinaryTree() { }
    
    public function add( node:ITreeNode ):void {
      
    }
    
    public function rem( node:ITreeNode ):void {
      
    }
    
    public function get root():ITreeNode {
      return _root;
    }
    
    public function createIterator( type:uint = TreeIterator.IN_ORDER ):TreeIterator {
      return new TreeIterator( this, type );
    }
    
  }

}