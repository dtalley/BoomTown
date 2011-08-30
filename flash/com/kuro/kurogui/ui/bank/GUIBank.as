package com.kuro.kurogui.ui.bank {
	import com.kuro.kurogui.core.GUIElement;
  import com.kuro.kurogui.ui.events.GUIDraggableEvent;
	
  /**
   * @author David Talley
   * 
   * A class that represents a grid-based bank, with individual boxes of the grid
   * representing "space" within the bank.  The GUIBank can contain any number
   * of GUIBankCoin objects, each of which has a specific number of grid units
   * that it occupies.  The occupied area of each GUIBankCoin object cannot
   * overlap with any other GUIBankCoin object.
   */
  
  public class GUIBank extends GUIElement {
    
    private var _slots:Array;
    private var _coins:Array;
    private var _active:Array;
    private var _free:Array;
    private var _taken:Array;
    
    public function GUIBank( width:uint, height:uint ) {
      _slots = new Array();
      _coins = new Array();
      _active = new Array();
      _free = new Array();
      _taken = new Array();
      init( width, height );
    }
    
    private function init( width:uint, height:uint ):void {
      for ( var i:int = 0; i < width; i++ ) {
        _slots[i] = new Array();
        for ( var j:int = 0; j < height; j++ ) {
          var slot:GUIBankSlot = createSlot();
          if ( j > 0 ) {
            slot.x = _slots[i][j - 1].x + _slots[i][j - 1].width;
          }
          if ( i > 0 ) {
            slot.y = _slots[i - 1][j].y + _slots[i - 1][j].height;
          }
          _slots[i][j] = slot;
          _free.push( slot );
        }
      }
    }
    
    protected function createSlot():GUIBankSlot {
      return new GUIBankSlot();
    }
    
    public function addCoin( coin:GUIBankCoin ):Boolean {
      _coins.push( coin );
      coin.addEventListener( GUIDraggableEvent.DRAGGED, coinDragged );
      coin.addEventListener( GUIDraggableEvent.DROPPED, coinDropped );
    }
    
    private function coinDragged( e:GUIDraggableEvent ):void {
      
    }
    
    private function coinDropped( e:GUIDraggableEvent ):void {
      
    }
    
  }

}