package com.kuro.kuroexpress.assets {
  import com.kuro.kuroexpress.KuroExpress;
  import flash.display.Loader;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.net.URLRequest;
  import flash.system.ApplicationDomain;
  import flash.system.LoaderContext;
  
  public class AssetsLoader {
    
    private static var fullURL:String = "";
    
    public static function setFullURL( url:String ):void {
      var otherSplit:Array = url.split( "?" );
      url = otherSplit[0];
      otherSplit = url.split( "#" );
      url = otherSplit[0];
      var urlSplit:Array = url.split( "/" );
      var totalSplits:Number = urlSplit.length;
      fullURL = "";
      for ( var i:int = 0; i < totalSplits-1; i++ ) {
        fullURL += urlSplit[i] + "/";
      }
    }
    
    /* Load a requested assets file into the current
     * application domain and return a sprite that can be
     * used to track the file's load progress.
     */
    private static var _assets:Array = [];
		public static function loadAssetsFile( file:String ):Sprite {
      if ( _assets.indexOf( file ) >= 0 ) {
        return null;
      }
      KuroExpress.broadcast( "Loading assets file: " + fullURL + file,
        { label:"KuroExpress::loadAssetsFile()" } );
			var request:URLRequest = new URLRequest( fullURL + file );
      _assets.push( file );
			var loader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
			loader.load( request, context );
			var loadDispatcher:Sprite = new Sprite();
			loadDispatcher.addChild( loader );
      KuroExpress.addFullListener( loader.contentLoaderInfo, ProgressEvent.PROGRESS, assetsProgress, loadDispatcher );
			KuroExpress.addListener( loader.contentLoaderInfo, Event.COMPLETE, assetsComplete, loader, loadDispatcher );
      KuroExpress.addListener( loader.contentLoaderInfo, IOErrorEvent.IO_ERROR, assetsError, file );
			return loadDispatcher;
		}
		
    
		private static function assetsProgress( dispatcher:Sprite, e:ProgressEvent ):void {
			dispatcher.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal ) );
		}
		
		private static function assetsComplete( loader:Loader, dispatcher:Sprite ):void {
			KuroExpress.removeListener( loader.contentLoaderInfo, ProgressEvent.PROGRESS, assetsProgress );
			KuroExpress.removeListener( loader.contentLoaderInfo, Event.COMPLETE, assetsComplete );
      KuroExpress.removeListener( loader.contentLoaderInfo, IOErrorEvent.IO_ERROR, assetsError );
			dispatcher.dispatchEvent( new Event( Event.COMPLETE ) );
		}
    
    private static function assetsError( file:String ):void {
      throw new Error( "A requested assets file (" + file + ") could not be loaded because it is either missing or corrupt." );
    }
    
  }

}