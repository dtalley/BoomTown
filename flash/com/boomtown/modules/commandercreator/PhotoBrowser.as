package com.boomtown.modules.commandercreator {
  import com.adobe.serialization.json.JSON;
  import com.boomtown.modules.commandercreator.events.PhotoBrowserEvent;
  import com.greensock.TweenLite;
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Bitmap;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.system.LoaderContext;
	/**
   * ...
   * @author David Talley
   */
  class PhotoBrowser extends Sprite {
    
    private var _photos:Array;
    private var _width:Number;
    private var _height:Number;
    
    public function PhotoBrowser( id:String, token:String, width:Number, height:Number ) {      
      _width = width;
      _height = height;
      
      var request:URLRequest = new URLRequest( "https://graph.facebook.com/" + id + "/photos?limit=20&access_token=" + token );
      var loader:URLLoader = new URLLoader();
      KuroExpress.addListener( loader, Event.COMPLETE, photosLoaded, loader );
      loader.load( request );
    }
    
    private function photosLoaded( loader:URLLoader ):void {
      KuroExpress.removeListener( loader, Event.COMPLETE, photosLoaded );
      
      var data:Object = JSON.decode( loader.data );
      _photos = data.data;
      addEventListener( Event.ADDED_TO_STAGE, init );
      dispatchEvent( new Event( Event.COMPLETE ) );
    }
    
    private var _holder:Sprite;
    private var _clips:Array = [];
    private function init( e:Event ):void {
      removeEventListener( Event.ADDED_TO_STAGE, init );
      
      _holder = new Sprite();
      addChild( _holder );
      
      var total:int = _photos.length;
      for ( var i:int = 0; i < total; i++ ) {
        var photo:Object = null;
        var images:int = _photos[i].images.length;
        _photos[i].images.sortOn( "height" );
        for ( var j:int = 0; j < images; j++ ) {
          if ( _photos[i].images[j].height > _height ) {
            photo = _photos[i].images[j];
            break;
          }
        }
        var clip:Sprite = new Sprite();
        var scale:Number = _height / photo.height;
        clip.graphics.beginFill( 0xFFFFFF );
        clip.graphics.drawRect( 0, 0, photo.width * scale, _height );
        clip.graphics.endFill();
        _holder.addChild( clip );
        var length:int = _clips.length;
        if ( length > 0 ) {
          clip.x = _clips[length - 1].x + _clips[length - 1].width + 10;
        }
        var loader:Loader = new Loader();
        var request:URLRequest = new URLRequest( photo.source );
        KuroExpress.addListener( loader.contentLoaderInfo, Event.COMPLETE, photoLoaded, loader, clip, scale );
        loader.load( request, new LoaderContext( true ) );
        _clips.push( clip );
      }
      
      if ( _holder.width > stage.stageWidth ) {
        stage.addEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
      }
    }
    
    private function mouseMove( e:MouseEvent ):void {
      var percent:Number = mouseX / stage.stageWidth;
      var diff:Number = _holder.width - stage.stageWidth;
      TweenLite.to( _holder, .3, { x:0 - diff * percent } );
    }
    
    private function photoLoaded( loader:Loader, clip:Sprite, scale:Number ):void {
      KuroExpress.removeListener( loader.contentLoaderInfo, Event.COMPLETE, photoLoaded );
      
      clip.addChild( loader.content );
      loader.content.scaleX = scale;
      loader.content.scaleY = scale;
      Bitmap( loader.content ).smoothing = true;
      TweenLite.from( loader.content, .3, { alpha:0 } );
      
      KuroExpress.addListener( clip, MouseEvent.CLICK, photoClicked, clip );
    }
    
    private function photoClicked( clip:Sprite ):void {
      dispatchEvent( new PhotoBrowserEvent( PhotoBrowserEvent.PHOTO_CLICKED, _photos[_clips.indexOf(clip)].source ) );
    }
    
    public function destroy():void {
      stage.removeEventListener( MouseEvent.MOUSE_MOVE, mouseMove );
      var total:int = _clips.length;
      for ( var i:int = 0; i < total; i++ ) {
        KuroExpress.removeListener( _clips[i], MouseEvent.CLICK, photoClicked );
        _holder.removeChildAt(0);
      }
      removeChild( _holder );
      _holder = null;
      _clips = null;
    }
    
    public override function get width():Number {
      return _width;
    }
    
    public override function get height():Number {
      return _height;
    }
    
  }

}