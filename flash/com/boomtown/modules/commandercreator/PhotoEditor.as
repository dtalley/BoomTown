package com.boomtown.modules.commandercreator {
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import fl.motion.MatrixTransformer;
  import flash.display.Bitmap;
  import flash.display.BitmapData;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.MouseEvent;
  import flash.geom.Matrix;
  import flash.geom.Point;
  import flash.geom.Rectangle;
  import flash.net.URLRequest;
	/**
   * ...
   * @author David Talley
   */
  class PhotoEditor extends Sprite {
    
    private var _width:Number, _height:Number;
    private var _mask:Sprite;
    private var _photo:Bitmap;
    private var _clip:Sprite;
    
    public function PhotoEditor( width:Number, height:Number ) {
      _width = width;
      _height = height;
      
      addEventListener( Event.ADDED_TO_STAGE, init );
    }
    
    private function init( e:Event ):void {
      removeEventListener( Event.ADDED_TO_STAGE, init );
      
      graphics.beginFill( 0xFFFFFF );
      graphics.drawRect( 0, 0, _width, _height );
      graphics.endFill();
    }
    
    public function load( photo:* ):void {
      if( photo is String ) {
        var loader:Loader = new Loader();
        var request:URLRequest = new URLRequest( photo );
        KuroExpress.addListener( loader.contentLoaderInfo, Event.COMPLETE, photoLoaded, loader );
        KuroExpress.addListener( loader.contentLoaderInfo, IOErrorEvent.IO_ERROR, photoError );
        loader.load( request );
      } else if( photo is Bitmap ) {
        _photo = photo;
        create();
      }
    }
    
    private function photoError():void {
      KuroExpress.broadcast( "An error occured when attempting to load a photo.", { obj:this, color:0xFF0000 } );
    }
    
    private function photoLoaded( loader:Loader ):void {
      KuroExpress.removeListener( loader.contentLoaderInfo, Event.COMPLETE, photoLoaded );
      _photo = Bitmap( loader.content );
      create();
    }
    
    private function create():void {
      _photo.smoothing = true;
      if ( !_mask ) {
        _mask = new Sprite();
        _mask.graphics.beginFill( 0, 0 );
        _mask.graphics.drawRect( 0, 0, _width, _height );
        _mask.graphics.endFill();
        addChild( _mask );
      }      
      if ( _clip ) {
        _clip.removeChildAt(0);
      } else {
        _clip = new Sprite();
        KuroExpress.addListener( _clip, MouseEvent.MOUSE_DOWN, photoDown );
      }
      _clip.addChildAt( _photo, 0 );
      addChild( _clip );
      _clip.mask = _mask;
      if ( _photo.width < _width || _photo.height < _height ) {
        KuroExpress.fitToSize( _photo, _width, _height, true );
      }
      TweenLite.from( _clip, .3, { alpha:0 } );
      _clip.x = 0;
      _clip.y = 0;
    }
    
    private var _offset:Point;
    private function photoDown():void {
      KuroExpress.addListener( stage, MouseEvent.MOUSE_UP, photoUp );
      KuroExpress.addListener( stage, MouseEvent.MOUSE_MOVE, photoMove );
      _offset = new Point( _clip.mouseX, _clip.mouseY );
    }
    
    private function photoMove():void {
      var tx:Number = mouseX - _offset.x;
      var ty:Number = mouseY - _offset.y;
      if ( tx > 0 ) {
        tx = 0;
      } else if ( tx < _width - _clip.width ) {
        tx = _width - _clip.width;
      }
      if ( ty > 0 ) {
        ty = 0;
      } else if ( ty < _height - _clip.height ) {
        ty = _height - _clip.height;
      }
      TweenLite.to( _clip, .2, { x:tx, y:ty } );
    }
    
    private function photoUp():void {
      KuroExpress.removeListener( stage, MouseEvent.MOUSE_UP, photoUp );
      KuroExpress.removeListener( stage, MouseEvent.MOUSE_MOVE, photoMove );
    }
    
    public function get photo():Bitmap {
      if ( !_photo ) {
        return null;
      }
      var clip:Bitmap = new Bitmap( new BitmapData( _width, _height, false, 0xFFFFFFFF ) );
      var matr:Matrix = new Matrix();
      matr.scale( _photo.scaleX, _photo.scaleY );
      matr.translate( _clip.x, _clip.y );
      clip.bitmapData.draw( _photo, matr, null, null );
      return clip;
    }
    
    public function destroy():void {
      if( _clip ) {
        KuroExpress.removeListener( _clip, MouseEvent.MOUSE_DOWN, photoDown );
        _clip.removeChild( _photo );
        removeChild( _clip );
        photoUp();
      }
    }
    
    override public function get width():Number {
      return _width;
    }
    
    override public function get height():Number {
      return _height;
    }
    
  }

}