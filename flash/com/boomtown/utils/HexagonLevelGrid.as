package com.boomtown.utils {
  import flash.geom.Point;
  
  public class HexagonLevelGrid {
    
    public static function calculateLevel( index:Number ):Number {
      if ( index == 0 ) {
        return 0;
      } else if ( index < 7 ) {
        return 1;
      }
      var a:Number = 1;
      var b:Number = 1;
      var c:Number = 0 - Math.floor( ( index - 1 ) / 6 ) * 2;
      
      var quad:Number = ( (0 - b) + Math.sqrt( Math.pow( b, 2 ) - ( 4 * a * c ) ) ) / ( 2 * a );
      return Number( Math.floor( quad ) + 1 );
    }
    
    public static function calculateIndex( index:Number ):Number {
      if ( index == 0 ) {
        return 0;
      } else if ( index < 7 ) {
        return index - 1;
      }
      var level:Number = calculateLevel(index) - 1;
      var total:Number = Number( ( level * ( level + 1 ) ) / 2 ) * 6;
      return index - total - 1;
    }
    
    public static function calculateOffset( i:Number, angle1:Number, angle2:Number, size1:Number, size2:Number ):Point {
      var level:Number = calculateLevel(i);
      var index:Number = calculateIndex(i);
      var direction:Number = Math.floor( ( index ) / level );
      var offset:Number = ( index + 1 ) - ( direction * level );
      direction %= 6;
      if ( i == 0 ) {
        direction = 0;
        offset = 0;
      }
      
      trace( "Index: " + i + ", Level: " + level + ", Offset: " + index + ", PrimeDirection: " + direction + ", DirectionOffset: " + offset );
      
      var angle3:Number = 0;
      var angle4:Number = 0;
      var size3:Number = 0;
      var size4:Number = 0;
      switch( direction ) {
        case 0:
          angle3 = 0 - angle1;
          angle4 = 180 - angle2;
          size3 = size1;
          size4 = size2;
          break;
        case 1:
          angle3 = angle2 + 180;
          angle4 = angle1;
          size3 = size2;
          size4 = size1;
          break;
        case 2:
          angle3 = 180 - angle2;
          angle4 = angle2;
          size3 = size2;
          size4 = size2;
          break;
        case 3:
          angle3 = angle1;
          angle4 = 0 - angle2;
          size3 = size1;
          size4 = size2;
          break;
        case 4:
          angle3 = angle2;
          angle4 = 0 - angle1;
          size3 = size2;
          size4 = size1;
          break;
        case 5:
          angle3 = 0 - angle2;
          angle4 = angle2 + 180;
          size3 = size2;
          size4 = size2;
          break;
      }
      trace( "Angle1: " + angle3 + ", Angle2:" + angle4 );
      angle3 *= Math.PI / 180;
      angle4 *= Math.PI / 180;
      return new Point( Math.round( Math.cos( angle3 ) * level * size3 ) + Math.round( Math.cos( angle4 ) * offset * size4 ), Math.round( Math.sin( angle3 ) * level * size3 * -1 ) + Math.round( Math.sin( angle4 ) * offset * size4 * -1 ) );
      //return new Point( Math.cos( angle3 ) * level * size3, Math.sin( angle3 ) * level * size3 * -1 );
      //return new Point( Math.cos( angle4 ) * offset * size4, Math.sin( angle4 ) * offset * size4 * -1 );
    }
    
  }
  
}