package com.boomtown.utils {
  import flash.geom.Point;
  
  public class HexagonLevelGrid {
    
    public static function levelStart( level:uint ):uint {
      return ( ( level * ( level - 1 ) ) / 2 ) * 6;
    }
    
    public static function levelTotal( level:uint ):uint {
      return level * 6;
    }
    
    public static function level( index:uint ):uint {
      if ( index == 0 ) {
        return 0;
      } else if ( index < 7 ) {
        return 1;
      }
      var a:int = 1;
      var b:int = 1;
      var c:Number = 0 - Math.floor( ( index - 1 ) / 6 ) * 2;
      
      var quad:Number = ( (0 - b) + Math.sqrt( Math.pow( b, 2 ) - ( 4 * a * c ) ) ) / ( 2 * a );
      return uint( Math.floor( quad ) + 1 );
    }
    
    public static function index( i:Number ):Number {
      if ( i == 0 ) {
        return 0;
      } else if ( i < 7 ) {
        return i - 1;
      }
      var _level:Number = level(i) - 1;
      var _total:Number = Number( ( _level * ( _level + 1 ) ) / 2 ) * 6;
      return i - _total - 1;
    }
    
    public static function offset( i:Number, metrics:Object ):Point {
      var _level:Number = level(i);
      var _index:Number = index(i);
      var direction:Number = Math.floor( ( _index ) / _level );
      var offset:Number = ( _index + 1 ) - ( direction * _level );
      direction %= 6;
      if ( i == 0 ) {
        direction = 0;
        offset = 0;
      }
      
      var angle3:Number = 0;
      var angle4:Number = 0;
      var size3:Number = 0;
      var size4:Number = 0;
      switch( direction ) {
        case 0:
          angle3 = 0 - metrics.angle1;
          angle4 = 180 - metrics.angle2;
          size3 = metrics.size1 * 2;
          size4 = metrics.size2 * 2;
          break;
        case 1:
          angle3 = metrics.angle2 + 180;
          angle4 = metrics.angle1;
          size3 = metrics.size2 * 2;
          size4 = metrics.size1 * 2;
          break;
        case 2:
          angle3 = 180 - metrics.angle2;
          angle4 = metrics.angle2;
          size3 = metrics.size2 * 2;
          size4 = metrics.size2 * 2;
          break;
        case 3:
          angle3 = metrics.angle1;
          angle4 = 0 - metrics.angle2;
          size3 = metrics.size1 * 2;
          size4 = metrics.size2 * 2;
          break;
        case 4:
          angle3 = metrics.angle2;
          angle4 = 0 - metrics.angle1;
          size3 = metrics.size2 * 2;
          size4 = metrics.size1 * 2;
          break;
        case 5:
          angle3 = 0 - metrics.angle2;
          angle4 = metrics.angle2 + 180;
          size3 = metrics.size2 * 2;
          size4 = metrics.size2 * 2;
          break;
      }
      
      angle3 *= Math.PI / 180;
      angle4 *= Math.PI / 180;
      return new Point( Math.cos( angle3 ) * _level * size3 + Math.cos( angle4 ) * offset * size4, Math.sin( angle3 ) * _level * size3 * -1 + Math.sin( angle4 ) * offset * size4 * -1 );
    }
    
  }
  
}