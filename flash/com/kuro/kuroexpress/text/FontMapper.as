package com.kuro.kuroexpress.text {
  
  public class FontMapper {
    
    private static var _fonts:Object = new Object();
    
    public static function addFont( id:String, font:String ):void {
      _fonts[id] = font;
      trace( "Mapped '" + id + "' to '" + font + "'" );
    }
    
    public static function getFont( id:String ):String {
      return _fonts[id];
    }
    
  }

}