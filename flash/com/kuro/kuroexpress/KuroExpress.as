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
      if( listeners[event] ) {
        var total:int = listeners[event].length;
        for ( var i:int = 0; i < total; i++ ) {
          if ( listeners[event][i].object == obj && listeners[event][i].listener == listener ) {
            obj.removeEventListener( event, listeners[event][i].delegate );
            listeners[event].splice( i, 1 );
            return true;
          }
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
    
    public static function broadcast( text:String, perms:Object = null ):void {
      if ( !perms ) {
        perms = {};
      }
      trace( ( perms.label ? perms.label + ": " : "" ) + text );
      if ( ApplicationDomain.currentDomain.hasDefinition( "com.demonsters.debugger.MonsterDebugger" ) ) {
        var debuggerClass:Class = getDefinitionByName( "com.demonsters.debugger.MonsterDebugger" ) as Class;
        debuggerClass.trace( 
          perms.obj ? perms.obj : { }, 
          text, 
          perms.person ? perms.person : "David Talley", 
          perms.label ? perms.label : "KuroExpress::broadcast()", 
          perms.color ? perms.color : 0x000000, 
          perms.depth ? perms.depth : 4 
        );
      }
    }
    
	}
	
}