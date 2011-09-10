package com.kuro.kurogui.ui.bank {
  import com.kuro.kurogui.ui.GUIDraggable;
  import flash.geom.Rectangle;
	
  public class GUIBankCoin extends GUIDraggable {
    
    private var _slots:Rectangle;
    
    public function GUIBankCoin( width:uint, height:uint ) {
      if ( width == 0 || height == 0 ) {
        throw new Error( "You can't make an invisible coin." );
      }
      _slots = new Rectangle( 0, 0, width, height );
    }
    
    override public function get width():Number {
      return _slots.width;
    }
    
    override public function get height():Number {
      return _slots.height;
    }
    
  }

}