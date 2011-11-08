package com.kuro.kuroexpress.text {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.net.URLRequest;
  import flash.system.ApplicationDomain;
  import flash.system.LoaderContext;
  import flash.text.Font;
  import flash.utils.getDefinitionByName;
  
  public class FontLoader {
    
    private static var fontList:Array;
    private static var currentFont:int;
    private static var totalFonts:int;
    private static var loadingFont:String;
    private static var loadingKey:String;
    private static var loadedFonts:Array;
    
    public static function loadFonts( list:Array ):Sprite {
      totalFonts = list.length;
      fontList = new Array();
      loadedFonts = new Array();
      currentFont = 0;
      for( var i:int = 0; i < totalFonts; i++ ) {
        fontList.push( list.pop() );
      }
      
      var loader:Sprite = new Sprite();
      beginLoadingFonts(null, loader);
      return loader;
    }
    
    private static function beginLoadingFonts( e:Event, holder:Sprite = null ):void {
      if ( e ) {
        e.target.removeEventListener( ProgressEvent.PROGRESS, fontListProgress );
        e.target.removeEventListener( Event.COMPLETE, beginLoadingFonts );
      }
      if ( currentFont < totalFonts ) {
        var loader:Sprite = loadFont( fontList[currentFont].name, fontList[currentFont].key );
        loader.addEventListener( ProgressEvent.PROGRESS, fontListProgress );
        loader.addEventListener( Event.COMPLETE, beginLoadingFonts );
        currentFont++;
        if ( holder ) {
          holder.addChild( loader );
        } else if ( e ) {
          Sprite( e.target.parent ).addChild( loader );
        }
      } else if ( e ) {
        fontList = null;
        currentFont = undefined;
        Sprite( e.target.parent ).dispatchEvent( new Event( Event.COMPLETE ) );
      }
    }
    
    private static function fontListProgress( e:ProgressEvent ):void {
      var bytesLoaded:Number = ( e.bytesLoaded * 100 ) + Math.round( ( e.bytesLoaded / e.bytesTotal ) * 100 );
      var span:Number = 100 / totalFonts;
      var currentSpan:Number = ( currentFont - 1 ) * span;
      var totalLoaded:Number = currentSpan + ( span * e.bytesLoaded / e.bytesTotal );
      //trace( span + "/" + currentSpan + "/" + totalLoaded + "/100" );
      Sprite( e.target.parent ).dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, totalLoaded, 100 ) );
    }
    
    /* Load a font file and then register that particular
     * font whenever it is finished loading.
     */
    public static function loadFont( font:String, key:String ):Sprite {
      loadingFont = font;
      loadingKey = key;
      var request:URLRequest = new URLRequest( "fonts/" + font + ".swf" );
      var loader:Loader = new Loader();
      var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
      loader.load( request, context );
      var loadDispatcher:Sprite = new Sprite();
      loadDispatcher.addChild( loader );
      loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, fontProgress );
      KuroExpress.addListener( loader.contentLoaderInfo, Event.COMPLETE, fontComplete, loader, font, key );
      loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, fontError );
			return loadDispatcher;
    }
    
    private static function fontProgress( e:ProgressEvent ):void {
			Sprite( Loader( e.target.loader ).parent ).dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal ) );
		}
		
		private static function fontComplete( loader:Loader, font:String, key:String ):void {
			loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, fontProgress );
			KuroExpress.removeListener( loader.contentLoaderInfo, Event.COMPLETE, fontComplete );
      loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, fontError );
			var fontClass:Class = getDefinitionByName( loadingFont ) as Class;
			Font.registerFont( fontClass );
      loadingFont = null;
      var fontList:Array = Font.enumerateFonts(false);
      for ( var i:int = 0; i < fontList.length; i++ ) {
        if ( loadedFonts.indexOf( fontList[i].fontName ) < 0 ) {
          FontMapper.add( key, fontList[i].fontName );
          loadedFonts.push( fontList[i].fontName );
        }
      }
      Sprite( loader.parent ).dispatchEvent( new Event( Event.COMPLETE ) );
		}
    
    private static function fontError( e:IOErrorEvent ):void {
      throw new Error( "The font '" + loadingFont + "' could not be loaded because it is either missing or corrupt." );
    }
    
  }

}