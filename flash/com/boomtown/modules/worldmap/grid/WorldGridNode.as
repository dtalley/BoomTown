package com.boomtown.modules.worldmap.grid {
  import com.boomtown.core.Faction;
  import com.boomtown.modules.worldmap.events.WorldGridNodeEvent;
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.greensock.motionPaths.RectanglePath2D;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.util.IQueueLoadable;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.events.MagasiRequestEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
	/**
   * ...
   * @author David Talley
   */
  internal class WorldGridNode extends Sprite implements IQueueLoadable {
    
    private var _metrics:HexagonMetrics;
    
    private var _hx:int = 0;
    private var _hy:int = 0;
    
    private var _type:WorldGridNodeType;
    
    private var _hit:Sprite;
    private var _details:Sprite;
    private var _map:Bitmap;
    
    private var _loader:Sprite;
    private var _loaded:Boolean = false;
    private var _selected:Boolean = false;
    
    private var _faction:Faction;
    
    public function WorldGridNode() {
      _hit = new Sprite();
      _details = new Sprite();
    }
    
    public function init( metrics:HexagonMetrics, x:int, y:int ):void {
      _metrics = metrics;
      _hx = x;
      _hy = y;
      
      var info:uint = WorldGridCache.getNode( x, y );
      if ( ( info & 0x00FFFFFF ) < 0xFFFFFF ) {
        _type = WorldGridNodeType.ACTIVE;
      } else {
        _type = WorldGridNodeType.INACTIVE;
      }
      
      generateDetails();      
      draw();
    }
    
    private function generateDetails():void {
      if ( !_map || ( _map.width != _metrics.width && _map.height != _metrics.height ) ) {
        _map = new Bitmap( new BitmapData( _metrics.width, _metrics.height, true, 0x00000000 ) );
      } else {
        _map.bitmapData.fillRect( new Rectangle( 0, 0, _map.width, _map.height ), 0x00000000 );
      }
      var metrics:HexagonMetrics = new HexagonMetrics( 9, 7, 0 );
      _details.graphics.clear();
      for ( var i:int = 0; i < 37; i++ ) {
        _details.graphics.beginFill( 0x444444, 1 );
        var offset:Point = HexagonLevelGrid.offset( i, metrics );
        Hexagon.drawHexagon( _details, 8, 6, offset.x, offset.y );
        _details.graphics.endFill();
      }
      var matr:Matrix = new Matrix();
      matr.translate( _metrics.width / 2, _metrics.height / 2 );
      _map.bitmapData.draw( _details, matr );
      _map.x = 0 - _metrics.width / 2;
      _map.y = 0 - _metrics.height / 2;
      _details.graphics.clear();
      _details.addChild( _map );
      addChild( _details );
      
      addChild( _hit );
      _hit.graphics.beginFill( 0, 0 );
      Hexagon.drawHexagon( _hit, _metrics.width - 2, _metrics.height - 2, 0, 0, _metrics.rotation );
      _hit.graphics.endFill();
      _hit.buttonMode = true;
      _hit.addEventListener( MouseEvent.MOUSE_OVER, nodeOver );
      _hit.addEventListener( MouseEvent.MOUSE_OUT, nodeOut );
      _hit.addEventListener( MouseEvent.CLICK, nodeClick );
    }
    
    private function nodeOver( e:MouseEvent ):void {
      dispatchEvent( new WorldGridNodeEvent( WorldGridNodeEvent.OVER ) );
      draw( true );
    }
    
    private function nodeOut( e:MouseEvent ):void {
      draw();
    }
    
    private function nodeClick( e:MouseEvent ):void {
      dispatchEvent( new WorldGridNodeEvent( WorldGridNodeEvent.CLICKED ) );
    }
    
    public function load():void {
      var store:WorldGridNodeStore = WorldGridNodeCache.retrieveNode( _hx, _hy );
      var expires:uint = WorldGridCache.nodeExpires( _hx, _hy );
      var date:Date = new Date();
      if ( expires > date.getTime() && store && store.complete ) {
        _loaded = true;
        dispatchEvent( new Event( Event.COMPLETE ) );
      } else {
        _loader = ActionRequest.sendRequest( { map_action:"get_territory", territory_x:_hx, territory_y:_hy } );
        _loader.addEventListener( MagasiErrorEvent.USER_ERROR, territoryUserError );
        _loader.addEventListener( MagasiRequestEvent.MAGASI_REQUEST, territoryRequest );
      }
    }
    
    private function territoryUserError( e:MagasiErrorEvent ):void {
      _loaded = true;
      cleanLoader();
      dispatchEvent( new Event( Event.COMPLETE ) );
      draw();
    }
    
    private function territoryRequest( e:MagasiRequestEvent ):void {
      _loaded = true;
      cleanLoader();
      var territory:XMLList = e.data.map.territory;
      WorldGridNodeCache.storeNode( _hx, _hy, uint(territory.status.id.toString()), uint(territory.faction.id.toString()) );
      dispatchEvent( new Event( Event.COMPLETE ) );
      draw();
    }
    
    public function cancel():void {
      if ( !_loaded ) {
        ActionRequest.cancelRequest( _loader );
        cleanLoader();
      }
    }
    
    private function cleanLoader():void {
      if ( _loader ) {
        _loader.removeEventListener( MagasiErrorEvent.USER_ERROR, territoryUserError );
        _loader.removeEventListener( MagasiRequestEvent.MAGASI_REQUEST, territoryRequest );
        _loader = null;
      }
    }
    
    public function get loaded():Boolean {
      return _loaded;
    }
    
    public function select():void {
      _selected = true;
      draw();
      mouseChildren = false;
    }
    
    public function deselect():void {
      _selected = false;
      draw();
      mouseChildren = true;
    }
    
    private function draw( over:Boolean = false ):void {
      graphics.clear();
      if( !_loaded ) {
        graphics.beginFill( over ? 0x8888FF : 0xAAAAAA );
        Hexagon.drawHexagon( this, _metrics.width - ( over ? -10 : 2 ), _metrics.height - ( over ? -10 : 2 ), 0, 0, _metrics.rotation );
        graphics.endFill();
        graphics.beginFill( over ? 0x222222 : 0x444444 );
        Hexagon.drawHexagon( this, _metrics.width - 6, _metrics.height - 6, 0, 0, _metrics.rotation );
        graphics.endFill();
      } else {
        var factionColor:uint = _faction ? 0xFF0000 : 0xFFFFFF;
        var factionOverColor:uint = _faction ? 0x550000 : 0xDDDDDD;
        graphics.beginFill( over ? 0x8888FF : 0xAAAAAA );
        Hexagon.drawHexagon( this, _metrics.width - ( over ? -10 : 2 ), _metrics.height - ( over ? -10 : 2 ), 0, 0, _metrics.rotation );
        graphics.endFill();
        graphics.beginFill( over || _selected ? factionOverColor : factionColor );
        Hexagon.drawHexagon( this, _metrics.width - 6, _metrics.height - 6, 0, 0, _metrics.rotation );
        graphics.endFill();
      }
    }
    
    public function clear():void {
      graphics.clear();
      _details.removeChild( _map );
      _map = null;
      _type = WorldGridNodeType.UNDEFINED;
      if ( _loader ) {
        cancel();
      }
      _loaded = false;
      
      _hit.graphics.clear();
      _hit.removeEventListener( MouseEvent.MOUSE_OVER, nodeOver );
      _hit.removeEventListener( MouseEvent.MOUSE_OUT, nodeOut );
      _hit.removeEventListener( MouseEvent.CLICK, nodeClick );
    }
    
    public function set metrics( val:HexagonMetrics ):void {
      if( !_metrics || !_metrics.compare( val ) ) {
        _metrics = val;
        draw();
      }
    }
    
    public function get metrics():HexagonMetrics {
      return _metrics;
    }
    
    public function get hX():Number {
      return _hx;
    }
    
    public function get hY():Number {
      return _hy;
    }
    
    public function get type():WorldGridNodeType {
      return _type ? _type : WorldGridNodeType.UNDEFINED;
    }
    
  }

}