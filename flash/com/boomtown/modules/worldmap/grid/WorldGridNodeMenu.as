package com.boomtown.modules.worldmap.grid {
  import com.boomtown.events.GetCommanderEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
	import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.text.TextField;
	
  internal class WorldGridNodeMenu extends Sprite {
    
    private var _node:WorldGridNode;
    private var _metrics:HexagonMetrics;
    private var _background:Sprite;
    
    function WorldGridNodeMenu( node:WorldGridNode ) {      
      _node = node;
      
      _metrics = new HexagonMetrics( HexagonAxisGrid.metrics.width + 20, HexagonAxisGrid.metrics.height + 20, HexagonAxisGrid.metrics.rotation );
      _background = new Sprite();
      _background.graphics.beginFill( 0xFFFFFF );
      Hexagon.drawHexagon( _background, _metrics.width, _metrics.height, 0, 0, _metrics.rotation );
      _background.graphics.endFill();
      addChild( _background );
      var scale:Number = HexagonAxisGrid.metrics.width / ( HexagonAxisGrid.metrics.width + 20 );
      TweenLite.from( _background, .2, { scaleX:scale, scaleY:scale } );      
      TweenLite.delayedCall( .1, showMenu );
    }
    
    private var _close:Sprite;
    private var _admin:Sprite;
    private var _zoom:Sprite;
    
    private function showMenu():void {
      var commanderEvent:GetCommanderEvent = new GetCommanderEvent();
      dispatchEvent( commanderEvent );
      
      var buttonSize:Number = 27;      
      var text:TextField;
      
      _close = new Sprite();
      drawButton( _close, buttonSize );
      text = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:14, color:0x000000 } );
      text.text = "C";
      _close.addChild( text );
      addChildAt( _close, 0 );
      _close.x = Math.cos( _metrics.radians2 ) * ( _metrics.size2 + buttonSize * .75 );
      _close.y = Math.sin( _metrics.radians2 ) * ( _metrics.size2 + buttonSize * .75 );
      _close.buttonMode = true;
      _close.mouseChildren = false;
      KuroExpress.addListener( _close, MouseEvent.MOUSE_OVER, drawButton, _close, buttonSize, true );
      KuroExpress.addListener( _close, MouseEvent.MOUSE_OUT, drawButton, _close, buttonSize );
      KuroExpress.addListener( _close, MouseEvent.CLICK, closeClicked );
      
      _admin = new Sprite();
      drawButton( _admin, buttonSize );
      text = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:14, color:0x000000 } );
      text.text = "A";
      _admin.addChild( text );
      addChildAt( _admin, 0 );
      _admin.x = Math.cos( _metrics.radians1 ) * ( _metrics.size1 + buttonSize * .75 );
      _admin.y = Math.sin( _metrics.radians1 ) * ( _metrics.size1 + buttonSize * .75 );
      _admin.buttonMode = true;
      _admin.mouseChildren = false;
      KuroExpress.addListener( _admin, MouseEvent.MOUSE_OVER, drawButton, _admin, buttonSize, true );
      KuroExpress.addListener( _admin, MouseEvent.MOUSE_OUT, drawButton, _admin, buttonSize );
      KuroExpress.addListener( _admin, MouseEvent.CLICK, adminClicked );
      
      _zoom = new Sprite();
      drawButton( _zoom, buttonSize );
      text = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:14, color:0x000000 } );
      text.text = "Z";
      _zoom.addChild( text );
      addChildAt( _zoom, 0 );
      _zoom.x = Math.cos( _metrics.radians1 + ( _metrics.radians1 - _metrics.radians2 ) ) * ( _metrics.size2 + buttonSize * .75 );
      _zoom.y = Math.sin( _metrics.radians1 + ( _metrics.radians1 - _metrics.radians2 ) ) * ( _metrics.size2 + buttonSize * .75 );
      _zoom.buttonMode = true;
      _zoom.mouseChildren = false;
      KuroExpress.addListener( _zoom, MouseEvent.MOUSE_OVER, drawButton, _zoom, buttonSize, true );
      KuroExpress.addListener( _zoom, MouseEvent.MOUSE_OUT, drawButton, _zoom, buttonSize );
      KuroExpress.addListener( _zoom, MouseEvent.CLICK, zoomClicked );
      
      TweenLite.from( _close, .2, { x:0, y:0 } );
      TweenLite.from( _admin, .2, { delay:.05, x:0, y:0 } );
      TweenLite.from( _zoom, .2, { delay:.1, x:0, y:0 } );
    }
    
    private function drawButton( button:Sprite, size:Number = 24, over:Boolean = false ):void {
      button.graphics.clear();
      button.graphics.beginFill( 0xFFFFFF );
      button.graphics.drawCircle( 0, 0, size );
      button.graphics.endFill();
      button.graphics.beginFill( over ? 0xAAAAAA : 0xCCCCCC );
      button.graphics.drawCircle( 0, 0, size - 2 );
      button.graphics.endFill();
    }
    
    private function adminClicked():void {
      close();
    }
    
    private function closeClicked():void {
      close();
    }
    
    private function zoomClicked():void {
      close();
    }
    
    internal function close():void {
      KuroExpress.removeListener( _close, MouseEvent.CLICK, closeClicked );
      var scale:Number = HexagonAxisGrid.metrics.width / ( HexagonAxisGrid.metrics.width + 20 );
      TweenLite.to( _close, .2, { x:0, y:0 } );
      TweenLite.to( _admin, .2, { delay:.05, x:0, y:0 } );
      TweenLite.to( _zoom, .2, { delay:.1, x:0, y:0 } );
      TweenLite.to( _background, .2, { delay:.15, scaleX:scale, scaleY:scale, onComplete:closed } );
    }
    
    private function closed():void {
      dispatchEvent( new Event( Event.CLOSE ) );
    }
    
  }

}