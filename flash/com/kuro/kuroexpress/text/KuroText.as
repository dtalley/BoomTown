package com.kuro.kuroexpress.text {
  import flash.text.AntiAliasType;
  import flash.text.TextField;
  import flash.text.TextFieldAutoSize;
  import flash.text.TextFormat;
  import flash.text.TextLineMetrics;
	
  public class KuroText {
    
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
    
  }

}