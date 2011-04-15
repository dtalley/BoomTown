package com.boomtown.core {
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonLevelGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.GradientType;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.geom.Matrix;
  import flash.geom.Point;
  
  /**
   * ...
   * @author ...
   */
  public class HexGridBackground extends Sprite {
    
    private var _color:Sprite;
    private var _hexagons:Sprite;
    private var _gradient:Sprite;
    private var _metrics:HexagonMetrics;
    
    public function HexGridBackground( color:uint, hexWidth:Number, hexHeight:Number ):void {
      KuroExpress.addListener( this, Event.ADDED_TO_STAGE, draw, color, hexWidth, hexHeight );
    }
    
    private function draw( color:uint, hexWidth:Number, hexHeight:Number ):void {
      KuroExpress.removeListener( this, Event.ADDED_TO_STAGE, draw );
      
      _color = new Sprite();
      _color.graphics.beginFill( color );
      _color.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
      _color.graphics.endFill();      
      addChild( _color );
      
      _metrics = Hexagon.getMetrics( hexWidth, hexHeight );
      
      _hexagons = new Sprite();
      var bits:Sprite = new Sprite();
      for ( var i:int = 0; i < 20; i++ ) {
        var bit:Sprite = new Sprite();
        bit.graphics.beginFill( 0x000000 );
        Hexagon.drawHexagon( bit, _metrics.width + 1, _metrics.height + 1 );
        Hexagon.drawHexagon( bit, _metrics.width, _metrics.height );
        bit.graphics.endFill();
        var offset:Point = HexagonLevelGrid.offset( i, _metrics );
        bits.addChild(bit);
        bit.x = offset.x;
        bit.y = offset.y;
      }
      var bmap:Bitmap = new Bitmap( new BitmapData( _metrics.width + ( _metrics.width / 2 ), _metrics.height, true, 0x00000000 ) );
      bmap.bitmapData.draw( bits, null, null, null, null );
      var matr:Matrix = new Matrix();
      matr.translate( 
        0 - ( Math.floor( stage.stageWidth / 2 ) - ( Math.floor( stage.stageWidth / 2 / bmap.width ) * bmap.width ) + _metrics.width ) - 2,
        0 - ( Math.floor( stage.stageHeight / 2 ) - ( Math.floor( stage.stageHeight / 2 / bmap.height ) * bmap.height ) + _metrics.height )
      );      
      _hexagons.graphics.beginBitmapFill( bmap.bitmapData, matr );
      _hexagons.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
      _hexagons.graphics.endFill();
      addChild( _hexagons );
      
      _gradient = new Sprite();
      KuroExpress.beginGradientFill( _gradient, stage.stageWidth, stage.stageHeight, GradientType.RADIAL, 0, [0x000000, 0x000000], [0, .6], [0x00, 0xFF] );
      _gradient.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
      _gradient.graphics.endFill();
      addChild( _gradient );
    }
    
  }
  
}