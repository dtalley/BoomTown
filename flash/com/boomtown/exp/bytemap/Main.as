package com.boomtown.exp.bytemap {
  import com.kuro.kuroexpress.ByteMap;
  import com.kuro.kuroexpress.text.KuroText;
  import flash.display.Sprite;
  import flash.text.TextField;
	
  public class Main extends Sprite {
    
    private var field:TextField;
    
    public function Main() {      
      field = KuroText.createTextField( { font:"Arial", embedFonts:false, size:12, color:0x000000 } );
      field.embedFonts = false;
      addChild( field );
      field.background = true;
      field.backgroundColor = 0xFFFFFF;
      field.x = 5;
      field.y = 5;
      
      var map:ByteMap = new ByteMap( 5, field );
      map.write( 1, 3, 34, 0xFFFFFFFF );
      if ( map.read( 1, 3, 34 ) != 0xFFFFFFFF ) {
        addText( "Problem with test 1." );
      } else {
        addText( "Test 1 passed." );
      }
      
      map.write( 1, 5, 12, 1 );
      if ( map.read( 1, 5, 12 ) != 1 ) {
        addText( "Problem with test 2." );
      } else {
        addText( "Test 2 passed." );
      }
      if ( map.read( 1, 5, 13 ) != 3 ) {
        addText( "Problem with test 3." );
      } else {
        addText( "Test 3 passed." );
      }
      if ( map.read( 1, 5, 14 ) != 7 ) {
        addText( "Problem with test 4." );
      } else {
        addText( "Test 4 passed." );
      }
      
      map.write( 0, 5, 36, 7 );
      if ( map.read( 0, 5, 36 ) != 7 ) {
        addText( "Problem with test 5." );
      } else {
        addText( "Test 5 passed." );
      }
      
    }
    
    private function addText( text:String ):void {
      field.text = text + "\n" + field.text;
    }
    
  }

}