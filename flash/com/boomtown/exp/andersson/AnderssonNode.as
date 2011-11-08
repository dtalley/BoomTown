package com.boomtown.exp.andersson {
  import com.kuro.kuroexpress.text.KuroText;
  import com.kuro.kuroexpress.util.IObjectNode;
  import com.kuro.kuroexpress.util.ITreeNode;
  import flash.display.Sprite;
  import flash.text.TextField;
  public class AnderssonNode extends Sprite implements ITreeNode {
    private static var _nil:AnderssonNode;
    private static var _nilSet:Boolean = false;
    private var _value:uint;
    private var _text:TextField;
    public function AnderssonNode( value:uint ) {
      if ( !_nilSet ) {
        _nilSet = true;
        _nil = new AnderssonNode( 0 );
        _nil.level = 0;
        _nil.left = _nil;
        _nil.right = _nil;
      }
      _left = _nil;
      _right = _nil;
      _level = 0;
      _value = value;
      
      _text = KuroText.createTextField( { font:"Arial", size:60, color:0xFFFFFF, embedFonts:false } );
      _text.embedFonts = false;
      _text.text = _value + " // " + _level;
      _text.background = true;
      _text.backgroundColor = 0;
      addChild( _text );
    }
    
    public function get value():uint {
      return _value;
    }
    
    public function compare( obj:ITreeNode ):int {
      if ( _value < AnderssonNode( obj ).value ) {
        return -1;
      } else if ( _value > AnderssonNode( obj ).value ) {
        return 1;
      }
      return 0;
    }
  }
}