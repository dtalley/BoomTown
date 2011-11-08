package com.kuro.kuroexpress {
  import flash.errors.EOFError;
  import flash.text.TextField;
	import flash.utils.ByteArray;
  import flash.utils.Endian;
  import com.buraks.utils.fastmem;
	
  public class ByteMap extends ByteArray {
    
    private var _length:uint;
    private var _field:TextField;
    
    protected static var _bound:ByteMap = null;
    private var _temp:Boolean = false;
    
    public function ByteMap( length:uint ) {
      this.endian = Endian.LITTLE_ENDIAN;
      this.length = 1024;
      super();
      _length = length;
    }
    
    public override function clear():void {
      super.clear();
      this.length = 1024;
    }
    
    public function bind():void {
      if ( ByteMap._bound && ByteMap._bound != this ) {
        throw new Error( "A ByteMap is already bound!" );
        return;
      } else if ( ByteMap._bound && ByteMap._bound == this ) {
        return;
      }
      fastmem.fastSelectMem(this);
      ByteMap._bound = this;
    }
    
    public function unbind():void {
      if ( ByteMap._bound && ByteMap._bound != this ) {
        throw new Error( "This ByteMap is not the currently bound ByteMap!" );
        return;
      } else if ( !ByteMap._bound ) {
        throw new Error( "No ByteMap is currently bound!" );
        return;
      }
      fastmem.fastDeselectMem();
      ByteMap._bound = null;
    }
    
    public function read( index:uint, start:uint, end:uint ):uint {
      if ( ByteMap._bound && ByteMap._bound != this ) {
        throw new Error( "A ByteMap is already bound!" );
        return 0;
      }
      if ( length < ( index * _length + Math.floor( start / 8 ) ) ) {
        return 0;
      }
      if ( end > _length * 8 ) {
        throw new Error( "Invalid offset." );
        return 0;
      }
      if ( end - start > 31 ) {
        throw new Error( "Cannot read more than 32 bits from a ByteMap." );
        return 0;
      }
      if ( start > end ) {
        throw new Error( "Can't read bits in reverse order." );
        return 0;
      }
      position = 0;
      if( !ByteMap._bound ) {
        fastmem.fastSelectMem( this );
        ByteMap._bound = this;
        _temp = true;
      }
      var pos:uint = index * _length + Math.floor( start / 8 );
      end -= Math.floor( start / 8 ) * 8;
      start %= 8;
      if ( length < pos + 5 ) {
        length = pos + 5;
      }
      var data:uint = fastmem.fastGetI32( pos );
      data <<= start;
      data >>>= start;
      if ( 31 < end ) {
        pos += 4;
        if ( length < pos + 5 ) {
          length = pos + 5;
        }
        var extra:uint = fastmem.fastGetI32( pos );
        extra >>>= 31 - ( end - 31 );
        data <<= end - 31 + 1;
        data |= extra;
      } else {
        data >>= 31 - end;
      }
      if( ByteMap._bound == this && _temp ) {
        fastmem.fastDeselectMem();
        ByteMap._bound = null;
        _temp = false;
      }
      return data;
    }
    
    public function write( index:uint, start:uint, end:uint, value:uint ):void {
      if ( ByteMap._bound && ByteMap._bound != this ) {
        throw new Error( "A ByteMap is already bound!" );
        return 0;
      }
      if ( end > _length * 8 ) {
        throw new Error( "Invalid offset." );
        return;
      }
      if ( end - start > 31 ) {
        throw new Error( "Cannot set more than 32 bits in a ByteMap." );
        return;
      }
      if ( start > end ) {
        throw new Error( "Can't set bits in reverse order." );
        return;
      }
      position = 0;
      if( !ByteMap._bound ) {
        fastmem.fastSelectMem(this);
        ByteMap._bound = this;
        _temp = true;
      }
      var pos:uint = index * _length + Math.floor( start / 8 );
      end -= Math.floor( start / 8 ) * 8;
      start %= 8;
      var data:uint;
      if ( length < pos + 5 ) {
        length = pos + 5;
      }
      data = fastmem.fastGetI32( pos );
      var front:uint = ( start > 0 ) ? ( ( 0xFFFFFFFF >>> 31 - start + 1 ) << ( 31 - start + 1 ) ) : 0;
      var back:uint = ( end < 31 ) ? ( 0xFFFFFFFF >>> end + 1 ) : 0;
      var sub:uint = front | back;
      data &= sub;
      if( end - start < 31 ) {
        sub = ~( 0xFFFFFFFF << end - start + 1 );
      } else {
        sub = 0xFFFFFFFF;
      }
      value &= sub;
      if ( 31 < end ) {
        var extra:uint = value << 31 - ( end - 31 );
        value >>>= ( end - 31 ) + 1;
        data |= value;
        if ( pos + 8 > length ) {
          length = pos + 8;
        }
        fastmem.fastSetI32( data, pos );
        pos += 4;
        if ( length < pos + 8 ) {
          length = pos + 8;
        }
        data = fastmem.fastGetI32( pos );
        sub = 0xFFFFFFFF >>> end - 31 + 1;
        data &= sub;
        data |= extra;
        if ( pos + 8 > length ) {
          length = pos + 8;
        }
        fastmem.fastSetI32( data, pos );
      } else {
        value <<= 31 - end;
        data |= value;
        if ( pos + 8 > length ) {
          length = pos + 8;
        }
        fastmem.fastSetI32( data, pos );
      }
      if( ByteMap._bound == this && _temp ) {
        fastmem.fastDeselectMem();
        ByteMap._bound = null;
        _temp = false;
      }
    }
    
  }

}