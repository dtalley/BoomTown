package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.ITreeNode;
	
  public class AnderssonTree extends BinaryTree {
    
    public function AnderssonTree() {}
    
    public override function add( node:ITreeNode ):void {
      _root = insert( _root, node );
    }
    
    public override function rem( node:ITreeNode ):void {
      _root = remove( _root, node );
    }
    
    private function insert( root:ITreeNode, node:ITreeNode ):ITreeNode {
      if ( root.compare( node ) == 0 ) {
        return root;
      } else if ( !root || root.level == 0 ) {
        root = node;
        root.level = 1;
      } else {
        if ( root.compare( node ) < 0 ) {
          root.right = insert( root.right, node );
        } else {
          root.left = insert( root.left, node );
        }
        root = skew( root );
        root = split( root );
      }
      return root;
    }
    
    private function remove( root:ITreeNode, node:ITreeNode ):ITreeNode {
      if ( root.level != 0 ) {
        if ( root.compare( node ) == 0 ) {
          if ( root.left.level != 0 && root.right.level != 0 ) {
            var heir:ITreeNode = root.left;
            while ( heir.right.level != 0 ) {
              heir = heir.right;
            }
            root.copy( heir );
            root.left = remove( root.left, heir );
          } else {
            root = root.left.level == 0 ? root.right : root.left;
          }
        } else {
          if ( root.compare( node ) < 0 ) {
            root.right = remove( root.right, node );
          } else {
            root.left = remove( root.left, node );
          }
        }
      }
      if ( root.left.level < root.level - 1 || root.right.level < root.level - 1 ) {
        if ( root.right.level > --root.level ) {
          root.right.level = root.level;
        }
        root = skew( root );
        root = split( root );
      }      
      return root;
    }
    
    private function skew( root:ITreeNode ):ITreeNode {
      if ( root.level != 0 ) {
        if ( root.left.level == root.level ) {
          var save:ITreeNode = root;
          root = root.left;
          save.left = root.right;
          root.right = save;
        }
        root.right = skew( root.right );
      }
      return root;
    }
    
    private function split( root:ITreeNode ):ITreeNode {
      if ( root.right.right.level == root.level && root.level != 0 ) {
        var save:ITreeNode = root;
        root = root.right;
        save.right = root.left;
        root.left = save;
        root.level += 1;
        root.right = split( root.right );
      }
      return root;
    }
    
  }

}