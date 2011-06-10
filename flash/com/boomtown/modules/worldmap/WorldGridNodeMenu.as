package com.boomtown.modules.worldmap {
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.greensock.TweenLite;
	import flash.display.Sprite;
  import flash.events.Event;
	
  internal class WorldGridNodeMenu extends Sprite {
    
    private var _background:Sprite;
    
    function WorldGridNodeMenu() {      
      _background = new Sprite();
      _background.graphics.beginFill( 0xFFFFFF );
      Hexagon.drawHexagon( _background, HexagonAxisGrid.metrics.width + 20, HexagonAxisGrid.metrics.height + 20, 0, 0, HexagonAxisGrid.metrics.rotation );
      _background.graphics.endFill();
      addChild( _background );
      var scale:Number = HexagonAxisGrid.metrics.width / ( HexagonAxisGrid.metrics.width + 20 );
      TweenLite.from( _background, .3, { scaleX:scale, scaleY:scale, onComplete:showMenu } );      
    }
    
    private var _close:Sprite;
    private var _admin:Sprite;
    
    private function showMenu():void {
      _close = new Sprite();
      _close.graphics.beginFill( 0xFFFFFF );
      _close.graphics.drawCircle( 0, 0, 15 );
      _close.graphics.endFill();
      addChild( _close );
      _close.x = Math.cos( HexagonAxisGrid.metrics.radians2 ) * ( HexagonAxisGrid.metrics.size2 + 30 );
      _close.y = Math.sin( HexagonAxisGrid.metrics.radians2 ) * ( HexagonAxisGrid.metrics.size2 + 30 );
      
      _admin = new Sprite();
      _admin.graphics.beginFill( 0xFFFFFF );
      _admin.graphics.drawCircle( 0, 0, 15 );
      _admin.graphics.endFill();
      addChild( _admin );
      _admin.x = Math.cos( HexagonAxisGrid.metrics.radians1 ) * ( HexagonAxisGrid.metrics.size1 + 30 );
      _admin.y = Math.sin( HexagonAxisGrid.metrics.radians1 ) * ( HexagonAxisGrid.metrics.size1 + 30 );
    }
    
    internal function close():void {
      var scale:Number = HexagonAxisGrid.metrics.width / ( HexagonAxisGrid.metrics.width + 20 );
      TweenLite.to( _background, .3, { scaleX:scale, scaleY:scale, onComplete:closed } );
    }
    
    private function closed():void {
      dispatchEvent( new Event( Event.CLOSE ) );
    }
    
  }

}