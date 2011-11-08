package com.boomtown.exp.andersson {
  import com.kuro.kuroexpress.struct.AnderssonTree;
  import com.kuro.kuroexpress.struct.TreeIterator;
  import com.kuro.kuroexpress.text.KuroText;
	import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.text.TextField;
  import flash.utils.Timer;
	
  public class Main extends Sprite {
    
    private var _tree:AnderssonTree;
    private var _button:Sprite;
    private var _phase:uint = 0;
    private var _values:Array = [];
    private var _details:Sprite;
    private var _list:TextField;
    
    public function Main() {
      _tree = new AnderssonTree();      
      
      _details = new Sprite();
      addChild( _details );
      
      _button = new Sprite();
      _button.graphics.beginFill( 0 );
      _button.graphics.drawRect( 0, 0, 100, 20 );
      _button.graphics.endFill();
      addChild( _button );
      _button.addEventListener( MouseEvent.CLICK, buttonClicked );
      
      _list = KuroText.createTextField( { font:"Arial", size:16, color:0 } );
      _list.embedFonts = false;
      addChild( _list );
      _list.x = 10;
      _list.y = stage.stageHeight - _list.height - 50;
      
      var timer:Timer = new Timer( 1 );
      timer.addEventListener( TimerEvent.TIMER, startPhase );
      timer.start();
    }
    
    private function buttonClicked( e:MouseEvent ):void {
      nextPhase();
    }
    
    private function nextPhase():void {
      _phase++;
      startPhase( null );
    }
    
    private function startPhase( e:TimerEvent ):void {
      addValue( Math.round( Math.random() * 199 + 1 ) );
      
      _details.graphics.clear();
      AnderssonNode( _tree.root ).scaleX = AnderssonNode( _tree.root ).scaleY = 1;
      AnderssonNode( _tree.root ).x = stage.stageWidth / 2 - AnderssonNode( _tree.root ).width / 2;
      AnderssonNode( _tree.root ).y = 20;
      positionNode( AnderssonNode( _tree.root ), 1 );
      
      _list.text = "";
      _list.text = _values.length + "";
    }
    
    private function positionNode( node:AnderssonNode, scale:Number ):void {
      if ( node.left && node.left.level > 0 ) {
        AnderssonNode( node.left ).scaleX = AnderssonNode( node.left ).scaleY = scale;
        AnderssonNode( node.left ).x = node.x + ( node.width / 2 ) - AnderssonNode( node.left ).width - ( 150 * scale * 2 );
        AnderssonNode( node.left ).y = node.y + node.height + 10;
        _details.graphics.lineStyle( 1, 0, 1 );
        _details.graphics.moveTo( node.x + node.width / 2, node.y + node.height / 2 );
        _details.graphics.lineTo( AnderssonNode( node.left ).x + AnderssonNode( node.left ).width / 2, AnderssonNode( node.left ).y + AnderssonNode( node.left ).height / 2 );
        positionNode( AnderssonNode( node.left ), scale / 2 );
      }
      if ( node.right && node.right.level > 0 ) {
        AnderssonNode( node.right ).scaleX = AnderssonNode( node.right ).scaleY = scale;
        AnderssonNode( node.right ).x = node.x + node.width - ( node.width / 2 ) + ( 150 * scale * 2 );
        AnderssonNode( node.right ).y = node.y + node.height + 10;
        _details.graphics.lineStyle( 1, 0, 1 );
        _details.graphics.moveTo( node.x + node.width / 2, node.y + node.height / 2 );
        _details.graphics.lineTo( AnderssonNode( node.right ).x + AnderssonNode( node.right ).width / 2, AnderssonNode( node.right ).y + AnderssonNode( node.right ).height / 2 );
        positionNode( AnderssonNode( node.right ), scale / 2 );
      }
    }
    
    private function addValue( val:uint ):void {
      var node:AnderssonNode = new AnderssonNode( val );
      addChild( node );
      _values.push( node );
      _tree.add( node );
    }
    
  }

}