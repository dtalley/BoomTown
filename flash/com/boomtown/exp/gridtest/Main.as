package com.boomtown.exp.gridtest {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.text.KuroText;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
	import flash.display.Sprite;
  import flash.events.TimerEvent;
  import flash.geom.Point;
  import flash.text.TextField;
  import flash.utils.Timer;
	
  public class Main extends Sprite {
    private var _roads:Number = 1;
    private var _buildings:Number = .3;
    private var _forests:Number = 1;
    private var _hills:Number = .1;
    private var _water:Number = .8;
    
    private var _map:Bitmap;
    private var _key:BitmapData;
    private var _data:BitmapData;
    
    private var _step:Timer;
    private var _phase:uint = 0;
    private var _started:Boolean = false;
    
    private var _points:Array;
    private var _seeds:Array;
    public function Main() {
      /*_roads = Math.round( Math.random() * 100 ) / 100;
      _buildings = Math.round( Math.random() * 100 ) / 100;
      _forests = Math.round( Math.random() * 100 ) / 100;*/
      
      var field:TextField = KuroText.createTextField( { font:"Arial", embedFonts:false, size:12, color:0x000000 } );
      field.embedFonts = false;
      field.text = "Roads: " + _roads + ", Buildings: " + _buildings + ", Forests: " + _forests;
      addChild( field );
      field.background = true;
      field.backgroundColor = 0xFFFFFF;
      field.x = 5;
      field.y = 5;
      
      _key = new BitmapData( 100, 100, true, 0x00000000 );
      _data = new BitmapData( _key.width, _key.height, false, 0xFFFFFFFF );
      _map = new Bitmap( _data );
      addChild( _map );
      _map.scaleX = 3;
      _map.scaleY = 3;
      _map.smoothing = false;
      _map.x = Math.round( stage.stageWidth / 2 - _map.width / 2 );
      _map.y = Math.round( stage.stageHeight / 2 - _map.height / 2 );
      
      _points = new Array();
      _seeds = new Array();
      
      _step = new Timer(1);
      _step.addEventListener( TimerEvent.TIMER, stepAutomata );
      _step.start();
    }
    
    private function stepAutomata( e:TimerEvent ):void {
      switch( _phase ) {
        case 0:
          stepRoads();
          break;
        case 1:
          stepBuildings();
          break;
        case 2:
          stepForests();
          break;
        case 3:
          stepHills();
          break;
        case 4:
          stepWater();
          break;
      }
      trace( _points.length );
      if ( _points.length == 0 && _started ) {
        _started = false;
        _points = _seeds;
        _seeds = new Array();
        _phase++;
        trace( "Switched to phase " + _phase );
      }
    }
    
    private function stepRoads():void {
      if ( !_started ) {
        var roads:uint = Math.ceil( 10 * _roads );
        var side:uint = 0;
        for ( var i:uint = 0; i < roads; i++ ) {
          var pixel:uint = Math.round( Math.random() * ( _key.width - 1 ) );
          var x:uint = side == 0 ? 0 : ( side == 2 ? _key.width - 1 : pixel );
          var y:uint = side == 1 ? 0 : ( side == 3 ? _key.height - 1 : pixel );
          makeRoad( x, y, side );
          side = side < 3 ? side + 1 : 0;
        }
        _started = true;
      } else {
        var total:uint = _points.length;
        for ( i = 0; i < total; i++ ) {
          var point:Point = _points.shift();
          var pix:uint = _key.getPixel32( point.x, point.y );
          side = KuroExpress.getBits( pix, 3, 4 );
          x = side == 0 ? point.x + 1 : ( side == 2 ? point.x - 1 : point.x );
          y = side == 1 ? point.y + 1 : ( side == 3 ? point.y - 1 : point.y );
          var pix2:uint = _key.getPixel32( x, y );
          var type:uint = KuroExpress.getBits( pix2, 0, 2 );
          if ( type == 0 && KuroExpress.pointInBounds( x, y, _key.width, _key.height ) ) {
            var created:Boolean = makeRoad( x, y, side );            
            if( created ) {
              var chance:uint = Math.round( Math.random() * ( 500 - ( 499 * _roads ) ) );
              if ( chance <= 1 && _points.length < 40 ) {
                var newside:uint = Math.round( Math.random() );
                if ( side == 0 || side == 1 ) {
                  makeRoad( point.x, point.y, 2 + newside );
                } else {
                  makeRoad( point.x, point.y, 0 + newside );
                }
              }
            }
          }
        }
      }
    }
    
    private function makeRoad( x:uint, y:uint, side:uint ):Boolean {
      var pts:Array = getPoints( new Point( x, y ) );
      var rotate:Boolean = false;
      for ( var i:uint = 0; i < 4; i++ ) {
        var chk:uint = _key.getPixel32( pts[i].x, pts[i].y );
        var type:uint = KuroExpress.getBits( chk, 0, 2 );
        if ( type == 1 && KuroExpress.pointInBounds( pts[i].x, pts[i].y, _key.width, _key.height ) ) {
          var oldside:uint = KuroExpress.getBits( chk, 3, 4 );
          if ( ( side == 0 || side == 2 ) && ( oldside == 0 || oldside == 2 ) && pts[i].y != y ) {
            rotate = true;
          } else if ( ( side == 1 || side == 3 ) && ( oldside == 1 || oldside == 3 ) && pts[i].x != x ) {
            rotate = true;
          }
        }
      }
      var seed:Boolean = false;
      var chance:uint = Math.round( Math.random() * ( 500 - ( 499 * _buildings ) ) );
      if ( chance <= 1 && _seeds.length < Math.round( _buildings * 10 ) ) {
        seed = true;
      }
      var pix:uint = _key.getPixel32( x, y );
      pix = KuroExpress.setBits( pix, 0, 2, 1 );
      pix = KuroExpress.setBits( pix, 3, 4, side );
      pix = KuroExpress.setBits( pix, 30, 31, 3 );
      _key.setPixel32( x, y, pix );
      _data.setPixel32( x, y, 0xFF000000 );
      _points.push( new Point( x, y ) );
      if ( seed ) {
        _seeds.push( new Point( x, y ) );
      }
      return true;
    }
    
    private function stepBuildings():void {
      if ( !_started ) {
        _started = true;
      }
      var total:uint = _points.length;
      for ( var i:uint = 0; i < total; i++ ) {
        var point:Point = _points.shift();
        var pix:uint = _key.getPixel32( point.x, point.y );
        var type:uint = KuroExpress.getBits( pix, 0, 2 );
        var tgt:Array = [];
        if ( type == 1 ) {
          var side:uint = KuroExpress.getBits( pix, 3, 4 );
          if ( side == 0 || side == 2 ) {
            tgt.push( { point:new Point( point.x, point.y + 1 ), side:4 } );
            tgt.push( { point:new Point( point.x, point.y - 1 ), side:4 } );
          } else {
            tgt.push( { point:new Point( point.x + 1, point.y ), side:5 } );
            tgt.push( { point:new Point( point.x - 1, point.y ), side:5 } );
          }
        } else if ( type == 2 ) {
          side = KuroExpress.getBits( pix, 3, 5 );
          if ( side == 0 ) {
            tgt.push( { point:new Point( point.x + 1, point.y ), side:0 } );
          } else if ( side == 1 ) {
            tgt.push( { point:new Point( point.x - 1, point.y ), side:1 } );
          } else if ( side == 2 ) {
            tgt.push( { point:new Point( point.x, point.y + 1 ), side:2 } );
          } else if ( side == 3 ) {
            tgt.push( { point:new Point( point.x, point.y - 1 ), side:3 } );
          } else if ( side == 4 ) {
            tgt.push( { point:new Point( point.x + 1, point.y ), side:0 } );
            tgt.push( { point:new Point( point.x - 1, point.y ), side:1 } );
          } else if ( side == 5 ) {
            tgt.push( { point:new Point( point.x, point.y + 1 ), side:2 } );
            tgt.push( { point:new Point( point.x, point.y - 1 ), side:3 } );
          }
        }
        var count:uint = tgt.length;
        for ( var j:uint = 0; j < count; j++ ) {
          var target:Object = tgt.shift();
          var x:uint = target.point.x;
          var y:uint = target.point.y;
          pix = _key.getPixel32( target.point.x, target.point.y );
          var ntype:uint = KuroExpress.getBits( pix, 0, 2 );
          if ( ntype == 0 && KuroExpress.pointInBounds( x, y, _key.width, _key.height ) ) {
            if ( target.side < 4 ) {
              trace( "Adding building from building" );
            } else {
              trace( "Adding building from road" );
            }
            makeBuilding( x, y, target.side );
          } else if ( ntype == 1 && _points.length < 20 ) {
            _points.push( new Point( x, y ) );
          }
        }
      }
    }
    
    private function makeBuilding( x:uint, y:uint, side:uint ):void {
      var chance:uint = Math.round( Math.random() * ( 200 ) );
      var pix:uint = _key.getPixel32( x, y );
      pix = KuroExpress.setBits( pix, 0, 2, 2 );
      pix = KuroExpress.setBits( pix, 3, 5, side );
      pix = KuroExpress.setBits( pix, 31, 31, 1 );
      _key.setPixel32( x, y, pix );
      if( chance < 200 * _buildings ) {
        _data.setPixel32( x, y, 0xFFFF0000 );
        chance = Math.round( Math.random() * ( 300 - ( 299 * _buildings ) ) );
        if ( chance <= 1 && side < 4 ) {
          trace( "Adding building from jump" );
          jumpBuilding( x, y, side );
        }
      }
      if( _points.length < 20 ) {
        _points.push( new Point( x, y ) );
      }
    }
    
    private function jumpBuilding( x:uint, y:uint, side:uint ):void {
      var pts:Array = new Array();
      var newside:uint = 0;
      if ( side == 0 || side == 1 ) {
        pts.push( new Point( x, y + 1 ) );
        pts.push( new Point( x, y - 1 ) );
        newside = 4;
      } else {
        pts.push( new Point( x + 1, y ) );
        pts.push( new Point( x - 1, y ) );
        newside = 5;
      }
      for ( var i:uint = 0; i < 2; i++ ) {
        var pt:Point = pts.shift();
        var pix:uint = _key.getPixel32( pt.x, pt.y );
        var type:uint = KuroExpress.getBits( pix, 0, 2 );
        if ( type == 1 ) {
          _points.push( new Point( pt.x, pt.y ) );
        }
      }
    }
    
    private function stepForests():void {
      if ( !_started ) {
        var forests:uint = Math.round( ( 10 * _forests ) );
        for ( var i:uint = 0; i < forests; i++ ) {
          var point:Point = new Point( Math.round( Math.random() * ( _key.width - 1 ) ), Math.round( Math.random() * ( _key.height - 1 ) ) );
          var pix:uint = _key.getPixel32( point.x, point.y );
          var type:uint = KuroExpress.getBits( pix, 0, 2 );
          if ( type == 0 ) {
            makeForest( point.x, point.y, 0, 0 );
          }
        }
        _started = true;
      } else {
        var total:uint = _points.length;
        for ( i = 0; i < total; i++ ) {
          point = _points.shift();
          pix = _key.getPixel32( point.x, point.y );
          var modifier:int = KuroExpress.getBits( pix, 3, 7 );
          var distance:uint = KuroExpress.getBits( pix, 8, 20 );
          var pts:Array = getPoints( new Point( point.x, point.y ) );
          for ( var j:uint = 0; j < 4; j++ ) {
            point = pts.shift();
            pix = _key.getPixel32( point.x, point.y );
            type = KuroExpress.getBits( pix, 0, 2 );
            var high:uint = 100;
            var chance:uint = Math.round( Math.random() * ( 1500 * ( modifier / 16 ) ) );
            if ( chance <= 1 && type == 0 && KuroExpress.pointInBounds( point.x, point.y, _key.width, _key.height ) ) {
              makeForest( point.x, point.y, modifier + 1, distance + 1 );
            }
          }
        }
      }
    }
    
    private function makeForest( x:uint, y:uint, modifier:int, distance:uint ):Boolean {
      if ( modifier < 16 ) {
        var chance:uint = Math.round( Math.random() * ( ( ( ( .35 * ( 2.7 * ( 1.2 - .9 + ( .1 * _forests ) ) ) ) + ( Math.min( distance, 127 ) / 128 ) ) ) * 100 / ( _forests * 100 ) ) );
        if ( chance < 1 ) {
          modifier -= ( chance + 1 );
        }
        if ( modifier < 0 ) {
          modifier = 0;
        }
      } else {
        modifier = 15;
      }
      var pix:uint = _key.getPixel32( x, y );
      pix = KuroExpress.setBits( pix, 0, 2, 3 );
      pix = KuroExpress.setBits( pix, 3, 7, modifier );
      pix = KuroExpress.setBits( pix, 8, 20, distance );
      pix = KuroExpress.setBits( pix, 31, 31, 1 );
      _key.setPixel32( x, y, pix );
      _data.setPixel32( x, y, 0xFF00FF00 );
      _points.push( new Point( x, y ) );
      return true;
    }
    
    private function stepHills():void {
      
    }
    
    private function stepWater():void {
      
    }
    
    private function getPoints( point:Point ):Array {
      var arr:Array = [];
      arr.push( new Point( point.x + 1, point.y ) );
      arr.push( new Point( point.x - 1, point.y ) );
      arr.push( new Point( point.x, point.y + 1 ) );
      arr.push( new Point( point.x, point.y - 1 ) );
      return arr;
    }
  }

}