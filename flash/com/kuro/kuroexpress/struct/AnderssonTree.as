package com.kuro.kuroexpress.struct {
  import com.kuro.kuroexpress.util.ITreeNode;
	
  public class AnderssonTree extends BinaryTree {
    
    public function AnderssonTree() {}
    
    public override function add( node:ITreeNode ):void {
      if ( _size > 800 ) {
        trace( "Tree is too large!" );
        return;
      }
      _root = insert( _root, node );
      _size++;
    }
    
    public override function rem( node:ITreeNode ):void {
      _root = remove( _root, node );
      _size--;
    }
    
    private function insert( root:ITreeNode, node:ITreeNode ):ITreeNode {
      if ( !nodeValid(root) ) {
        root = node;
        root.level = 1;
      } else if ( root.compare( node ) == 0 ) {
        return root;
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
    
    private function remove( root:ITreeNode, node:ITreeNode, iteration:uint = 0 ):ITreeNode {
      trace( "Remove " + iteration + " called ---------------" );
      if ( !nodeValid(root) || !nodeValid(node) ) {
        trace( "Root was not valid" );
        return root;
      }
      if ( root.compare( node ) == 0 ) {
        trace( "Removal found..." );
        if ( nodeValid(root.left) && nodeValid(root.right) ) {
          trace( "Root has valid heir..." );
          var heir:ITreeNode = root.left;
          while ( nodeValid(heir.right) ) {
            trace( "Advancing heir..." );
            heir = heir.right;
          }
          root.copy( heir );
          root.left = remove( root.left, heir, iteration + 1 );
        } else {
          if ( nodeValid( root.left ) ) {
            trace( "Root had no valid heir, choosing left..." );
            root = root.left;
          } else {
            trace( "Root had no valid heir, choosing right..." );
            root = root.right;
          }
        }
      } else {
        if ( root.compare( node ) < 0 ) {
          trace( "Recursing right..." );
          root.right = remove( root.right, node, iteration + 1 );
        } else {
          trace( "Recursing left..." );
          root.left = remove( root.left, node, iteration + 1 );
        }
      }
      var process:Boolean = false;
      if( nodeValid( root ) ) {
        if ( nodeValid( root.left ) ) {
          if( root.left.level < root.level - 1 ) {
            process = true;
          }
        }
        if ( nodeValid( root.right ) ) {
          if( root.right.level < root.level - 1 ) {
            process = true;
          }
        }
      }
      if ( process ) {
        if ( nodeValid( root.right ) ) {
          trace( "Root had proper descendants..." );
          root.level--;
          if ( root.right.level > root.level ) {
            trace( "Root had higher level descendant..." );
            root.right.level = root.level;
          }
        }
        trace( "Skewing and splitting..." );
        root = skew( root );
        root = split( root );
      }      
      trace( "Remove " + iteration + " returning ---------------" );
      return root;
    }
    
    private function skew( root:ITreeNode ):ITreeNode {
      if ( nodeValid(root) ) {
        if ( nodeValid(root.left) && root.left.level == root.level ) {
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
      if ( nodeValid(root) && nodeValid(root.right) && nodeValid(root.right.right) && root.right.right.level == root.level ) {
        var save:ITreeNode = root;
        root = root.right;
        save.right = root.left;
        root.left = save;
        root.level += 1;
        root.right = split( root.right );
      }
      return root;
    }
    
    private function nodeValid( node:ITreeNode ):Boolean {
      if ( node && node.level != 0 ) {
        return true;
      }
      return false;
    }
    
  }

}