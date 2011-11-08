package com.boomtown.exp.gridtest {
  import com.boomtown.utils.Hexagon;
  import com.boomtown.utils.HexagonAxisGrid;
  import com.boomtown.utils.HexagonMetrics;
  import com.kuro.kuroexpress.ByteMap;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.text.KuroText;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
	import flash.display.Sprite;
  import flash.events.MouseEvent;
  import flash.events.TimerEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.text.TextField;
  import flash.utils.Timer;
	
  public class Main extends Sprite {
    private var _roads:Number = .5;
    private var _buildings:Number = .5;
    private var _forests:Number = .5;
    private var _hills:Number = .1;
    private var _water:Number = .8;
    
    private var _sides:Array = [
      [ -1, 0 ],
      [ 0, -1 ],
      [ 1, 0 ],
      [ 0, 1 ],
      [ 1, -1 ],
      [ -1, 1 ]
    ];
    
    private var _map:Bitmap;
    private var _key:ByteMap;
    private var _temp:ByteMap;
    private var _data:BitmapData;
    private var _vis:BitmapData;
    
    private var _step:Timer;
    private var _phase:uint = 0;
    private var _started:Boolean = false;
    
    private var _max:uint = 30;
    
    private var _width:uint = 100;
    private var _height:uint = 100;
    
    private var _points:Array;
    private var _seeds:Array;
    private var _scale:uint = 1;
    private var _arrows:Sprite;
    public function Main() {         
      HexagonAxisGrid.metrics = new HexagonMetrics( 4, 8, 90 );
      _key = new ByteMap( 4 );
      _temp = new ByteMap( 4 );
      _data = new BitmapData( stage.stageWidth, stage.stageHeight, false, 0xFFFFFFFF );
      _vis = new BitmapData( _width, _height, false, 0xFFFFFFFF );
      _map = new Bitmap( _data );
      addChild( _map );
      _map.scaleX = _scale;
      _map.scaleY = _scale;
      _map.smoothing = false;
      _map.x = Math.round( stage.stageWidth / 2 - _map.width / 2 );
      _map.y = Math.round( stage.stageHeight / 2 - _map.height / 2 );
      var newmap:Bitmap = new Bitmap( _vis );
      addChild( newmap );
      newmap.rotation = -90;
      newmap.scaleX = 4;
      newmap.scaleY = 4;
      newmap.x = stage.stageWidth - newmap.width;
      newmap.y = stage.stageHeight;
      
      _arrows = new Sprite();
      addChild( _arrows );
      _arrows.x = _map.x;
      _arrows.y = _map.y;
      
      _points = new Array();
      _seeds = new Array();
      
      _step = new Timer(1);
      _step.addEventListener( TimerEvent.TIMER, stepAutomata );
      _step.start();
    }
    
    private function createHexagon( color:uint ):Sprite {
      var hex:Sprite = new Sprite();
      hex.graphics.beginFill( color );
      Hexagon.drawHexagon( hex, HexagonAxisGrid.metrics.width, HexagonAxisGrid.metrics.height, HexagonAxisGrid.metrics.width / 2, HexagonAxisGrid.metrics.height / 2, HexagonAxisGrid.metrics.rotation );
      hex.graphics.endFill();
      return hex;
    }
    
    private function copyHexagon( map:BitmapData, hex:Sprite, x:uint, y:uint ):void {
      var matrix:Matrix = new Matrix();
      matrix.translate( 
        ( -1 * HexagonAxisGrid.calculateX( x, y ) ) - ( HexagonAxisGrid.metrics.width / 2 ) + 450, 
        ( 1 * HexagonAxisGrid.calculateY( x, y ) ) - ( HexagonAxisGrid.metrics.height / 2 ) + 400
      );
      map.draw( hex, matrix, null, null, null, true );
    }
    
    private function drawArrow( x:uint, y:uint, side:uint, color:uint = 0 ):void {
      return;
      _arrows.graphics.beginFill( color );
      _arrows.graphics.drawRect( x * _scale, y * _scale, _scale, _scale );
      _arrows.graphics.endFill();
      _arrows.graphics.beginFill( 0xFFFF00 );
      if ( side == 0 ) {
        _arrows.graphics.moveTo( x * _scale, y * _scale );
        _arrows.graphics.lineTo( x * _scale + _scale, y * _scale + _scale / 2 );
        _arrows.graphics.lineTo( x * _scale, y * _scale + _scale ); 
      } else if ( side == 1 ) {
        _arrows.graphics.moveTo( x * _scale, y * _scale );
        _arrows.graphics.lineTo( x * _scale + _scale / 2, y * _scale + _scale );
        _arrows.graphics.lineTo( x * _scale + _scale, y * _scale ); 
      } else if ( side == 2 ) {
        _arrows.graphics.moveTo( x * _scale + _scale, y * _scale );
        _arrows.graphics.lineTo( x * _scale, y * _scale + _scale / 2 );
        _arrows.graphics.lineTo( x * _scale + _scale, y * _scale + _scale ); 
      } else {
        _arrows.graphics.moveTo( x * _scale, y * _scale + _scale );
        _arrows.graphics.lineTo( x * _scale + _scale / 2, y * _scale );
        _arrows.graphics.lineTo( x * _scale + _scale, y * _scale + _scale );  
      }
      _arrows.graphics.endFill();
    }
    
    private function addText( text:String ):void {
      //field.text = text + "\n" + field.text;
    }
    
    private var _rep:uint = 0;
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
      if ( _points.length == 0 && _started ) {
        _started = false;
        _points = _seeds;
        _seeds = new Array();
        _temp.clear();
        _phase++;
        trace( "Switched to phase " + _phase );
      }
    }
    
    private function position( x:uint, y:uint ):uint {
      return ( y * _height ) + x;
    }
    
    private function stepRoads():void {
      if ( !_started ) {
        var roads:uint = Math.ceil( 10 * _roads );
        var side:uint = 0;
        var i:uint;
        var x:uint;
        var y:uint;
        for ( i = 0; i < roads; i++ ) {
          var pixel:uint = Math.round( Math.random() * ( _width - 1 ) );
          x = side == 0 ? 0 : ( side == 2 ? _width - 1 : pixel );
          y = side == 1 ? 0 : ( side == 3 ? _height - 1 : pixel );
          makeRoad( x, y, side, false );
          side = side < 3 ? side + 1 : 0;
        }
        _started = true;
      } else {
        var total:uint = _points.length;
        for ( i = 0; i < Math.min( _max, total ); i++ ) {
          var point:Point = _points.shift();
          var pos:uint = position( point.x, point.y );
          side = _key.read( pos, 3, 5 );
          x = side == 0 ? point.x + 1 : ( side == 2 ? point.x - 1 : point.x );
          y = side == 1 ? point.y + 1 : ( side == 3 ? point.y - 1 : point.y );
          if ( ( x < 2 || x > _width - 3 ) && side % 2 == 1 ) {
            continue;
          }
          if ( ( y < 2 || y > _height - 3 ) && side % 2 == 0 ) {
            continue;
          }
          var newpos:uint = position( x, y );
          var type:uint = _key.read( newpos, 0, 2 );
          if ( type == 0 && KuroExpress.pointInBounds( x, y, _width, _height ) ) {
            var created:Boolean = makeRoad( x, y, side );            
            if( created && 1 ) {
              var chance:uint = Math.round( Math.random() * ( 150 - ( 149 * _roads ) ) );
              if ( chance <= 1 && _points.length < 40 * _roads ) {
                var newside:uint = Math.round( Math.random() );
                if ( side == 0 || side == 2 ) {
                  makeRoad( point.x, point.y, newside == 0 ? 1 : 3, false );
                } else {
                  makeRoad( point.x, point.y, newside == 0 ? 0 : 2, false );
                }
              }
            }
          } else if ( type == 1 ) {
            _seeds.push( new Point( point.x + 1, point.y ) );
            _seeds.push( new Point( point.x - 1, point.y ) );
            _seeds.push( new Point( point.x, point.y + 1 ) );
            _seeds.push( new Point( point.x, point.y - 1 ) );
          }
        }
      }
    }
    
    private function getRoadPoints( x:uint, y:uint, side:uint, front:Boolean = true ):Array {
      var addition:int = front ? -1 : 1;
      var points:Array = new Array();
      if ( side % 2 == 0 ) {
        points.push( new Point( x, y + addition ) );
        points.push( new Point( x, y - addition ) );
        if ( side == 0 ) {
          points.push( new Point( x - addition, y + addition ) );
          points.push( new Point( x - addition, y - addition ) );
        } else {
          points.push( new Point( x + addition, y + addition ) );
          points.push( new Point( x + addition, y - addition ) );
        }
      } else {
        points.push( new Point( x + addition, y ) );
        points.push( new Point( x - addition, y ) );
        if ( side == 1 ) {
          points.push( new Point( x + addition, y - addition ) );
          points.push( new Point( x - addition, y - addition ) );
        } else {
          points.push( new Point( x + addition, y + addition ) );
          points.push( new Point( x - addition, y + addition ) );
        } 
      }
      return points;
    }
    
    private function makeRoad( x:uint, y:uint, side:uint, redirect:Boolean = true ):Boolean {
      var pts:Array = getRoadPoints( x, y, side );
      for ( var i:uint = 0; i < pts.length; i++ ) {
        var pos:uint = position( pts[i].x, pts[i].y );
        var type:uint = _key.read( pos, 0, 2 );
        if ( type == 1 && KuroExpress.pointInBounds( pts[i].x, pts[i].y, _width, _height ) ) {
          var addpts:Array = getRoadPoints( x, y, side, false );
          var chkpts:Array = [false, false, false, false];
          for ( var j:uint = 0; j < addpts.length; j++ ) {
            var newpos:uint = position( addpts[j].x, addpts[j].y );
            var addtype:uint = _key.read( newpos, 0, 2 );
            if ( addtype == 1 ) {
              chkpts[j] = true;
            }
          }
          if ( ( chkpts[0] && chkpts[2] ) || ( chkpts[1] && chkpts[3] ) ) {
            return false;
          }
        }
      }
      if( redirect ) {
        var chance:uint = Math.round( Math.random() * ( 1000 - ( 850 * _roads ) ) );
        if ( chance <= 1 ) {
          var newside:uint = Math.round( Math.random() );
          if ( side == 0 || side == 2 ) {
            side = newside == 0 ? 1 : 3;
          } else {
            side = newside == 0 ? 0 : 2;
          }
        }
      }
      var pos:uint = position( x, y );
      var oldtype:uint = _key.read( pos, 0, 2 );
      _key.write( pos, 0, 2, 1 );
      _key.write( pos, 3, 5, side );
      _points.push( new Point( x, y ) );
      return true;
    }
    
    private function stepBuildings():void {
      if ( !_started ) {
        _started = true;
      }
      var total:uint = _points.length;
      for ( var i:uint = 0; i < Math.min( _max, total ); i++ ) {
        var point:Point = _points.shift();
        var pos:uint = position( point.x, point.y );
        var checked:uint = _temp.read( pos, 8, 8 );
        if ( checked ) {
          continue;
        }
        _temp.write( pos, 8, 8, 1 );
        var type:uint = _key.read( pos, 0, 2 );
        var filled:uint = _temp.read( pos, 0, 0 );
        if ( !filled && type == 2 ) {
          _key.write( pos, 0, 2, 0 );
        }
        var distance:uint = _temp.read( pos, 1, 7 );
        var tgt:Array = [];
        if ( type == 1 ) {
          var side:uint = _key.read( pos, 3, 5 );
          if ( side == 0 || side == 2 ) {
            tgt.push( { point:new Point( point.x, point.y + 1 ), side:4 } );
            tgt.push( { point:new Point( point.x, point.y - 1 ), side:4 } );
          } else {
            tgt.push( { point:new Point( point.x + 1, point.y ), side:5 } );
            tgt.push( { point:new Point( point.x - 1, point.y ), side:5 } );
          }
        } else if ( type == 2 ) {
          side = _key.read( pos, 3, 5 );
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
          pos = position( target.point.x, target.point.y );
          checked = _temp.read( pos, 8, 8 );
          var ntype:uint = _key.read( pos, 0, 2 );
          if ( ntype == 0 && KuroExpress.pointInBounds( x, y, _width, _height ) ) {
            makeBuilding( x, y, target.side, distance + 1 );
          }
        }
      }
    }
    
    private function makeBuilding( x:uint, y:uint, side:uint, distance:uint ):void {
      var pts:Array = getPoints( new Point( x, y ) );
      var cnt:uint = 0;
      for ( var i:uint = 0; i < 4; i++ ) {
        var pos:uint = position( pts[i].x, pts[i].y );
        var type:uint = _key.read( pos, 0, 2 );
        if ( type == 1 ) {
          cnt++;
        }
      }
      if ( !cnt ) {
        return;
      }
      var chance:uint = Math.round( Math.random() * ( distance + 1 ) / ( 4 * _buildings ) );
      var pos:uint = position( x, y );
      _key.write( pos, 0, 2, 2 );
      _key.write( pos, 3, 5, side );
      _temp.write( pos, 1, 7, distance );
      if ( chance <= 1 ) {
        _temp.write( pos, 0, 0, 1 );
        chance = Math.round( Math.random() * ( 300 - ( 299 * _buildings ) ) );
        if ( chance <= 1 && side < 4 ) {
          jumpBuilding( x, y, side );
        }
      }
      _points.push( new Point( x, y ) );
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
        var pos:uint = position( pt.x, pt.y );
        var type:uint = _key.read( pos, 0, 2 );
        if ( type == 1 ) {
          _points.push( new Point( pt.x, pt.y ) );
        }
      }
    }
    
    private function stepForests():void {
      if ( !_started ) {
        var forests:uint = Math.round( ( 30 * _forests ) );
        for ( var i:uint = 0; i < forests; i++ ) {
          var point:Point = new Point( Math.round( Math.random() * ( _width - 1 ) ), Math.round( Math.random() * ( _height - 1 ) ) );
          var pos:uint = position( point.x, point.y );
          var type:uint = _key.read( pos, 0, 2 );
          makeForest( point.x, point.y, 0, 0, type == 0 ? true : false );
        }
        _started = true;
      } else {
        var total:uint = _points.length;
        for ( i = 0; i < Math.min( _max, total ); i++ ) {
          point = _points.shift();
          pos = position( point.x, point.y );
          var checked:uint = _temp.read( pos, 18, 18 );
          if ( checked ) {
            continue;
          }
          _temp.write( pos, 18, 18, 1 );
          var modifier:int = _temp.read( pos, 0, 4 );
          var distance:uint = _temp.read( pos, 5, 17 );
          var pts:Array = getPoints( new Point( point.x, point.y ) );
          for ( var j:uint = 0; j < 4; j++ ) {
            point = pts.shift();
            pos = position( point.x, point.y );
            var checked:uint = _temp.read( pos, 18, 18 );
            if ( checked ) {
              continue;
            }
            type = _key.read( pos, 0, 2 );
            var chance:uint = Math.round( Math.random() * ( 30 * ( ( type == 0 ? modifier : distance ) / 100 ) ) );
            if ( chance < 1 && KuroExpress.pointInBounds( point.x, point.y, _width, _height ) ) {
              makeForest( point.x, point.y, modifier + 1, distance + 1, type == 0 ? true : false );
            }
          }
        }
      }
    }
    
    private function makeForest( x:uint, y:uint, modifier:int, distance:uint, useable:Boolean = true ):Boolean {
      if ( modifier < 16 ) {
        var chance:uint = Math.round( Math.random() * ( ( ( ( ( .76 - ( .54 * _forests ) ) * ( 2.7 * ( 1.2 - .9 + ( .1 * .6 ) ) ) ) + ( Math.min( distance, 127 ) / 128 ) ) ) * 100 / ( .6 * 100 ) ) );
        if ( chance < 1 ) {
          modifier -= ( chance + 1 );
        }
        if ( modifier < 0 ) {
          modifier = 0;
        }
      } else {
        modifier = 15;
      }
      var pos:uint = position( x, y );
      if ( useable ) {
        _key.write( pos, 0, 2, 3 );
        _key.write( pos, 3, 5, 0 );
        _vis.setPixel32( x, y, 0xFF00FF00 );
        copyHexagon( _data, createHexagon( 0xFF00FF00 ), x, y );
      }
      _temp.write( pos, 0, 4, modifier );
      _temp.write( pos, 5, 17, distance );
      _points.push( new Point( x, y ) );
      return true;
    }
    
    private function stepHills():void {
      
    }
    
    private function stepWater():void {
      
    }
    
    private function getPointInformation( x:uint, y:uint ):Object {
      var pos:uint = position( x, y );
      var ret:Object = {
        type: _key.read( pos, 0, 2 ),
        side: _key.read( pos, 3, 5 )
      };
      return ret;
    }
    
    private function getBuildingInformation( x:uint, y:uint ):Object {
      var pos:uint = position( x, y );
      var ret:Object = {
        filled: _temp.read( pos, 0, 0 ),
        distance: _temp.read( pos, 1, 7 )
      };
      return ret;
    }
    
    private function getForestInformation( x:uint, y:uint ):Object {
      var pos:uint = position( x, y );
      var ret:Object = {
        modifier: _temp.read( pos, 0, 4 ),
        distance: _temp.read( pos, 5, 17 )
      };
      return ret;
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