package com.boomtown.exp.andersson {
  import com.kuro.kuroexpress.text.KuroText;
  import com.kuro.kuroexpress.util.IComparableObjectNode;
  import com.kuro.kuroexpress.util.ITreeNode;
  import com.kuro.kuroexpress.util.TreeNode;
  import flash.display.Sprite;
  import flash.text.TextField;
  public class AnderssonNode extends TreeNode {
    private var _value:uint;
    private var _text:TextField;
    private var _sprite:Sprite;
    public function AnderssonNode( value:uint ) {
      _sprite = new Sprite();
      _value = value;
      
      _text = KuroText.createTextField( { font:"Arial", size:60, color:0xFFFFFF, embedFonts:false } );
      _text.embedFonts = false;
      _text.text = _value + " // " + level;
      _text.background = true;
      _text.backgroundColor = 0;
      _sprite.addChild( _text );
    }
    
    public function get sprite():Sprite {
      return _sprite;
    }
    
    public function get value():uint {
      return _value;
    }
    
    public function set x( val:Number ):void {
      _sprite.x = val;
    }
    
    public function set y( val:Number ):void {
      _sprite.y = val;
    }
    
    public function set scaleX( val:Number ):void {
      _sprite.scaleX = val;
    }
    
    public function set scaleY( val:Number ):void {
      _sprite.scaleY = val;
    }
    
    public function get scaleX():Number {
      return _sprite.scaleX;
    }
    
    public function get scaleY():Number {
      return _sprite.scaleY;
    }
    
    public function get x():Number {
      return _sprite.x;
    }
    
    public function get y():Number {
      return _sprite.y;
    }
    
    public function get width():Number {
      return _sprite.width;
    }
    
    public function get height():Number {
      return _sprite.height;
    }
    
    override public function copy( obj:ITreeNode ):void {
      var node:AnderssonNode = obj as AnderssonNode;
      trace( "Copying " + node.value + " to " + _value );
      _value = node.value;
      _text.text = _value + " // " + level;
    }
    
    override public function compare( obj:IComparableObjectNode ):int {
      if ( _value < AnderssonNode( obj ).value ) {
        return -1;
      } else if ( _value > AnderssonNode( obj ).value ) {
        return 1;
      }
      return 0;
    }
  }
}