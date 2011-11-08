package com.kuro.kuroexpress.text {
  
  public class FontMapper {
    
    private static var _fonts:Object = new Object();
    
    public static function add( id:String, font:String ):void {
      _fonts[id] = font;
      trace( "Mapped '" + id + "' to '" + font + "'" );
    }
    
    public static function font( id:String ):String {
      return _fonts[id];
    }
    
    public static function get fonts():Object {
      return _fonts;
    }
    
  }

}