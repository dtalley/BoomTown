package com.kuro.kuroexpress {
	
	//flash.display
  import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.DisplayObject;
	import flash.display.SpreadMethod;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  import flash.text.TextLineMetrics;
	
	//flash.events
  import flash.events.Event;
  import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
  
  //flash.external
  import flash.external.ExternalInterface;
	
	//flash.geom
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	//flash.net
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	
	//flash.system
  import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	//flash.text
  import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	
	//flash.utils
	import flash.utils.getDefinitionByName;
	
	public class KuroExpress {
    
    private static var fontList:Array;
    
    private static var currentFont:Number;
    
    private static var loadingFont:String;
    
    private static var fullURL:String = "";
		
		public function KuroExpress():void {
			
		}
    
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
    
    /* Load an array of font files one by one
     */
    public static function loadFonts( list:Array ):Sprite {
      var totalFonts:Number = list.length;
      fontList = new Array();
      currentFont = 0;
      for( var i:int = 0; i < totalFonts; i++ ) {
        fontList.push( list.pop() );
      }
      var loader:Sprite = new Sprite();
      beginLoadingFonts(loader);
      return loader;
    }
    
    private static function beginLoadingFonts( holder:Sprite = null, loader:Sprite = null ):void {
      if ( loader ) {
        loader.removeEventListener( ProgressEvent.PROGRESS, fontListProgress );
        KuroExpress.removeListener( loader, Event.COMPLETE, beginLoadingFonts );
      }
      if ( currentFont < fontList.length ) {
        var loader:Sprite = loadFont( fontList[currentFont] );
        loader.addEventListener( ProgressEvent.PROGRESS, fontListProgress );
        KuroExpress.addListener( loader, Event.COMPLETE, beginLoadingFonts, holder, loader );
        currentFont++;
        holder.addChild( loader );
      } else if( holder ) {
        fontList = null;
        currentFont = undefined;
        holder.dispatchEvent( new Event( Event.COMPLETE ) );
      }
    }
    
    private static function fontListProgress( e:ProgressEvent ):void {
      var bytesLoaded:Number = ( e.bytesLoaded ) + Math.round( ( e.bytesLoaded / e.bytesTotal ) );
      Sprite( e.target.parent ).dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, bytesLoaded, e.bytesTotal ) );
    }
    
    /* Load a font file and then register that particular
     * font whenever it is finished loading.
     */
    public static function loadFont( font:String ):Sprite {
      loadingFont = font;
      var request:URLRequest = new URLRequest( fullURL + "fonts/" + font + ".swf" );
      var loader:Loader = new Loader();
      var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain );
      loader.load( request, context );
      var loadDispatcher:Sprite = new Sprite();
      loadDispatcher.addChild( loader );
      loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, fontProgress );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, fontComplete );
      loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, fontError );
			return loadDispatcher;
    }
    
    private static function fontProgress( e:ProgressEvent ):void {
			Sprite( Loader( e.target.loader ).parent ).dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal ) );
		}
		
		private static function fontComplete( e:Event ):void {
			e.target.removeEventListener( ProgressEvent.PROGRESS, fontProgress );
			e.target.removeEventListener( Event.COMPLETE, fontComplete );
      e.target.removeEventListener( IOErrorEvent.IO_ERROR, fontError );
			var fontClass:Class = getDefinitionByName( loadingFont ) as Class;
			Font.registerFont( fontClass );
      loadingFont = null;
      var fontList:Array = Font.enumerateFonts(false);
      trace( "Current Font List: ---------------------------------------" );
      for ( var i:int = 0; i < fontList.length; i++ ) {
        trace( "Font Loaded: " + fontList[i].fontName );
      }
      trace( "----------------------------------------------------------" );
      trace( "" );
      Sprite( Loader( e.target.loader ).parent ).dispatchEvent( new Event( Event.COMPLETE ) );
		}
    
    private static function fontError( e:IOErrorEvent ):void {
      throw new Error( "The font '" + loadingFont + "' could not be loaded because it is either missing or corrupt." );
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
      KuroExpress.broadcast( { }, "Loading assets file: " + fullURL + file );
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
		
		public static function createComment( comment:String ):void {
			trace( comment );
      if( ExternalInterface.available && ExternalInterface.objectID ) {
        ExternalInterface.call( "createComment", comment );
      }
		}
		
		public static function fitToSize( obj:DisplayObject, fitWidth:Number, fitHeight:Number, fillSpace:Boolean = false ):void {
			obj.scaleX = 1;
      obj.scaleY = 1;
      var r1:Number = obj.width / obj.height;
			var r2:Number = fitWidth / fitHeight;
			var scaleW:Number = fitWidth / obj.width;
			var scaleH:Number = fitHeight / obj.height;
			if( fillSpace ) {
				if( r1 > r2 ) {
					obj.scaleX = scaleH;
					obj.scaleY = scaleH;
				} else {
					obj.scaleX = scaleW;
					obj.scaleY = scaleW;
				}
			} else {
				if( r1 > r2 ) {
					obj.scaleX = scaleW;
					obj.scaleY = scaleW;
				} else {
					obj.scaleX = scaleH;
					obj.scaleY = scaleH;
				}
			}
		}
		
		public static function createTextField( properties:Object ):TextField {			
			var format:TextFormat = new TextFormat();
			var field:TextField = new TextField();
			for( var key:String in properties ) {
				try {
					format[key] = properties[key];
				} catch( e:Error ) {}
				try {
					field[key] = properties[key];
				} catch( e:Error ) {}
			}
      field.antiAliasType = AntiAliasType.ADVANCED;
			if( !properties.defaultTextFormat ) {
				field.defaultTextFormat = format;
			}
			if( !properties.embedFonts ) {
				field.embedFonts = true;
			}
			if( !properties.selectable ) {
				field.selectable = false;
			}
			if( !properties.autoSize ) {
				field.autoSize = TextFieldAutoSize.LEFT;
			}
      if ( !properties.sharpness ) {
        field.sharpness = 0;
      }
      if ( !properties.thickness ) {
        field.thickness = 0;
      }
			return field;
		}
    
    public static function setTextFormat( field:TextField, properties:Object ):void {
      var format:TextFormat = new TextFormat();
			for( var key:String in properties ) {
				try {
					format[key] = properties[key];
				} catch( e:Error ) {
          try {
            field[key] = properties[key];
          } catch ( e:Error ) { }
        }
			}
      field.setTextFormat( format, ( properties.start ) ? properties.start : -1, ( properties.end ) ? properties.end : -1 );
      if ( properties.setDefault ) {
        field.defaultTextFormat = format;
      }
    }
		
		public static function getAsset( id:String ):Class {
			var assetClass:Class = getDefinitionByName( id ) as Class;
			return assetClass;
		}
		
		public static function createAsset( id:String ):Object {
			var assetClass:Class = getDefinitionByName( id ) as Class;
			return new assetClass();
		}
    
    public static function createBitmap( id:String ):Bitmap {
      var assetClass:Class = getDefinitionByName( id ) as Class;
      return new Bitmap( new assetClass( 0, 0 ) );
    }
		
    public static function beginGradientFill( obj:Sprite, w:Number, h:Number, type:String, rotation:Number, colors:Array, alphas:Array, ratios:Array, tx:Number = 0, ty:Number = 0 ):void {
      var matr:Matrix = new Matrix();
      matr.createGradientBox( w, h, rotation, tx, ty );
      var spreadMethod:String = SpreadMethod.PAD;		
      obj.graphics.beginGradientFill( type, colors, alphas, ratios, matr, spreadMethod );		
    }
    
    public static function convertFloat( float:Number, precision:Number = 2 ):String {			
			var newPrice:String = "" + float;
			var priceArray = newPrice.split( "." );
			if( priceArray.length == 1 ) {
				newPrice = float + ".";
        for ( var i:int = 0; i < precision; i++ ) {
          newPrice += "0";
        }
			} else if( priceArray[1].length < precision ) {
				newPrice = float + "";
        for ( i = 0; i < precision - priceArray[1].length; i++ ) {
          newPrice += "0";
        }
			} else {
				newPrice = priceArray[0] + "." + priceArray[1].substr(0,precision);
			}
			return newPrice;			
		}		
    
    public static function getLineMetrics( field:TextField, line:Number = 0 ):Object {
      var metrics:TextLineMetrics = field.getLineMetrics( line );
      var obj:Object = new Object();
      obj.ascent = metrics.ascent;
      obj.descent = metrics.descent;
      obj.height = metrics.height;
      obj.leading = metrics.leading;
      obj.width = metrics.width;
      obj.x = metrics.x;
      return obj;
    }
    
    private static var listeners:Object = {};
    
    public static function addListener( obj:IEventDispatcher, event:String, listener:Function, ... params ):void {
      var delFunction:Function = delegate( obj, listener, params, false );
      if ( !listeners[event] ) {
        listeners[event] = [];
      }
      listeners[event].push( { object:obj, delegate:delFunction, listener:listener } );
      obj.addEventListener( event, delFunction );
    }
    
    public static function addFullListener( obj:IEventDispatcher, event:String, listener:Function, ... params ):void {
      var delFunction:Function = delegate( obj, listener, params, true );
      if ( !listeners[event] ) {
        listeners[event] = [];
      }
      listeners[event].push( { object:obj, delegate:delFunction, listener:listener } );
      obj.addEventListener( event, delFunction );
    }
    
    public static function removeListener( obj:IEventDispatcher, event:String, listener:Function ):Boolean {
      var total:int = listeners[event].length;
      for ( var i:int = 0; i < total; i++ ) {
        if ( listeners[event][i].object == obj && listeners[event][i].listener == listener ) {
          obj.removeEventListener( event, listeners[event][i].delegate );
          listeners[event].splice( i, 1 );
          return true;
        }
      }
      return false;
    }
    
    private static function delegate( obj:IEventDispatcher, listener:Function, params:Array, addEvent:Boolean ):Function {
      var f:Function;
      if( addEvent ) {
        f = function( e:Event ):void {
          listener.apply( obj, params.concat(e) ); 
        };
      } else {
        f = function( e:Event ):void {
          listener.apply( obj, params ); 
        };
      }
      return f;
    }
    
    public static function distance( x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      return Math.sqrt( Math.pow( centerX - x, 2 ) + Math.pow( centerY - y, 2 ) );
    }
    
    public static function angle( x:Number, y:Number, centerX:Number, centerY:Number ):Number {
      var tAngle:Number = ( 180 / Math.PI ) * Math.atan2( ( 0 - y ) - ( 0 - centerY ), x - centerX );
      if ( tAngle < 0 ) {
        tAngle += 360;
      }
      if ( tAngle >= 360 ) {
        tAngle -= 360;
      }
      return tAngle;
    }
    
    public static function broadcast( obj:Object, text:String, color:uint = 0x000000, functions:Boolean = false, depth:int = 4 ):void {
      trace( text );
      if ( ApplicationDomain.currentDomain.hasDefinition( "nl.demonsters.debugger.MonsterDebugger" ) ) {
        var debuggerClass:Class = getDefinitionByName( "nl.demonsters.debugger.MonsterDebugger" ) as Class;
        debuggerClass.trace( obj, text, color, functions, depth );
      }
    }
    
	}
	
}